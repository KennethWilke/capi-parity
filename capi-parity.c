#include "capi-parity.h"

#define STRIPE_SIZE 1048576
#define ALLOCATION_ALIGNMENT 128

typedef struct
{
	__u64 size;
	void *stripe1;
	void *stripe2;
	void *parity;
	char done;
} parity_request;


void* random_data(__u64 size)
{
	__u64 bytes_remaining = size;
	long int *offset;
	void *new = aligned_alloc(ALLOCATION_ALIGNMENT, size);

	if(size % sizeof(long int))
	{
		fprintf(stderr,
		        "Warning: randomized data size is not multiple of %zd bytes, "
		        "last %llu byte(s) will be left unrandomized\n",
		        sizeof(long int), size % sizeof(long int));
	}

	if(!new)
	{
		fprintf(stderr, "Error: Failed to allocate space for random data\n");
		return NULL;
	}

	offset = new;
	// Generate random data
	while(bytes_remaining > sizeof(long int))
	{
		*offset = random();
		offset++;
		bytes_remaining -= sizeof(long int);
	}

	return new;
}

parity_request* example_parity_request(void)
{
	parity_request *new = aligned_alloc(ALLOCATION_ALIGNMENT, sizeof(*new));

	new->size = STRIPE_SIZE;
	new->stripe1 = random_data(STRIPE_SIZE);
	new->stripe2 = random_data(STRIPE_SIZE);
	new->parity = aligned_alloc(ALLOCATION_ALIGNMENT, STRIPE_SIZE);
	new->done = 0;

	return new;
}


int main(int argc, char *argv[])
{
	struct cxl_afu_h *afu;
	parity_request *example = example_parity_request();

	printf("example: %p\n", example);
	printf("example->size: %llu\n", example->size);
	printf("example->stripe1: %p\n", example->stripe1);
	printf("example->stripe2: %p\n", example->stripe2);
	printf("example->parity: %p\n", example->parity);

	afu = cxl_afu_open_dev("/dev/cxl/afu0.0d");
	if(!afu)
	{
		printf("Failed to open AFU: %m\n");
		return 1;
	}

	cxl_afu_attach(afu, (__u64)example);

	while(!example->done){
		sleep(1);
	}

	printf("releasing AFU\n");
	cxl_afu_free(afu);

	return 0;
}

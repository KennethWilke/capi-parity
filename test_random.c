#include "capi-parity.h"

#define STRIPE_SIZE 1048576
//#define STRIPE_SIZE 32768

void validate_parity(parity_request *request)
{
	char *stripe1, *stripe2, *parity;
	stripe1 = request->stripe1;
	stripe2 = request->stripe2;
	parity = request->parity;
	int i;

	for(i = 0; i < request->size; i++)
	{
		if(parity[i] != (stripe1[i] ^ stripe2[i]))
		{
			printf("Failure at byte %d!\n", i);
			printf("%02hhx != %02hhx ^ %02hhx\n",
			       parity[i], stripe1[i], stripe2[i]);
			return;
		}
	}
	printf("Success!\n");
}

void* random_data(__u64 size)
{
	__u64 bytes_remaining = size;
	long long int *offset;
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
	while(bytes_remaining > sizeof(long long int))
	{
		// Shift to write full 64 bits
		*offset = (long int)random() << 32;
		*offset += (long long int)random();
		offset++;
		bytes_remaining -= sizeof(long long int);
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
	printf("&(example->done): %p\n", &(example->done));

	afu = cxl_afu_open_dev("/dev/cxl/afu0.0d");
	if(!afu)
	{
		printf("Failed to open AFU: %m\n");
		return 1;
	}

	cxl_afu_attach(afu, (__u64)example);

	printf("Waiting for completion by AFU\n");
	while(!example->done){
		sleep(1);
	}

	printf("example->done: %llx\n", example->done);
	printf("releasing AFU\n");
	cxl_afu_free(afu);

	validate_parity(example);

	return 0;
}

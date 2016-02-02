#ifndef __CAPI_PARITY_H__
#define __CAPI_PARITY_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "libcxl.h"

#define ALLOCATION_ALIGNMENT 128

typedef struct
{
	__u64 size;
	void *stripe1;
	void *stripe2;
	void *parity;
	__u64 done;
} parity_request;

#endif

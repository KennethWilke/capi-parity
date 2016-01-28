LIBCXL_PATH=~/workprojects/pslse/libcxl
LIBCXL_INCLUDE=-I $(LIBCXL_PATH) -L $(LIBCXL_PATH) -lcxl -lpthread
LIBRARIES=$(LIBCXL_INCLUDE)
CC=gcc -Wall -o $@ $< $(LIBRARIES)


all: capi-parity

capi-parity: capi-parity.c
	$(CC)

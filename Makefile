LIBCXL_PATH=~/workprojects/pslse/libcxl
LIBCXL_INCLUDE=-I $(LIBCXL_PATH) -L $(LIBCXL_PATH) -lcxl -lpthread
LIBRARIES=$(LIBCXL_INCLUDE)
CC=gcc -Wall -o $@ $< $(LIBRARIES) 

all: test_set test_random


test_set: test_set.c
	$(CC)

test_random: test_random.c
	$(CC)


clean:
	rm -f test_set test_random

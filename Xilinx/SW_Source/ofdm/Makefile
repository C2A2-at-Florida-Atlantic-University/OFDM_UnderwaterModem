CC:=gcc
CROSS_COMPILER:=arm-linux-gnueabihf-

TARGET:=ofdm

SOURCEDIR:=.
BUILDDIR:=./
INCLUDEDIR:=.

SOURCES=TransmitChain.c \
ofdm.c

INCLUDE := $(shell find $(SOURCEDIR) -name '*.h')
OBJECTS := $(SOURCES:%.c=%.o)

CFLAGS := -Wall -Wextra -O2 -lpthread -lm

%.o: %.c $(INCLUDE)
	$(CROSS_COMPILER)$(CC) $(CFLAGS) -c -o $@ $< -I $(INCLUDEDIR)

$(BUILDDIR)$(TARGET): $(OBJECTS)
	$(CROSS_COMPILER)$(CC) $(CFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm $(BUILDDIR)$(TARGET) $(OBJECTS) *.o

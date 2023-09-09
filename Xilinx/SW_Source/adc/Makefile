############################################################################
# Jared Hermans
############################################################################

CC:=gcc
CROSS_COMPILER:=arm-linux-gnueabihf-

TARGET:=adc

SOURCEDIR:=.
BUILDDIR:=./
INCLUDEDIR:=.

SOURCES=FpgaInterface.c \
HwInterface.c \
adc.c

INCLUDE := $(shell find $(SOURCEDIR) -name '*.h')
OBJECTS := $(SOURCES:%.c=%.o)

CFLAGS := -Wall -Wextra -O2 -lpthread -lm

%.o: %.c $(INCLUDE)
	$(CROSS_COMPILER)$(CC) $(CFLAGS) -c -o $@ $< -I $(INCLUDEDIR)

$(BUILDDIR)$(TARGET): $(OBJECTS)
	$(CROSS_COMPILER)$(CC) $(CFLAGS) -o $@ $^ -lm

.PHONY: clean
clean:
	rm $(BUILDDIR)$(TARGET) $(OBJECTS)

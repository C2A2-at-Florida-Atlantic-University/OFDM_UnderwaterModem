NO_DEVMEM = NO_DEVMEM
CC:=gcc
CROSS_COMPILER:=arm-linux-gnueabihf-

TARGET:=ofdm

SOURCEDIR:=.
QAMMODDIR:=../../../MATLAB/QamModCoder/codegen/lib/QamMod
BUILDDIR:=./
INCLUDEDIR:=.

SOURCES=TransmitChain.c \
FpgaInterface.c \
HwInterface.c \
../../../MATLAB/QamModCoder/codegen/lib/QamMod/QamMod_data.c \
../../../MATLAB/QamModCoder/codegen/lib/QamMod/rt_nonfinite.c \
../../../MATLAB/QamModCoder/codegen/lib/QamMod/rtGetNaN.c \
../../../MATLAB/QamModCoder/codegen/lib/QamMod/rtGetInf.c \
../../../MATLAB/QamModCoder/codegen/lib/QamMod/QamMod_initialize.c \
../../../MATLAB/QamModCoder/codegen/lib/QamMod/QamMod_terminate.c \
../../../MATLAB/QamModCoder/codegen/lib/QamMod/QamMod.c \
../../../MATLAB/QamModCoder/codegen/lib/QamMod/log2.c \
../../../MATLAB/QamModCoder/codegen/lib/QamMod/getConstellation.c \
TxModulate.c \
ofdm.c

INCLUDE := $(shell find $(SOURCEDIR) -name '*.h')
OBJECTS := $(SOURCES:%.c=%.o)

CFLAGS := -D$(NO_DEVMEM) -Wall -Wextra -O2 -lpthread

%.o: %.c $(INCLUDE)
	$(CC) $(CFLAGS) -c -o $@ $< -I $(INCLUDEDIR) -I $(QAMMODDIR) -lm

$(BUILDDIR)$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ -lm

.PHONY: clean
clean:
	rm $(BUILDDIR)$(TARGET) $(OBJECTS)

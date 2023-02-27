CC:=gcc
CROSS_COMPILER:=arm-linux-gnueabihf-

TARGET:=ofdm

SOURCEDIR:=.
QAMMODDIR:=../../../MATLAB/C_CODER2/codegen/lib/QamMod
BUILDDIR:=./
INCLUDEDIR:=.

SOURCES=TransmitChain.c \
FpgaInterface.c \
HwInterface.c \
../../../MATLAB/C_CODER2/codegen/lib/QamMod/QamMod_data.c \
../../../MATLAB/C_CODER2/codegen/lib/QamMod/rt_nonfinite.c \
../../../MATLAB/C_CODER2/codegen/lib/QamMod/rtGetNaN.c \
../../../MATLAB/C_CODER2/codegen/lib/QamMod/rtGetInf.c \
../../../MATLAB/C_CODER2/codegen/lib/QamMod/QamMod_initialize.c \
../../../MATLAB/C_CODER2/codegen/lib/QamMod/QamMod_terminate.c \
../../../MATLAB/C_CODER2/codegen/lib/QamMod/QamMod.c \
../../../MATLAB/C_CODER2/codegen/lib/QamMod/log2.c \
../../../MATLAB/C_CODER2/codegen/lib/QamMod/getConstellation.c \
TxModulate.c \
ofdm.c

INCLUDE := $(shell find $(SOURCEDIR) -name '*.h')
OBJECTS := $(SOURCES:%.c=%.o)

CFLAGS := -Wall -Wextra -O2 -lpthread -lm

%.o: %.c $(INCLUDE)
	$(CROSS_COMPILER)$(CC) $(CFLAGS) -c -o $@ $< -I $(INCLUDEDIR) -I $(QAMMODDIR)

$(BUILDDIR)$(TARGET): $(OBJECTS)
	$(CROSS_COMPILER)$(CC) $(CFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm $(BUILDDIR)$(TARGET) $(OBJECTS)

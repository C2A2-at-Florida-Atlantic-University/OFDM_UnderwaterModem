NO_DEVMEM = NO_DEVMEM
#PS_PL_POINT = FFT
PS_PL_POINT = DUC

CC:=gcc

TARGET:=ofdm

SOURCEDIR:=.
QAMMODDIR:=../../../MATLAB/QamModCoder/codegen/lib/QamMod
QAMDEMODDIR:=../../../MATLAB/QamDemodCoder/codegen/lib/QamDemod
IFFTDIR:=../../../MATLAB/Ifft/codegen/lib/Ifft/
FFTDIR:=../../../MATLAB/Fft/codegen/lib/Fft/
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
../../../MATLAB/QamDemodCoder/codegen/lib/QamDemod/d_QamDemod_emxutil.c \
../../../MATLAB/QamDemodCoder/codegen/lib/QamDemod/d_QamDemod_data.c \
../../../MATLAB/QamDemodCoder/codegen/lib/QamDemod/d_log2.c \
../../../MATLAB/QamDemodCoder/codegen/lib/QamDemod/d_getSquareConstellation.c \
../../../MATLAB/QamDemodCoder/codegen/lib/QamDemod/d_QamDemod_initialize.c \
../../../MATLAB/QamDemodCoder/codegen/lib/QamDemod/d_QamDemod_terminate.c \
../../../MATLAB/QamDemodCoder/codegen/lib/QamDemod/d_getGrayMapping.c \
../../../MATLAB/QamDemodCoder/codegen/lib/QamDemod/d_QamDemod.c \
../../../MATLAB/Ifft/codegen/lib/Ifft/c_Ifft_emxutil.c \
../../../MATLAB/Ifft/codegen/lib/Ifft/c_Ifft_initialize.c \
../../../MATLAB/Ifft/codegen/lib/Ifft/c_Ifft_terminate.c \
../../../MATLAB/Ifft/codegen/lib/Ifft/c_Ifft_emxAPI.c \
../../../MATLAB/Ifft/codegen/lib/Ifft/c_FFTImplementationCallback.c \
../../../MATLAB/Ifft/codegen/lib/Ifft/c_Ifft_data.c \
../../../MATLAB/Ifft/codegen/lib/Ifft/c_Ifft.c \
../../../MATLAB/Fft/codegen/lib/Fft/f_Fft_emxutil.c \
../../../MATLAB/Fft/codegen/lib/Fft/f_Fft_initialize.c \
../../../MATLAB/Fft/codegen/lib/Fft/f_Fft_terminate.c \
../../../MATLAB/Fft/codegen/lib/Fft/f_Fft_data.c \
../../../MATLAB/Fft/codegen/lib/Fft/f_FFTImplementationCallback.c \
../../../MATLAB/Fft/codegen/lib/Fft/f_Fft.c \
TxModulate.c \
RxDemodulate.c \
Ber.c \
ofdm.c

INCLUDE := $(shell find $(SOURCEDIR) -name '*.h')
OBJECTS := $(SOURCES:%.c=%.o)

CFLAGS := -D$(NO_DEVMEM) -D$(PS_PL_POINT) -Wall -Wextra -O2 -lpthread

%.o: %.c $(INCLUDE)
	$(CC) $(CFLAGS) -c -o $@ $< -I $(INCLUDEDIR) -I $(QAMMODDIR) -I $(QAMDEMODDIR) -I $(IFFTDIR) -I $(FFTDIR) -lm

$(BUILDDIR)$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ -lm

.PHONY: clean
clean:
	rm $(BUILDDIR)$(TARGET) $(OBJECTS)

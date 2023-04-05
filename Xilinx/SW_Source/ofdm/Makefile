############################################################################
# Jared Hermans
############################################################################

MEM_ACCESS = DEVMEM
# PS_PL_POINT = FFT
PS_PL_POINT = DUC
SPI_ACCESS = SPI

CC:=gcc
CROSS_COMPILER:=arm-linux-gnueabihf-

TARGET:=ofdm

SOURCEDIR:=.
QAMMODDIR:=../../../MATLAB/QamModCoder/codegen/lib/QamMod/
QAMDEMODDIR:=../../../MATLAB/QamDemodCoder/codegen/lib/QamDemod/
IFFTDIR:=../../../MATLAB/Ifft/codegen/lib/Ifft/
FFTDIR:=../../../MATLAB/Fft/codegen/lib/Fft/
INTERPDIR:=../../../MATLAB/Interp/codegen/lib/Interp/
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
../../../MATLAB/Interp/codegen/lib/Interp/g_Interp_emxutil.c \
../../../MATLAB/Interp/codegen/lib/Interp/g_Interp_emxAPI.c \
../../../MATLAB/Interp/codegen/lib/Interp/g_Interp_data.c \
../../../MATLAB/Interp/codegen/lib/Interp/g_Interp_initialize.c \
../../../MATLAB/Interp/codegen/lib/Interp/g_Interp_terminate.c \
../../../MATLAB/Interp/codegen/lib/Interp/g_div.c \
../../../MATLAB/Interp/codegen/lib/Interp/g_eml_mtimes_helper.c \
../../../MATLAB/Interp/codegen/lib/Interp/g_inv.c \
../../../MATLAB/Interp/codegen/lib/Interp/g_filter.c \
../../../MATLAB/Interp/codegen/lib/Interp/g_Interp.c \
Equalizer.c \
TxModulate.c \
RxDemodulate.c \
AdcChain.c \
DacChain.c \
Ber.c \
DirectDma.c \
ofdm.c

INCLUDE := $(shell find $(SOURCEDIR) -name '*.h')
OBJECTS := $(SOURCES:%.c=%.o)

CFLAGS := -D$(MEM_ACCESS) -D$(PS_PL_POINT) -D$(SPI_ACCESS) -Wall -Wextra -O2 -lpthread -lm

%.o: %.c $(INCLUDE)
	$(CROSS_COMPILER)$(CC) $(CFLAGS) -c -o $@ $< -I $(INCLUDEDIR) -I $(QAMMODDIR) -I $(QAMDEMODDIR) -I $(IFFTDIR) -I $(FFTDIR) -I $(INTERPDIR)

$(BUILDDIR)$(TARGET): $(OBJECTS)
	$(CROSS_COMPILER)$(CC) $(CFLAGS) -o $@ $^ -lm

.PHONY: clean
clean:
	rm $(BUILDDIR)$(TARGET) $(OBJECTS)

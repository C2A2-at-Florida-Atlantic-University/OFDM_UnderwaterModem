###########################################################################
## Makefile generated for component 'Decimate'. 
## 
## Makefile     : Decimate_rtw.mk
## Generated on : Thu Mar 30 23:35:07 2023
## Final product: ./Decimate.lib
## Product type : static-library
## 
###########################################################################

###########################################################################
## MACROS
###########################################################################

# Macro Descriptions:
# PRODUCT_NAME            Name of the system to build
# MAKEFILE                Name of this makefile
# MODELLIB                Static library target

PRODUCT_NAME              = Decimate
MAKEFILE                  = Decimate_rtw.mk
MATLAB_ROOT               = C:/PROGRA~1/MATLAB/R2022b
MATLAB_BIN                = C:/PROGRA~1/MATLAB/R2022b/bin
MATLAB_ARCH_BIN           = $(MATLAB_BIN)/win64
START_DIR                 = C:/Projects/FAU-Modem/OFDM/MATLAB/Decimate
TGT_FCN_LIB               = ISO_C
SOLVER_OBJ                = 
CLASSIC_INTERFACE         = 0
MODEL_HAS_DYNAMICALLY_LOADED_SFCNS = 
RELATIVE_PATH_TO_ANCHOR   = ../../..
C_STANDARD_OPTS           = 
CPP_STANDARD_OPTS         = 
MODELLIB                  = Decimate.lib

###########################################################################
## TOOLCHAIN SPECIFICATIONS
###########################################################################

# Toolchain Name:          Linaro AArch32 Linux v6.3.1
# Supported Version(s):    
# ToolchainInfo Version:   2022b
# Specification Revision:  1.0
# 
#-------------------------------------------
# Macros assumed to be defined elsewhere
#-------------------------------------------

# TARGET_LOAD_CMD_ARGS
# TARGET_PKG_INSTALLDIR
# LINARO_TOOLCHAIN_6_3_1_AARCH32

#-----------
# MACROS
#-----------

SHELL                          = %SystemRoot%/system32/cmd.exe
CCOUTPUTFLAG                   = --output_file=
LDOUTPUTFLAG                   = --output_file=

TOOLCHAIN_SRCS = 
TOOLCHAIN_INCS = 
TOOLCHAIN_LIBS = -lm -lm

#------------------------
# BUILD TOOL COMMANDS
#------------------------

# Assembler: Linaro AArch32 Linux 6.3.1 Assembler
AS_PATH = $(LINARO_TOOLCHAIN_6_3_1_AARCH32)
AS = "$(AS_PATH)/arm-linux-gnueabihf-as"

# C Compiler: Linaro AArch32 Linux 6.3.1 C Compiler
CC_PATH = $(LINARO_TOOLCHAIN_6_3_1_AARCH32)
CC = "$(CC_PATH)/arm-linux-gnueabihf-gcc"

# Linker: Linaro AArch32 Linux 6.3.1 Linker
LD_PATH = $(LINARO_TOOLCHAIN_6_3_1_AARCH32)
LD = "$(LD_PATH)/arm-linux-gnueabihf-gcc"

# C++ Compiler: Linaro AArch32 Linux 6.3.1 C++ Compiler
CPP_PATH = $(LINARO_TOOLCHAIN_6_3_1_AARCH32)
CPP = "$(CPP_PATH)/arm-linux-gnueabihf-g++"

# C++ Linker: Linaro AArch32 Linux 6.3.1 C++ Linker
CPP_LD_PATH = $(LINARO_TOOLCHAIN_6_3_1_AARCH32)
CPP_LD = "$(CPP_LD_PATH)/arm-linux-gnueabihf-g++"

# Archiver: Linaro AArch32 Linux 6.3.1 Archiver
AR_PATH = $(LINARO_TOOLCHAIN_6_3_1_AARCH32)
AR = "$(AR_PATH)/arm-linux-gnueabihf-ar"

# MEX Tool: MEX Tool
MEX_PATH = $(MATLAB_ARCH_BIN)
MEX = "$(MEX_PATH)/mex"

# Download: Download
DOWNLOAD_PATH = $(TARGET_PKG_INSTALLDIR)
DOWNLOAD = "$(DOWNLOAD_PATH)/ssh_download.bat"

# Execute: Execute
EXECUTE = $(PRODUCT)

# Builder: GMAKE Utility
MAKE_PATH = %MATLAB%\bin\win64
MAKE = "$(MAKE_PATH)/gmake"


#-------------------------
# Directives/Utilities
#-------------------------

ASDEBUG             = -g
AS_OUTPUT_FLAG      = -o
CDEBUG              = -g
C_OUTPUT_FLAG       = -o
LDDEBUG             = -g
OUTPUT_FLAG         = -o
CPPDEBUG            = -g
CPP_OUTPUT_FLAG     = -o
CPPLDDEBUG          = -g
OUTPUT_FLAG         = -o
ARDEBUG             =
STATICLIB_OUTPUT_FLAG =
MEX_DEBUG           = -g
RM                  = @del /F
ECHO                = @echo
MV                  = @move
RUN                 =

#--------------------------------------
# "Faster Runs" Build Configuration
#--------------------------------------

ARFLAGS              = -ruvs
ASFLAGS              = -c \
                       -march=armv7-a -mcpu=cortex-a9 -mfpu=neon \
                       $(ASFLAGS_ADDITIONAL) \
                       $(INCLUDES)
CFLAGS               = -c \
                       -march=armv7-a -mcpu=cortex-a9 -mfpu=neon \
                       -MMD -MP -MF"$(@:%.o=%.dep)" -MT"$@"  \
                       -O2
CPPFLAGS             = -c \
                       -march=armv7-a -mcpu=cortex-a9 -mfpu=neon \
                       -MMD -MP -MF"$(@:%.o=%.dep)" -MT"$@"  \
                       -O2
CPP_LDFLAGS          = -lm -lrt -lpthread -ldl \
                       -march=armv7-a -mcpu=cortex-a9 -mfpu=neon
CPP_SHAREDLIB_LDFLAGS  = -shared  \
                         -lm -lrt -lpthread -ldl \
                         -march=armv7-a -mcpu=cortex-a9 -mfpu=neon
DOWNLOAD_FLAGS       = $(TARGET_LOAD_CMD_ARGS) $(PRODUCT)
EXECUTE_FLAGS        =
LDFLAGS              = -lm -lrt -lpthread -ldl \
                       -march=armv7-a -mcpu=cortex-a9 -mfpu=neon
MEX_CPPFLAGS         =
MEX_CPPLDFLAGS       =
MEX_CFLAGS           =
MEX_LDFLAGS          =
MAKE_FLAGS           = -f $(MAKEFILE)
SHAREDLIB_LDFLAGS    = -shared  \
                       -lm -lrt -lpthread -ldl \
                       -march=armv7-a -mcpu=cortex-a9 -mfpu=neon



###########################################################################
## OUTPUT INFO
###########################################################################

PRODUCT = ./Decimate.lib
PRODUCT_TYPE = "static-library"
BUILD_TYPE = "Static Library"

###########################################################################
## INCLUDE PATHS
###########################################################################

INCLUDES_BUILDINFO = -I$(START_DIR)/codegen/lib/Decimate -I$(START_DIR) -IC:/PROGRA~3/MATLAB/SUPPOR~1/R2022b/toolbox/target/SUPPOR~1/zynq/src -IC:/PROGRA~3/MATLAB/SUPPOR~1/R2022b/toolbox/target/SUPPOR~1/zynq/include -IC:/PROGRA~3/MATLAB/SUPPOR~1/R2022b/toolbox/target/SUPPOR~1/zynq/blocks/include -I$(MATLAB_ROOT)/extern/include

INCLUDES = $(INCLUDES_BUILDINFO)

###########################################################################
## DEFINES
###########################################################################

DEFINES_ = -D__MW_TARGET_USE_HARDWARE_RESOURCES_H__
DEFINES_CUSTOM = 
DEFINES_SKIPFORSIL = -DARM_PROJECT -DMW_EXTMODE_RECV_TIMEOUT_USEC=10 -DSTACK_SIZE=200000
DEFINES_STANDARD = -DMODEL=Decimate

DEFINES = $(DEFINES_) $(DEFINES_CUSTOM) $(DEFINES_SKIPFORSIL) $(DEFINES_STANDARD)

###########################################################################
## SOURCE FILES
###########################################################################

SRCS = $(START_DIR)/codegen/lib/Decimate/h_Decimate_data.c $(START_DIR)/codegen/lib/Decimate/rt_nonfinite.c $(START_DIR)/codegen/lib/Decimate/rtGetNaN.c $(START_DIR)/codegen/lib/Decimate/rtGetInf.c $(START_DIR)/codegen/lib/Decimate/h_Decimate_initialize.c $(START_DIR)/codegen/lib/Decimate/h_Decimate_terminate.c $(START_DIR)/codegen/lib/Decimate/h_Decimate.c $(START_DIR)/codegen/lib/Decimate/h_fir1.c $(START_DIR)/codegen/lib/Decimate/h_firls.c $(START_DIR)/codegen/lib/Decimate/h_xnrm2.c $(START_DIR)/codegen/lib/Decimate/h_filter.c $(START_DIR)/codegen/lib/Decimate/h_grpdelay.c $(START_DIR)/codegen/lib/Decimate/h_fft.c $(START_DIR)/codegen/lib/Decimate/h_FFTImplementationCallback.c $(START_DIR)/codegen/lib/Decimate/h_islinphase.c $(START_DIR)/codegen/lib/Decimate/h_minOrMax.c $(START_DIR)/codegen/lib/Decimate/h_find.c $(START_DIR)/codegen/lib/Decimate/h_lusolve.c $(START_DIR)/codegen/lib/Decimate/h_xzgeqp3.c $(START_DIR)/codegen/lib/Decimate/h_div.c $(START_DIR)/codegen/lib/Decimate/h_poly2rc.c $(START_DIR)/codegen/lib/Decimate/h_Decimate_emxutil.c $(START_DIR)/codegen/lib/Decimate/h_Decimate_emxAPI.c $(START_DIR)/codegen/lib/Decimate/h_mldivide.c $(START_DIR)/codegen/lib/Decimate/h_qrsolve.c $(START_DIR)/codegen/lib/Decimate/h_Decimate_rtwutil.c

ALL_SRCS = $(SRCS)

###########################################################################
## OBJECTS
###########################################################################

OBJS = h_Decimate_data.c.o rt_nonfinite.c.o rtGetNaN.c.o rtGetInf.c.o h_Decimate_initialize.c.o h_Decimate_terminate.c.o h_Decimate.c.o h_fir1.c.o h_firls.c.o h_xnrm2.c.o h_filter.c.o h_grpdelay.c.o h_fft.c.o h_FFTImplementationCallback.c.o h_islinphase.c.o h_minOrMax.c.o h_find.c.o h_lusolve.c.o h_xzgeqp3.c.o h_div.c.o h_poly2rc.c.o h_Decimate_emxutil.c.o h_Decimate_emxAPI.c.o h_mldivide.c.o h_qrsolve.c.o h_Decimate_rtwutil.c.o

ALL_OBJS = $(OBJS)

###########################################################################
## PREBUILT OBJECT FILES
###########################################################################

PREBUILT_OBJS = 

###########################################################################
## LIBRARIES
###########################################################################

LIBS = 

###########################################################################
## SYSTEM LIBRARIES
###########################################################################

SYSTEM_LIBS = 

###########################################################################
## ADDITIONAL TOOLCHAIN FLAGS
###########################################################################

#---------------
# C Compiler
#---------------

CFLAGS_BASIC = $(DEFINES) $(INCLUDES)

CFLAGS += $(CFLAGS_BASIC)

#-----------------
# C++ Compiler
#-----------------

CPPFLAGS_BASIC = $(DEFINES) $(INCLUDES)

CPPFLAGS += $(CPPFLAGS_BASIC)

###########################################################################
## INLINED COMMANDS
###########################################################################


ALL_DEPS:=$(patsubst %.o,%.dep,$(ALL_OBJS))
all:




-include codertarget_assembly_flags.mk
-include ../codertarget_assembly_flags.mk
-include $(ALL_DEPS)


###########################################################################
## PHONY TARGETS
###########################################################################

.PHONY : all build clean info prebuild download execute


all : build
	@echo "### Successfully generated all binary outputs."


build : prebuild $(PRODUCT)


prebuild : 


download : $(PRODUCT)


execute : download


###########################################################################
## FINAL TARGET
###########################################################################

#---------------------------------
# Create a static library         
#---------------------------------

$(PRODUCT) : $(OBJS) $(PREBUILT_OBJS)
	@echo "### Creating static library "$(PRODUCT)" ..."
	$(AR) $(ARFLAGS)  $(PRODUCT) $(OBJS)
	@echo "### Created: $(PRODUCT)"


###########################################################################
## INTERMEDIATE TARGETS
###########################################################################

#---------------------
# SOURCE-TO-OBJECT
#---------------------

%.c.o : %.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.s.o : %.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.pp.o : %.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.c.o : $(RELATIVE_PATH_TO_ANCHOR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.s.o : $(RELATIVE_PATH_TO_ANCHOR)/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.pp.o : $(RELATIVE_PATH_TO_ANCHOR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.c.o : $(START_DIR)/codegen/lib/Decimate/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.s.o : $(START_DIR)/codegen/lib/Decimate/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.pp.o : $(START_DIR)/codegen/lib/Decimate/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.c.o : $(START_DIR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.s.o : $(START_DIR)/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.pp.o : $(START_DIR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


h_Decimate_data.c.o : $(START_DIR)/codegen/lib/Decimate/h_Decimate_data.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rt_nonfinite.c.o : $(START_DIR)/codegen/lib/Decimate/rt_nonfinite.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rtGetNaN.c.o : $(START_DIR)/codegen/lib/Decimate/rtGetNaN.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rtGetInf.c.o : $(START_DIR)/codegen/lib/Decimate/rtGetInf.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_Decimate_initialize.c.o : $(START_DIR)/codegen/lib/Decimate/h_Decimate_initialize.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_Decimate_terminate.c.o : $(START_DIR)/codegen/lib/Decimate/h_Decimate_terminate.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_Decimate.c.o : $(START_DIR)/codegen/lib/Decimate/h_Decimate.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_fir1.c.o : $(START_DIR)/codegen/lib/Decimate/h_fir1.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_firls.c.o : $(START_DIR)/codegen/lib/Decimate/h_firls.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_xnrm2.c.o : $(START_DIR)/codegen/lib/Decimate/h_xnrm2.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_filter.c.o : $(START_DIR)/codegen/lib/Decimate/h_filter.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_grpdelay.c.o : $(START_DIR)/codegen/lib/Decimate/h_grpdelay.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_fft.c.o : $(START_DIR)/codegen/lib/Decimate/h_fft.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_FFTImplementationCallback.c.o : $(START_DIR)/codegen/lib/Decimate/h_FFTImplementationCallback.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_islinphase.c.o : $(START_DIR)/codegen/lib/Decimate/h_islinphase.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_minOrMax.c.o : $(START_DIR)/codegen/lib/Decimate/h_minOrMax.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_find.c.o : $(START_DIR)/codegen/lib/Decimate/h_find.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_lusolve.c.o : $(START_DIR)/codegen/lib/Decimate/h_lusolve.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_xzgeqp3.c.o : $(START_DIR)/codegen/lib/Decimate/h_xzgeqp3.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_div.c.o : $(START_DIR)/codegen/lib/Decimate/h_div.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_poly2rc.c.o : $(START_DIR)/codegen/lib/Decimate/h_poly2rc.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_Decimate_emxutil.c.o : $(START_DIR)/codegen/lib/Decimate/h_Decimate_emxutil.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_Decimate_emxAPI.c.o : $(START_DIR)/codegen/lib/Decimate/h_Decimate_emxAPI.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_mldivide.c.o : $(START_DIR)/codegen/lib/Decimate/h_mldivide.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_qrsolve.c.o : $(START_DIR)/codegen/lib/Decimate/h_qrsolve.c
	$(CC) $(CFLAGS) -o "$@" "$<"


h_Decimate_rtwutil.c.o : $(START_DIR)/codegen/lib/Decimate/h_Decimate_rtwutil.c
	$(CC) $(CFLAGS) -o "$@" "$<"


###########################################################################
## DEPENDENCIES
###########################################################################

$(ALL_OBJS) : rtw_proj.tmw $(MAKEFILE)


###########################################################################
## MISCELLANEOUS TARGETS
###########################################################################

info : 
	@echo "### PRODUCT = $(PRODUCT)"
	@echo "### PRODUCT_TYPE = $(PRODUCT_TYPE)"
	@echo "### BUILD_TYPE = $(BUILD_TYPE)"
	@echo "### INCLUDES = $(INCLUDES)"
	@echo "### DEFINES = $(DEFINES)"
	@echo "### ALL_SRCS = $(ALL_SRCS)"
	@echo "### ALL_OBJS = $(ALL_OBJS)"
	@echo "### LIBS = $(LIBS)"
	@echo "### MODELREF_LIBS = $(MODELREF_LIBS)"
	@echo "### SYSTEM_LIBS = $(SYSTEM_LIBS)"
	@echo "### TOOLCHAIN_LIBS = $(TOOLCHAIN_LIBS)"
	@echo "### ASFLAGS = $(ASFLAGS)"
	@echo "### CFLAGS = $(CFLAGS)"
	@echo "### LDFLAGS = $(LDFLAGS)"
	@echo "### SHAREDLIB_LDFLAGS = $(SHAREDLIB_LDFLAGS)"
	@echo "### CPPFLAGS = $(CPPFLAGS)"
	@echo "### CPP_LDFLAGS = $(CPP_LDFLAGS)"
	@echo "### CPP_SHAREDLIB_LDFLAGS = $(CPP_SHAREDLIB_LDFLAGS)"
	@echo "### ARFLAGS = $(ARFLAGS)"
	@echo "### MEX_CFLAGS = $(MEX_CFLAGS)"
	@echo "### MEX_CPPFLAGS = $(MEX_CPPFLAGS)"
	@echo "### MEX_LDFLAGS = $(MEX_LDFLAGS)"
	@echo "### MEX_CPPLDFLAGS = $(MEX_CPPLDFLAGS)"
	@echo "### DOWNLOAD_FLAGS = $(DOWNLOAD_FLAGS)"
	@echo "### EXECUTE_FLAGS = $(EXECUTE_FLAGS)"
	@echo "### MAKE_FLAGS = $(MAKE_FLAGS)"


clean : 
	$(ECHO) "### Deleting all derived files..."
	$(RM) $(subst /,\,$(PRODUCT))
	$(RM) $(subst /,\,$(ALL_OBJS))
	$(RM) *.c.dep
	$(RM) *.cpp.dep
	$(RM) *.s.dep
	$(ECHO) "### Deleted all derived files."



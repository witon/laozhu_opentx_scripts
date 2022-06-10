PROJNAME = z
LIBNAME = z

OPT = YES

INCLUDES = ../include

SRC = adler32.c crc32.c inffast.c inftrees.c uncompr.c \
     gzclose.c gzlib.c gzread.c gzwrite.c compress.c \
     deflate.c infback.c inflate.c trees.c zutil.c

ifneq ($(findstring dll, $(TEC_UNAME)), )
  SRC += zlib1.rc
  DEF_FILE = zlib.def
endif

ifneq ($(findstring Win, $(TEC_SYSNAME)), )
  # To be compatible with the existing DLLs of gnuwin32
  LIBNAME = zlib1
endif

ifneq ($(findstring gcc, $(TEC_UNAME)), )
  # To be compatible with the existing static libs of gnuwin32 and cygwin
  LIBNAME = z
endif
ifneq ($(findstring mingw, $(TEC_UNAME)), )
  LIBNAME = z
endif
ifneq ($(findstring dllw, $(TEC_UNAME)), )
  DEFINES = GCC_WINDRES
endif

ifneq ($(findstring cygw, $(TEC_UNAME)), )
  # To be compatible with the existing DLLs of cygwin
  LIBNAME = z
endif

ifneq ($(findstring MacOS, $(TEC_UNAME)), )
  ifneq ($(TEC_SYSMINOR), 4)
    BUILD_DYLIB=Yes
  endif
endif

# - Find libsai
# Find the libsai library <https://github.com/Wunkolo/libsai>
# This module defines
#  Libsai_INCLUDE_DIR, where to find sai.hpp
#  Libsai_LIBRARIES, the libraries needed to use libsai
#  Libsai_DEFINITIONS, the definitions needed to use libsai

FIND_PACKAGE(PkgConfig)

IF(PKG_CONFIG_FOUND)
   PKG_CHECK_MODULES(PC_LIBSAI libsai)
   SET(Libsai_DEFINITIONS ${PC_LIBSAI_CPPFLAGS_OTHER})
ENDIF()

FIND_PATH(Libsai_INCLUDE_DIR sai.hpp
          HINTS
          ${PC_LIBSAI_INCLUDEDIR}
          ${PC_Libsai_INCLUDE_DIRS}
          PATH_SUFFIXES libsai
         )

FIND_LIBRARY(Libsai_LIBRARY_RELEASE NAMES sai
             HINTS
             ${PC_LIBSAI_LIBDIR}
             ${PC_LIBSAI_LIBRARY_DIRS}
            )

include(SelectLibraryConfigurations)
select_library_configurations(Libsai)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Libsai
                                  REQUIRED_VARS Libsai_LIBRARIES Libsai_INCLUDE_DIR
                                 )

MARK_AS_ADVANCED(Libsai_VERSION_STRING
                 Libsai_INCLUDE_DIR
                 Libsai_LIBRARIES
                 Libsai_DEFINITIONS
                 )

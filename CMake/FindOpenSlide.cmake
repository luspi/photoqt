# look for header (openslide subdirectory)
find_path(OPENSLIDE_INCLUDE_DIR NAMES openslide.h
          PATH_SUFFIXES openslide
)
mark_as_advanced(OPENSLIDE_INCLUDE_DIR)

# look for library
find_library(OPENSLIDE_LIBRARY NAMES openslide)
mark_as_advanced(OPENSLIDE_LIBRARY)

find_package(PackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(OPENSLIDE
                                  DEFAULT_MSG OPENSLIDE_LIBRARY OPENSLIDE_INCLUDE_DIR)

if(OPENSLIDE_FOUND)
    set(OPENSLIDE_LIBRARIES ${OPENSLIDE_LIBRARY})
    set(OPENSLIDE_INCLUDE_DIRS ${OPENSLIDE_INCLUDE_DIR})
endif()

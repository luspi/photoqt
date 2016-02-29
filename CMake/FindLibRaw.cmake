#-*-cmake-*-
#
# Test for LibRaw sources
#
# Once loaded this will define
#  EXIV2_FOUND        - system has Exiv2
#  EXIV2_INCLUDE_DIR  - include directory for Exiv2
#

SET(LIBRAW_FOUND "NO")

FIND_PATH(LIBRAW_INCLUDE_DIR libraw/libraw.h
	"$ENV{LIBRAW_LOCATION}"
	"$ENV{LIBRAW_LOCATION}/include"
	/usr/include
	/usr/include/libraw
	/opt/local/include
	/opt/local/include/libraw
)

IF(LIBRAW_INCLUDE_DIR)
	SET(LIBRAW_FOUND "YES")
	MESSAGE(STATUS "LibRaw found at: ${LIBRAW_INCLUDE_DIR}/libraw")
ENDIF(LIBRAW_INCLUDE_DIR)

#####


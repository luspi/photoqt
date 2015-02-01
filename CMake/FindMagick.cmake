#-*-cmake-*-
#
# Test for GraphicsMagick libraries, unlike CMake's FindGraphicsMagick.cmake which
# tests for GraphicsMagick's binary utilities
#
# Once loaded this will define
#  MAGICK++_FOUND        - system has GraphicsMagick
#  MAGICK++_INCLUDE_DIR  - include directory for GraphicsMagick
#  MAGICK++_LIBRARY_DIR  - library directory for GraphicsMagick
#  MAGICK++_LIBRARIES    - libraries you need to link to
#

SET(MAGICK++_FOUND "NO" )

FIND_PATH(MAGICK++_INCLUDE_DIR Magick++.h
	"$ENV{MAGICK_LOCATION}/Magick++"
	"$ENV{MAGICK_LOCATION}/include/Magick++"
	"$ENV{MAGICK_LOCATION}/include/"
	"$ENV{MAGICK_LOCATION}"
	/usr/include/Magick++
	/usr/include/GraphicsMagick
	/usr/include/
	/opt/local/include/GraphicsMagick/Magick++
	/opt/local/include/GraphicsMagick
)

FIND_LIBRARY(Magick++ GraphicsMagick++ PATHS
	"$ENV{MAGICK_LOCATION}/.libs"
	"$ENV{MAGICK_LOCATION}/lib"
	/opt/local/lib
	DOC "GraphicsMagick Magick++ library"
)

SET(MAGICK++_LIBRARIES ${Magick++} )

IF(MAGICK++_INCLUDE_DIR)
	IF(MAGICK++_LIBRARIES)
		SET(MAGICK++_FOUND "YES")
		MESSAGE(STATUS "GraphicsMagick found at: ${MAGICK++_INCLUDE_DIR}")
		GET_FILENAME_COMPONENT(MAGICK++_LIBRARY_DIR ${Magick++} PATH)
	ENDIF(MAGICK++_LIBRARIES)
ENDIF(MAGICK++_INCLUDE_DIR)

#####


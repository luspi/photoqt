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

FIND_PATH(TMP_INCLUDE_DIR GraphicsMagick/Magick++.h
    "${MAGICK_LOCATION}"
    "${MAGICK_LOCATION}/Magick++"
    "${MAGICK_LOCATION}/GraphicsMagick"
    "${MAGICK_LOCATION}/include/"
    "${MAGICK_LOCATION}/include/Magick++"
    "${MAGICK_LOCATION}/include/GraphicsMagick"
    /usr/include/
    /usr/include/Magick++
    /usr/include/GraphicsMagick
    /opt/local/include/
    /opt/local/include/Magick++
    /opt/local/include/GraphicsMagick
    /usr/local/include
    /usr/local/include/Magick++
    /usr/local/include/GraphicsMagick
)

FIND_LIBRARY(Magick++ GraphicsMagick++ PATHS
    "${MAGICK_LOCATION}/.libs"
    "${MAGICK_LOCATION}/lib"
    /opt/local/lib
    /usr/local/lib
    DOC "GraphicsMagick Magick++ library"
)

SET(MAGICK++_LIBRARIES ${Magick++} )

IF(TMP_INCLUDE_DIR)
    IF(MAGICK++_LIBRARIES)
        SET(MAGICK++_FOUND "YES")
        SET(MAGICK++_INCLUDE_DIR "${TMP_INCLUDE_DIR}/GraphicsMagick")
        UNSET(TMP_INCLUDE_DIR)
        MESSAGE(STATUS "GraphicsMagick found at: ${MAGICK++_INCLUDE_DIR}")
        GET_FILENAME_COMPONENT(MAGICK++_LIBRARY_DIR ${Magick++} PATH)
    ENDIF(MAGICK++_LIBRARIES)
ENDIF(TMP_INCLUDE_DIR)

#####



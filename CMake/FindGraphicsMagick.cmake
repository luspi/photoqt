# Taken from https://github.com/buaazp/zimg/blob/master/src/CMakeModules/FindGraphicsMagick.cmake
#
# LICENSE (https://github.com/buaazp/zimg/blob/master/LICENSE)
#
# Copyright (c) 2013 - 2014, 招牌疯子
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the {organization} nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# Contact GitHub API Training Shop Blog About
#
#-*-cmake-*-
#
# Test for GraphicsMagick libraries, unlike CMake's FindGraphicsMagick.cmake which
# tests for GraphicsMagick's binary utilities
#
# Once loaded this will define
#  MAGICK_FOUND        - system has GraphicsMagick
#  MAGICK_INCLUDE_DIR  - include directory for GraphicsMagick
#  MAGICK_LIBRARY_DIR  - library directory for GraphicsMagick
#  MAGICK_LIBRARIES    - libraries you need to link to
#
#  MAGICK++_FOUND        - system has GraphicsMagick
#  MAGICK++_INCLUDE_DIR  - include directory for GraphicsMagick
#  MAGICK++_LIBRARY_DIR  - library directory for GraphicsMagick
#  MAGICK++_LIBRARIES    - libraries you need to link to
#
#  MAGICKWAND_FOUND        - system has GraphicsMagick
#  MAGICKWAND_INCLUDE_DIR  - include directory for GraphicsMagick
#  MAGICKWAND_LIBRARY_DIR  - library directory for GraphicsMagick
#  MAGICKWAND_LIBRARIES    - libraries you need to link to
#

SET(MAGICK_FOUND        "NO" )
SET(MAGICK++_FOUND      "NO" )
SET(MAGICKWAND_FOUND    "NO" )

FIND_PATH( MAGICK_INCLUDE_DIR
  NAMES "magick/magick.h"
  PATHS
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\GraphicsMagick\\Current;BinPath]/include"
  "$ENV{MAGICK_LOCATION}"
  "$ENV{MAGICK_LOCATION}/include"
  "$ENV{MAGICK_LOCATION}/include/GraphicsMagick"
  "$ENV{MAGICK_HOME}/include"
  /usr/include/
  /usr/include/GraphicsMagick
  /usr/local/include
  /usr/local/include/GraphicsMagick
  /opt/local/include/GraphicsMagick
  )

FIND_PATH( MAGICK++_INCLUDE_DIR
  NAMES "Magick++/Magick++.h"
  PATHS
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\GraphicsMagick\\Current;BinPath]/include"
  "$ENV{MAGICK++_LOCATION}"
  "$ENV{MAGICK++_LOCATION}/include"
  "$ENV{MAGICK_LOCATION}"
  "$ENV{MAGICK_LOCATION}/include"
  "$ENV{MAGICK_LOCATION}/include/GraphicsMagick"
  "$ENV{MAGICK_HOME}/include"
  /usr/include/
  /usr/include/GraphicsMagick
  /usr/local/include
  /usr/local/include/GraphicsMagick
  /opt/local/include/GraphicsMagick
  )

FIND_PATH( MAGICKWAND_INCLUDE_DIR
  NAMES "wand/magick_wand.h"
  PATHS
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\GraphicsMagick\\Current;BinPath]/include"
  "$ENV{MAGICKWAND_LOCATION}"
  "$ENV{MAGICKWAND_LOCATION}/include"
  "$ENV{MAGICK_LOCATION}"
  "$ENV{MAGICK_LOCATION}/include"
  "$ENV{MAGICK_LOCATION}/include/GraphicsMagick"
  "$ENV{MAGICK_HOME}/include"
  /usr/include/
  /usr/include/GraphicsMagick
  /usr/local/include
  /usr/local/include/GraphicsMagick
  /opt/local/include/GraphicsMagick
  )

FIND_LIBRARY( Magick
  NAMES GraphicsMagick CORE_RL_magick_
  PATHS
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\GraphicsMagick\\Current;BinPath]/lib"
  "$ENV{MAGICK_LOCATION}/magick/.libs"
  "$ENV{MAGICK_LOCATION}/lib"
  "$ENV{MAGICK_HOME}/lib"
  /usr/lib64
  /usr/local/lib64
  /opt/local/lib64
  /usr/lib
  /usr/local/lib
  /opt/local/lib
  DOC   "GraphicsMagick magic library"
  )

FIND_LIBRARY( Magick++
  NAMES GraphicsMagick++ CORE_RL_Magick++_
  PATHS
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\GraphicsMagick\\Current;BinPath]/lib"
  "$ENV{MAGICK++_LOCATION}/.libs"
  "$ENV{MAGICK_LOCATION}/.libs"
  "$ENV{MAGICK++_LOCATION}/lib"
  "$ENV{MAGICK_LOCATION}/lib"
  "$ENV{MAGICK_HOME}/lib"
  /opt/local/lib64
  /usr/lib64
  /usr/local/lib64
  /opt/local/lib
  /usr/lib
  /usr/local/lib
  DOC   "GraphicsMagick Magick++ library"
  )

FIND_LIBRARY( MagickWand
  NAMES GraphicsMagickWand CORE_RL_MagickWand_
  PATHS
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\GraphicsMagick\\Current;BinPath]/lib"
  "$ENV{MAGICKWAND_LOCATION}/.libs"
  "$ENV{MAGICK_LOCATION}/.libs"
  "$ENV{MAGICKWAND_LOCATION}/lib"
  "$ENV{MAGICK_LOCATION}/lib"
  "$ENV{MAGICK_HOME}/lib"
  /opt/local/lib64
  /usr/lib64
  /usr/local/lib64
  /opt/local/lib
  /usr/lib
  /usr/local/lib
  DOC   "GraphicsMagick MagickWand library"
  )

SET(MAGICK_LIBRARIES ${Magick} )
SET(MAGICK++_LIBRARIES ${Magick++} )
SET(MAGICKWAND_LIBRARIES ${MagickWand} )

IF (MAGICK_INCLUDE_DIR)
  IF(MAGICK_LIBRARIES)
    SET(MAGICK_FOUND "YES")
    GET_FILENAME_COMPONENT(MAGICK_LIBRARY_DIR ${Magick}   PATH)
  ENDIF(MAGICK_LIBRARIES)
ENDIF(MAGICK_INCLUDE_DIR)

IF (MAGICK++_INCLUDE_DIR)
  IF(MAGICK++_LIBRARIES)
    SET(MAGICK++_FOUND "YES")
    GET_FILENAME_COMPONENT(MAGICK++_LIBRARY_DIR ${Magick++} PATH)
  ENDIF(MAGICK++_LIBRARIES)
ENDIF(MAGICK++_INCLUDE_DIR)

IF (MAGICKWAND_INCLUDE_DIR)
  IF(MAGICKWAND_LIBRARIES)
    SET(MAGICKWAND_FOUND "YES")
    GET_FILENAME_COMPONENT(MAGICKWAND_LIBRARY_DIR ${MagickWand} PATH)
  ENDIF(MAGICKWAND_LIBRARIES)
ENDIF(MAGICKWAND_INCLUDE_DIR)

IF(NOT MAGICK_FOUND)
  # make FIND_PACKAGE friendly
  IF(NOT Magick_FIND_QUIETLY)
    IF(Magick_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR
        "GraphicsMagick required, please specify it's location with MAGICK_HOME, MAGICK_LOCATION or MAGICK++_LOCATION")
    ELSE(Magick_FIND_REQUIRED)
      MESSAGE(STATUS "GraphicsMagick was not found.")
    ENDIF(Magick_FIND_REQUIRED)
  ENDIF(NOT Magick_FIND_QUIETLY)
ENDIF(NOT MAGICK_FOUND)

#####

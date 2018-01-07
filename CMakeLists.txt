##############################################
# CMakeLists for PhotoQt: http://photoqt.org #
##############################################

cmake_minimum_required(VERSION 2.8.12)
project(photoqt)


##################################################################
####  GLOBAL VERSION STRING FOR ALL FILES (INCLUDING CPP/QML) ####
##################################################################

add_definitions(-DVERSION="dev")


#################################
#### SET SOME COMPILER FLAGS ####
#################################

add_definitions(-DQT_DEPRECATED_WARNINGS)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -O0 -g -Wall")


################################
#### MANIPULATE DEBUG BUILD ####
################################

add_definitions(-DPHOTOQTDEBUG)
set(CMAKE_BUILD_TYPE "Debug")


##########################
####  ENABLE AUTOMOC  ####
##########################

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)


#############################
####  GET list of files  ####
#############################

include(CMake/ListFilesCPlusPlus.cmake)
include(CMake/ListFilesQML.cmake)
include(CMake/ListFilesResources.cmake)


#############################################
#### OPTIONS THAT CAN BE SET BY THE USER ####
#############################################

option(RAW "Use libraw library" ON)
option(EXIV2 "Use exiv2 library" ON)
option(GM "Use graphicsmagick library" ON)
option(QTONLY "ONLY USE QT-ONLY FEATURES" OFF)


################################
#### FIND REQUIRED PACKAGES ####
################################

find_package(Qt5 COMPONENTS Core Quick Svg Sql Xml LinguistTools REQUIRED)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
find_package(Magick)
find_package(Exiv2)
find_package(LibRaw)


####################################
#### TRANSLATIONS AND RESOURCES ####
####################################

# We first copy the most recent *.ts files to the build directory and then process them
# This way, we don't have to mess with files outside of the build folder
FILE(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/buildlang)
FILE(GLOB files "lang/*.ts")
FOREACH(file ${files})
    GET_FILENAME_COMPONENT(filename ${file} NAME)
    FILE(COPY ${CMAKE_CURRENT_SOURCE_DIR}/lang/${filename} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/buildlang)
    QT5_CREATE_TRANSLATION(qm_files ${photoqt_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/buildlang/${filename} OPTIONS "-no-obsolete")
ENDFOREACH()

# Copy the language QRC file to the output directory, because the files listed in the
# qrc file are relative to that directory.
ADD_CUSTOM_COMMAND(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/lang.qrc ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc
    MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/lang.qrc
    DEPENDS ${qm_files})


##################################################################
#### GENERATE RANDOM CRYPT KEY FOR SIMPLE ENCRYPTION          ####
#### THIS IS ONLY SET THE FIRST CMAKE RUN AND KEPT AFTERWARDS ####
##################################################################

if(NOT DEFINED CRYPTKEY)
    string(RANDOM LENGTH 5 ALPHABET "0123456789" tmp_CRYPTKEY)
    set(CRYPTKEY ${tmp_CRYPTKEY} CACHE STRING "Seed for SimpleCrypt" FORCE)
endif()
add_definitions(-DSIMPLECRYPTKEY="${CRYPTKEY}")


#############################
#### Add the executeable ####
#############################

# on windows we add application icons
if(WIN32)
    add_executable(${PROJECT_NAME} WIN32 ${photoqt_SOURCES} ${photoqt_QML} ${photoqt_RESOURCES} windowsicons.rc)
    qt5_use_modules(photoqt Quick Sql Svg Core Xml WinExtras)
elseif(NOT WIN32)
    add_executable(${PROJECT_NAME} ${photoqt_SOURCES} ${photoqt_QML} ${photoqt_RESOURCES})
    qt5_use_modules(photoqt Quick Sql Svg Core Xml)
endif(WIN32)

# We need to link to zlib for zip support
target_link_libraries(photoqt "z")


#######################################
#### EMPLY THE PROPER DESKTOP FILE ####
#######################################

if(GM)
    add_custom_command(TARGET photoqt POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/for_photoqt_desktop_FULL ${CMAKE_CURRENT_SOURCE_DIR}/photoqt.desktop)
elseif(NOT GM)
    add_custom_command(TARGET photoqt POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/for_photoqt_desktop_QT ${CMAKE_CURRENT_SOURCE_DIR}/photoqt.desktop)
endif(GM)


########################
#### CUSTOM OPTIONS ####
########################

if(RAW)
    if(NOT ${LIBRAW_FOUND})
        message(FATAL_ERROR "** Unable to locate LibRaw... is it installed?")
    elseif(${LIBRAW_FOUND})
        include_directories(${LIBRAW_INCLUDE_DIR})
        target_link_libraries(photoqt "raw")
        message("** LibRaw enabled")
        add_definitions(-DRAW)
    endif(NOT ${LIBRAW_FOUND})
elseif(NOT RAW)
    message("** LibRaw DISABLED")
endif(RAW)

if(EXIV2)
    if(NOT ${EXIV2_FOUND})
        message(FATAL_ERROR "** Unable to locate Exiv2... is it installed?")
    elseif(${EXIV2_FOUND})
        include_directories(${EXIV2_INCLUDE_DIR})
        target_link_libraries(photoqt "exiv2")
        if(WIN32)
            target_link_libraries(photoqt "expat")
            target_link_libraries(photoqt "ws2_32")
            target_link_libraries(photoqt "wsock32")
            target_link_libraries(photoqt "z")
            target_link_libraries(photoqt "intl")
            target_link_libraries(photoqt "iconv")
            target_link_libraries(photoqt "psapi")
        endif(WIN32)
        add_definitions(-DEXIV2)
        message("** Exiv2 enabled")
    endif(NOT ${EXIV2_FOUND})
elseif(NOT EXIV2)
        message("** Exiv2 DISABLED")
endif(EXIV2)

if(GM)
    if(NOT ${MAGICK++_FOUND})
        message(FATAL_ERROR "** Unable to locate GraphicsMagick... is it installed?")
    elseif(${MAGICK++_FOUND})
        include_directories(${MAGICK++_INCLUDE_DIR})
        target_link_libraries(photoqt "GraphicsMagick++")
        add_definitions(-DGM)
        message("** Graphicsmagick enabled")
    endif(NOT ${MAGICK++_FOUND})
elseif(NOT GM)
    message("** Graphicsmagick DISABLED")
endif(GM)


#######################
#### INSTALL FILES ####
#######################

if(UNIX)

    # Install executeable
    install(
        TARGETS photoqt
        DESTINATION bin/
    )

        # Install desktop file
    install(
        FILES photoqt.desktop
        DESTINATION share/applications
    )

        # And install all the icons
    install(
        FILES icons/16x16/apps/photoqt.png
        DESTINATION share/icons/hicolor/16x16/apps/
    )
    install(
        FILES icons/32x32/apps/photoqt.png
        DESTINATION share/icons/hicolor/32x32/apps/
    )
    install(
        FILES icons/48x48/apps/photoqt.png
        DESTINATION share/icons/hicolor/48x48/apps/
    )
    install(
        FILES icons/64x64/apps/photoqt.png
        DESTINATION share/icons/hicolor/64x64/apps/
    )
    install(
        FILES icons/128x128/apps/photoqt.png
        DESTINATION share/icons/hicolor/128x128/apps/
    )
    install(
        FILES photoqt.appdata.xml
        DESTINATION share/appdata/
    )
endif(UNIX)



##########################
#### UNINSTALL TARGET ####
##########################

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/CMake/cmake_uninstall.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY)
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

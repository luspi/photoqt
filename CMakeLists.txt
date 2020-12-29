##############################################
# CMakeLists for PhotoQt: http://photoqt.org #
##############################################

cmake_minimum_required(VERSION 3.9)
project(photoqt LANGUAGES CXX)


##################################################################
####  GLOBAL VERSION STRING FOR ALL FILES (INCLUDING CPP/QML) ####
##################################################################

add_definitions(-DVERSION="2.0")


########################################
####  SOME SETTINGS/FLAGS FOR CMAKE ####
########################################

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


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
option(GRAPHICSMAGICK "Use GraphicsMagick library" OFF)
option(IMAGEMAGICK "Use ImageMagick library" ON)
option(DEVIL "Use DevIL library" ON)
option(FREEIMAGE "Use FreeImage library" ON)
option(POPPLER "Use Poppler library" ON)
option(LIBARCHIVE "Enable features that require libarchive" ON)
option(PUGIXML "Enable features that require pugixml" ON)
option(VIDEO "Enable video support" ON)

# name of this option changed
# this helps to make sure nothing breaks
if(GM)
    message("")
    message("** DEPRECATED OPTION to enable GraphicsMagick used: GM")
    message("** Support of this name will be removed in a future version")
    message("** Please use new option name: GRAPHICSMAGICK")
    message("** (make sure to remove GM variable from cmake cache)")
    message("")
    set(GRAPHICSMAGICK ON)
endif()

################################
#### FIND REQUIRED PACKAGES ####
################################

if(WIN32)
    find_package(Qt5 COMPONENTS Core Quick Xml Svg Multimedia DBus LinguistTools Sql WinExtras REQUIRED)
else()
    find_package(Qt5 COMPONENTS Core Quick Xml Svg Multimedia DBus LinguistTools Sql REQUIRED)
endif()

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
if(IMAGEMAGICK)
    find_package(ImageMagick COMPONENTS Magick++)
    if(GRAPHICSMAGICK)
        set(GRAPHICSMAGICK OFF)
        message("** ImageMagick and GraphicsMagick cannot be used at the same time")
    endif()
endif()
if(GRAPHICSMAGICK)
    find_package(GraphicsMagick)
endif()
if(EXIV2)
    find_package(exiv2 REQUIRED CONFIG NAMES exiv2)
    if(WIN32)
        find_package(Threads)
        find_package(Iconv)
    endif()
endif()
if(RAW)
    find_package(LibRaw)
endif()
if(FREEIMAGE)
    find_package(FreeImage)
endif()
if(LIBARCHIVE)
    find_package(LibArchive)
endif()

if(NOT WIN32)
    find_package(ECM REQUIRED NO_MODULE)
    set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} "${CMAKE_MODULE_PATH}")
    if(POPPLER)
        find_package(Poppler COMPONENTS Qt5)
    endif()
    if(DEVIL)
        find_package(DevIL)
    endif()
endif()


######################
#### TRANSLATIONS ####
######################

# We first copy the most recent *.ts files to the build directory and then process them
# This way, we don't have to mess with files outside of the build folder

file(GLOB files "lang/*.ts")
foreach(file ${files})
   get_filename_component(filename ${file} NAME)
   file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/lang/${filename} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
   qt5_add_translation(qm_files ${CMAKE_CURRENT_BINARY_DIR}/${filename})
endforeach()
add_custom_target(translations ALL DEPENDS ${qm_files})

# Create the lang resource file
include("CMake/ComposeLangResourceFile.cmake")
composeLangResourceFile()

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
    add_executable(${PROJECT_NAME} WIN32 ${photoqt_SOURCES} ${photoqt_QML} ${photoqt_RESOURCES} ${qm_files} windowsicons.rc)
    target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick Qt5::Xml Qt5::Svg Qt5::Multimedia Qt5::DBus Qt5::Sql Qt5::WinExtras)
elseif(NOT WIN32)
    add_executable(${PROJECT_NAME} ${photoqt_SOURCES} ${photoqt_QML} ${photoqt_RESOURCES} ${qm_files})
    target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick Qt5::Xml Qt5::Svg Qt5::Multimedia Qt5::DBus Qt5::Sql)
endif()

######################################################
#### CMAKE BUILD TYPE (DETERMINES COMPILER FLAGS) ####
######################################################

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
    add_definitions(-DPHOTOQTDEBUG)
    target_compile_definitions(${PROJECT_NAME} PRIVATE QT_QML_DEBUG)
    target_compile_options(${PROJECT_NAME} PRIVATE -Wall -pedantic -Wextra -O0 -g)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -O3)
endif()


##############################################
#### COMPOSE THE APPROPRIATE DESKTOP FILE ####
##############################################

include("CMake/ComposeDesktopFile.cmake")
composeDesktopFile()


########################
#### CUSTOM OPTIONS ####
########################

if(PUGIXML)
    add_definitions(-DPUGIXML)
    target_link_libraries(${PROJECT_NAME} "pugixml")
endif()

if(VIDEO)
    add_definitions(-DVIDEO)
endif()

if(LIBARCHIVE)
    if(NOT ${LibArchive_FOUND})
        message(FATAL_ERROR "** Unable to locate LibArchive... is it installed?")
    else()
        include_directories(${LibArchive_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} ${LibArchive_LIBRARIES})
        message("** Using LibArchive " ${LibArchive_VERSION})
        add_definitions(-DLIBARCHIVE)
    endif()
else()
    message("** LibArchive disabled")
endif()

if(POPPLER)
    if(NOT ${Poppler_FOUND})
        message(FATAL_ERROR "** Unable to locate Poppler... is it installed?")
    else()
        include_directories(${Poppler_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} ${Poppler_LIBRARIES})
        message("** Using Poppler ${Poppler_VERSION}")
        add_definitions(-DPOPPLER)
    endif()
else()
    message("** Poppler DISABLED")
endif()

if(DEVIL)
    if(NOT ${IL_FOUND})
        message(FATAL_ERROR "** Unable to locate DevIL... is it installed?")
    else()
        include_directories(${IL_INCLUDE_DIR})
        target_link_libraries(${PROJECT_NAME} ${IL_LIBRARIES})
        message("** Using DevIL")
        add_definitions(-DDEVIL)
    endif()
else()
    message("** DevIL DISABLED")
endif()

if(FREEIMAGE)
    if(NOT ${FREEIMAGE_FOUND})
        message(FATAL_ERROR "** Unable to locate FreeImage... is it installed?")
    else()
        include_directories(${FREEIMAGE_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} ${FREEIMAGE_LIBRARIES})
        message("** Using FreeImage")
        add_definitions(-DFREEIMAGE)
    endif()
else()
    message("** FreeImage DISABLED")
endif()

if(RAW)
    if(NOT ${LIBRAW_FOUND})
        message(FATAL_ERROR "** Unable to locate LibRaw... is it installed?")
    else()
        include_directories(${LIBRAW_INCLUDE_DIR})
        target_link_libraries(${PROJECT_NAME} "raw")
         message("** Using LibRaw")
        add_definitions(-DRAW)
    endif()
else()
    message("** LibRaw DISABLED")
endif()

if(EXIV2)
    if(NOT ${exiv2_FOUND})
        message(FATAL_ERROR "** Unable to locate Exiv2... is it installed?")
    else()
        include_directories(${EXIV2_INCLUDE_DIR})
        target_link_libraries(${PROJECT_NAME} "exiv2lib")
        add_definitions(-DEXIV2)
        message("** Using Exiv2 ${exiv2_VERSION}")
    endif()
else()
    message("** Exiv2 DISABLED")
endif()

if(GRAPHICSMAGICK)
    if(NOT ${MAGICK++_FOUND})
        message(FATAL_ERROR "** Unable to locate GraphicsMagick... is it installed?")
    else()
        include_directories(${MAGICK++_INCLUDE_DIR})
        target_link_libraries(${PROJECT_NAME} "GraphicsMagick++")
        add_definitions(-DGRAPHICSMAGICK)
        message("** Using Graphicsmagick")
    endif()
else()
    message("** Graphicsmagick DISABLED")
endif()

if(IMAGEMAGICK)
    if(NOT ${ImageMagick_FOUND})
        message(FATAL_ERROR "** Unable to locate ImageMagick... is it installed?")
    else()
        include_directories(${ImageMagick_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} ${ImageMagick_LIBRARIES})
        add_definitions(-DIMAGEMAGICK)
        add_definitions(-DMAGICKCORE_QUANTUM_DEPTH=16)
        add_definitions(-DMAGICKCORE_HDRI_ENABLE=1)
        message("** Using ImageMagick")
    endif()
else()
    message("** ImageMagick DISABLED")
endif()


#######################
#### INSTALL FILES ####
#######################

if(UNIX)

    # Install executeable
    install(
        TARGETS ${PROJECT_NAME}
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

endif()



##########################
#### UNINSTALL TARGET ####
##########################

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/CMake/cmake_uninstall.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY)
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)


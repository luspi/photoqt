##############################################
# CMakeLists for PhotoQt: http://photoqt.org #
##############################################

cmake_minimum_required(VERSION 3.16)
project(photoqt LANGUAGES CXX)


##################################################################
####  GLOBAL VERSION STRING FOR ALL FILES (INCLUDING CPP/QML) ####
##################################################################

add_definitions(-DVERSION="dev")


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
include(CMake/ListFilesResources.cmake)


#############################################
#### OPTIONS THAT CAN BE SET BY THE USER ####
#############################################

option(RAW "Use libraw library" ON)
option(EXIV2 "Use exiv2 library" ON)
option(OLDEXIV2 "Use exiv2 library (v0.25 or older)" OFF)
option(GRAPHICSMAGICK "Use GraphicsMagick library" OFF)
option(IMAGEMAGICK "Use ImageMagick library" ON)
option(DEVIL "Use DevIL library" ON)
option(FREEIMAGE "Use FreeImage library" ON)
option(POPPLER "Use Poppler library" ON)
option(QTPDF "Use QtPDF module instead of Poppler" OFF)
option(LIBARCHIVE "Enable features that require libarchive" ON)
option(PUGIXML "Enable features that require pugixml" ON)
option(VIDEO_QT "Enable video support through Qt" ON)
option(VIDEO_MPV "Enable video support through MPV" ON)
option(CHROMECAST "Enable Chromecast support" ON)
option(CHROMECAST_PIPINSTALL "Allows CMake to attempt to install PyChromecast locally using pip." OFF)
option(LIBVIPS "Use libvips" OFF)
option(LOCATION "Enable use of QtPositioning/QtLocation QML modules" ON)

option(EXIV2_ENABLE_BMFF "Enable BMFF format support in Exiv2 (if available)" ON)

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
if(VIDEO)
    message("")
    message("** The VIDEO cmake flag was changed to VIDEO_QT")
    message("** This was done to distinguish it from VIDEO_MPV")
    message("")
    set(VIDEO_QT ON)
endif()
if(QTPDF)
    if(POPPLER)
        set(POPPLER OFF)
        message("** For displaying PDF documents you have to choose either Poppler OR QtPDF")
    endif()
endif()


################################
#### FIND REQUIRED PACKAGES ####
################################

find_package(Qt5 COMPONENTS Core Quick Xml Svg Multimedia DBus LinguistTools Sql PrintSupport Concurrent REQUIRED)

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
if(OLDEXIV2)
    set(EXIV2 Off)
    # this uses a custom shipped FindLibExiv2.cmake file
    # as versions 0.25 and older do not provide one yet
    find_package(LibExiv2 REQUIRED)
endif()
if(EXIV2)
    find_package(exiv2 REQUIRED)
endif()
if(RAW)
    find_package(LibRaw)
endif()
if(NOT WIN32)
    if(FREEIMAGE)
        find_package(FreeImage)
    endif()
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
endif()
if(DEVIL)
    find_package(DevIL)
endif()
if(CHROMECAST)
    find_package(Python3 COMPONENTS Interpreter Development)
endif()
if(LIBVIPS)
    find_package(PkgConfig REQUIRED)
    pkg_search_module(GLIB REQUIRED glib-2.0 gobject-2.0)
endif()
if(VIDEO_MPV)
    find_package(Libmpv)
    set(photoqt_SOURCES ${photoqt_SOURCES} ${photoqt_libmpv_SOURCES})
endif()
if(QTPDF)
    find_package(Qt5 COMPONENTS Pdf REQUIRED)
endif()

# Since Python might be imported we have to avoid using Qt keywords (like 'slots') to avoid naming conflicts
ADD_DEFINITIONS(-DQT_NO_KEYWORDS)


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

#############################
#### Add the executeable ####
#############################

# on windows we add application icons
if(WIN32)
    add_executable(${PROJECT_NAME} WIN32 ${photoqt_SOURCES} ${photoqt_RESOURCES} ${qm_files} windowsicons.rc)
elseif(NOT WIN32)
    add_executable(${PROJECT_NAME} ${photoqt_SOURCES} ${photoqt_RESOURCES} ${qm_files})
endif()
target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick Qt5::Xml Qt5::Svg Qt5::Multimedia Qt5::DBus Qt5::Sql Qt5::PrintSupport Qt5::Concurrent)
if(QTPDF)
    target_link_libraries(${PROJECT_NAME} Qt5::Pdf)
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

if(VIDEO_QT)
    add_definitions(-DVIDEOQT)
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
    if(WIN32)
        message("** Using Poppler")
        target_link_libraries(${PROJECT_NAME} "poppler")
        target_link_libraries(${PROJECT_NAME} "poppler-qt5")
        add_definitions(-DPOPPLER)
    else()
        if(NOT ${Poppler_FOUND})
            message(FATAL_ERROR "** Unable to locate Poppler... is it installed?")
        else()
            include_directories(${Poppler_INCLUDE_DIRS})
            target_link_libraries(${PROJECT_NAME} ${Poppler_LIBRARIES})
            message("** Using Poppler ${Poppler_VERSION}")
            add_definitions(-DPOPPLER)
        endif()
    endif()
else()
    message("** Poppler DISABLED")
endif()

if(QTPDF)
    message("** Using QtPDF module")
    add_definitions(-DQTPDF)
endif()

if(DEVIL)
    if(WIN32)
        target_link_libraries(${PROJECT_NAME} "DevIL")
        message("** Using DevIL")
        add_definitions(-DDEVIL)
    else()
        if(NOT ${DevIL_FOUND})
            message(FATAL_ERROR "** Unable to locate DevIL... is it installed?")
        else()
            include_directories(${IL_INCLUDE_DIR})
            target_link_libraries(${PROJECT_NAME} ${IL_LIBRARIES})
            message("** Using DevIL")
            add_definitions(-DDEVIL)
        endif()
    endif()
else()
    message("** DevIL DISABLED")
endif()

if(FREEIMAGE)
    if(WIN32)
        target_link_libraries(${PROJECT_NAME} "FreeImage")
        message("** Using FreeImage")
        add_definitions(-DFREEIMAGE)
    else()
        if(NOT ${FREEIMAGE_FOUND})
            message(FATAL_ERROR "** Unable to locate FreeImage... is it installed?")
        else()
            include_directories(${FREEIMAGE_INCLUDE_DIRS})
            target_link_libraries(${PROJECT_NAME} ${FREEIMAGE_LIBRARIES})
            message("** Using FreeImage")
            add_definitions(-DFREEIMAGE)
        endif()
    endif()
else()
    message("** FreeImage DISABLED")
endif()

if(RAW)
    if(NOT ${LIBRAW_FOUND})
        message(FATAL_ERROR "** Unable to locate LibRaw... is it installed?")
    else()
        include_directories(${LIBRAW_INCLUDE_DIR})
        if(WIN32)
            target_link_libraries(${PROJECT_NAME} "libraw")
        else()
            target_link_libraries(${PROJECT_NAME} "raw")
        endif()
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
        if(EXIV2_ENABLE_BMFF)
            add_definitions(-DEXIV2_ENABLE_BMFF)
        endif()
    endif()
elseif(OLDEXIV2)
    if(NOT ${LibExiv2_FOUND})
        message(FATAL_ERROR "** Unable to locate Exiv2... is it installed?")
    else()
        include_directories(${LibExiv2_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} ${LibExiv2_LIBRARIES})
        add_definitions(-DEXIV2)
        message("** Using Exiv2 ${LibExiv2_VERSION}")
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

if(CHROMECAST)
    if(NOT ${Python3_FOUND})
        message(FATAL_ERROR "** Unable to locate Python3... is it installed?")
    elseif(NOT ${Python3_Interpreter_FOUND})
        message(FATAL_ERROR "** Unable to locate Python3 Interpreter... is it installed?")
    else()
        execute_process(COMMAND ${Python3_EXECUTABLE} -c "import pychromecast" RESULT_VARIABLE EXIT_CODE OUTPUT_QUIET TIMEOUT 60)
        if(NOT ${EXIT_CODE} EQUAL 0)
            if(CHROMECAST_PIPINSTALL)
                # try installing it with pip
                message(">> Attempt to install pychromecast locally using pip...")
                execute_process(COMMAND ${Python3_EXECUTABLE} -m pip install pychromecast)
                execute_process(COMMAND ${Python3_EXECUTABLE} -c "import pychromecast" RESULT_VARIABLE EXIT_CODE OUTPUT_QUIET TIMEOUT 60)
                if(NOT ${EXIT_CODE} EQUAL 0)
                    message(FATAL_ERROR "** Unable to locate Python3 module pychromecast. Please first install it or disable Chromecast support.")
                else()
                    message(">> Success!")
                endif()
            else()
                message(FATAL_ERROR "** Unable to import PyChromecast, make sure it is installed. "
                                    "Enabling the CHROMECAST_PIPINSTALL option allows CMake to try to install it locally using pip.")
            endif()
        endif()
        include_directories(${Python3_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} ${Python3_LIBRARIES})
        message("** Chromecast support enabled")
        message("** Using Python ${Python3_VERSION}")
        add_definitions(-DCHROMECAST)
    endif()
else()
    message("** Chromecast support DISABLED")
endif()

if(LIBVIPS)
    include_directories(${GLIB_INCLUDE_DIRS})
    target_link_libraries(${PROJECT_NAME} ${GLIB_LIBRARIES})
    target_link_libraries(${PROJECT_NAME} "vips")
    target_link_libraries(${PROJECT_NAME} "gobject-2.0")
    target_link_libraries(${PROJECT_NAME} "vips-cpp")
    add_definitions(-DLIBVIPS)
    message("** Using libvips")
else()
    message("** libvips DISABLED")
endif()

if(VIDEO_MPV)
    if(NOT ${Libmpv_FOUND})
        message(FATAL_ERROR "** Unable to locate libmpv... is it installed?")
    else()
        include_directories(${Libmpv_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} ${Libmpv_LIBRARIES})
        message("** Using libmpv " ${Libmpv_VERSION})
        add_definitions(-DVIDEOMPV)
    endif()
else()
    message("** libmpv DISABLED")
endif()

if(LOCATION)
    message("** Use of QtLocation/QtPosition enabled")
    add_definitions(-DLOCATION)
else()
    message("** Use of QtLocation/QtPosition DISABLED")
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
        FILES org.photoqt.PhotoQt.desktop
        DESTINATION share/applications
    )

    # And install all the icons
    install(
        FILES icons/16x16/apps/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/16x16/apps/
    )
    install(
        FILES icons/32x32/apps/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/32x32/apps/
    )
    install(
        FILES icons/48x48/apps/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/48x48/apps/
    )
    install(
        FILES icons/64x64/apps/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/64x64/apps/
    )
    install(
        FILES icons/128x128/apps/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/128x128/apps/
    )
    install(
        FILES org.photoqt.PhotoQt.metainfo.xml
        DESTINATION share/metainfo/
    )
    # These are the old icon names up to v2.6
    # we remove the old files if they are still there
    file(REMOVE share/icons/hicolor/16x16/apps/photoqt.png)
    file(REMOVE share/icons/hicolor/32x32/apps/photoqt.png)
    file(REMOVE share/icons/hicolor/48x48/apps/photoqt.png)
    file(REMOVE share/icons/hicolor/64x64/apps/photoqt.png)
    file(REMOVE share/icons/hicolor/128x128/apps/photoqt.png)

endif()



##########################
#### UNINSTALL TARGET ####
##########################

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/CMake/cmake_uninstall.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY)
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)


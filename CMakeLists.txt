##############################################
# CMakeLists for PhotoQt: http://photoqt.org #
##############################################

cmake_minimum_required(VERSION 3.16)
project(photoqt VERSION 4.0 LANGUAGES CXX)

##################################################################
####  GLOBAL VERSION STRING FOR ALL FILES (INCLUDING CPP/QML) ####
##################################################################

add_definitions(-DVERSION="dev")#"${PROJECT_VERSION}")

########################################
####  SOME SETTINGS/FLAGS FOR CMAKE ####
########################################

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

#############################
####  GET list of files  ####
#############################

include(CMake/ListFilesCPlusPlus.cmake)
include(CMake/ListFilesQML.cmake)

#############################################
#### OPTIONS THAT CAN BE SET BY THE USER ####
#############################################

option(RAW "Use libraw library" ON)
option(GRAPHICSMAGICK "Use GraphicsMagick library" OFF)
option(IMAGEMAGICK "Use ImageMagick library" ON)
option(DEVIL "Use DevIL library" ON)
option(FREEIMAGE "Use FreeImage library" ON)
option(POPPLER "Use Poppler library" ON)
option(QTPDF "Use QtPDF module instead of Poppler" OFF)
option(LIBARCHIVE "Enable features that require libarchive" ON)
option(VIDEO_QT "Enable video support through Qt" ON)
option(VIDEO_MPV "Enable video support through MPV" ON)
option(LIBVIPS "Use libvips" OFF)
option(RESVG "Replace Qt's SVG engine with resvg for better SVG support" OFF)

option(EXIV2 "Use exiv2 library" ON)
option(EXIV2_ENABLE_BMFF "Enable BMFF format support in Exiv2 (if available)" ON)
option(PUGIXML "Enable features that require pugixml" ON)
option(CHROMECAST "Enable Chromecast support" ON)
option(CHROMECAST_PIPINSTALL "Allows CMake to attempt to install PyChromecast locally using pip." OFF)
option(LOCATION "Enable use of QtPositioning/QtLocation QML modules" ON)

option(TESTING "Build some unit tests" OFF)

if(QTPDF)
    if(POPPLER)
        set(POPPLER OFF)
        message("** For displaying PDF documents you have to choose either Poppler OR QtPDF")
    endif()
endif()

################################
#### FIND REQUIRED PACKAGES ####
################################

find_package(Qt6 6.2 REQUIRED COMPONENTS Quick Widgets Sql Core Svg Concurrent Multimedia)
if(TESTING)
    find_package(Qt6 6.2 REQUIRED COMPONENTS Test)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake")

find_package(ECM REQUIRED NO_MODULE)
list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

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
    if(POPPLER)
        find_package(Poppler COMPONENTS Qt6)
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
    find_package(Qt6 COMPONENTS Pdf REQUIRED)
endif()

###############################
#### ADDITIONAL QT OPTIONS ####
###############################

# Since Python might be imported we have to avoid using Qt keywords (like 'slots') to avoid naming conflicts
ADD_DEFINITIONS(-DQT_NO_KEYWORDS)

# we always want to capture debug/log context information
add_definitions(-DQT_MESSAGELOGCONTEXT)

######################
#### TRANSLATIONS ####
######################

# We first copy the most recent *.ts files to the build directory and then process them
# This way, we don't have to mess with files outside of the build folder

#file(GLOB files "lang/*.ts")
#foreach(file ${files})
#   get_filename_component(filename ${file} NAME)
#   file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/lang/${filename} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
#   qt5_add_translation(qm_files ${CMAKE_CURRENT_BINARY_DIR}/${filename})
#endforeach()
#add_custom_target(translations ALL DEPENDS ${qm_files})

# Create the lang resource file
#include("CMake/ComposeLangResourceFile.cmake")
#composeLangResourceFile()

#############################
#### Add the executeable ####
#############################

qt_add_executable(photoqt ${photoqt_SOURCES} ${ALLHEADERS} misc/misc.qrc img/img.qrc img/filetypes.qrc)

# add qml files
qt_add_qml_module(photoqt URI src VERSION 1.0 QML_FILES ${photoqt_QML})

# set header files as include files
target_include_directories(photoqt PRIVATE "cplusplus/header")

# set some properties for executable
set_target_properties(photoqt PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER photoqt.PhotoQt.org
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# link executable
target_link_libraries(photoqt PRIVATE Qt6::Quick Qt6::Widgets Qt6::Sql Qt6::Core Qt6::Svg Qt6::Concurrent Qt6::Multimedia)

if(QTPDF)
    target_link_libraries(photoqt PRIVATE Qt6::Pdf)
endif()

if(TESTING)
    qt_add_executable(photoqt_test ${photoqt_testscripts_SOURCES} misc/misc.qrc testing/resources/testing.qrc)
    target_link_libraries(photoqt_test PRIVATE Qt6::Quick Qt6::Widgets Qt6::Sql Qt6::Core Qt6::Svg Qt6::Concurrent Qt6::Test)
    target_include_directories(photoqt_test PRIVATE "testing/header")
    target_include_directories(photoqt_test PRIVATE "cplusplus/header")
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
    target_link_libraries(photoqt PRIVATE "pugixml")
    if(TESTING)
        target_link_libraries(photoqt_test PRIVATE "pugixml")
    endif()
endif()

if(VIDEO_QT)
    add_definitions(-DVIDEOQT)
endif()

if(LIBARCHIVE)
    if(NOT ${LibArchive_FOUND})
        message(FATAL_ERROR "** Unable to locate LibArchive... is it installed?")
    else()
        message("** Using LibArchive " ${LibArchive_VERSION})
        add_definitions(-DLIBARCHIVE)
        include_directories(${LibArchive_INCLUDE_DIRS})
        target_link_libraries(photoqt PRIVATE ${LibArchive_LIBRARIES})
        if(TESTING)
            target_link_libraries(photoqt_test PRIVATE ${LibArchive_LIBRARIES})
        endif()
    endif()
else()
    message("** LibArchive disabled")
endif()

if(POPPLER)
    if(WIN32)
        message("** Using Poppler")
        add_definitions(-DPOPPLER)
        target_link_libraries(photoqt PRIVATE "poppler")
        target_link_libraries(photoqt PRIVATE "poppler-qt6")
        if(TESTING)
            target_link_libraries(photoqt_test PRIVATE "poppler")
            target_link_libraries(photoqt_test PRIVATE "poppler-qt6")
        endif()
    else()
        if(NOT ${Poppler_FOUND})
            message(FATAL_ERROR "** Unable to locate Poppler... is it installed?")
        else()
            message("** Using Poppler ${Poppler_VERSION}")
            include_directories(${Poppler_INCLUDE_DIRS})
            add_definitions(-DPOPPLER)
            target_link_libraries(photoqt PRIVATE ${Poppler_LIBRARIES})
            if(TESTING)
                target_link_libraries(photoqt_test PRIVATE ${Poppler_LIBRARIES})
            endif()
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
        target_link_libraries(photoqt PRIVATE "DevIL")
        message("** Using DevIL")
        add_definitions(-DDEVIL)
    else()
        if(NOT ${DevIL_FOUND})
            message(FATAL_ERROR "** Unable to locate DevIL... is it installed?")
        else()
            message("** Using DevIL")
            include_directories(${IL_INCLUDE_DIR})
            add_definitions(-DDEVIL)
            target_link_libraries(photoqt PRIVATE ${IL_LIBRARIES})
            if(TESTING)
                target_link_libraries(photoqt_test PRIVATE ${IL_LIBRARIES})
            endif()
        endif()
    endif()
else()
    message("** DevIL DISABLED")
endif()

if(FREEIMAGE)
    if(WIN32)
        target_link_libraries(photoqt PRIVATE "FreeImage")
        message("** Using FreeImage")
        add_definitions(-DFREEIMAGE)
    else()
        if(NOT ${FREEIMAGE_FOUND})
            message(FATAL_ERROR "** Unable to locate FreeImage... is it installed?")
        else()
            message("** Using FreeImage")
            include_directories(${FREEIMAGE_INCLUDE_DIRS})
            add_definitions(-DFREEIMAGE)
            target_link_libraries(photoqt PRIVATE ${FREEIMAGE_LIBRARIES})
            if(TESTING)
                target_link_libraries(photoqt_test PRIVATE ${FREEIMAGE_LIBRARIES})
            endif()
        endif()
    endif()
else()
    message("** FreeImage DISABLED")
endif()

if(RAW)
    if(NOT ${LIBRAW_FOUND})
        message(FATAL_ERROR "** Unable to locate LibRaw... is it installed?")
    else()
        message("** Using LibRaw")
        add_definitions(-DRAW)
        include_directories(${LIBRAW_INCLUDE_DIR})
        if(WIN32)
            target_link_libraries(photoqt PRIVATE "libraw")
            if(TESTING)
                target_link_libraries(photoqt_test PRIVATE "libraw")
            endif()
        else()
            target_link_libraries(photoqt PRIVATE "raw")
            if(TESTING)
                target_link_libraries(photoqt_test PRIVATE "raw")
            endif()
        endif()
    endif()
else()
    message("** LibRaw DISABLED")
endif()

if(EXIV2)
    if(NOT ${exiv2_FOUND})
        message(FATAL_ERROR "** Unable to locate Exiv2... is it installed?")
    else()
        message("** Using Exiv2 ${exiv2_VERSION}")
        include_directories(${EXIV2_INCLUDE_DIR})
        add_definitions(-DEXIV2)
        target_link_libraries(photoqt PRIVATE "exiv2lib")
        if(EXIV2_ENABLE_BMFF)
            add_definitions(-DEXIV2_ENABLE_BMFF)
        endif()
        if(TESTING)
            target_link_libraries(photoqt_test PRIVATE "exiv2lib")
        endif()
    endif()
else()
    message("** Exiv2 DISABLED")
endif()

if(GRAPHICSMAGICK)
    if(NOT ${MAGICK++_FOUND})
        message(FATAL_ERROR "** Unable to locate GraphicsMagick... is it installed?")
    else()
        message("** Using Graphicsmagick")
        include_directories(${MAGICK++_INCLUDE_DIR})
        add_definitions(-DGRAPHICSMAGICK)
        target_link_libraries(photoqt PRIVATE "GraphicsMagick++")
        if(TESTING)
            target_link_libraries(photoqt_test PRIVATE "GraphicsMagick++")
        endif()
    endif()
else()
    message("** Graphicsmagick DISABLED")
endif()

if(IMAGEMAGICK)
    if(NOT ${ImageMagick_FOUND})
        message(FATAL_ERROR "** Unable to locate ImageMagick... is it installed?")
    else()
        message("** Using ImageMagick")
        include_directories(${ImageMagick_INCLUDE_DIRS})
        add_definitions(-DIMAGEMAGICK)
        add_definitions(-DMAGICKCORE_QUANTUM_DEPTH=16)
        add_definitions(-DMAGICKCORE_HDRI_ENABLE=1)
        target_link_libraries(photoqt PRIVATE ${ImageMagick_LIBRARIES})
        if(TESTING)
            target_link_libraries(photoqt_test PRIVATE ${ImageMagick_LIBRARIES})
        endif()
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
        execute_process(COMMAND ${Python3_EXECUTABLE} -c "import pychromecast" RESULT_VARIABLE EXIT_CODE OUTPUT_QUIET TIMEOUT 2)
        if(NOT ${EXIT_CODE} EQUAL 0)
            if(CHROMECAST_PIPINSTALL)
                # try installing it with pip
                message(">> Attempt to install pychromecast locally using pip...")
                execute_process(COMMAND ${Python3_EXECUTABLE} -m pip install pychromecast)
                execute_process(COMMAND ${Python3_EXECUTABLE} -c "import pychromecast" RESULT_VARIABLE EXIT_CODE OUTPUT_QUIET TIMEOUT 2)
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
        message("** Chromecast support enabled")
        message("** Using Python ${Python3_VERSION}")
        add_definitions(-DCHROMECAST)
        include_directories(${Python3_INCLUDE_DIRS})
        target_link_libraries(photoqt PRIVATE ${Python3_LIBRARIES})
        if(TESTING)
            target_link_libraries(photoqt_test PRIVATE ${Python3_LIBRARIES})
        endif()
    endif()
else()
    message("** Chromecast support DISABLED")
endif()

if(LIBVIPS)
    message("** Using libvips")
    include_directories(${GLIB_INCLUDE_DIRS})
    add_definitions(-DLIBVIPS)
    target_link_libraries(photoqt PRIVATE ${GLIB_LIBRARIES})
    target_link_libraries(photoqt PRIVATE "vips")
    target_link_libraries(photoqt PRIVATE "gobject-2.0")
    target_link_libraries(photoqt PRIVATE "vips-cpp")
    if(TESTING)
        target_link_libraries(photoqt_test PRIVATE ${GLIB_LIBRARIES})
        target_link_libraries(photoqt_test PRIVATE "vips")
        target_link_libraries(photoqt_test PRIVATE "gobject-2.0")
        target_link_libraries(photoqt_test PRIVATE "vips-cpp")
    endif()
else()
    message("** libvips DISABLED")
endif()

if(VIDEO_MPV)
    if(NOT ${Libmpv_FOUND})
        message(FATAL_ERROR "** Unable to locate libmpv... is it installed?")
    else()
        message("** Using libmpv " ${Libmpv_VERSION})
        include_directories(${Libmpv_INCLUDE_DIRS})
        add_definitions(-DVIDEOMPV)
        target_link_libraries(photoqt PRIVATE ${Libmpv_LIBRARIES})
        if(TESTING)
            target_link_libraries(photoqt_test PRIVATE ${Libmpv_LIBRARIES})
        endif()
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

if(RESVG)
    target_link_libraries(${PROJECT_NAME} PRIVATE "resvg")
    message("** Using resvg")
    add_definitions(-DRESVG)
else()
    message("** resvg DISABLED")
endif()


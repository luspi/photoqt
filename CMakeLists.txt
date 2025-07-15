##############################################
# CMakeLists for PhotoQt: http://photoqt.org #
##############################################

cmake_minimum_required(VERSION 3.26)
project(photoqt LANGUAGES C CXX)

##################################################################
####  GLOBAL VERSION STRING FOR ALL FILES (INCLUDING CPP/QML) ####
##################################################################

SET(APPVERSION "dev")

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

option(WITH_IMAGEMAGICK           "Configure with support for the ImageMagick library" ON)
option(WITH_GRAPHICSMAGICK        "Configure with support for the GraphicsMagick library" OFF)
option(WITH_LIBRAW                "Configure with support for the libraw library" ON)
option(WITH_DEVIL                 "Configure with support for the DevIL library" ON)
option(WITH_FREEIMAGE             "Configure with support for the FreeImage library" ON)
option(WITH_POPPLER               "Configure with support for the Poppler library" ON)
option(WITH_QTPDF                 "Configure with support for the QtPDF module (instead of Poppler)" OFF)
option(WITH_LIBARCHIVE            "Configure with support for the libarchive library" ON)
option(WITH_VIDEO_QT              "Configure with video support through Qt" ON)
option(WITH_VIDEO_MPV             "Configure with video support through MPV" ON)
option(WITH_LIBVIPS               "Configure with support for the libvips library" OFF)
option(WITH_RESVG                 "Configure with support for the resvg library (better SVG support)" OFF)

option(WITH_EXIV2                 "Configure with support for the Exiv2 library" ON)
option(WITH_EXIV2_ENABLE_BMFF     "Configure with BMFF format support in Exiv2 (if available) - only needed for Exiv2 0.27.x and before" ON)
option(WITH_PUGIXML               "Configure with support for the pugixml library" ON)
option(WITH_ZXING                 "Configure with support for the ZXing library (QR and barcodes detection)" ON)
option(WITH_CHROMECAST            "Configure with support for Chromecast (through Python)" ON)
option(WITH_CHROMECAST_PIPINSTALL "Allows CMake to attempt to install PyChromecast locally using pip" OFF)
option(WITH_LOCATION              "Configure with support for the QtPositioning/QtLocation QML modules" ON)
option(WITH_LCMS2                 "Configure with support for the Little CMS library (advanced color management)" ON)
option(WITH_MOTIONPHOTO           "Configure with support for Google Motion Photos and Apple Live Photos" ON)
option(WITH_PHOTOSPHERE           "Configure with support for photo spheres and 360 degree panoramic views" ON)
option(WITH_EXTENSIONS_SUPPORT    "Enable support for extensions (requires yaml-cpp library)" ON)

option(WITH_TESTING               "Enable and build some unit tests" OFF)
option(WITH_RUNCPPCHECK           "Analyse source code with cppcheck" OFF)
option(WITH_FLATPAKBUILD          "Enable this option if this is a build for Flatpak" OFF)
option(WITH_ADAPTSOURCE           "Adapt and change the source files for the current Qt version (if necessary)" OFF)
option(WITHOUT_ICU                "Enable this option if your Qt6 setup has no ICU support" OFF)
option(WITH_PORTABLETWEAKS        "Apply tweaks for a build of a portable version" OFF)
option(WITH_WAYLANDSPECIFIC      "Enable optional Wayland-specific code to allow for further optimizations." OFF)


#####################################
#### RESOLVE CONFLICTING OPTIONS ####
#####################################

if(WITH_QTPDF)
    if(WITH_POPPLER)
        set(WITH_POPPLER OFF)
        message("** For displaying PDF documents you have to choose either Poppler OR QtPDF.")
        message("** Poppler has been automatically disabled in favour of QtPDF.")
    endif()
endif()

if(WITH_IMAGEMAGICK)
    if(WITH_GRAPHICSMAGICK)
        set(WITH_GRAPHICSMAGICK OFF)
        message("** ImageMagick and GraphicsMagick cannot be used at the same time.")
        message("** GraphicsMagick has been automatically disabled in favour of ImageMagick.")
    endif()
endif()

################################
#### FIND REQUIRED PACKAGES ####
################################

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick Widgets Sql Core Svg Concurrent Multimedia PrintSupport DBus LinguistTools)
if(WITH_TESTING)
    find_package(Qt6 6.4 REQUIRED COMPONENTS Test)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake")

find_package(ECM REQUIRED NO_MODULE)
list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

#########

if(WITH_IMAGEMAGICK)
    find_package(ImageMagick COMPONENTS Magick++ REQUIRED)
endif()

if(WITH_GRAPHICSMAGICK)
    find_package(GraphicsMagick REQUIRED)
endif()

if(WITH_LIBRAW)
    find_package(LibRaw REQUIRED)
endif()

if(WITH_DEVIL)
    find_package(DevIL REQUIRED)
endif()

if(WITH_FREEIMAGE)
    find_package(FreeImage REQUIRED)
endif()

if(WITH_POPPLER)
    find_package(Poppler COMPONENTS Qt6 REQUIRED)
endif()

if(WITH_QTPDF)
    find_package(Qt6 COMPONENTS Pdf REQUIRED)
endif()

if(WITH_LIBARCHIVE)
    find_package(LibArchive REQUIRED)
endif()

if(WITH_VIDEO_MPV)
    find_package(Libmpv REQUIRED)
    set(photoqt_SOURCES ${photoqt_SOURCES} ${photoqt_libmpv_SOURCES})
endif()

if(WITH_LIBVIPS)
    pkg_search_module(GLIB REQUIRED glib-2.0 gobject-2.0)
    pkg_search_module(VIPS REQUIRED vips-cpp)
endif()

if(WITH_EXIV2)
    find_package(exiv2 REQUIRED)
endif()

if(WITH_PUGIXML)
    find_package(pugixml REQUIRED)
endif()

if(WITH_ZXING)
    find_package(ZXing REQUIRED)
endif()

if(WITH_CHROMECAST)
    find_package(Python3 COMPONENTS Interpreter)
endif()

if(WITH_LCMS2)
    find_package(LCMS2 REQUIRED)
endif()

if(WITH_FLATPAKBUILD)
    find_package(PkgConfig REQUIRED)
    pkg_search_module(GLIB REQUIRED glib-2.0 gobject-2.0 gio-2.0)
endif()

if(WITH_WAYLANDSPECIFIC)
    find_package(Wayland REQUIRED Client)
endif()

if(WITH_EXTENSIONS_SUPPORT)
    find_package(yaml-cpp)
    if(NOT TARGET yaml-cpp)
        message(" * yaml-cpp library not found, downloading local copy")
        include(FetchContent)
        FetchContent_Declare(
            yaml-cpp
            GIT_REPOSITORY https://github.com/jbeder/yaml-cpp.git
            GIT_TAG 0.8.0
        )
        FetchContent_MakeAvailable(yaml-cpp)
    endif()
endif()

######################
#### RUN CPPCHECK ####
######################

if(WITH_RUNCPPCHECK)

    # Find CppCheck executable
    find_program(CMAKE_CXX_CPPCHECK NAMES cppcheck)

    # If CppCheck executable found
    if(CMAKE_CXX_CPPCHECK)

        message("** Analyzing source code with cppcheck")

        # Append desired arguments to CppCheck
        list(APPEND CMAKE_CXX_CPPCHECK
                "--enable=warning"
                "--inconclusive"
                "--library=qt"
        )

    endif()

else()

    unset(CMAKE_CXX_CPPCHECK CACHE)

endif()

#####################################
#### Handle Qt<6.4/5 specific stuff ####
#####################################

# MultiEffect is only available since Qt 6.5
if(Qt6_VERSION VERSION_LESS 6.5)

    # we need to modify the code slightly to make it work with Qt 6.4
    foreach(QMLFILE ${photoqt_QML})

        file(READ ${QMLFILE} FILE_CONTENTS)

        set(anything_changed FALSE)

        # pragma ComponentBehavior causes issues with Qt 6.4 (and isn't supported before)
        if(FILE_CONTENTS MATCHES "pragma ComponentBehavior: Bound")
            string(REPLACE "pragma ComponentBehavior: Bound" "/*Qt64:pragma/ComponentBehavior:/Bound*/" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()

        # switch on Qt 6.4 specific code
        if(FILE_CONTENTS MATCHES "/\\*1off_Qt64")
            set(anything_changed TRUE)
            string(REPLACE "/*1off_Qt64" "/*1on_Qt64*/" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()
        if(FILE_CONTENTS MATCHES "2off_Qt64\\*/")
            set(anything_changed TRUE)
            string(REPLACE "2off_Qt64*/" "/*2on_Qt64*/" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()

        # switch off Qt 6.5+ specific code
        if(FILE_CONTENTS MATCHES "/\\*1on_Qt65\\+\\*/")
            set(anything_changed TRUE)
            string(REPLACE "/*1on_Qt65+*/" "/*1off_Qt65+" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()
        if(FILE_CONTENTS MATCHES "/\\*2on_Qt65\\+\\*/")
            set(anything_changed TRUE)
            string(REPLACE "/*2on_Qt65+*/" "2off_Qt65+*/" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()

        # Qt 6.4 striggles with properties of type list somewhat randomly
        # Replacing them all by var keeps the code working and avoids any issues
        if(FILE_CONTENTS MATCHES "list\\<")
            set(anything_changed TRUE)
            string(REPLACE "property list<int>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<string>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<double>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<real>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<var>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<bool>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<point>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<PQMenu>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<PQButton>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<PQButtonElement>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<PQComboBox>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            string(REPLACE "property list<PQSliderSpinBox>" "property var" FILE_CONTENTS "${FILE_CONTENTS}")
            # a list<string> is used in a few places as type in function definitions
            string(REPLACE ": list<string>" ": var" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()

        if(anything_changed)
            if(WITH_ADAPTSOURCE)
                file(WRITE ${QMLFILE} "${FILE_CONTENTS}")
            else()
                message(FATAL_ERROR "Error: Source files are not adapted for Qt 6.4. You need to enable the ADAPT_SOURCE option to automatically convert them!")
            endif()
        endif()

    endforeach()

else()

    # we potentially need to undo some of the changes done above for Qt 6.4 specific code
    foreach(QMLFILE ${photoqt_QML})

        file(READ ${QMLFILE} FILE_CONTENTS)

        set(anything_changed FALSE)

        # re-enable pragma's if they were disabled previously
        if(FILE_CONTENTS MATCHES "/\\*Qt64:pragma/ComponentBehavior:/Bound\\*/")
            set(anything_changed TRUE)
            string(REPLACE "/*Qt64:pragma/ComponentBehavior:/Bound*/" "pragma ComponentBehavior: Bound" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()

        # switch off Qt 6.4 specific code
        if(FILE_CONTENTS MATCHES "/\\*1on_Qt64\\*/")
            set(anything_changed TRUE)
            string(REPLACE "/*1on_Qt64*/" "/*1off_Qt64" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()
        if(FILE_CONTENTS MATCHES "/\\*2on_Qt64\\*/")
            set(anything_changed TRUE)
            string(REPLACE "/*2on_Qt64*/" "2off_Qt64*/" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()

        # switch on Qt 6.5+ specific code
        if(FILE_CONTENTS MATCHES "/\\*1off_Qt65\\+")
            set(anything_changed TRUE)
            string(REPLACE "/*1off_Qt65+" "/*1on_Qt65+*/" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()
        if(FILE_CONTENTS MATCHES "2off_Qt65\\+\\*/")
            set(anything_changed TRUE)
            string(REPLACE "2off_Qt65+*/" "/*2on_Qt65+*/" FILE_CONTENTS "${FILE_CONTENTS}")
        endif()

        if(anything_changed)
            if(WITH_ADAPTSOURCE)
                file(WRITE ${QMLFILE} "${FILE_CONTENTS}")
            else()
                message(FATAL_ERROR "Error: Source files were prepared for Qt 6.4 and are not adapted for Qt 6.5+. You need to enable the ADAPT_SOURCE option to automatically convert them!")
            endif()
        endif()

    endforeach()

endif()


#############################
#### Add the executable ####
#############################

if(WIN32)
    qt_add_executable(photoqt ${photoqt_SOURCES} ${ALLHEADERS} misc/misc.qrc img/img.qrc img/filetypes.qrc python/python.qrc windowsicons.rc)
else()
    qt_add_executable(photoqt ${photoqt_SOURCES} ${ALLHEADERS} misc/misc.qrc img/img.qrc img/filetypes.qrc python/python.qrc)
endif()

# set the version number
target_compile_definitions(photoqt PRIVATE PQMVERSION="${APPVERSION}")

# ensure that the QTP0001 policy is set to NEW otherwise the QML files will not be found on import (on Qt 6.8+)
if(QT_KNOWN_POLICY_QTP0001)
    qt_policy(SET QTP0001 "NEW")
endif()
# disable warning with this policy not being set (on Qt 6.8+)
if(QT_KNOWN_POLICY_QTP0004)
    qt_policy(SET QTP0004 "OLD")
endif()

# add qml files
qt_add_qml_module(photoqt URI PhotoQt VERSION 1.0 QML_FILES ${photoqt_QML}
    RESOURCES img/light/mirrorhor.svg img/light/mirrorver.svg
    RESOURCES img/dark/mirrorver.svg img/dark/mirrorhor.svg)

# set header files as include files
target_include_directories(photoqt PRIVATE "cplusplus/header")
target_include_directories(photoqt PRIVATE "cplusplus/header/scripts")
target_include_directories(photoqt PRIVATE "cplusplus/extensions")

# set some properties for executable
set_target_properties(photoqt PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER photoqt.PhotoQt.org
    MACOSX_BUNDLE_BUNDLE_VERSION "${APPVERSION}"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${APPVERSION}"
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# link executable
target_link_libraries(photoqt PRIVATE Qt6::Quick Qt6::Widgets Qt6::Sql Qt6::Core Qt6::Svg Qt6::Concurrent Qt6::Multimedia Qt6::PrintSupport Qt6::DBus)

if(WITH_QTPDF)
    target_link_libraries(photoqt PRIVATE Qt6::Pdf)
endif()

if(WITH_TESTING)
    qt_add_executable(photoqt_test ${photoqt_testscripts_SOURCES} misc/misc.qrc testing/resources/testing.qrc)
    target_link_libraries(photoqt_test PRIVATE Qt6::Quick Qt6::Widgets Qt6::Sql Qt6::Core Qt6::Svg Qt6::Concurrent Qt6::Multimedia Qt6::PrintSupport Qt6::DBus Qt6::Test)
    if(WITH_QTPDF)
        target_link_libraries(photoqt_test PRIVATE Qt6::Pdf)
    endif()
    target_include_directories(photoqt_test PRIVATE "testing/header")
    target_include_directories(photoqt_test PRIVATE "cplusplus/header")
    target_compile_definitions(photoqt_test PRIVATE PQMVERSION="${APPVERSION}")
    target_include_directories(photoqt_test PRIVATE "cplusplus/header")
    target_include_directories(photoqt_test PRIVATE "extensions")
endif()

###############################
#### ADDITIONAL QT OPTIONS ####
###############################

# Since Python might be imported we have to avoid using Qt keywords (like 'slots') to avoid naming conflicts
target_compile_definitions(photoqt PRIVATE QT_NO_KEYWORDS)
if(WITH_TESTING)
    target_compile_definitions(photoqt_test PRIVATE QT_NO_KEYWORDS)
endif()

# we always want to capture debug/log context information
target_compile_definitions(photoqt PRIVATE QT_MESSAGELOGCONTEXT)
if(WITH_TESTING)
    target_compile_definitions(photoqt_test PRIVATE QT_MESSAGELOGCONTEXT)
endif()

if(WITHOUT_ICU)
    message("** Configured WITHOUT ICU support")
    target_compile_definitions(photoqt PRIVATE PQMWITHOUTICU)
    if(WITH_TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMWITHOUTICU)
    endif()
endif()

##############################################
#### COMPOSE THE APPROPRIATE DESKTOP FILE ####
##############################################

include("CMake/ComposeDesktopFile.cmake")
composeDesktopFile()

######################
#### TRANSLATIONS ####
######################

# the compiled translations are automatically embedded as resource in executable
file(GLOB files "lang/*.ts")
qt_add_translations(photoqt TS_FILES ${files} RESOURCE_PREFIX "/lang")

########################
#### CUSTOM OPTIONS ####
########################

if(WITH_IMAGEMAGICK)
    if(NOT ${ImageMagick_FOUND})
        message(FATAL_ERROR "** Unable to locate ImageMagick... is it installed?")
    else()
        message("** Using ImageMagick ${ImageMagick_VERSION_STRING}")
        # These checks are necessary to "fix" compiling PhotoQt with both ImageMagick 6 and 7 available
        if(ImageMagick_VERSION_STRING MATCHES "^7")
            string(REPLACE "libMagick++-6." "libMagick++-7." ImageMagick_LIBRARIES "${ImageMagick_LIBRARIES}")
            string(REPLACE "ImageMagick-6" "ImageMagick-7" ImageMagick_INCLUDE_DIRS "${ImageMagick_INCLUDE_DIRS}")
        endif()
        target_compile_definitions(photoqt PRIVATE PQMIMAGEMAGICK)
        target_compile_definitions(photoqt PRIVATE MAGICKCORE_QUANTUM_DEPTH=16)
        target_compile_definitions(photoqt PRIVATE MAGICKCORE_HDRI_ENABLE=1)
        target_link_libraries(photoqt PRIVATE ImageMagick::Magick++)
        if(WITH_TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMIMAGEMAGICK)
            target_compile_definitions(photoqt_test PRIVATE MAGICKCORE_QUANTUM_DEPTH=16)
            target_compile_definitions(photoqt_test PRIVATE MAGICKCORE_HDRI_ENABLE=1)
            target_link_libraries(photoqt_test PRIVATE ImageMagick::Magick++)
        endif()
    endif()
else()
    message("** ImageMagick DISABLED")
endif()

if(WITH_GRAPHICSMAGICK)
    if(NOT ${MAGICK++_FOUND})
        message(FATAL_ERROR "** Unable to locate GraphicsMagick... is it installed?")
    else()
        message("** Using Graphicsmagick")
        target_include_directories(photoqt PRIVATE ${MAGICK++_INCLUDE_DIR})
        target_compile_definitions(photoqt PRIVATE PQMGRAPHICSMAGICK)
        target_link_libraries(photoqt PRIVATE "GraphicsMagick++")
        if(WITH_TESTING)
            target_include_directories(photoqt_test PRIVATE ${MAGICK++_INCLUDE_DIR})
            target_compile_definitions(photoqt_test PRIVATE PQMGRAPHICSMAGICK)
            target_link_libraries(photoqt_test PRIVATE "GraphicsMagick++")
        endif()
    endif()
else()
    message("** Graphicsmagick DISABLED")
endif()

if(WITH_LIBRAW)
    if(NOT ${LibRaw_FOUND})
        message(FATAL_ERROR "** Unable to locate LibRaw... is it installed?")
    else()
        message("** Using LibRaw")
        target_compile_definitions(photoqt PRIVATE PQMRAW)
        target_include_directories(photoqt PRIVATE ${LibRaw_INCLUDE_DIR})
        target_link_libraries(photoqt PRIVATE ${LibRaw_LIBRARIES})
        if(WITH_TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMRAW)
            target_include_directories(photoqt_test PRIVATE ${LibRaw_INCLUDE_DIR})
            target_link_libraries(photoqt_test PRIVATE ${LibRaw_LIBRARIES})
        endif()
    endif()
else()
    message("** LibRaw DISABLED")
endif()

if(WITH_DEVIL)
    if(NOT ${DevIL_FOUND})
        message(FATAL_ERROR "** Unable to locate DevIL... is it installed?")
    else()
        message("** Using DevIL")
        target_compile_definitions(photoqt PRIVATE PQMDEVIL)
        target_link_libraries(photoqt PRIVATE DevIL::IL)
        if(WITH_TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMDEVIL)
            target_link_libraries(photoqt_test PRIVATE DevIL::IL)
        endif()
    endif()
else()
    message("** DevIL DISABLED")
endif()

if(WITH_FREEIMAGE)
    if(NOT ${FREEIMAGE_FOUND})
        message(FATAL_ERROR "** Unable to locate FreeImage... is it installed?")
    else()
        message("** Using FreeImage")
        target_include_directories(photoqt PRIVATE ${FREEIMAGE_INCLUDE_DIRS})
        target_compile_definitions(photoqt PRIVATE PQMFREEIMAGE)
        target_link_libraries(photoqt PRIVATE ${FREEIMAGE_C_LIBRARY})
        if(WITH_TESTING)
            target_include_directories(photoqt_test PRIVATE ${FREEIMAGE_INCLUDE_DIRS})
            target_compile_definitions(photoqt_test PRIVATE PQMFREEIMAGE)
            target_link_libraries(photoqt_test PRIVATE ${FREEIMAGE_C_LIBRARY})
        endif()
    endif()
else()
    message("** FreeImage DISABLED")
endif()

if(WITH_POPPLER)
    if(NOT ${Poppler_FOUND})
        message(FATAL_ERROR "** Unable to locate Poppler... is it installed?")
    else()
        message("** Using Poppler ${Poppler_VERSION}")
        target_include_directories(photoqt PRIVATE ${Poppler_INCLUDE_DIRS})
        target_compile_definitions(photoqt PRIVATE PQMPOPPLER)
        target_link_libraries(photoqt PRIVATE ${Poppler_LIBRARIES})
        if(WITH_TESTING)
            target_include_directories(photoqt_test PRIVATE ${Poppler_INCLUDE_DIRS})
            target_compile_definitions(photoqt_test PRIVATE PQMPOPPLER)
            target_link_libraries(photoqt_test PRIVATE ${Poppler_LIBRARIES})
        endif()
    endif()
else()
    message("** Poppler DISABLED")
endif()

if(WITH_QTPDF)
    message("** Using QtPDF module")
    target_compile_definitions(photoqt PRIVATE PQMQTPDF)
    if(WITH_TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMQTPDF)
    endif()
endif()

if(WITH_LIBARCHIVE)
    if(NOT ${LibArchive_FOUND})
        message(FATAL_ERROR "** Unable to locate LibArchive... is it installed?")
    else()
        message("** Using LibArchive " ${LibArchive_VERSION})
        target_compile_definitions(photoqt PRIVATE PQMLIBARCHIVE)
        target_link_libraries(photoqt PRIVATE LibArchive::LibArchive)
        if(WITH_TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMLIBARCHIVE)
            target_link_libraries(photoqt_test PRIVATE LibArchive::LibArchive)
        endif()
    endif()
else()
    message("** LibArchive disabled")
endif()

if(WITH_VIDEO_QT)
    target_compile_definitions(photoqt PRIVATE PQMVIDEOQT)
    if(WITH_TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMVIDEOQT)
    endif()
endif()

if(WITH_VIDEO_MPV)
    if(NOT ${Libmpv_FOUND})
        message(FATAL_ERROR "** Unable to locate libmpv... is it installed?")
    else()
        message("** Using libmpv " ${Libmpv_VERSION})
        target_compile_definitions(photoqt PRIVATE PQMVIDEOMPV)
        target_link_libraries(photoqt PRIVATE Libmpv::Libmpv)
        if(WITH_TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMVIDEOMPV)
            target_link_libraries(photoqt_test PRIVATE Libmpv::Libmpv)
        endif()
    endif()
else()
    message("** libmpv DISABLED")
endif()

if(WITH_LIBVIPS)
    message("** Using libvips")
    target_include_directories(photoqt PRIVATE ${GLIB_INCLUDE_DIRS})
    target_compile_definitions(photoqt PRIVATE PQMLIBVIPS)
    target_link_libraries(photoqt PRIVATE ${GLIB_LIBRARIES})
    target_link_libraries(photoqt PRIVATE "vips")
    target_link_libraries(photoqt PRIVATE "gobject-2.0")
    target_link_libraries(photoqt PRIVATE "vips-cpp")
    if(WITH_TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMLIBVIPS)
        target_include_directories(photoqt_test PRIVATE ${GLIB_INCLUDE_DIRS})
        target_link_libraries(photoqt_test PRIVATE ${GLIB_LIBRARIES})
        target_link_libraries(photoqt_test PRIVATE "vips")
        target_link_libraries(photoqt_test PRIVATE "gobject-2.0")
        target_link_libraries(photoqt_test PRIVATE "vips-cpp")
    endif()
else()
    message("** libvips DISABLED")
endif()

if(WITH_RESVG)
    target_link_libraries(photoqt PRIVATE "resvg")
    message("** Using resvg")
    target_compile_definitions(photoqt PRIVATE PQMRESVG)
    if(WITH_TESTING)
        target_link_libraries(photoqt_test PRIVATE "resvg")
        target_compile_definitions(photoqt_test PRIVATE PQMRESVG)
    endif()
else()
    message("** resvg DISABLED")
endif()

if(WITH_EXIV2)
    if(NOT ${exiv2_FOUND})
        message(FATAL_ERROR "** Unable to locate Exiv2... is it installed?")
    else()
        message("** Using Exiv2 ${exiv2_VERSION}")
        target_compile_definitions(photoqt PRIVATE PQMEXIV2)
        target_link_libraries(photoqt PRIVATE exiv2lib)
        if(WITH_EXIV2_ENABLE_BMFF)
            target_compile_definitions(photoqt PRIVATE PQMEXIV2_ENABLE_BMFF)
        endif()
        if(WITH_TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMEXIV2)
            target_link_libraries(photoqt_test PRIVATE exiv2lib)
            if(WITH_EXIV2_ENABLE_BMFF)
                target_compile_definitions(photoqt_test PRIVATE PQMEXIV2_ENABLE_BMFF)
            endif()
        endif()
        if(WIN32)
            target_compile_definitions(photoqt PRIVATE NOMINMAX)
        endif()
        # if exiv2 0.27.x is used some c++ features removed in c++17 need to be re-enabled
        if(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
            if(${exiv2_VERSION} MATCHES "^0\.27\.")
                message("** Enabling C++ features removed in C++17 for Exiv2 0.27.x")
                message("** Please update Exiv2 to at least 0.28.x!")
                target_compile_definitions(photoqt PRIVATE _HAS_AUTO_PTR_ETC=1)
            endif()
        elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            if(${exiv2_VERSION} MATCHES "^0\.27\.")
                message("** Enabling C++ features removed in C++17 for Exiv2 0.27.x")
                message("** Please update Exiv2 to at least 0.28.x!")
                add_definitions(-fpermissive)
            endif()
        endif()
    endif()
else()
    message("** Exiv2 DISABLED")
endif()

if(WITH_PUGIXML)
    target_compile_definitions(photoqt PRIVATE PQMPUGIXML)
    target_link_libraries(photoqt PRIVATE pugixml::pugixml)
    if(WITH_TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMPUGIXML)
        target_link_libraries(photoqt_test PRIVATE pugixml::pugixml)
    endif()
endif()

if(WITH_ZXING)
    if(NOT ${ZXing_FOUND})
        message(FATAL_ERROR "** Unable to locate ZXing... is it installed?")
    else()
        message("** Using ZXing " ${ZXing_VERSION})
        target_compile_definitions(photoqt PRIVATE PQMZXING)
        target_link_libraries(photoqt PRIVATE ZXing::ZXing)
        if(WITH_TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMZXING)
            target_link_libraries(photoqt_test PRIVATE ZXing::ZXing)
        endif()
    endif()
else()
    message("** ZXing DISABLED")
endif()

if(WITH_CHROMECAST)
    if(NOT ${Python3_FOUND})
        message(FATAL_ERROR "** Unable to locate Python3... is it installed?")
    elseif(NOT ${Python3_Interpreter_FOUND})
        message(FATAL_ERROR "** Unable to locate Python3 Interpreter... is it installed?")
    else()
        execute_process(COMMAND ${Python3_EXECUTABLE} -c "import pychromecast" RESULT_VARIABLE EXIT_CODE OUTPUT_QUIET TIMEOUT 60)
        if(NOT ${EXIT_CODE} EQUAL 0)
            if(WITH_CHROMECAST_PIPINSTALL)
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
                                    "** Enabling the WITH_CHROMECAST_PIPINSTALL option allows CMake to try to install it locally using pip.")
            endif()
        endif()
        message("** Chromecast support enabled")
        message("** Using Python ${Python3_VERSION}")
        target_compile_definitions(photoqt PRIVATE PQMCHROMECAST)
        target_include_directories(photoqt PRIVATE ${Python3_INCLUDE_DIRS})
        target_link_libraries(photoqt PRIVATE ${Python3_LIBRARIES})
        if(WITH_TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMCHROMECAST)
            target_include_directories(photoqt_test PRIVATE ${Python3_INCLUDE_DIRS})
            target_link_libraries(photoqt_test PRIVATE ${Python3_LIBRARIES})
        endif()
    endif()
else()
    message("** Chromecast support DISABLED")
endif()

if(WITH_LOCATION)
    message("** Use of QtLocation/QtPosition enabled")
    target_compile_definitions(photoqt PRIVATE PQMLOCATION)
    if(WITH_TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMLOCATION)
    endif()
else()
    message("** Use of QtLocation/QtPosition DISABLED")
endif()

if(WITH_LCMS2)
    if(NOT ${LCMS2_FOUND})
        message(FATAL_ERROR "** Unable to locate LCMS2... is it installed?")
    else()
        message("** Using LCMS2 " ${LCMS2_VERSION})
        target_include_directories(photoqt PRIVATE ${LCMS2_INCLUDE_DIR})
        target_compile_definitions(photoqt PRIVATE PQMLCMS2)
        target_link_libraries(photoqt PRIVATE ${LCMS2_LIBRARIES})
        if(WITH_TESTING)
            target_include_directories(photoqt_test PRIVATE ${LCMS2_INCLUDE_DIR})
            target_compile_definitions(photoqt_test PRIVATE PQMLCMS2)
            target_link_libraries(photoqt_test PRIVATE ${LCMS2_LIBRARIES})
        endif()
    endif()
else()
    message("** LCMS2 DISABLED")
endif()

if(WITH_MOTIONPHOTO)
    message("** Support for Motion Photos and Apple Live Photos enabled")
    target_compile_definitions(photoqt PRIVATE PQMMOTIONPHOTO)
    if(WITH_TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMMOTIONPHOTO)
    endif()
else()
    message("** Support for Motion Photos and Apple Live Photos DISABLED")
endif()

if(WITH_PHOTOSPHERE)
    message("** Support for photo spheres enabled")
    target_compile_definitions(photoqt PRIVATE PQMPHOTOSPHERE)
    if(WITH_TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMPHOTOSPHERE)
    endif()
else()
    message("** Support for photo spheres DISABLED")
endif()

if(WITH_EXTENSIONS_SUPPORT)
    message("** Extended (yaml) support for extensions enabled")
    target_compile_definitions(photoqt PRIVATE PQMEXTENSIONS)
    target_link_libraries(photoqt PRIVATE yaml-cpp)
    if(WITH_TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMEXTENSIONS)
        target_link_libraries(photoqt_test PRIVATE yaml-cpp)
    endif()
else()
    message("** Extended (yaml) support for extensions DISABLED")
endif()

if(WITH_FLATPAKBUILD)
    message("** Enabling Flatpak workarounds")
    target_compile_definitions(photoqt PRIVATE PQMFLATPAKBUILD)
    target_include_directories(photoqt PRIVATE ${GLIB_INCLUDE_DIRS})
    target_link_libraries(photoqt PRIVATE ${GLIB_LIBRARIES})
    target_link_libraries(photoqt PRIVATE "gobject-2.0")
    target_link_libraries(photoqt PRIVATE "gio-2.0")
endif()

if(WITH_PORTABLETWEAKS)
    message("** Enabling Portable tweaks")
    target_compile_definitions(photoqt PRIVATE PQMPORTABLETWEAKS)
endif()

if(WITH_WAYLANDSPECIFIC)
    if(NOT ${WAYLAND_CLIENT_FOUND})
        message(FATAL_ERROR "** Unable to locate Wayland... is it installed?")
    else()
        message("** Enabling Wayland-specific code")
        target_compile_definitions(photoqt PRIVATE PQMWAYLANDSPECIFIC)
        target_link_libraries(photoqt PRIVATE Wayland::Client)
    endif()
endif()


#######################
#### INSTALL FILES ####
#######################

if(UNIX)

    # Install executable
    install(
        TARGETS photoqt
        DESTINATION bin/
    )

    # Install desktop file
    install(
        FILES org.photoqt.PhotoQt.desktop
        DESTINATION share/applications
    )

    # And install all the icons
    install(
        FILES icons/16x16/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/16x16/apps/
    )
    install(
        FILES icons/32x32/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/32x32/apps/
    )
    install(
        FILES icons/48x48/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/48x48/apps/
    )
    install(
        FILES icons/64x64/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/64x64/apps/
    )
    install(
        FILES icons/128x128/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/128x128/apps/
    )
    install(
        FILES icons/256x256/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/256x256/apps/
    )
    install(
        FILES icons/512x512/org.photoqt.PhotoQt.png
        DESTINATION share/icons/hicolor/512x512/apps/
    )
    # the max allowed icon size for flathub is 512x512
    if(NOT WITH_FLATPAKBUILD)
        install(
            FILES icons/1024x1024/org.photoqt.PhotoQt.png
            DESTINATION share/icons/hicolor/1024x1024/apps/
        )
    endif()
    install(
        FILES org.photoqt.PhotoQt.metainfo.xml
        DESTINATION share/metainfo/
    )

endif()


##########################
#### UNINSTALL TARGET ####
##########################

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/CMake/cmake_uninstall.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY)
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

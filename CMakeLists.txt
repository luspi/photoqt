##############################################
# CMakeLists for PhotoQt: http://photoqt.org #
##############################################

cmake_minimum_required(VERSION 3.26)
project(photoqt LANGUAGES C CXX)

##################################################################
####  GLOBAL VERSION STRING FOR ALL FILES (INCLUDING CPP/QML) ####
##################################################################

SET(APPVERSION "dev")

###################################
####  ENSURE BUILD TYPE IS SET ####
###################################

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

#############################
####  GET list of files  ####
#############################

include(CMake/ListFilesCPlusPlus.cmake)
include(CMake/ListFilesQMLModern.cmake)
include(CMake/ListFilesQMLIntegrated.cmake)

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
    find_package(yaml-cpp REQUIRED)
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
    foreach(QMLFILE ${photoqt_modern_QML})

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
    foreach(QMLFILE ${photoqt_modern_QML})

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


########################
#### QT SETUP STUFF ####
########################

qt_standard_project_setup(REQUIRES 6.4)

qt_add_resources(photoqt_SOURCES misc/misc.qrc img/img.qrc img/filetypes.qrc python/python.qrc)


#############################
#### Add the executable ####
#############################


if(WIN32)
    qt_add_executable(photoqt windowsicons.rc)
else()
    qt_add_executable(photoqt)
endif()

# ensure that the QTP0001 policy is set to NEW otherwise the QML files will not be found on import (on Qt 6.8+)
if(QT_KNOWN_POLICY_QTP0001)
    qt_policy(SET QTP0001 "NEW")
endif()
# disable warning with this policy not being set (on Qt 6.8+)
if(QT_KNOWN_POLICY_QTP0004)
    qt_policy(SET QTP0004 "OLD")
endif()

# add qml files
qt_add_qml_module(photoqt-modern
    URI PhotoQt.Modern
    VERSION 1.0
    QML_FILES ${photoqt_modern_QML}
    SOURCES ${photoqt_SOURCES} ${ALLHEADERS}
    OUTPUT_DIRECTORY PhotoQt/Modern)

qt_add_qml_module(photoqt-integrated
    URI PhotoQt.Integrated
    VERSION 1.0
    QML_FILES ${photoqt_integrated_QML}
    SOURCES ${photoqt_SOURCES} ${ALLHEADERS}
    OUTPUT_DIRECTORY PhotoQt/Integrated)

###########################
# cmake macros

macro(pqt_target_compile_definitions nme)
    set(val ${ARGN})
    list(LENGTH val val_count)
    if(${val_count} GREATER 0)
        target_compile_definitions(photoqt-modern     PRIVATE ${nme}="${val}")
        target_compile_definitions(photoqt-integrated PRIVATE ${nme}="${val}")
        target_compile_definitions(photoqt            PRIVATE ${nme}="${val}")
    else()
        target_compile_definitions(photoqt-modern     PRIVATE ${nme})
        target_compile_definitions(photoqt-integrated PRIVATE ${nme})
        target_compile_definitions(photoqt            PRIVATE ${nme})
    endif()
endmacro()

macro(pqt_target_include_directories)
    set(dir ${ARGN})
    list(LENGTH dir dir_count)
    if(${dir_count} GREATER 0)
        target_include_directories(photoqt-modern     PRIVATE ${dir})
        target_include_directories(photoqt-integrated PRIVATE ${dir})
        target_include_directories(photoqt            PRIVATE ${dir})
    endif()
endmacro()

macro(pqt_target_link_libraries)
    set(lnk ${ARGN})
    list(LENGTH lnk lnk_count)
    if(${lnk_count} GREATER 0)
        target_link_libraries(photoqt-modern     PRIVATE ${lnk} ${extra_lnk})
        target_link_libraries(photoqt-integrated PRIVATE ${lnk} ${extra_lnk})
        target_link_libraries(photoqt            PRIVATE ${lnk} ${extra_lnk})
    endif()
endmacro()


# set the version number
pqt_target_compile_definitions(PQMVERSION "${APPVERSION}")

# set header files as include files
pqt_target_include_directories("cplusplus/header")
pqt_target_include_directories("cplusplus/header/scripts")
pqt_target_include_directories("cplusplus/header/scripts/qml")
pqt_target_include_directories("cplusplus/header/scripts/qmlcpp")
pqt_target_include_directories("cplusplus/header/scripts/qmlwrapper")
pqt_target_include_directories("cplusplus/extensions")

# set some properties for executable
set_target_properties(photoqt PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER photoqt.PhotoQt.org
    MACOSX_BUNDLE_BUNDLE_VERSION "${APPVERSION}"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${APPVERSION}"
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(photoqt PRIVATE photoqt-modern photoqt-integrated)

# link executable
pqt_target_link_libraries(Qt6::Quick Qt6::Widgets Qt6::Sql Qt6::Core
                          Qt6::Svg Qt6::Concurrent Qt6::Multimedia
                          Qt6::PrintSupport Qt6::DBus)

if(WITH_QTPDF)
    pqt_target_link_libraries(Qt6::Pdf)
endif()

###############################
#### ADDITIONAL QT OPTIONS ####
###############################

# Since Python might be imported we have to avoid using Qt keywords (like 'slots') to avoid naming conflicts
pqt_target_compile_definitions(QT_NO_KEYWORDS)

# we always want to capture debug/log context information
pqt_target_compile_definitions(QT_MESSAGELOGCONTEXT)

if(WITHOUT_ICU)
    message("** Configured WITHOUT ICU support")
    pqt_target_compile_definitions(PQMWITHOUTICU)
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
        pqt_target_compile_definitions(PQMIMAGEMAGICK)
        pqt_target_link_libraries(ImageMagick::Magick++)
    endif()
else()
    message("** ImageMagick DISABLED")
endif()

if(WITH_GRAPHICSMAGICK)
    if(NOT ${MAGICK++_FOUND})
        message(FATAL_ERROR "** Unable to locate GraphicsMagick... is it installed?")
    else()
        message("** Using Graphicsmagick")
        pqt_target_include_directories(${MAGICK++_INCLUDE_DIR})
        pqt_target_compile_definitions(PQMGRAPHICSMAGICK)
        pqt_target_link_libraries("GraphicsMagick++")
    endif()
else()
    message("** Graphicsmagick DISABLED")
endif()

if(WITH_LIBRAW)
    if(NOT ${LibRaw_FOUND})
        message(FATAL_ERROR "** Unable to locate LibRaw... is it installed?")
    else()
        message("** Using LibRaw")
        pqt_target_compile_definitions(PQMRAW)
        pqt_target_include_directories(${LibRaw_INCLUDE_DIR})
        pqt_target_link_libraries(${LibRaw_LIBRARIES})
    endif()
else()
    message("** LibRaw DISABLED")
endif()

if(WITH_DEVIL)
    if(NOT ${DevIL_FOUND})
        message(FATAL_ERROR "** Unable to locate DevIL... is it installed?")
    else()
        message("** Using DevIL")
        pqt_target_compile_definitions(PQMDEVIL)
        pqt_target_link_libraries(DevIL::IL)
    endif()
else()
    message("** DevIL DISABLED")
endif()

if(WITH_FREEIMAGE)
    if(NOT ${FREEIMAGE_FOUND})
        message(FATAL_ERROR "** Unable to locate FreeImage... is it installed?")
    else()
        message("** Using FreeImage")
        pqt_target_include_directories(${FREEIMAGE_INCLUDE_DIRS})
        pqt_target_compile_definitions(PQMFREEIMAGE)
        pqt_target_link_libraries(${FREEIMAGE_C_LIBRARY})
    endif()
else()
    message("** FreeImage DISABLED")
endif()

if(WITH_POPPLER)
    if(NOT ${Poppler_FOUND})
        message(FATAL_ERROR "** Unable to locate Poppler... is it installed?")
    else()
        message("** Using Poppler ${Poppler_VERSION}")
        pqt_target_include_directories(${Poppler_INCLUDE_DIRS})
        pqt_target_compile_definitions(PQMPOPPLER)
        pqt_target_link_libraries(${Poppler_LIBRARIES})
    endif()
else()
    message("** Poppler DISABLED")
endif()

if(WITH_QTPDF)
    message("** Using QtPDF module")
    pqt_target_compile_definitions(PQMQTPDF)
endif()

if(WITH_LIBARCHIVE)
    if(NOT ${LibArchive_FOUND})
        message(FATAL_ERROR "** Unable to locate LibArchive... is it installed?")
    else()
        message("** Using LibArchive " ${LibArchive_VERSION})
        pqt_target_compile_definitions(PQMLIBARCHIVE)
        pqt_target_link_libraries(LibArchive::LibArchive)
    endif()
else()
    message("** LibArchive disabled")
endif()

if(WITH_VIDEO_QT)
    pqt_target_compile_definitions(PQMVIDEOQT)
endif()

if(WITH_VIDEO_MPV)
    if(NOT ${Libmpv_FOUND})
        message(FATAL_ERROR "** Unable to locate libmpv... is it installed?")
    else()
        message("** Using libmpv " ${Libmpv_VERSION})
        pqt_target_compile_definitions(PQMVIDEOMPV)
        pqt_target_link_libraries(Libmpv::Libmpv)
    endif()
else()
    message("** libmpv DISABLED")
endif()

if(WITH_LIBVIPS)
    message("** Using libvips")
    pqt_target_include_directories(${GLIB_INCLUDE_DIRS})
    pqt_target_compile_definitions(PQMLIBVIPS)
    pqt_target_link_libraries(${GLIB_LIBRARIES} "vips" "gobject-2.0" "vips-cpp")
else()
    message("** libvips DISABLED")
endif()

if(WITH_RESVG)
    message("** Using resvg")
    pqt_target_link_libraries("resvg")
    pqt_target_compile_definitions(PQMRESVG)
else()
    message("** resvg DISABLED")
endif()

if(WITH_EXIV2)
    if(NOT ${exiv2_FOUND})
        message(FATAL_ERROR "** Unable to locate Exiv2... is it installed?")
    else()
        message("** Using Exiv2 ${exiv2_VERSION}")
        pqt_target_compile_definitions(PQMEXIV2)
        pqt_target_link_libraries(exiv2lib)
        if(WITH_EXIV2_ENABLE_BMFF)
            pqt_target_compile_definitions(PQMEXIV2_ENABLE_BMFF)
        endif()
        if(WIN32)
            pqt_target_compile_definitions(NOMINMAX)
        endif()
        # if exiv2 0.27.x is used some c++ features removed in c++17 need to be re-enabled
        if(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
            if(${exiv2_VERSION} MATCHES "^0\.27\.")
                message("** Enabling C++ features removed in C++17 for Exiv2 0.27.x")
                message("** Please update Exiv2 to at least 0.28.x!")
                pqt_target_compile_definitions(_HAS_AUTO_PTR_ETC=1)
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
    pqt_target_compile_definitions(PQMPUGIXML)
    pqt_target_link_libraries(pugixml::pugixml)
endif()

if(WITH_ZXING)
    if(NOT ${ZXing_FOUND})
        message(FATAL_ERROR "** Unable to locate ZXing... is it installed?")
    else()
        message("** Using ZXing " ${ZXing_VERSION})
        pqt_target_compile_definitions(PQMZXING)
        pqt_target_link_libraries(ZXing::ZXing)
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
        pqt_target_compile_definitions(PQMCHROMECAST)
        pqt_target_include_directories(${Python3_INCLUDE_DIRS})
        pqt_target_link_libraries(${Python3_LIBRARIES})
    endif()
else()
    message("** Chromecast support DISABLED")
endif()

if(WITH_LOCATION)
    message("** Use of QtLocation/QtPosition enabled")
    pqt_target_compile_definitions(PQMLOCATION)
else()
    message("** Use of QtLocation/QtPosition DISABLED")
endif()

if(WITH_LCMS2)
    if(NOT ${LCMS2_FOUND})
        message(FATAL_ERROR "** Unable to locate LCMS2... is it installed?")
    else()
        message("** Using LCMS2 " ${LCMS2_VERSION})
        pqt_target_include_directories(${LCMS2_INCLUDE_DIR})
        pqt_target_compile_definitions(PQMLCMS2)
        pqt_target_link_libraries(${LCMS2_LIBRARIES})
    endif()
else()
    message("** LCMS2 DISABLED")
endif()

if(WITH_MOTIONPHOTO)
    message("** Support for Motion Photos and Apple Live Photos enabled")
    pqt_target_compile_definitions(PQMMOTIONPHOTO)
else()
    message("** Support for Motion Photos and Apple Live Photos DISABLED")
endif()

if(WITH_PHOTOSPHERE)
    message("** Support for photo spheres enabled")
    pqt_target_compile_definitions(PQMPHOTOSPHERE)
else()
    message("** Support for photo spheres DISABLED")
endif()

if(WITH_EXTENSIONS_SUPPORT)
    message("** Extended (yaml) support for extensions enabled")
    pqt_target_compile_definitions(PQMEXTENSIONS)
    pqt_target_link_libraries(yaml-cpp)
else()
    message("** Extended (yaml) support for extensions DISABLED")
endif()

if(WITH_FLATPAKBUILD)
    message("** Enabling Flatpak workarounds")
    pqt_target_compile_definitions(PQMFLATPAKBUILD)
    pqt_target_include_directories(${GLIB_INCLUDE_DIRS})
    pqt_target_link_libraries(${GLIB_LIBRARIES} "gobject-2.0" "gio-2.0")
endif()

if(WITH_PORTABLETWEAKS)
    message("** Enabling Portable tweaks")
    pqt_target_compile_definitions(PQMPORTABLETWEAKS)
endif()

if(WITH_WAYLANDSPECIFIC)
    if(NOT ${WAYLAND_CLIENT_FOUND})
        message(FATAL_ERROR "** Unable to locate Wayland... is it installed?")
    else()
        message("** Enabling Wayland-specific code")
        pqt_target_compile_definitions(PQMWAYLANDSPECIFIC)
        pqt_target_link_libraries(Wayland::Client)
    endif()
endif()


#############################
#### ENABLE UNIT TESTING ####
#############################

if(WITH_TESTING)
    enable_testing()
    add_subdirectory(testing)
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

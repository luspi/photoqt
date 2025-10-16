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
include(CMake/ListFilesQMLDuplicate.cmake)

#############################################
#### OPTIONS THAT CAN BE SET BY THE USER ####
#############################################

option(WITH_IMAGEMAGICK           "Configure with support for the ImageMagick library" ON)
option(WITH_GRAPHICSMAGICK        "Configure with support for the GraphicsMagick library" OFF)
option(WITH_LIBRAW                "Configure with support for the libraw library" ON)
option(WITH_DEVIL                 "Configure with support for the DevIL library" ON)
option(WITH_FREEIMAGE             "Configure with support for the FreeImage library" OFF)
option(WITH_POPPLER               "Configure with support for the Poppler library" ON)
option(WITH_QTPDF                 "Configure with support for the QtPDF module (instead of Poppler)" ON)
option(WITH_LIBARCHIVE            "Configure with support for the libarchive library" ON)
option(WITH_VIDEO_QT              "Configure with video support through Qt" ON)
option(WITH_VIDEO_MPV             "Configure with video support through MPV" ON)
option(WITH_LIBVIPS               "Configure with support for the libvips library" OFF)
option(WITH_RESVG                 "Configure with support for the resvg library (better SVG support)" OFF)
option(WITH_LIBSAI                "Configure with support for the libsai library (requires C++20 support)" OFF)

option(WITH_EXTENSIONS_SUPPORT    "Enable support for extensions (requires yaml-cpp library)" ON)
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
    find_package(ImageMagick COMPONENTS Magick++)
    if(NOT ${ImageMagick_FOUND})
        message("** ImageMagick not found. Disabling.")
        SET(WITH_IMAGEMAGICK OFF)
    endif()
endif()

if(WITH_GRAPHICSMAGICK)
    find_package(GraphicsMagick)
    if(NOT ${MAGICK++_FOUND})
        message("** GraphicsMagick not found. Disabling.")
        SET(WITH_GRAPHICSMAGICK OFF)
    endif()
endif()

if(WITH_LIBRAW)
    find_package(LibRaw)
    if(NOT ${LibRaw_FOUND})
        message("** LibRaw not found. Disabling.")
        SET(WITH_LIBRAW OFF)
    endif()
endif()

if(WITH_DEVIL)
    find_package(DevIL)
    if(NOT ${DevIL_FOUND})
        message("** DevIL not found. Disabling.")
        SET(WITH_DEVIL OFF)
    endif()
endif()

if(WITH_FREEIMAGE)
    find_package(FreeImage)
    if(NOT ${FREEIMAGE_FOUND})
        message("** FreeImage not found. Disabling.")
        SET(WITH_FREEIMAGE OFF)
    endif()
endif()

if(WITH_POPPLER)
    find_package(Poppler COMPONENTS Qt6)
    if(NOT ${Poppler_FOUND})
        message("** Poppler not found. Disabling.")
        SET(WITH_POPPLER OFF)
    endif()
endif()

if(WITH_QTPDF)
    find_package(Qt6 COMPONENTS Pdf)
    if(NOT ${Qt6Pdf_FOUND})
        message("** Qt PDF component not found. Disabling.")
        SET(WITH_QTPDF OFF)
    endif()
endif()

if(WITH_LIBARCHIVE)
    find_package(LibArchive)
    if(NOT ${LibArchive_FOUND})
        message("** LibArchive not found. Disabling.")
        SET(WITH_LIBARCHIVE OFF)
    endif()
endif()

if(WITH_VIDEO_MPV)
    find_package(Libmpv)
    if(NOT ${Libmpv_FOUND})
        message("** libmpv not found. Disabling.")
        SET(WITH_VIDEO_MPV OFF)
    endif()
endif()

if(WITH_LIBVIPS)
    pkg_search_module(GLIB glib-2.0 gobject-2.0)
    if(NOT ${GLIB_FOUND})
        message("** glib not found. Disabling libvips.")
        SET(WITH_LIBVIPS OFF)
    else()
        pkg_search_module(VIPS vips-cpp)
        if(NOT ${VIPS_FOUND})
            message("** libvips not found. Disabling.")
            SET(WITH_LIBVIPS OFF)
        endif()
    endif()
endif()

if(WITH_LIBSAI)
    find_package(Libsai)
    if(NOT ${Libsai_FOUND})
        message("** Libsai not found. Disabling.")
        SET(WITH_LIBSAI OFF)
    else()
        set(CMAKE_CXX_STANDARD 20)
    endif()
endif()

if(WITH_EXTENSIONS_SUPPORT)
    find_package(yaml-cpp REQUIRED)
    if(NOT ${yaml-cpp_FOUND})
        message("** yaml-cpp not found. Disabling extensions.")
        SET(WITH_EXTENSIONS_SUPPORT OFF)
    endif()
endif()

if(WITH_EXIV2)
    find_package(exiv2)
    if(NOT ${exiv2_FOUND})
        message("** Exiv2 not found. Disabling.")
        SET(WITH_EXIV2 OFF)
    endif()
endif()

if(WITH_PUGIXML)
    find_package(pugixml)
    if(NOT ${pugixml_FOUND})
        message("** pugixml not found. Disabling.")
        SET(WITH_PUGIXML OFF)
    endif()
endif()

if(WITH_ZXING)
    find_package(ZXing)
    if(NOT ${ZXing_FOUND})
        message("** ZXing not found. Disabling.")
        SET(WITH_ZXING OFF)
    endif()
endif()

if(WITH_CHROMECAST)
    find_package(Python3 COMPONENTS Interpreter)
    if(NOT ${Python3_FOUND})
        message("** Python3 not found. Disabling Chromecast.")
        SET(WITH_CHROMECAST OFF)
    elseif(NOT ${Python3_Interpreter_FOUND})
        message("** Python3 Interpreter not found. Disabling Chromecast.")
        SET(WITH_CHROMECAST OFF)
    endif()
endif()

if(WITH_LCMS2)
    find_package(LCMS2)
    if(NOT ${LCMS2_FOUND})
        message("** LCMS2 not found. Disabling.")
        SET(WITH_LCMS2 OFF)
    endif()
endif()

if(WITH_FLATPAKBUILD)
    find_package(PkgConfig)
    if(NOT ${PkgConfig_FOUND})
        message("** PkgConfig not found. Disabling flatpak workaround.")
        SET(WITH_FLATPAKBUILD OFF)
    else()
        pkg_search_module(GLIB glib-2.0 gobject-2.0 gio-2.0)
        if(NOT ${GLIB_FOUND})
            message("** GLIB not found. Disabling flatpak workaround.")
            SET(WITH_FLATPAKBUILD OFF)
        endif()
    endif()
endif()

if(WITH_WAYLANDSPECIFIC)
    find_package(Wayland Client)
    if(NOT ${WAYLAND_CLIENT_FOUND})
        message("** Wayland not found. Disabling.")
        SET(WITH_WAYLANDSPECIFIC OFF)
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


#################################################################
#### CREATE PROPER DUPLICATES OF SOME QML FILES (IF CHANGED) ####
#################################################################

set(photoqt_duplicate_modern_QML "")
set(photoqt_duplicate_integrated_QML "")

SET(ADDITIONAL_CLEAN_FILES "${CMAKE_SOURCE_DIR}/qml/duplicate/.generated")

foreach(QMLFILE ${photoqt_duplicate_QML})

    # we need the absolute path as otherwise the EXISTS check below fails
    SET(QMLFILE "${CMAKE_SOURCE_DIR}/${QMLFILE}")

    # a change to any of these files triggers cmake rerun
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${QMLFILE}")

    # get relative dir without qml/duplicate prefix
    file(RELATIVE_PATH GENERICPATH "${CMAKE_SOURCE_DIR}/qml/duplicate" "${QMLFILE}")

    # the two target filenames
    set(FILENAME_MODERN "${CMAKE_SOURCE_DIR}/qml/duplicate/.generated/modern/${GENERICPATH}")
    set(FILENAME_INTEGRATED "${CMAKE_SOURCE_DIR}/qml/duplicate/.generated/integrated/${GENERICPATH}")

    # if the source file has been updated
    if("${QMLFILE}" IS_NEWER_THAN "${FILENAME_MODERN}" OR "${QMLFILE}" IS_NEWER_THAN "${FILENAME_INTEGRATED}")

        # create two copies of the files with the two different imports
        file(READ "${QMLFILE}" FILE_CONTENTS)

        set(TXT_NOTE "/****************************************************/
/*                                                  */
/*                                                  */
/*              DO NOT EDIT THIS FILE!              */
/*                                                  */
/*                                                  */
/****************************************************/
")

        string(REPLACE "/* :-)) <3 */\n" "${TXT_NOTE}" FILE_CONTENTS_MODERN "${FILE_CONTENTS}")
        string(REPLACE "import PhotoQt.Integrated" "import PhotoQt.Modern" FILE_CONTENTS_MODERN "${FILE_CONTENTS_MODERN}")
        file(WRITE "${FILENAME_MODERN}" "${FILE_CONTENTS_MODERN}")

        string(REPLACE "/* :-)) <3 */\n" "${TXT_NOTE}" FILE_CONTENTS_INTEGRATED "${FILE_CONTENTS}")
        string(REPLACE "import PhotoQt.Modern" "import PhotoQt.Integrated" FILE_CONTENTS_INTEGRATED "${FILE_CONTENTS_INTEGRATED}")
        file(WRITE "${FILENAME_INTEGRATED}" "${FILE_CONTENTS_INTEGRATED}")

    endif()

    # append new file to one of two variables to add to the respective modules below
    set(photoqt_duplicate_modern_QML ${photoqt_duplicate_modern_QML} qml/duplicate/.generated/modern/${GENERICPATH})
    set(photoqt_duplicate_integrated_QML ${photoqt_duplicate_integrated_QML} qml/duplicate/.generated/integrated/${GENERICPATH})

endforeach()


########################################
#### Handle Qt<6.4/5 specific stuff ####
########################################

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

qt_add_resources(photoqt_CPP_SOURCES misc/misc.qrc img/img.qrc img/filetypes.qrc python/python.qrc)
qt_add_resources(photoqt_QML_SOURCES misc/misc.qrc img/img.qrc img/filetypes.qrc python/python.qrc)

# Add Qt Designer files (currently only one, not likely to change anytime soon)
qt_wrap_ui(photoqt_HEADER_ui cplusplus/other/startuphandler/pqc_wizard.ui)
set(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${photoqt_HEADER_ui})


#############################
#### Add the executable ####
#############################

if(WIN32)
    qt_add_executable(photoqt ${photoqt_CPP_SOURCES} ${photoqt_CPPQML_SOURCES} windowsicons.rc)
else()
    qt_add_executable(photoqt ${photoqt_CPP_SOURCES} ${photoqt_CPPQML_SOURCES})
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
    QML_FILES ${photoqt_modern_QML} ${photoqt_duplicate_modern_QML}
    OUTPUT_DIRECTORY PhotoQt/Modern)

qt_add_qml_module(photoqt-integrated
    URI PhotoQt.Integrated
    VERSION 1.0
    QML_FILES ${photoqt_integrated_QML} ${photoqt_duplicate_integrated_QML}
    OUTPUT_DIRECTORY PhotoQt/Integrated)

qt_add_qml_module(photoqt-cplusplus
    URI PhotoQt.CPlusPlus
    VERSION 1.0
    SOURCES ${photoqt_QML_SOURCES} ${photoqt_CPPQML_SOURCES}
    OUTPUT_DIRECTORY PhotoQt/CPlusPlus)

###########################
# cmake macros

macro(pqt_target_compile_definitions nme)
    set(val ${ARGN})
    list(LENGTH val val_count)
    if(${val_count} GREATER 0)
        target_compile_definitions(photoqt-modern     PRIVATE ${nme}="${val}")
        target_compile_definitions(photoqt-integrated PRIVATE ${nme}="${val}")
        target_compile_definitions(photoqt-cplusplus  PRIVATE ${nme}="${val}")
        target_compile_definitions(photoqt            PRIVATE ${nme}="${val}")
    else()
        target_compile_definitions(photoqt-modern     PRIVATE ${nme})
        target_compile_definitions(photoqt-integrated PRIVATE ${nme})
        target_compile_definitions(photoqt-cplusplus  PRIVATE ${nme})
        target_compile_definitions(photoqt            PRIVATE ${nme})
    endif()
endmacro()

macro(pqt_target_include_directories)
    set(dir ${ARGN})
    list(LENGTH dir dir_count)
    if(${dir_count} GREATER 0)
        target_include_directories(photoqt-modern     PRIVATE ${dir})
        target_include_directories(photoqt-integrated PRIVATE ${dir})
        target_include_directories(photoqt-cplusplus  PRIVATE ${dir})
        target_include_directories(photoqt            PRIVATE ${dir})
    endif()
endmacro()

macro(pqt_target_link_libraries)
    set(lnk ${ARGN})
    list(LENGTH lnk lnk_count)
    if(${lnk_count} GREATER 0)
        target_link_libraries(photoqt-modern     PRIVATE ${lnk} ${extra_lnk})
        target_link_libraries(photoqt-integrated PRIVATE ${lnk} ${extra_lnk})
        target_link_libraries(photoqt-cplusplus  PRIVATE ${lnk} ${extra_lnk})
        target_link_libraries(photoqt            PRIVATE ${lnk} ${extra_lnk})
    endif()
endmacro()

# set the version number
pqt_target_compile_definitions(PQMVERSION "${APPVERSION}")

# set header files as include files
pqt_target_include_directories("cplusplus/header")
pqt_target_include_directories("cplusplus/header/qml")  # this is needed for the qml processor to find all the singletons

# set some properties for executable
set_target_properties(photoqt PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER photoqt.PhotoQt.org
    MACOSX_BUNDLE_BUNDLE_VERSION "${APPVERSION}"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${APPVERSION}"
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(photoqt PRIVATE photoqt-modern photoqt-integrated photoqt-cplusplus)

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

SET(STATUS_FORMATS_ENABLED "")
SET(STATUS_FORMATS_DISABLED "")
SET(STATUS_ENABLED "")
SET(STATUS_DISABLED "")

if(WITH_IMAGEMAGICK)
    list(APPEND STATUS_FORMATS_ENABLED "ImageMagick ${ImageMagick_VERSION_STRING}")
    # These checks are necessary to "fix" compiling PhotoQt with both ImageMagick 6 and 7 available
    if(ImageMagick_VERSION_STRING MATCHES "^7")
        string(REPLACE "libMagick++-6." "libMagick++-7." ImageMagick_LIBRARIES "${ImageMagick_LIBRARIES}")
        string(REPLACE "ImageMagick-6" "ImageMagick-7" ImageMagick_INCLUDE_DIRS "${ImageMagick_INCLUDE_DIRS}")
    endif()
    pqt_target_compile_definitions(PQMIMAGEMAGICK)
    pqt_target_link_libraries(ImageMagick::Magick++)
else()
    list(APPEND STATUS_FORMATS_DISABLED "ImageMagick")
endif()

if(WITH_GRAPHICSMAGICK)
    list(APPEND STATUS_FORMATS_ENABLED "Graphicsmagick")
    pqt_target_include_directories(${MAGICK++_INCLUDE_DIR})
    pqt_target_compile_definitions(PQMGRAPHICSMAGICK)
    pqt_target_link_libraries("GraphicsMagick++")
else()
    list(APPEND STATUS_FORMATS_DISABLED "GraphicsMagick")
endif()

if(WITH_LIBRAW)
    list(APPEND STATUS_FORMATS_ENABLED "LibRaw")
    pqt_target_compile_definitions(PQMRAW)
    pqt_target_include_directories(${LibRaw_INCLUDE_DIR})
    pqt_target_link_libraries(${LibRaw_LIBRARIES})
else()
    list(APPEND STATUS_FORMATS_DISABLED "LibRaw")
endif()

if(WITH_DEVIL)
    list(APPEND STATUS_FORMATS_ENABLED "DevIL")
    pqt_target_compile_definitions(PQMDEVIL)
    pqt_target_link_libraries(DevIL::IL)
else()
    list(APPEND STATUS_FORMATS_DISABLED "DevIL")
endif()

if(WITH_FREEIMAGE)
    list(APPEND STATUS_FORMATS_ENABLED "FreeImage")
    pqt_target_include_directories(${FREEIMAGE_INCLUDE_DIRS})
    pqt_target_compile_definitions(PQMFREEIMAGE)
    pqt_target_link_libraries(${FREEIMAGE_C_LIBRARY})
else()
    list(APPEND STATUS_FORMATS_DISABLED "FreeImage")
endif()

if(WITH_POPPLER)
    list(APPEND STATUS_FORMATS_ENABLED "Poppler ${Poppler_VERSION}")
    pqt_target_include_directories(${Poppler_INCLUDE_DIRS})
    pqt_target_compile_definitions(PQMPOPPLER)
    pqt_target_link_libraries(${Poppler_LIBRARIES})
else()
    list(APPEND STATUS_FORMATS_DISABLED "Poppler")
endif()

if(WITH_QTPDF)
    list(APPEND STATUS_FORMATS_ENABLED "QtPDF module")
    pqt_target_compile_definitions(PQMQTPDF)
else()
    list(APPEND STATUS_FORMATS_DISABLED "QtPDF module")
endif()

if(WITH_LIBARCHIVE)
    list(APPEND STATUS_FORMATS_ENABLED "LibArchive ${LibArchive_VERSION}")
    pqt_target_compile_definitions(PQMLIBARCHIVE)
    pqt_target_link_libraries(LibArchive::LibArchive)
else()
    list(APPEND STATUS_FORMATS_DISABLED "LibArchive")
endif()

if(WITH_VIDEO_QT)
    list(APPEND STATUS_FORMATS_ENABLED "Qt video module")
    pqt_target_compile_definitions(PQMVIDEOQT)
else()
    list(APPEND STATUS_FORMATS_DISABLED "Qt video module")
endif()

if(WITH_VIDEO_MPV)
    list(APPEND STATUS_FORMATS_ENABLED "libmpv ${Libmpv_VERSION}")
    pqt_target_compile_definitions(PQMVIDEOMPV)
    pqt_target_link_libraries(Libmpv::Libmpv)
else()
    list(APPEND STATUS_FORMATS_DISABLED "libmpv")
endif()

if(WITH_LIBVIPS)
    list(APPEND STATUS_FORMATS_ENABLED "libvips")
    pqt_target_include_directories(${GLIB_INCLUDE_DIRS})
    pqt_target_compile_definitions(PQMLIBVIPS)
    pqt_target_link_libraries(${GLIB_LIBRARIES} "vips" "gobject-2.0" "vips-cpp")
else()
    list(APPEND STATUS_FORMATS_DISABLED "libvips")
endif()

if(WITH_RESVG)
    list(APPEND STATUS_FORMATS_ENABLED "resvg")
    pqt_target_link_libraries("resvg")
    pqt_target_compile_definitions(PQMRESVG)
else()
    list(APPEND STATUS_FORMATS_DISABLED "resvg")
endif()

if(WITH_LIBSAI)
    list(APPEND STATUS_FORMATS_ENABLED "libsai")
    pqt_target_include_directories(${Libsai_INCLUDE_DIR})
    pqt_target_compile_definitions(PQMLIBSAI)
    pqt_target_link_libraries("sai")
else()
    list(APPEND STATUS_FORMATS_DISABLED "libsai")
endif()

if(WITH_EXTENSIONS_SUPPORT)
    list(APPEND STATUS_ENABLED "Extensions (yaml-cpp)")
    set(BUILD_EXTENSIONS_AS_PART_OF_PHOTOQT ON)
    add_subdirectory("extensions/")
    pqt_target_compile_definitions(PQMINSTALLPREFIX ${CMAKE_INSTALL_PREFIX})
    pqt_target_compile_definitions(PQMBUILDDIR ${CMAKE_BINARY_DIR})
    pqt_target_compile_definitions(PQMSOURCEDIR ${CMAKE_SOURCE_DIR})
    pqt_target_compile_definitions(PQMEXTENSIONS)
    pqt_target_link_libraries(yaml-cpp)
else()
    list(APPEND STATUS_DISABLED "Extensions (yaml-cpp)")
endif()

if(WITH_EXIV2)
    list(APPEND STATUS_ENABLED "Exiv2 ${exiv2_VERSION}")
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
else()
    list(APPEND STATUS_DISABLED "Exiv2")
endif()

if(WITH_PUGIXML)
    list(APPEND STATUS_ENABLED "pugixml")
    pqt_target_compile_definitions(PQMPUGIXML)
    pqt_target_link_libraries(pugixml::pugixml)
else()
    list(APPEND STATUS_DISABLED "pugixml")
endif()

if(WITH_ZXING)
    list(APPEND STATUS_ENABLED "ZXing ${ZXing_VERSION}")
    pqt_target_compile_definitions(PQMZXING)
    pqt_target_link_libraries(ZXing::ZXing)
else()
    list(APPEND STATUS_DISABLED "ZXing")
endif()

if(WITH_CHROMECAST)
    execute_process(COMMAND ${Python3_EXECUTABLE} -c "import pychromecast" RESULT_VARIABLE EXIT_CODE OUTPUT_QUIET TIMEOUT 60)
    if(NOT ${EXIT_CODE} EQUAL 0)
        if(WITH_CHROMECAST_PIPINSTALL)
            # try installing it with pip
            message(">> Attempt to install pychromecast locally using pip...")
            execute_process(COMMAND ${Python3_EXECUTABLE} -m pip install pychromecast)
            execute_process(COMMAND ${Python3_EXECUTABLE} -c "import pychromecast" RESULT_VARIABLE EXIT_CODE OUTPUT_QUIET TIMEOUT 60)
            if(NOT ${EXIT_CODE} EQUAL 0)
                message("** Unable to locate Python3 module pychromecast. Please first install it before re-enabling Chromecast support.")
                SET(WITH_CHROMECAST OFF)
                list(APPEND STATUS_DISABLED "Chromecast (Python)")
            else()
                message(">> Success!")
            endif()
        else()
            message("** Unable to import PyChromecast, make sure it is installed before re-enabling Chromecast support.")
            message("** Enabling the WITH_CHROMECAST_PIPINSTALL option allows CMake to try to install it locally using pip.")
            SET(WITH_CHROMECAST OFF)
            list(APPEND STATUS_DISABLED "Chromecast (Python)")
        endif()
    endif()
    # it might have been disabled in the checks above
    if(WITH_CHROMECAST)
        list(APPEND STATUS_ENABLED "Chromecast (Python ${Python3_VERSION})")
        pqt_target_compile_definitions(PQMCHROMECAST)
        pqt_target_include_directories(${Python3_INCLUDE_DIRS})
        pqt_target_link_libraries(${Python3_LIBRARIES})
    endif()
else()
    list(APPEND STATUS_DISABLED "Chromecast (Python)")
endif()

if(WITH_LOCATION)
    list(APPEND STATUS_ENABLED "QtLocation/QtPosition")
    pqt_target_compile_definitions(PQMLOCATION)
else()
    list(APPEND STATUS_DISABLED "QtLocation/QtPosition")
endif()

if(WITH_LCMS2)
    list(APPEND STATUS_ENABLED "LCMS2 ${LCMS2_VERSION}")
    pqt_target_include_directories(${LCMS2_INCLUDE_DIR})
    pqt_target_compile_definitions(PQMLCMS2)
    pqt_target_link_libraries(${LCMS2_LIBRARIES})
else()
    list(APPEND STATUS_DISABLED "LCMS2")
endif()

if(WITH_MOTIONPHOTO)
    list(APPEND STATUS_ENABLED "Motion photos and Apple live photos")
    pqt_target_compile_definitions(PQMMOTIONPHOTO)
else()
    list(APPEND STATUS_DISABLED "Motion photos and Apple live photos")
endif()

if(WITH_PHOTOSPHERE)
    list(APPEND STATUS_ENABLED "Photo spheres")
    pqt_target_compile_definitions(PQMPHOTOSPHERE)
else()
    list(APPEND STATUS_DISABLED "Photo spheres")
endif()

if(WITH_FLATPAKBUILD)
    list(APPEND STATUS_ENABLED "Flatpak workarounds")
    pqt_target_compile_definitions(PQMFLATPAKBUILD)
    pqt_target_include_directories(${GLIB_INCLUDE_DIRS})
    pqt_target_link_libraries(${GLIB_LIBRARIES} "gobject-2.0" "gio-2.0")
else()
    list(APPEND STATUS_DISABLED "Flatpak workarounds")
endif()

if(WITH_PORTABLETWEAKS)
    list(APPEND STATUS_ENABLED "Portable tweaks (do not use unless you know what you are doing!)")
    pqt_target_compile_definitions(PQMPORTABLETWEAKS)
else()
    list(APPEND STATUS_DISABLED "Portable tweaks (leave disabled unless you know what you are doing!)")
endif()

if(WITH_WAYLANDSPECIFIC)
    list(APPEND STATUS_ENABLED "Wayland-specific code")
    pqt_target_compile_definitions(PQMWAYLANDSPECIFIC)
    pqt_target_link_libraries(Wayland::Client)
else()
    list(APPEND STATUS_DISABLED "Wayland-specific code")
endif()

message("")
message("** The following options are enabled for this build:")
message("")
foreach(opt IN LISTS STATUS_FORMATS_ENABLED)
    message("    - ${opt}")
endforeach()
message("")
foreach(opt IN LISTS STATUS_ENABLED)
    message("    - ${opt}")
endforeach()
message("")


message("")
message("")
message("** The following options are DISABLED for this build:")
message("")
foreach(opt IN LISTS STATUS_FORMATS_DISABLED)
    message("    - ${opt}")
endforeach()
message("")
foreach(opt IN LISTS STATUS_DISABLED)
    message("    - ${opt}")
endforeach()
message("")

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
    install(
        TARGETS photoqt-modern photoqt-integrated photoqt-cplusplus
        DESTINATION lib/
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

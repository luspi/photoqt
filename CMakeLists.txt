##############################################
# CMakeLists for PhotoQt: http://photoqt.org #
##############################################

cmake_minimum_required(VERSION 3.16)
project(photoqt LANGUAGES CXX)

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
option(ZXING "Support for QR and barcodes detection (using ZXing)" ON)

option(EXIV2 "Use exiv2 library" ON)
option(EXIV2_ENABLE_BMFF "Enable BMFF format support in Exiv2 (if available)" ON)
option(PUGIXML "Enable features that require pugixml" ON)
option(CHROMECAST "Enable Chromecast support" ON)
option(CHROMECAST_PIPINSTALL "Allows CMake to attempt to install PyChromecast locally using pip." OFF)
option(LOCATION "Enable use of QtPositioning/QtLocation QML modules" ON)
option(MOTIONPHOTO "Enable support for Google Motion Photos and Apple Live Photos" ON)
option(PHOTOSPHERE "Enable support for photo spheres and 360 degree panoramic views" ON)
option(LCMS2 "Enable advanced color management with LCMS2" ON)

option(TESTING "Build some unit tests" OFF)
option(RUNCPPCHECK "Analyse source code with cppcheck" OFF)
option(FLATPAKBUILD "Enable this if this is a build for Flatpak" OFF)

if(QTPDF)
    if(POPPLER)
        set(POPPLER OFF)
        message("** For displaying PDF documents you have to choose either Poppler OR QtPDF.")
        message("** Poppler has been automatically disabled in favour of QtPDF.")
    endif()
endif()

################################
#### FIND REQUIRED PACKAGES ####
################################

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick Widgets Sql Core Svg Concurrent Multimedia PrintSupport DBus LinguistTools)
if(TESTING)
    find_package(Qt6 6.4 REQUIRED COMPONENTS Test)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake")

find_package(ECM REQUIRED NO_MODULE)
list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

if(IMAGEMAGICK)
    find_package(ImageMagick COMPONENTS Magick++)
    if(GRAPHICSMAGICK)
        set(GRAPHICSMAGICK OFF)
        message("** ImageMagick and GraphicsMagick cannot be used at the same time.")
        message("** GraphicsMagick has been automatically disabled in favour of ImageMagick.")
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
    find_package(Python3 COMPONENTS Interpreter)
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

if(ZXING)
    find_package(ZXing)
endif()

if(PHOTOSPHERE)
    set(photoqt_SOURCES ${photoqt_SOURCES} ${photoqt_ps_SOURCES})
endif()

if(LCMS2)
    find_package(LCMS2)
endif()

if(FLATPAKBUILD)
    find_package(PkgConfig REQUIRED)
    pkg_search_module(GLIB REQUIRED glib-2.0 gobject-2.0 gio-2.0)
endif()

######################
#### RUN CPPCHECK ####
######################

if(RUNCPPCHECK)

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

    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different
                   "${CMAKE_CURRENT_SOURCE_DIR}/qml/elements/PQMultiEffect_fake.qml" "${CMAKE_CURRENT_SOURCE_DIR}/qml/elements/PQMultiEffect.qml")
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different
                   "${CMAKE_CURRENT_SOURCE_DIR}/qml/elements/PQBlurBackground_fake.qml" "${CMAKE_CURRENT_SOURCE_DIR}/qml/elements/PQBlurBackground.qml")

    # pragma ComponentBehavior causes issues with Qt 6.4 (and isn't supported before)
    foreach(QMLFILE ${photoqt_QML})
        file(READ ${QMLFILE} FILE_CONTENTS)
        string(REPLACE "pragma ComponentBehavior: Bound" "" FILE_CONTENTS "${FILE_CONTENTS}")
        file(WRITE ${QMLFILE} "${FILE_CONTENTS}")
    endforeach()

else()

    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different
                   "${CMAKE_CURRENT_SOURCE_DIR}/qml/elements/PQMultiEffect_real.qml" "${CMAKE_CURRENT_SOURCE_DIR}/qml/elements/PQMultiEffect.qml")
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different
                   "${CMAKE_CURRENT_SOURCE_DIR}/qml/elements/PQBlurBackground_real.qml" "${CMAKE_CURRENT_SOURCE_DIR}/qml/elements/PQBlurBackground.qml")

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

# add qml files
qt_add_qml_module(photoqt URI src VERSION 1.0 QML_FILES ${photoqt_QML} RESOURCE_PREFIX)

# set header files as include files
target_include_directories(photoqt PRIVATE "cplusplus/header")

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

if(QTPDF)
    target_link_libraries(photoqt PRIVATE Qt6::Pdf)
endif()

if(TESTING)
    qt_add_executable(photoqt_test ${photoqt_testscripts_SOURCES} misc/misc.qrc testing/resources/testing.qrc)
    target_link_libraries(photoqt_test PRIVATE Qt6::Quick Qt6::Widgets Qt6::Sql Qt6::Core Qt6::Svg Qt6::Concurrent Qt6::Multimedia Qt6::PrintSupport Qt6::DBus Qt6::Test)
    target_include_directories(photoqt_test PRIVATE "testing/header")
    target_include_directories(photoqt_test PRIVATE "cplusplus/header")
    target_compile_definitions(photoqt_test PRIVATE PQMVERSION="${APPVERSION}")
    target_include_directories(photoqt_test PRIVATE "cplusplus/header")
endif()

###############################
#### ADDITIONAL QT OPTIONS ####
###############################

# Since Python might be imported we have to avoid using Qt keywords (like 'slots') to avoid naming conflicts
target_compile_definitions(photoqt PRIVATE QT_NO_KEYWORDS)

# we always want to capture debug/log context information
target_compile_definitions(photoqt PRIVATE QT_MESSAGELOGCONTEXT)

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
qt_add_translations(photoqt
    TS_FILES ${files}
    RESOURCE_PREFIX "/lang")


########################
#### CUSTOM OPTIONS ####
########################

if(PUGIXML)
    target_compile_definitions(photoqt PRIVATE PQMPUGIXML)
    target_link_libraries(photoqt PRIVATE "pugixml")
    if(TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMPUGIXML)
        target_link_libraries(photoqt_test PRIVATE "pugixml")
    endif()
endif()

if(VIDEO_QT)
    target_compile_definitions(photoqt PRIVATE PQMVIDEOQT)
endif()

if(LIBARCHIVE)
    if(NOT ${LibArchive_FOUND})
        message(FATAL_ERROR "** Unable to locate LibArchive... is it installed?")
    else()
        message("** Using LibArchive " ${LibArchive_VERSION})
        target_compile_definitions(photoqt PRIVATE PQMLIBARCHIVE)
        include_directories(${LibArchive_INCLUDE_DIRS})
        target_link_libraries(photoqt PRIVATE ${LibArchive_LIBRARIES})
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMLIBARCHIVE)
            target_link_libraries(photoqt_test PRIVATE ${LibArchive_LIBRARIES})
        endif()
    endif()
else()
    message("** LibArchive disabled")
endif()

if(POPPLER)
    if(WIN32)
        message("** Using Poppler")
        target_compile_definitions(photoqt PRIVATE PQMPOPPLER)
        target_link_libraries(photoqt PRIVATE "poppler")
        target_link_libraries(photoqt PRIVATE "poppler-qt6")
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMPOPPLER)
            target_link_libraries(photoqt_test PRIVATE "poppler")
            target_link_libraries(photoqt_test PRIVATE "poppler-qt6")
        endif()
    else()
        if(NOT ${Poppler_FOUND})
            message(FATAL_ERROR "** Unable to locate Poppler... is it installed?")
        else()
            message("** Using Poppler ${Poppler_VERSION}")
            include_directories(${Poppler_INCLUDE_DIRS})
            target_compile_definitions(photoqt PRIVATE PQMPOPPLER)
            target_link_libraries(photoqt PRIVATE ${Poppler_LIBRARIES})
            if(TESTING)
                target_compile_definitions(photoqt_test PRIVATE PQMPOPPLER)
                target_link_libraries(photoqt_test PRIVATE ${Poppler_LIBRARIES})
            endif()
        endif()
    endif()
else()
    message("** Poppler DISABLED")
endif()

if(QTPDF)
    message("** Using QtPDF module")
    target_compile_definitions(photoqt PRIVATE PQMQTPDF)
endif()

if(DEVIL)
    if(WIN32)
        target_link_libraries(photoqt PRIVATE "DevIL")
        message("** Using DevIL")
        target_compile_definitions(photoqt PRIVATE PQMDEVIL)
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMDEVIL)
            target_link_libraries(photoqt_test PRIVATE "DevIL")
        endif()
    else()
        if(NOT ${DevIL_FOUND})
            message(FATAL_ERROR "** Unable to locate DevIL... is it installed?")
        else()
            message("** Using DevIL")
            include_directories(${IL_INCLUDE_DIR})
            target_compile_definitions(photoqt PRIVATE PQMDEVIL)
            target_link_libraries(photoqt PRIVATE ${IL_LIBRARIES})
            if(TESTING)
                target_compile_definitions(photoqt_test PRIVATE PQMDEVIL)
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
        target_compile_definitions(photoqt PRIVATE PQMFREEIMAGE)
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMFREEIMAGE)
            target_link_libraries(photoqt_test PRIVATE "FreeImage")
        endif()
    else()
        if(NOT ${FREEIMAGE_FOUND})
            message(FATAL_ERROR "** Unable to locate FreeImage... is it installed?")
        else()
            message("** Using FreeImage")
            include_directories(${FREEIMAGE_INCLUDE_DIRS})
            target_compile_definitions(photoqt PRIVATE PQMFREEIMAGE)
            target_link_libraries(photoqt PRIVATE ${FREEIMAGE_C_LIBRARY})
            if(TESTING)
                target_compile_definitions(photoqt_test PRIVATE PQMFREEIMAGE)
                target_link_libraries(photoqt_test PRIVATE ${FREEIMAGE_C_LIBRARY})
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
        target_compile_definitions(photoqt PRIVATE PQMRAW)
        include_directories(${LIBRAW_INCLUDE_DIR})
        if(WIN32)
            target_link_libraries(photoqt PRIVATE "libraw")
            if(TESTING)
                target_compile_definitions(photoqt_test PRIVATE PQMRAW)
                target_link_libraries(photoqt_test PRIVATE "libraw")
            endif()
        else()
            target_link_libraries(photoqt PRIVATE "raw")
            if(TESTING)
                target_compile_definitions(photoqt_test PRIVATE PQMRAW)
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
        target_compile_definitions(photoqt PRIVATE PQMEXIV2)
        target_link_libraries(photoqt PRIVATE "exiv2")
        if(EXIV2_ENABLE_BMFF)
            target_compile_definitions(photoqt PRIVATE PQMEXIV2_ENABLE_BMFF)
        endif()
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMEXIV2)
            target_link_libraries(photoqt_test PRIVATE "exiv2")
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

if(GRAPHICSMAGICK)
    if(NOT ${MAGICK++_FOUND})
        message(FATAL_ERROR "** Unable to locate GraphicsMagick... is it installed?")
    else()
        message("** Using Graphicsmagick")
        include_directories(${MAGICK++_INCLUDE_DIR})
        target_compile_definitions(photoqt PRIVATE PQMGRAPHICSMAGICK)
        target_link_libraries(photoqt PRIVATE "GraphicsMagick++")
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMGRAPHICSMAGICK)
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
        message("** Using ImageMagick ${ImageMagick_VERSION_STRING}")
        # These checks are necessary to "fix" compiling PhotoQt with both ImageMagick 6 and 7 available
        if(ImageMagick_VERSION_STRING MATCHES "^7")
            string(REPLACE "libMagick++-6." "libMagick++-7." ImageMagick_LIBRARIES "${ImageMagick_LIBRARIES}")
            string(REPLACE "ImageMagick-6" "ImageMagick-7" ImageMagick_INCLUDE_DIRS "${ImageMagick_INCLUDE_DIRS}")
        endif()
        include_directories("${ImageMagick_INCLUDE_DIRS}")
        target_compile_definitions(photoqt PRIVATE PQMIMAGEMAGICK)
        target_compile_definitions(photoqt PRIVATE MAGICKCORE_QUANTUM_DEPTH=16)
        target_compile_definitions(photoqt PRIVATE MAGICKCORE_HDRI_ENABLE=1)
        target_link_libraries(photoqt PRIVATE "${ImageMagick_LIBRARIES}")
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMIMAGEMAGICK)
            target_compile_definitions(photoqt_test PRIVATE MAGICKCORE_QUANTUM_DEPTH=16)
            target_compile_definitions(photoqt_test PRIVATE MAGICKCORE_HDRI_ENABLE=1)
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
        message("** Chromecast support enabled")
        message("** Using Python ${Python3_VERSION}")
        target_compile_definitions(photoqt PRIVATE PQMCHROMECAST)
        include_directories(${Python3_INCLUDE_DIRS})
        target_link_libraries(photoqt PRIVATE ${Python3_LIBRARIES})
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMCHROMECAST)
            target_link_libraries(photoqt_test PRIVATE ${Python3_LIBRARIES})
        endif()
    endif()
else()
    message("** Chromecast support DISABLED")
endif()

if(LIBVIPS)
    message("** Using libvips")
    include_directories(${GLIB_INCLUDE_DIRS})
    target_compile_definitions(photoqt PRIVATE PQMLIBVIPS)
    target_link_libraries(photoqt PRIVATE ${GLIB_LIBRARIES})
    target_link_libraries(photoqt PRIVATE "vips")
    target_link_libraries(photoqt PRIVATE "gobject-2.0")
    target_link_libraries(photoqt PRIVATE "vips-cpp")
    if(TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMLIBVIPS)
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
        target_compile_definitions(photoqt PRIVATE PQMVIDEOMPV)
        target_link_libraries(photoqt PRIVATE ${Libmpv_LIBRARIES})
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMVIDEOMPV)
            target_link_libraries(photoqt_test PRIVATE ${Libmpv_LIBRARIES})
        endif()
    endif()
else()
    message("** libmpv DISABLED")
endif()

if(LOCATION)
    message("** Use of QtLocation/QtPosition enabled")
    target_compile_definitions(photoqt PRIVATE PQMLOCATION)
    if(TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMLOCATION)
    endif()
else()
    message("** Use of QtLocation/QtPosition DISABLED")
endif()

if(RESVG)
    target_link_libraries(${PROJECT_NAME} PRIVATE "resvg")
    message("** Using resvg")
    target_compile_definitions(photoqt PRIVATE PQMRESVG)
    if(TESTING)
        target_link_libraries(photoqt_test PRIVATE "resvg")
        target_compile_definitions(photoqt_test PRIVATE PQMRESVG)
    endif()
else()
    message("** resvg DISABLED")
endif()

if(MOTIONPHOTO)
    message("** Support for Motion Photos and Apple Live Photos enabled")
    target_compile_definitions(photoqt PRIVATE PQMMOTIONPHOTO)
    if(TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMMOTIONPHOTO)
    endif()
else()
    message("** Support for Motion Photos and Apple Live Photos DISABLED")
endif()

if(PHOTOSPHERE)
    message("** Support for photo spheres enabled")
    message("** NOTE: When changing the PHOTOSPHERE option the source tree")
    message("**       might need to be cleaned before the next build")
    target_compile_definitions(photoqt PRIVATE PQMPHOTOSPHERE)
    if(TESTING)
        target_compile_definitions(photoqt_test PRIVATE PQMPHOTOSPHERE)
    endif()
else()
    message("** Support for photo spheres DISABLED")
endif()

if(ZXING)
    if(NOT ${ZXing_FOUND})
        message(FATAL_ERROR "** Unable to locate ZXing... is it installed?")
    else()
        message("** Using ZXing " ${ZXing_VERSION})
        include_directories(${ZXing_INCLUDE_DIRS})
        target_compile_definitions(photoqt PRIVATE PQMZXING)
        target_link_libraries(photoqt PRIVATE "ZXing")
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMZXING)
            target_link_libraries(photoqt_test PRIVATE "ZXing")
        endif()
    endif()
else()
    message("** ZXing DISABLED")
endif()

if(LCMS2)
    if(NOT ${LCMS2_FOUND})
        message(FATAL_ERROR "** Unable to locate LCMS2... is it installed?")
    else()
        message("** Using LCMS2 " ${LCMS2_VERSION})
        include_directories(${LCMS2_INCLUDE_DIR})
        target_compile_definitions(photoqt PRIVATE PQMLCMS2)
        target_link_libraries(photoqt PRIVATE ${LCMS2_LIBRARIES})
        if(TESTING)
            target_compile_definitions(photoqt_test PRIVATE PQMLCMS2)
            target_link_libraries(photoqt_test PRIVATE ${LCMS2_LIBRARIES})
        endif()
    endif()
else()
    message("** LCMS2 DISABLED")
endif()

if(FLATPAKBUILD)
    message("** Enabling Flatpak workarounds")
    target_compile_definitions(photoqt PRIVATE PQMFLATPAKBUILD)
    include_directories(${GLIB_INCLUDE_DIRS})
    target_link_libraries(photoqt PRIVATE ${GLIB_LIBRARIES})
    target_link_libraries(photoqt PRIVATE "gobject-2.0")
    target_link_libraries(photoqt PRIVATE "gio-2.0")
endif()


#######################
#### INSTALL FILES ####
#######################

if(UNIX)

    # Install executable
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
    if(NOT FLATPAKBUILD)
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

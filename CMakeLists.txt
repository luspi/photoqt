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
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -O3 -Wall")


################################
#### MANIPULATE DEBUG BUILD ####
################################

#add_definitions(-DPHOTOQTDEBUG)
set(CMAKE_BUILD_TYPE "Release")


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
include(CMake/ListFilesTesting.cmake)
include(CMake/ListFilesQML.cmake)
include(CMake/ListFilesResources.cmake)


#############################################
#### OPTIONS THAT CAN BE SET BY THE USER ####
#############################################

option(RAW "Use libraw library" ON)
option(EXIV2 "Use exiv2 library" ON)
option(GM "Use graphicsmagick library" ON)
option(DEVIL "Use DevIL library" ON)
option(FREEIMAGE "Use FreeImage library" ON)
option(POPPLER "Use Poppler library" ON)
option(QTONLY "ONLY USE QT-ONLY FEATURES" OFF)
option(TESTING "Enable some tests" OFF)


################################
#### FIND REQUIRED PACKAGES ####
################################

find_package(Qt5 COMPONENTS Core Quick Svg Sql Xml LinguistTools REQUIRED)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
find_package(Magick)
find_package(Exiv2)
find_package(LibRaw)
find_package(FreeImage)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(Poppler COMPONENTS Qt5)
find_package(DevIL)

####################################
#### TRANSLATIONS AND RESOURCES ####
####################################

# We first copy the most recent *.ts files to the build directory and then process them
# This way, we don't have to mess with files outside of the build folder

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/buildlang)
file(GLOB files "lang/*.ts")
foreach(file ${files})
   get_filename_component(filename ${file} NAME)
   file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/lang/${filename} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/buildlang)
   qt5_create_translation(qm_files ${photoqt_SOURCES} ${photoqt_QML} ${CMAKE_CURRENT_BINARY_DIR}/buildlang/${filename} OPTIONS "-no-obsolete")
endforeach()

# Copy the language QRC file to the output directory, because the files listed in the
# qrc file are relative to that directory.
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/lang.qrc ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc
    MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/lang.qrc
    DEPENDS ${qm_files})

# Add the resource files
qt5_add_resources(RESOURCES ${photoqt_RESOURCES})


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
    add_executable(${PROJECT_NAME} WIN32 ${photoqt_SOURCES} ${photoqt_QML} ${RESOURCES} windowsicons.rc)
    qt5_use_modules(${PROJECT_NAME} Quick Sql Svg Core Xml WinExtras)
elseif(NOT WIN32)
    add_executable(${PROJECT_NAME} ${photoqt_SOURCES} ${photoqt_QML} ${RESOURCES})
    qt5_use_modules(${PROJECT_NAME} Quick Sql Svg Core Xml)
endif(WIN32)

# We need to link to zlib for zip support
target_link_libraries(${PROJECT_NAME} "z")


########################
#### HANDLE TESTING ####
########################

if(TESTING)

    # Set the testing project name
    set(PROJECT_TEST_NAME ${PROJECT_NAME}_test)

    # Enable testing and fint the required test package
    enable_testing()
    find_package(Qt5Test REQUIRED)

    # Add the test executable and mark
    add_executable(${PROJECT_TEST_NAME} ${photoqt_TESTING})
    add_test(${PROJECT_TEST_NAME} ${PROJECT_TEST_NAME})
    qt5_use_modules(${PROJECT_TEST_NAME} Quick Core Widgets)

    # link against the testing library
    target_link_libraries(${PROJECT_TEST_NAME} Qt5::Test)

    # And inform the user
    message("** TESTING ENABLED")

endif(TESTING)


#######################################
#### EMPLY THE PROPER DESKTOP FILE ####
#######################################

if(GM)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/for_photoqt_desktop_FULL ${CMAKE_CURRENT_SOURCE_DIR}/photoqt.desktop)
elseif(NOT GM)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/for_photoqt_desktop_QT ${CMAKE_CURRENT_SOURCE_DIR}/photoqt.desktop)
endif(GM)


########################
#### CUSTOM OPTIONS ####
########################

if(POPPLER)
    if(NOT ${Poppler_FOUND})
        message(FATAL_ERROR "** Unable to locate Poppler... is it installed?")
    elseif(${Poppler_FOUND})
        include_directories(${Poppler_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} ${Poppler_LIBRARIES})
        message("** Poppler enabled")
        add_definitions(-DPOPPLER)
    endif(NOT ${Poppler_FOUND})
elseif(NOT POPPLER)
    message("** Poppler DISABLED")
endif(POPPLER)

if(DEVIL)
    if(NOT ${IL_FOUND})
        message(FATAL_ERROR "** Unable to locate DevIL... is it installed?")
    elseif(${IL_FOUND})
        include_directories(${IL_INCLUDE_DIR})
        target_link_libraries(${PROJECT_NAME} ${IL_LIBRARIES})
        message("** DevIL enabled")
        add_definitions(-DDEVIL)
    endif(NOT ${IL_FOUND})
elseif(NOT DEVIL)
    message("** DevIL DISABLED")
endif(DEVIL)

if(FREEIMAGE)
    if(NOT ${FREEIMAGE_FOUND})
        message(FATAL_ERROR "** Unable to locate FreeImage... is it installed?")
    elseif(${FREEIMAGE_FOUND})
        include_directories(${FREEIMAGE_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} ${FREEIMAGE_LIBRARIES})
        message("** FreeImage enabled")
        add_definitions(-DFREEIMAGE)
    endif(NOT ${FREEIMAGE_FOUND})
elseif(NOT FREEIMAGE)
    message("** FreeImage DISABLED")
endif(FREEIMAGE)

if(RAW)
    if(NOT ${LIBRAW_FOUND})
        message(FATAL_ERROR "** Unable to locate LibRaw... is it installed?")
    elseif(${LIBRAW_FOUND})
        include_directories(${LIBRAW_INCLUDE_DIR})
        target_link_libraries(${PROJECT_NAME} "raw")
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
        target_link_libraries(${PROJECT_NAME} "exiv2")
        if(TESTING)
            target_link_libraries(${PROJECT_TEST_NAME} "exiv2")
        endif(TESTING)
        if(WIN32)
            target_link_libraries(${PROJECT_NAME} "expat")
            target_link_libraries(${PROJECT_NAME} "ws2_32")
            target_link_libraries(${PROJECT_NAME} "wsock32")
            target_link_libraries(${PROJECT_NAME} "z")
            target_link_libraries(${PROJECT_NAME} "intl")
            target_link_libraries(${PROJECT_NAME} "iconv")
            target_link_libraries(${PROJECT_NAME} "psapi")
            if(TESTING)
                target_link_libraries(${PROJECT_TEST_NAME} "expat")
                target_link_libraries(${PROJECT_TEST_NAME} "ws2_32")
                target_link_libraries(${PROJECT_TEST_NAME} "wsock32")
                target_link_libraries(${PROJECT_TEST_NAME} "z")
                target_link_libraries(${PROJECT_TEST_NAME} "intl")
                target_link_libraries(${PROJECT_TEST_NAME} "iconv")
                target_link_libraries(${PROJECT_TEST_NAME} "psapi")
            endif(TESTING)
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
        target_link_libraries(${PROJECT_NAME} "GraphicsMagick++")
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
endif(UNIX)



##########################
#### UNINSTALL TARGET ####
##########################

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/CMake/cmake_uninstall.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY)
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

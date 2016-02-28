##################################################
# CMakeLists for PhotoQt-QML: http://photoqt.org #
##################################################

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
PROJECT(photoqt)


##################################################################
####  GLOBAL VERSION STRING FOR ALL FILES (INCLUDING CPP/QML) ####
##################################################################
ADD_DEFINITIONS(-DVERSION="devel")


###########################################
####  LOCATIONS OF CONFIGURATION/DATA  ####
###########################################

SET(CONFIG_DIR "$ENV{HOME}/.config/PhotoQt")
SET(DATA_DIR "$ENV{HOME}/.local/share/PhotoQt/")
SET(CACHE_DIR "$ENV{HOME}/.cache/PhotoQt/")
ADD_DEFINITIONS(-DCONFIG_DIR="${CONFIG_DIR}")
ADD_DEFINITIONS(-DDATA_DIR="${DATA_DIR}")
ADD_DEFINITIONS(-DCACHE_DIR="${CACHE_DIR}")

ADD_DEFINITIONS(-DCFG_SETTINGS_FILE="${CONFIG_DIR}/settings")
ADD_DEFINITIONS(-DCFG_CONTEXTMENU_FILE="${CONFIG_DIR}/contextmenu")
ADD_DEFINITIONS(-DCFG_FILEFORMATS_FILE="${CONFIG_DIR}/fileformats.disabled")
ADD_DEFINITIONS(-DCFG_SHORTCUTS_FILE="${CONFIG_DIR}/shortcuts")
ADD_DEFINITIONS(-DCFG_SHORTCUTSNOTIFIER_FILE="${CONFIG_DIR}/shortcutsnotifier")
ADD_DEFINITIONS(-DCFG_THUMBNAILS_DB="${CACHE_DIR}/thumbnails")
ADD_DEFINITIONS(-DCFG_SEETINGS_SESSION_FILE="${CONFIG_DIR}/settings_session")
ADD_DEFINITIONS(-DCFG_MAINWINDOW_GEOMETRY_FILE="${CONFIG_DIR}/geometry")


#############################
####  GET list of files  ####
#############################

# Prepare variables
SET(photoqt_SOURCES)
SET(photoqt_HEADERS)

# Get list of files
INCLUDE(CMake/ListFilesCPlusPlus.cmake)
INCLUDE(CMake/ListFilesQML.cmake)


#############################################
#### OPTIONS THAT CAN BE SET BY THE USER ####
#############################################

OPTION(EXIV2 "Use exiv2 library" ON)
OPTION(GM "Use graphicsmagick library" ON)
OPTION(QTONLY "ONLY USE QT-ONLY FEATURES" OFF)


###############################
#### ENABLE C++11 FEATURES ####
###############################

SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -O3")


################################
#### FIND REQUIRED PACKAGES ####
################################

FIND_PACKAGE(Qt5 COMPONENTS LinguistTools Quick Widgets Core Svg REQUIRED)
SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
FIND_PACKAGE(Magick)
FIND_PACKAGE(Exiv2)

SET(CMAKE_BUILD_TYPE "Debug")


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

# Set resources
SET(photoqt_RESOURCES)
INCLUDE(CMake/ListFilesResources.cmake)
QT5_ADD_RESOURCES(RESOURCES ${photoqt_RESOURCES})


######################
#### FINISHING UP ####
######################

# moc files
QT5_WRAP_CPP(photoqt_HEADERS_MOC ${photoqt_HEADERS})

# include, add defiunitions and include dirs
INCLUDE_DIRECTORIES(${Qt5Widgets_INCLUDES})
ADD_DEFINITIONS(${Qt5Widgets_DEFINITIONS})
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR})

# And add the executeable (on windows we add application icons...)
IF(WIN32)
	ADD_EXECUTABLE(photoqt WIN32 ${photoqt_SOURCES} ${photoqt_HEADERS_MOC} ${RESOURCES} windowsicons.rc)
ELSEIF(NOT WIN32)
	ADD_EXECUTABLE(photoqt ${photoqt_SOURCES} ${photoqt_HEADERS_MOC} ${RESOURCES})
ENDIF(WIN32)
QT5_USE_MODULES(photoqt Quick Widgets Sql Svg Core Xml)

#Depending on setup, we copy one of the desktop files to photoqt.desktop
IF(GM)
	ADD_CUSTOM_COMMAND(TARGET photoqt POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/for_photoqt_desktop_FULL ${CMAKE_CURRENT_SOURCE_DIR}/photoqt.desktop)
ELSEIF(NOT GM)
	ADD_CUSTOM_COMMAND(TARGET photoqt POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/for_photoqt_desktop_QT ${CMAKE_CURRENT_SOURCE_DIR}/photoqt.desktop)
ENDIF(GM)


MESSAGE("")


########################
#### CUSTOM OPTIONS ####
########################

IF(EXIV2)
	IF(NOT ${EXIV2_FOUND})
		MESSAGE(FATAL_ERROR "** Unable to locate Exiv2... is it installed?")
	ELSEIF(${EXIV2_FOUND})
		INCLUDE_DIRECTORIES(${EXIV2_INCLUDE_DIR})
		TARGET_LINK_LIBRARIES(photoqt "exiv2")
		IF(WIN32)
			TARGET_LINK_LIBRARIES(photoqt "expat")
			TARGET_LINK_LIBRARIES(photoqt "ws2_32")
			TARGET_LINK_LIBRARIES(photoqt "wsock32")
			TARGET_LINK_LIBRARIES(photoqt "z")
			TARGET_LINK_LIBRARIES(photoqt "intl")
			TARGET_LINK_LIBRARIES(photoqt "iconv")
			TARGET_LINK_LIBRARIES(photoqt "psapi")
		ENDIF(WIN32)
		ADD_DEFINITIONS(-DEXIV2)
		MESSAGE("** Exiv2 enabled")
	ENDIF(NOT ${EXIV2_FOUND})
ELSEIF(NOT EXIV2)
	MESSAGE("** Exiv2 DISABLED")
ENDIF(EXIV2)

IF(GM)
	IF(NOT ${MAGICK++_FOUND})
		MESSAGE(FATAL_ERROR "** Unable to locate GraphicsMagick... is it installed?")
	ELSEIF(${MAGICK++_FOUND})
		INCLUDE_DIRECTORIES(${MAGICK++_INCLUDE_DIR})
		TARGET_LINK_LIBRARIES(photoqt "GraphicsMagick++")
		ADD_DEFINITIONS(-DGM)
		MESSAGE("** Graphicsmagick enabled")
	ENDIF(NOT ${MAGICK++_FOUND})
ELSEIF(NOT GM)
	MESSAGE("** Graphicsmagick DISABLED")
ENDIF(GM)


#######################
#### INSTALL FILES ####
#######################

IF(UNIX)

	# Set the install prefix to /usr/
	SET(PRODUCT_INSTALL_PREFIX /usr)

	# Install executeable
	INSTALL(
		TARGETS photoqt
		DESTINATION bin/
	)

	# Install desktop file
	INSTALL(
		FILES photoqt.desktop
		DESTINATION share/applications
	)

	# And install all the icons
	INSTALL(
		FILES icons/16x16/apps/photoqt.png
		DESTINATION share/icons/hicolor/16x16/apps/
	)
	INSTALL(
		FILES icons/32x32/apps/photoqt.png
		DESTINATION share/icons/hicolor/32x32/apps/
	)
	INSTALL(
		FILES icons/48x48/apps/photoqt.png
		DESTINATION share/icons/hicolor/48x48/apps/
	)
	INSTALL(
		FILES icons/64x64/apps/photoqt.png
		DESTINATION share/icons/hicolor/64x64/apps/
	)
	INSTALL(
		FILES icons/128x128/apps/photoqt.png
		DESTINATION share/icons/hicolor/128x128/apps/
	)
ENDIF(UNIX)



##########################
#### UNINSTALL TARGET ####
##########################

CONFIGURE_FILE("${CMAKE_CURRENT_SOURCE_DIR}/CMake/cmake_uninstall.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY)
ADD_CUSTOM_TARGET(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)



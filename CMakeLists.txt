##################################################
# CMakeLists for PhotoQt-QML: http://photoqt.org #
##################################################

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
PROJECT(photoqt)

#### SOURCES ####
SET(photoqt_SOURCES cplusplus/main.cpp cplusplus/mainwindow.cpp cplusplus/variables.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/handlefiles/loaddir.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/imageprovider/imageproviderfull.cpp cplusplus/imageprovider/imageproviderthumbnail.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getstuff.cpp cplusplus/scripts/getmetadata.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/settings/settings.h cplusplus/settings/settingssession.h cplusplus/settings/fileformats.h)

SET(photoqt_SOURCES ${photoqt_SOURCES} qml/mainwindow.qml qml/Shortcuts.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/slidein/ThumbnailBar.qml qml/slidein/MetaData.qml qml/slidein/MainMenu.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/mainview/Background.qml qml/mainview/Display.qml qml/mainview/QuickInfo.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/elements/ScrollBarHorizontal.qml qml/elements/ScrollBarVertical.qml qml/elements/CustomCheckBox.qml qml/elements/CustomButton.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/fadein/About.qml)

#### HEADER ####
SET(photoqt_HEADERS cplusplus/mainwindow.h cplusplus/variables.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/handlefiles/loaddir.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/imageprovider/imageproviderthumbnail.h cplusplus/imageprovider/imageproviderfull.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getstuff.h cplusplus/scripts/getmetadata.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/settings/settings.h cplusplus/settings/settingssession.h cplusplus/settings/fileformats.h)


#############################################
#### OPTIONS THAT CAN BE SET BY THE USER ####
#############################################

OPTION(EXIV2 "Use exiv2 library" ON)
OPTION(GM "Use graphicsmagick library" ON)
OPTION(QTONLY "ONLY USE QT-ONLY FEATURES" OFF)


################################
#### FIND REQUIRED PACKAGES ####
################################

FIND_PACKAGE(Qt5 COMPONENTS Quick Widgets Core Svg REQUIRED)
SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
FIND_PACKAGE(Magick)
FIND_PACKAGE(Exiv2)

SET(CMAKE_BUILD_TYPE "Debug")


####################################
#### TRANSLATIONS AND RESOURCES ####
####################################

# Set resources
SET(photoqt_RESOURCES qml.qrc img.qrc)
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

# And add the executeable
add_executable(photoqt ${photoqt_SOURCES} ${photoqt_HEADERS_MOC} ${RESOURCES})
qt5_use_modules(photoqt Quick Widgets Sql Svg Core)

IF(EXIV2)
	IF(NOT ${EXIV2_FOUND})
		MESSAGE(FATAL_ERROR "** Unable to locate Exiv2... is it installed?")
	ELSEIF(${EXIV2_FOUND})
		INCLUDE_DIRECTORIES(${EXIV2_INCLUDE_DIR})
		TARGET_LINK_LIBRARIES(photoqt "exiv2")
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




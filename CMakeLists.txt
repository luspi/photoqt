##################################################
# CMakeLists for PhotoQt-QML: http://photoqt.org #
##################################################

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
PROJECT(photoqt)


##################################################################
####  GLOBAL VERSION STRING FOR ALL FILES (INCLUDING CPP/QML) ####
##################################################################
ADD_DEFINITIONS(-DVERSION="1.2")


#### SOURCES ####
SET(photoqt_SOURCES cplusplus/main.cpp cplusplus/mainwindow.cpp cplusplus/variables.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/handlefiles/loaddir.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/imageprovider/imageproviderfull.cpp cplusplus/imageprovider/imageproviderthumbnail.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getanddostuff.h cplusplus/scripts/getmetadata.cpp cplusplus/scripts/runprocess.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/thumbnailsmanagement.cpp cplusplus/shortcuts/shortcuts.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/settings/settings.h cplusplus/settings/settingssession.h cplusplus/settings/fileformats.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getanddostuff/context.cpp cplusplus/scripts/getanddostuff/external.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getanddostuff/manipulation.cpp cplusplus/scripts/getanddostuff/file.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getanddostuff/other.cpp cplusplus/scripts/getanddostuff/shortcuts.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getanddostuff/wallpaper.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/singleinstance/singleinstance.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} javascript/keydetect.js)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/mainwindow.qml qml/Shortcuts.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/slidein/ThumbnailBar.qml qml/slidein/MetaData.qml qml/slidein/MainMenu.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/slidein/QuickSettings.qml qml/slidein/SlideshowBar.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/mainview/Background.qml qml/mainview/Display.qml qml/mainview/QuickInfo.qml qml/mainview/ContextMenu.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/mainview/TransitionImage.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/mainview/ContextMenuEntry.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/elements/ScrollBarHorizontal.qml qml/elements/ScrollBarVertical.qml qml/elements/SettingsText.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/elements/CustomCheckBox.qml qml/elements/CustomButton.qml qml/elements/CustomTabView.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/elements/CustomComboBox.qml qml/elements/CustomRadioButton.qml qml/elements/CustomSlider.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/elements/CustomSpinBox.qml qml/elements/CustomConfirm.qml qml/elements/CustomTextEdit.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/elements/CustomDetectShortcut.qml qml/elements/CustomMouseShortcut.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/elements/CustomExternalCommand.qml qml/elements/CustomLineEdit.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/fadein/About.qml qml/fadein/Scale.qml qml/fadein/Rename.qml qml/fadein/Delete.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/fadein/Wallpaper.qml qml/fadein/Slideshow.qml qml/fadein/Filter.qml qml/fadein/Startup.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/settings/SettingsItem.qml qml/settings/TabDetailsTile.qml qml/settings/TabOtherLanguageTiles.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/settings/TabLookAndFeelBasic.qml qml/settings/TabLookAndFeelAdvanced.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/settings/TabOtherContext.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/settings/TabFiletypesTiles.qml qml/settings/TabShortcutsCategories.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/settings/TabShortcutsTilesSet.qml qml/settings/TabShortcutsTilesAvail.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/settings/TabThumbnailsBasic.qml qml/settings/TabThumbnailsAdvanced.qml qml/settings/TabShortcuts.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/settings/TabDetails.qml qml/settings/TabOther.qml qml/settings/TabFiletypes.qml)

#### HEADER ####
SET(photoqt_HEADERS cplusplus/mainwindow.h cplusplus/variables.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/handlefiles/loaddir.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/imageprovider/imageproviderthumbnail.h cplusplus/imageprovider/imageproviderfull.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getanddostuff.h cplusplus/scripts/getmetadata.h cplusplus/scripts/runprocess.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/thumbnailsmanagement.h cplusplus/shortcuts/shortcuts.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getanddostuff/context.h cplusplus/scripts/getanddostuff/external.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getanddostuff/manipulation.h cplusplus/scripts/getanddostuff/file.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getanddostuff/other.h cplusplus/scripts/getanddostuff/shortcuts.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getanddostuff/wallpaper.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/singleinstance/singleinstance.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/settings/settings.h cplusplus/settings/settingssession.h cplusplus/settings/fileformats.h)


#############################################
#### OPTIONS THAT CAN BE SET BY THE USER ####
#############################################

OPTION(EXIV2 "Use exiv2 library" ON)
OPTION(GM "Use graphicsmagick library" ON)
OPTION(QTONLY "ONLY USE QT-ONLY FEATURES" OFF)
OPTION(C11 "Enable C++11 features (recommended!)" ON)


###############################
#### ENABLE C++11 FEATURES ####
###############################

IF(C11)
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
	ADD_DEFINITIONS(-DC11)
ELSEIF(NOT C11)
	MESSAGE(WARNING "C++11 HAS BEEN DISABLED! It is highly recommended to keep it ENABLED, as some things might not quite work as expected!")
ENDIF(C11)


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




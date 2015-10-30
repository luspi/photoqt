##################################################
# CMakeLists for PhotoQt-QML: http://photoqt.org #
##################################################

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
PROJECT(photoqt)


##################################################################
####  GLOBAL VERSION STRING FOR ALL FILES (INCLUDING CPP/QML) ####
##################################################################
ADD_DEFINITIONS(-DVERSION="1.3")


#### SOURCES ####
SET(photoqt_SOURCES cplusplus/main.cpp cplusplus/mainwindow.cpp cplusplus/variables.h cplusplus/logger.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/handlefiles/loaddir.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/imageprovider/imageproviderfull.cpp cplusplus/imageprovider/imageproviderthumbnail.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getanddostuff.h cplusplus/scripts/getmetadata.cpp cplusplus/scripts/runprocess.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/thumbnailsmanagement.cpp cplusplus/shortcuts/shortcuts.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/settings/settings.h cplusplus/settings/settingssession.h cplusplus/settings/fileformats.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getanddostuff/context.cpp cplusplus/scripts/getanddostuff/external.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getanddostuff/manipulation.cpp cplusplus/scripts/getanddostuff/file.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getanddostuff/other.cpp cplusplus/scripts/getanddostuff/shortcuts.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/scripts/getanddostuff/wallpaper.cpp cplusplus/scripts/gmimagemagick.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/singleinstance/singleinstance.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/mainwindow.qml qml/Shortcuts.qml qml/Colour.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/slidein/ThumbnailBar.qml qml/slidein/MetaData.qml qml/slidein/MainMenu.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/slidein/QuickSettings.qml qml/slidein/SlideshowBar.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/mainview/Background.qml qml/mainview/QuickInfo.qml qml/mainview/ContextMenu.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} qml/mainview/ContextMenuEntry.qml qml/mainview/SmartImage.qml qml/mainview/MainView.qml)
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
SET(photoqt_HEADERS cplusplus/mainwindow.h cplusplus/variables.h cplusplus/logger.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/handlefiles/loaddir.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/imageprovider/imageproviderthumbnail.h cplusplus/imageprovider/imageproviderfull.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getanddostuff.h cplusplus/scripts/getmetadata.h cplusplus/scripts/runprocess.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/thumbnailsmanagement.h cplusplus/shortcuts/shortcuts.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getanddostuff/context.h cplusplus/scripts/getanddostuff/external.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getanddostuff/manipulation.h cplusplus/scripts/getanddostuff/file.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getanddostuff/other.h cplusplus/scripts/getanddostuff/shortcuts.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/scripts/getanddostuff/wallpaper.h cplusplus/scripts/gmimagemagick.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/singleinstance/singleinstance.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} cplusplus/settings/settings.h cplusplus/settings/settingssession.h cplusplus/settings/fileformats.h)


#############################################
#### OPTIONS THAT CAN BE SET BY THE USER ####
#############################################

OPTION(EXIV2 "Use exiv2 library" ON)
OPTION(GM "Use graphicsmagick library" ON)
OPTION(QTONLY "ONLY USE QT-ONLY FEATURES" OFF)


###############################
#### ENABLE C++11 FEATURES ####
###############################

SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")


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

FILE(GLOB files "lang/*.ts")
FOREACH(file ${files})
	QT5_CREATE_TRANSLATION(qm_files ${photoqt_SOURCES} ${file} OPTIONS "-no-obsolete")
ENDFOREACH()

# Copy the language QRC file to the output directory, because the files listed in the
# qrc file are relative to that directory.
ADD_CUSTOM_COMMAND(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc
		   COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/lang.qrc ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc
		   MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/lang.qrc
		   DEPENDS ${qm_files})

# Set resources
SET(photoqt_RESOURCES qml.qrc img.qrc ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc)
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
QT5_USE_MODULES(photoqt Quick Widgets Sql Svg Core)

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



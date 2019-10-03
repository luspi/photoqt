#####################
#### QML SOURCES ####
#####################

SET(d "qml")
SET(photoqt_QML ${photoqt_QML} ${d}/mainwindow.qml ${d}/PQLoader.qml ${d}/PQVariables.qml ${d}/loadfiles.js)

SET(d "qml/mainwindow")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImage.qml ${d}/PQQuickInfo.qml ${d}/PQCloseButton.qml ${d}/PQThumbnailBar.qml ${d}/PQSystemTrayIcon.qml)

SET(d "qml/mainwindow/image")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImageNormal.qml ${d}/PQImageAnimated.qml ${d}/PQLoading.qml ${d}/PQMovie.qml ${d}/PQFaceTracker.qml ${d}/PQFaceTagger.qml)

SET(d "qml/elements")
SET(photoqt_QML ${photoqt_QML} ${d}/PQSlider.qml ${d}/PQCheckbox.qml ${d}/PQButton.qml ${d}/PQMenu.qml ${d}/PQMenuItem.qml ${d}/PQToolTip.qml ${d}/PQMouseArea.qml ${d}/PQComboBox.qml ${d}/PQScrollBar.qml ${d}/PQSpinBox.qml ${d}/PQLineEdit.qml ${d}/PQProgress.qml ${d}/PQRadioButton.qml)

SET(d "qml/shortcuts")
SET(photoqt_QML ${photoqt_QML} ${d}/PQKeyShortcuts.qml ${d}/PQMouseShortcuts.qml ${d}/handleshortcuts.js)

SET(d "qml/filedialog")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFileDialog.qml ${d}/PQFileDialogPopout.qml)

SET(d "qml/filedialog/parts")
SET(photoqt_QML ${photoqt_QML} ${d}/PQPlaces.qml ${d}/PQDevices.qml ${d}/PQFileView.qml ${d}/PQStandard.qml ${d}/PQTweaks.qml ${d}/PQBreadCrumbs.qml ${d}/PQPreview.qml ${d}/PQRightClickMenu.qml)

SET(d "qml/menumeta")
SET(photoqt_QML ${photoqt_QML} ${d}/PQMainMenu.qml ${d}/PQMainMenuPopout.qml ${d}/PQMetaData.qml ${d}/PQMetaDataPopout.qml)

SET(d "qml/histogram")
SET(photoqt_QML ${photoqt_QML} ${d}/PQHistogram.qml ${d}/PQHistogramPopout.qml)

SET(d "qml/slideshow")
SET(photoqt_QML ${photoqt_QML} ${d}/PQSlideShowSettings.qml ${d}/PQSlideShowSettingsPopout.qml ${d}/PQSlideShowControls.qml ${d}/PQSlideShowControlsPopout.qml)

SET(d "qml/filemanagement")
SET(photoqt_QML ${photoqt_QML} ${d}/PQRename.qml ${d}/PQRenamePopout.qml ${d}/PQDelete.qml ${d}/PQDeletePopout.qml)

SET(d "qml/scale")
SET(photoqt_QML ${photoqt_QML} ${d}/PQScale.qml ${d}/PQScalePopout.qml)

SET(d "qml/about")
SET(photoqt_QML ${photoqt_QML} ${d}/PQAbout.qml ${d}/PQAboutPopout.qml)

SET(d "qml/imgur")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImgur.qml ${d}/PQImgurPopout.qml)

SET(d "qml/wallpaper")
SET(photoqt_QML ${photoqt_QML} ${d}/PQWallpaper.qml ${d}/PQWallpaperPopout.qml)

SET(d "qml/wallpaper/ele")
SET(photoqt_QML ${photoqt_QML} ${d}/PQPlasma.qml ${d}/PQGnome.qml ${d}/PQXfce.qml ${d}/PQEnlightenment.qml ${d}/PQOther.qml)

SET(d "qml/filter")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFilter.qml ${d}/PQFilterPopout.qml)

#####################
#### QML SOURCES ####
#####################

SET(d "qml")
SET(photoqt_QML ${photoqt_QML} ${d}/mainwindow.qml ${d}/PQLoader.qml ${d}/PQVariables.qml ${d}/loadfiles.js)

SET(d "qml/mainwindow")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImage.qml ${d}/PQQuickInfo.qml ${d}/PQCloseButton.qml ${d}/PQThumbnailBar.qml ${d}/PQMessage.qml)

SET(d "qml/mainwindow/image")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImageNormal.qml ${d}/PQImageAnimated.qml ${d}/PQLoading.qml ${d}/PQMovie.qml ${d}/PQFaceTracker.qml ${d}/PQFaceTagger.qml)

SET(d "qml/elements")
SET(photoqt_QML ${photoqt_QML} ${d}/PQSlider.qml ${d}/PQCheckbox.qml ${d}/PQButton.qml ${d}/PQMenu.qml ${d}/PQToolTip.qml ${d}/PQMouseArea.qml ${d}/PQComboBox.qml ${d}/PQScrollBar.qml ${d}/PQSpinBox.qml ${d}/PQLineEdit.qml ${d}/PQProgress.qml ${d}/PQRadioButton.qml ${d}/PQTabButton.qml ${d}/PQSetting.qml ${d}/PQTile.qml ${d}/PQHorizontalLine.qml)

SET(d "qml/shortcuts")
SET(photoqt_QML ${photoqt_QML} ${d}/PQKeyShortcuts.qml ${d}/PQMouseShortcuts.qml ${d}/handleshortcuts.js ${d}/PQKeyMouseStrings.qml ${d}/mouseshortcuts.js)

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

SET(d "qml/settingsmanager")
SET(photoqt_QML ${photoqt_QML} ${d}/PQSettingsManager.qml ${d}/PQSettingsManagerPopout.qml)

SET(d "qml/settingsmanager/tabs")
SET(photoqt_QML ${photoqt_QML} ${d}/PQTabInterface.qml ${d}/PQTabImageView.qml ${d}/PQTabThumbnails.qml ${d}/PQTabMetadata.qml ${d}/PQTabFileTypes.qml ${d}/PQTabShortcuts.qml ${d}/PQTabManageSettings.qml)

SET(d "qml/settingsmanager/tabs/interface")
SET(photoqt_QML ${photoqt_QML} ${d}/PQHotEdgeWidth.qml ${d}/PQWindowManagement.qml ${d}/PQMouseWheel.qml ${d}/PQOverlayColor.qml ${d}/PQPopout.qml ${d}/PQQuickInfo.qml ${d}/PQBackground.qml ${d}/PQCloseOnEmpty.qml ${d}/PQLanguage.qml ${d}/PQStartupLoadLast.qml ${d}/PQTrayIcon.qml ${d}/PQWindowMode.qml)

SET(d "qml/settingsmanager/tabs/imageview")
SET(photoqt_QML ${photoqt_QML} ${d}/PQAnimation.qml ${d}/PQFitInWindow.qml ${d}/PQInterpolation.qml ${d}/PQKeep.qml ${d}/PQLeftButton.qml ${d}/PQLoop.qml ${d}/PQMargin.qml ${d}/PQPixmapCache.qml ${d}/PQSort.qml ${d}/PQTransparencyMarker.qml ${d}/PQZoomSpeed.qml)

SET(d "qml/settingsmanager/tabs/thumbnails")
SET(photoqt_QML ${photoqt_QML} ${d}/PQCache.qml ${d}/PQCenter.qml ${d}/PQDisable.qml ${d}/PQFilenameOnly.qml ${d}/PQFilenameLabel.qml ${d}/PQLiftUp.qml ${d}/PQPosition.qml ${d}/PQSize.qml ${d}/PQSpacing.qml ${d}/PQThreads.qml ${d}/PQVisible.qml)

SET(d "qml/settingsmanager/tabs/metadata")
SET(photoqt_QML ${photoqt_QML} ${d}/PQHotEdge.qml ${d}/PQOpacity.qml ${d}/PQRotation.qml ${d}/PQGPSMap.qml ${d}/PQMetaData.qml ${d}/PQFaceTags.qml ${d}/PQFaceTagsFontSize.qml ${d}/PQFaceTagsBorder.qml ${d}/PQFaceTagsVisibility.qml)

SET(d "qml/settingsmanager/tabs/filetypes")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFileTypeTile.qml ${d}/PQAdvancedTuning.qml ${d}/PQFileTypeTileQt.qml ${d}/PQFileTypeTileLibArchive.qml ${d}/PQFileTypeTileLibRaw.qml ${d}/PQFileTypeTileGm.qml ${d}/PQFileTypeTileDevil.qml ${d}/PQFileTypeTileFreeImage.qml ${d}/PQFileTypeTilePoppler.qml ${d}/PQFileTypeTileXCF.qml ${d}/PQFileTypeTileVideo.qml)

SET(d "qml/settingsmanager/tabs/shortcuts")
SET(photoqt_QML ${photoqt_QML} ${d}/PQAvailableCommands.qml ${d}/PQActiveShortcuts.qml ${d}/PQContainer.qml ${d}/PQDetectCombo.qml)

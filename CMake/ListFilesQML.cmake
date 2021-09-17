#####################
#### QML SOURCES ####
#####################

SET(d "qml")
SET(photoqt_QML ${photoqt_QML} ${d}/mainwindow.qml ${d}/PQLoader.qml ${d}/PQVariables.qml ${d}/PQModel.qml ${d}/PQTrayIcon.qml ${d}/PQCmdReceived.qml)

SET(d "qml/mainwindow")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImage.qml ${d}/PQWindowButtons.qml ${d}/PQThumbnailBar.qml ${d}/PQMessage.qml ${d}/PQLoading.qml ${d}/PQLabels.qml ${d}/PQNavigation.qml ${d}/PQContextMenu.qml)

SET(d "qml/mainwindow/image")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImageNormal.qml ${d}/PQImageAnimated.qml ${d}/PQMovie.qml ${d}/PQFaceTracker.qml ${d}/PQFaceTagger.qml ${d}/PQFaceTagsUnsupported.qml)

SET(d "qml/elements")
SET(photoqt_QML ${photoqt_QML} ${d}/PQSlider.qml ${d}/PQCheckbox.qml ${d}/PQButton.qml ${d}/PQMenu.qml ${d}/PQToolTip.qml ${d}/PQMouseArea.qml ${d}/PQComboBox.qml ${d}/PQScrollBar.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQSpinBox.qml ${d}/PQLineEdit.qml ${d}/PQProgress.qml ${d}/PQRadioButton.qml ${d}/PQTabButton.qml ${d}/PQSetting.qml ${d}/PQTile.qml ${d}/PQHorizontalLine.qml)

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
SET(photoqt_QML ${photoqt_QML} ${d}/PQRename.qml ${d}/PQRenamePopout.qml ${d}/PQDelete.qml ${d}/PQDeletePopout.qml ${d}/PQCopyMove.qml ${d}/PQSaveAs.qml ${d}/PQSaveAsPopout.qml)

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
SET(photoqt_QML ${photoqt_QML} ${d}/PQSettingsManager.qml ${d}/PQSettingsManagerPopout.qml ${d}/PQRestoreDefaults.qml)

SET(d "qml/settingsmanager/tabs")
SET(photoqt_QML ${photoqt_QML} ${d}/PQTabInterface.qml ${d}/PQTabImageView.qml ${d}/PQTabThumbnails.qml ${d}/PQTabMetadata.qml ${d}/PQTabFileTypes.qml ${d}/PQTabShortcuts.qml)

SET(d "qml/settingsmanager/tabs/interface")
SET(photoqt_QML ${photoqt_QML} ${d}/PQHotEdgeWidth.qml ${d}/PQWindowManagement.qml ${d}/PQMouseWheel.qml ${d}/PQOverlayColor.qml ${d}/PQPopout.qml ${d}/PQLabels.qml ${d}/PQBackground.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQCloseOnEmpty.qml ${d}/PQLanguage.qml ${d}/PQStartupLoadLast.qml ${d}/PQTrayIcon.qml ${d}/PQWindowMode.qml ${d}/PQContextMenu.qml ${d}/PQNavigation.qml)

SET(d "qml/settingsmanager/tabs/imageview")
SET(photoqt_QML ${photoqt_QML} ${d}/PQAnimation.qml ${d}/PQFitInWindow.qml ${d}/PQInterpolation.qml ${d}/PQKeep.qml ${d}/PQLeftButton.qml ${d}/PQLoop.qml ${d}/PQMargin.qml ${d}/PQPixmapCache.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQSort.qml ${d}/PQTransparencyMarker.qml ${d}/PQZoomSpeed.qml ${d}/PQZoomSmallerDefault.qml)

SET(d "qml/settingsmanager/tabs/thumbnails")
SET(photoqt_QML ${photoqt_QML} ${d}/PQCache.qml ${d}/PQCenter.qml ${d}/PQDisable.qml ${d}/PQFilenameOnly.qml ${d}/PQFilenameLabel.qml ${d}/PQLiftUp.qml ${d}/PQPosition.qml ${d}/PQSize.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQSpacing.qml ${d}/PQThreads.qml ${d}/PQVisible.qml)

SET(d "qml/settingsmanager/tabs/metadata")
SET(photoqt_QML ${photoqt_QML} ${d}/PQHotEdge.qml ${d}/PQOpacity.qml ${d}/PQRotation.qml ${d}/PQGPSMap.qml ${d}/PQMetaData.qml ${d}/PQFaceTags.qml ${d}/PQFaceTagsFontSize.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQFaceTagsBorder.qml ${d}/PQFaceTagsVisibility.qml)

SET(d "qml/settingsmanager/tabs/filetypes")
SET(photoqt_QML ${photoqt_QML} ${d}/PQVideo.qml ${d}/PQPoppler.qml ${d}/PQLibArchive.qml ${d}/PQFileTypes.qml)

SET(d "qml/settingsmanager/tabs/shortcuts")
SET(photoqt_QML ${photoqt_QML} ${d}/PQContainer.qml ${d}/PQShortcutTile.qml ${d}/PQNewShortcut.qml ${d}/PQExternalContainer.qml ${d}/PQExternalShortcutTile.qml)

SET(d "qml/welcome")
SET(photoqt_QML ${photoqt_QML} ${d}/PQWelcome.qml)

SET(d "qml/unavailable")
SET(photoqt_QML ${photoqt_QML} ${d}/PQUnavailable.qml ${d}/PQUnavailablePopout.qml)

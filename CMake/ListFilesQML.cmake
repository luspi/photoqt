#####################
#### QML SOURCES ####
#####################

SET(d "qml")
SET(photoqt_QML ${photoqt_QML} ${d}/mainwindow.qml ${d}/Caller.qml)

SET(d "qml/vars")
SET(photoqt_QML ${photoqt_QML} ${d}/Variables.qml ${d}/StringsKeys.qml ${d}/StringsMouse.qml)

SET(d "qml/mainview")
SET(photoqt_QML ${photoqt_QML} ${d}/Background.qml ${d}/MainImage.qml ${d}/MainImageRectangle.qml ${d}/Thumbnails.qml)

SET(d "qml/shortcuts")
SET(photoqt_QML ${photoqt_QML} ${d}/Shortcuts.qml)

SET(d "qml/openfile")
SET(photoqt_QML ${photoqt_QML} ${d}/BreadCrumbs.qml ${d}/EditFiles.qml ${d}/FilesView.qml ${d}/FilesViewGrid.qml ${d}/FilesViewList.qml ${d}/Folders.qml ${d}/OpenFile.qml ${d}/Tweaks.qml ${d}/TweaksFileTypeSelection.qml ${d}/TweaksHiddenFolders.qml ${d}/TweaksPreview.qml ${d}/TweaksThumbnail.qml ${d}/TweaksViewMode.qml ${d}/TweaksZoom.qml ${d}/UserPlaces.qml)

SET(d "qml/elements")
SET(photoqt_QML ${photoqt_QML} ${d}/ContextMenu.qml ${d}/CustomButton.qml ${d}/CustomCheckBox.qml ${d}/CustomComboBox.qml ${d}/CustomConfirm.qml ${d}/CustomFileSelect.qml ${d}/CustomLineEdit.qml ${d}/CustomProgressBar.qml ${d}/CustomRadioButton.qml ${d}/CustomSlider.qml ${d}/CustomSpinBox.qml ${d}/CustomTabView.qml ${d}/CustomTextEdit.qml ${d}/ScrollBarHorizontal.qml ${d}/ScrollBarVertical.qml ${d}/SettingsText.qml ${d}/ShortcutNotifier.qml ${d}/ToolTip.qml)

SET(d "qml/settingsmanager")
SET(photoqt_QML ${photoqt_QML} ${d}/DetectShortcut.qml ${d}/EntryContainer.qml ${d}/EntrySetting.qml ${d}/EntryTitle.qml ${d}/ExportImport.qml ${d}/SettingInfoOverlay.qml ${d}/SettingsManager.qml)

SET(d "qml/settingsmanager/tabs")
SET(photoqt_QML ${photoqt_QML} ${d}/TabFileformats.qml ${d}/TabLookAndFeel.qml ${d}/TabMetadata.qml ${d}/TabOther.qml ${d}/TabShortcuts.qml ${d}/TabThumbnails.qml)

SET(d "qml/settingsmanager/tabs/fileformats")
SET(photoqt_QML ${photoqt_QML} ${d}/FileTypesExtras.qml ${d}/FileTypesGM.qml ${d}/FileTypesGMGhostscript.qml ${d}/FileTypesQt.qml ${d}/FileTypesRaw.qml ${d}/FileTypesTile.qml ${d}/FileTypesUntested.qml)

SET(d "qml/settingsmanager/tabs/lookandfeel")
SET(photoqt_QML ${photoqt_QML} ${d}/Animation.qml ${d}/Background.qml ${d}/Blur.qml ${d}/BorderAroundImage.qml ${d}/CloseOnClick.qml ${d}/ClosingX.qml ${d}/FitInWindow.qml ${d}/HotEdge.qml ${d}/Interpolation.qml ${d}/Keep.qml ${d}/Loop.qml ${d}/MouseWheelSensitivity.qml ${d}/OverlayColor.qml ${d}/PixmapCache.qml ${d}/Quickinfo.qml ${d}/ReOpenFile.qml ${d}/SortBy.qml ${d}/Transition.qml ${d}/TrayIcon.qml ${d}/WindowMode.qml)

SET(d "qml/settingsmanager/tabs/metadata")
SET(photoqt_QML ${photoqt_QML} ${d}/FontSize.qml ${d}/MetaData.qml ${d}/MetaDataTile.qml ${d}/MouseTrigger.qml ${d}/OnlineMap.qml ${d}/Opacity.qml ${d}/RotateFlip.qml)

SET(d "qml/settingsmanager/tabs/other")
SET(photoqt_QML ${photoqt_QML} ${d}/CustomEntries.qml ${d}/CustomEntriesInteractive.qml ${d}/Imgur.qml ${d}/Language.qml ${d}/LanguageTile.qml)

SET(d "qml/settingsmanager/tabs/shortcuts")
SET(photoqt_QML ${photoqt_QML} ${d}/Available.qml ${d}/Set.qml ${d}/ShortcutsContainer.qml)

SET(d "qml/settingsmanager/tabs/thumbnails")
SET(photoqt_QML ${photoqt_QML} ${d}/Cache.qml ${d}/CenterOn.qml ${d}/Disable.qml ${d}/FilenameOnly.qml ${d}/KeepVisible.qml ${d}/Label.qml ${d}/LiftUp.qml ${d}/Spacing.qml ${d}/ThumbnailSize.qml ${d}/TopOrBottom.qml)

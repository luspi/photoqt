#####################
#### QML SOURCES ####
#####################

SET(d "qml")
SET(photoqt_QML ${photoqt_QML} ${d}/mainwindow.qml ${d}/Caller.qml ${d}/loadfile.js)

SET(d "qml/vars")
SET(photoqt_QML ${photoqt_QML} ${d}/Variables.qml ${d}/Strings.qml)

SET(d "qml/mainview")
SET(photoqt_QML ${photoqt_QML} ${d}/Background.qml ${d}/MainImage.qml ${d}/MainImageRectangle.qml ${d}/Thumbnails.qml ${d}/QuickInfo.qml ${d}/ClosingX.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/MainMenu.qml ${d}/HandleMouseMovements.qml ${d}/MetaData.qml ${d}/Histogram.qml ${d}/MainImageRectangleAnimated.qml)

SET(d "qml/shortcuts")
SET(photoqt_QML ${photoqt_QML} ${d}/Shortcuts.qml ${d}/mouseshortcuts.js)

SET(d "qml/openfile")
SET(photoqt_QML ${photoqt_QML} ${d}/OpenFile.qml ${d}/BreadCrumbs.qml ${d}/handlestuff.js ${d}/OpenVariables.qml ${d}/UserPlaces.qml ${d}/Folders.qml ${d}/FilesView.qml ${d}/Tweaks.qml)

SET(d "qml/openfile/tweaks")
SET(photoqt_QML ${photoqt_QML} ${d}/TweaksFileType.qml  ${d}/TweaksPreview.qml  ${d}/TweaksThumbnails.qml  ${d}/TweaksViewMode.qml  ${d}/TweaksZoom.qml)

SET(d "qml/elements")
SET(photoqt_QML ${photoqt_QML} ${d}/ContextMenu.qml ${d}/CustomButton.qml ${d}/CustomCheckBox.qml ${d}/CustomComboBox.qml ${d}/CustomConfirm.qml ${d}/CustomFileSelect.qml ${d}/CustomLineEdit.qml ${d}/CustomProgressBar.qml ${d}/CustomRadioButton.qml ${d}/CustomSlider.qml ${d}/CustomSpinBox.qml ${d}/CustomTabView.qml ${d}/CustomTextEdit.qml ${d}/ScrollBarHorizontal.qml ${d}/ScrollBarVertical.qml ${d}/SettingsText.qml ${d}/ShortcutNotifier.qml ${d}/ToolTip.qml ${d}/FadeInTemplate.qml)

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

SET(d "qml/slideshow")
SET(photoqt_QML ${photoqt_QML} ${d}/SlideshowBar.qml ${d}/SlideshowSettings.qml ${d}/slideshow.js)

SET(d "qml/filemanagement")
SET(photoqt_QML ${photoqt_QML} ${d}/Copy.qml ${d}/Delete.qml ${d}/Management.qml ${d}/Move.qml ${d}/Rename.qml ${d}/ManagementNavigation.qml ${d}/ManagementContainer.qml)

SET(d "qml/other")
SET(photoqt_QML ${photoqt_QML} ${d}/About.qml ${d}/ImgurFeedback.qml ${d}/Filter.qml ${d}/Scale.qml ${d}/ScaleUnsupported.qml ${d}/Startup.qml)

SET(d "qml/wallpaper")
SET(photoqt_QML ${photoqt_QML} ${d}/Wallpaper.qml)

SET(d "qml/wallpaper/modules")
SET(photoqt_QML ${photoqt_QML} ${d}/Enlightenment.qml ${d}/GnomeUnity.qml ${d}/KDE4.qml ${d}/Other.qml ${d}/Plasma5.qml ${d}/XFCE4.qml)

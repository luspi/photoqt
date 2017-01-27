#####################
#### QML SOURCES ####
#####################

SET(d "qml")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/mainwindow.qml)

SET(d "qml/slidein")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/ThumbnailBar.qml ${d}/MetaData.qml ${d}/MainMenu.qml ${d}/SlideshowBar.qml)

SET(d "qml/mainview")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/Background.qml ${d}/QuickInfo.qml ${d}/SmartImage.qml ${d}/ImageItem.qml ${d}/MainView.qml ${d}/Histogram.qml)

SET(d "qml/openfile")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/OpenFile.qml ${d}/BreadCrumbs.qml ${d}/UserPlaces.qml ${d}/Folders.qml ${d}/FilesView.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/EditFiles.qml ${d}/TweaksZoom.qml ${d}/Tweaks.qml ${d}/TweaksViewMode.qml ${d}/TweaksPreview.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/TweaksThumbnail.qml ${d}/FilesViewGrid.qml ${d}/FilesViewList.qml ${d}/TweaksFileTypeSelection.qml)

SET(d "qml/elements")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/ScrollBarHorizontal.qml ${d}/ScrollBarVertical.qml ${d}/SettingsText.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/CustomCheckBox.qml ${d}/CustomButton.qml ${d}/CustomTabView.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/CustomComboBox.qml ${d}/CustomRadioButton.qml ${d}/CustomSlider.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/CustomSpinBox.qml ${d}/CustomConfirm.qml ${d}/CustomTextEdit.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/ShortcutNotifier.qml ${d}/ContextMenu.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/CustomLineEdit.qml ${d}/ToolTip.qml ${d}/CustomFileSelect.qml)

SET(d "qml/fadein")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/FadeInTemplate.qml ${d}/About.qml ${d}/Scale.qml ${d}/Rename.qml ${d}/Delete.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/Wallpaper.qml ${d}/Slideshow.qml ${d}/Filter.qml ${d}/Startup.qml ${d}/ScaleUnsupported.qml)

SET(d "qml/fadein/wallpaper")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/KDE4.qml ${d}/Plasma5.qml ${d}/GnomeUnity.qml ${d}/XFCE4.qml ${d}/Enlightenment.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/Other.qml)

SET(d "qml/settingsmanager")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/SettingsManager.qml ${d}/EntryTitle.qml ${d}/EntrySetting.qml ${d}/EntryContainer.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/DetectShortcut.qml)
SET(d "qml/settingsmanager/tabs")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/TabLookAndFeel.qml ${d}/TabThumbnails.qml ${d}/TabMetadata.qml ${d}/TabOther.qml ${d}/TabShortcuts.qml ${d}/TabFileformats.qml)
SET(d "qml/settingsmanager/tabs/lookandfeel")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/SortBy.qml ${d}/WindowMode.qml ${d}/TrayIcon.qml ${d}/ClosingX.qml ${d}/FitInWindow.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/OverlayColor.qml ${d}/Quickinfo.qml ${d}/Background.qml ${d}/BorderAroundImage.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/CloseOnClick.qml ${d}/Loop.qml ${d}/Transition.qml ${d}/HotEdge.qml ${d}/Blur.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/MouseWheelSensitivity.qml ${d}/Interpolation.qml ${d}/Keep.qml ${d}/Animation.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/PixmapCache.qml ${d}/ReOpenFile.qml)
SET(d "qml/settingsmanager/tabs/thumbnails")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/ThumbnailSize.qml ${d}/Spacing.qml ${d}/LiftUp.qml ${d}/KeepVisible.qml ${d}/Cache.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/CenterOn.qml ${d}/TopOrBottom.qml ${d}/Label.qml ${d}/FilenameOnly.qml ${d}/Disable.qml)
SET(d "qml/settingsmanager/tabs/metadata")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/MouseTrigger.qml ${d}/MetaData.qml ${d}/MetaDataTile.qml ${d}/FontSize.qml ${d}/RotateFlip.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/OnlineMap.qml ${d}/Opacity.qml)
SET(d "qml/settingsmanager/tabs/other")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/Language.qml ${d}/LanguageTile.qml ${d}/CustomEntries.qml ${d}/CustomEntriesInteractive.qml)
SET(d "qml/settingsmanager/tabs/fileformats")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/FileTypesQt.qml ${d}/FileTypesTile.qml ${d}/FileTypesGM.qml ${d}/FileTypesGMGhostscript.qml)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/FileTypesExtras.qml ${d}/FileTypesUntested.qml ${d}/FileTypesRaw.qml)
SET(d "qml/settingsmanager/tabs/shortcuts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/Available.qml ${d}/Set.qml ${d}/ShortcutsContainer.qml)

SET(d "qml/globalstrings")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/Keys.qml ${d}/Mouse.qml)

SET(d "qml/shortcuts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/Shortcuts.qml ${d}/mouseshortcuts.js ${d}/keyshortcuts.js ${d}/touchshortcuts.js)

##############################
#### MODERN QML INTERFACE ####
##############################

SET(photoqt_duplicate_QML "")

SET(d "qml/duplicate/filedialog")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQFileDialog.qml ${d}/PQPlaces.qml ${d}/PQFileView.qml ${d}/PQTweaks.qml ${d}/PQPreview.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQPasteExistingConfirm.qml ${d}/PQFileDialogSettingsMenu.qml ${d}/PQBreadCrumbs.qml)

SET(d "qml/duplicate/filedialog/elements")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQFileDialogButtonElement.qml ${d}/PQFileDeleteConfirm.qml ${d}/PQFileDialogComboBox.qml ${d}/PQFileDialogButton.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQFileDialogScrollBar.qml ${d}/PQFileDialogSlider.qml)

SET(d "qml/duplicate/filedialog/fileviews")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQFileViewList.qml ${d}/PQFileViewGrid.qml ${d}/PQFileViewMasonry.qml)

SET(d "qml/duplicate/filedialog/fileviews/parts")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQFolderThumb.qml ${d}/PQFileThumb.qml ${d}/PQFileIcon.qml)

SET(d "qml/duplicate/filedialog/popout")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQFileDialogPopout.qml)

SET(d "qml/duplicate/ongoing")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQThumbnails.qml ${d}/PQTrayIcon.qml)

SET(d "qml/duplicate/other")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQShortcuts.qml ${d}/PQMultiEffect.qml ${d}/PQShadowEffect.qml ${d}/PQWorking.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQScrollManager.qml)

SET(d "qml/duplicate/image")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQImage.qml ${d}/PQImageDisplay.qml)
SET(d "qml/duplicate/image/imageitems")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQImageNormal.qml ${d}/PQImageAnimated.qml ${d}/PQVideoMpv.qml ${d}/PQVideoQt.qml ${d}/PQArchive.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQPhotoSphere.qml ${d}/PQDocument.qml ${d}/PQSVG.qml)
SET(d "qml/duplicate/image/components")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQKenBurnsSlideshowEffect.qml ${d}/PQKenBurnsSlideshowBackground.qml ${d}/PQBarCodes.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQMinimap.qml ${d}/PQAnimatedImageControls.qml ${d}/PQArchiveControls.qml ${d}/PQVideoControls.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQPhotoSphereControls.qml ${d}/PQDocumentControls.qml ${d}/PQMotionPhotoControls.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQFaceTracker.qml ${d}/PQFaceTagger.qml)


SET(d "qml/duplicate/settingsmanager2")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsManager2.qml)

SET(d "qml/duplicate/settingsmanager2/elements")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsSeparator.qml ${d}/PQSetting.qml)

SET(d "qml/duplicate/settingsmanager2/interface")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsInterfaceAccentColor.qml ${d}/PQSettingsInterfaceBackground.qml ${d}/PQSettingsInterfaceClicksOnBackground.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsInterfaceContextMenu.qml ${d}/PQSettingsInterfaceEdges.qml ${d}/PQSettingsInterfaceFontWeight.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsInterfaceLanguage.qml ${d}/PQSettingsInterfaceNotification.qml ${d}/PQSettingsInterfacePopout.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsInterfaceStatusInfo.qml ${d}/PQSettingsInterfaceWindowButtons.qml ${d}/PQSettingsInterfaceWindowMode.qml)



SET(d "qml/duplicate/settingsmanager")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsManager.qml ${d}/PQCategory.qml)

SET(d "qml/duplicate/settingsmanager/popout")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsManagerPopout.qml)

SET(d "qml/duplicate/settingsmanager/settings/filetypes")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQFileTypesSettings.qml ${d}/PQBehaviorSettings.qml ${d}/PQAdvancedSettings.qml)

SET(d "qml/duplicate/settingsmanager/settings/imageview")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQShareOnlineSettings.qml ${d}/PQImageSettings.qml ${d}/PQInteractionSettings.qml ${d}/PQFolderSettings.qml ${d}/PQMetadataSettings.qml)

SET(d "qml/duplicate/settingsmanager/settings/interface")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQBackgroundSettings.qml ${d}/PQContextMenuSettings.qml ${d}/PQPopoutSettings.qml ${d}/PQInterfaceSettings.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQStatusInfoSettings.qml ${d}/PQEdgesSettings.qml)

SET(d "qml/duplicate/settingsmanager/settings/shortcuts")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQShortcutsSettings.qml ${d}/PQNewActionSettings.qml ${d}/PQNewShortcutSettings.qml ${d}/PQShortcutsBehaviorSettings.qml)

SET(d "qml/duplicate/settingsmanager/settings/thumbnails")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQThumbnailImageSettings.qml ${d}/PQAllThumbnailsSettings.qml ${d}/PQThumbnailManageSettings.qml)

SET(d "qml/duplicate/settingsmanager/settings/manage")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSessionSettings.qml ${d}/PQConfigurationSettings.qml)

SET(d "qml/duplicate/settingsmanager/settings/other")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQFileDialogSettings.qml ${d}/PQSlideshowSettings.qml ${d}/PQExtensionsSettings.qml)

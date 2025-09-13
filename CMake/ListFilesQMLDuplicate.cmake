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
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQThumbnails.qml ${d}/PQTrayIcon.qml ${d}/PQContextMenu.qml ${d}/PQNotification.qml)

SET(d "qml/duplicate/other")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQShortcuts.qml ${d}/PQMultiEffect.qml ${d}/PQShadowEffect.qml ${d}/PQWorking.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQScrollManager.qml ${d}/PQCommonFunctions.js)

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


SET(d "qml/duplicate/settingsmanager")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsManager.qml ${d}/PQSettingsTabs.qml)

SET(d "qml/duplicate/settingsmanager/elements")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsSeparator.qml ${d}/PQSetting.qml ${d}/PQSettingSubtitle.qml ${d}/PQSettingSpacer.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsResetButton.qml)

SET(d "qml/duplicate/settingsmanager/interface")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsInterfaceAccentColor.qml ${d}/PQSettingsInterfaceBackground.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsInterfaceContextMenu.qml ${d}/PQSettingsInterfaceEdges.qml ${d}/PQSettingsInterfaceFontWeight.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsInterfaceOverallInterface.qml ${d}/PQSettingsInterfaceNotification.qml ${d}/PQSettingsInterfacePopout.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsInterfaceStatusInfo.qml ${d}/PQSettingsInterfaceWindowButtons.qml ${d}/PQSettingsInterfaceWindowMode.qml)

SET(d "qml/duplicate/settingsmanager/imageview")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsImageViewCache.qml ${d}/PQSettingsImageViewImageProcessing.qml ${d}/PQSettingsImageViewMetadata.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsImageViewFaceTags.qml ${d}/PQSettingsImageViewFileList.qml ${d}/PQSettingsImageViewLook.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsImageViewShareOnline.qml ${d}/PQSettingsImageViewInteraction.qml)

SET(d "qml/duplicate/settingsmanager/thumbnails")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsThumbnailsBar.qml ${d}/PQSettingsThumbnailsImage.qml ${d}/PQSettingsThumbnailsInfo.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsThumbnailsManage.qml)

SET(d "qml/duplicate/settingsmanager/filetypes")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsFiletypesList.qml ${d}/PQSettingsFiletypesAnimated.qml ${d}/PQSettingsFiletypesArchives.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsFiletypesDocuments.qml ${d}/PQSettingsFiletypesMotion.qml ${d}/PQSettingsFiletypesRAW.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsFiletypesSpheres.qml ${d}/PQSettingsFiletypesVideos.qml)

SET(d "qml/duplicate/settingsmanager/manage")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsManageSession.qml ${d}/PQSettingsManageTrayIcon.qml ${d}/PQSettingsManageManage.qml)

SET(d "qml/duplicate/settingsmanager/shortcuts")
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsShortcutsList.qml ${d}/PQSettingsShortcutsExtraMouse.qml ${d}/PQSettingsShortcutsExtraKeys.qml)
SET(photoqt_duplicate_QML ${photoqt_duplicate_QML} ${d}/PQSettingsShortcutsDetectNew.qml ${d}/PQSettingsShortcutsExternalShortcuts.qml ${d}/PQSettingsShortcutsDuplicateShortcuts.qml)

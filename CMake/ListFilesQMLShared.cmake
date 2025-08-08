##############################
#### MODERN QML INTERFACE ####
##############################

SET(photoqt_shared_QML "")

SET(d "qml/shared/filedialog")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQFileDialog.qml ${d}/PQPlaces.qml ${d}/PQFileView.qml ${d}/PQTweaks.qml ${d}/PQPreview.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQPasteExistingConfirm.qml ${d}/PQFileDialogSettingsMenu.qml ${d}/PQBreadCrumbs.qml)

SET(d "qml/shared/filedialog/elements")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQFileDialogButtonElement.qml ${d}/PQFileDeleteConfirm.qml ${d}/PQFileDialogComboBox.qml ${d}/PQFileDialogButton.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQFileDialogScrollBar.qml ${d}/PQFileDialogSlider.qml)

SET(d "qml/shared/filedialog/fileviews")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQFileViewList.qml ${d}/PQFileViewGrid.qml ${d}/PQFileViewMasonry.qml)

SET(d "qml/shared/filedialog/fileviews/parts")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQFolderThumb.qml ${d}/PQFileThumb.qml ${d}/PQFileIcon.qml)

SET(d "qml/shared/filedialog/popout")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQFileDialogPopout.qml)

SET(d "qml/shared/ongoing")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQThumbnails.qml ${d}/PQTrayIcon.qml)

SET(d "qml/shared/other")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQShortcuts.qml ${d}/PQMultiEffect.qml ${d}/PQShadowEffect.qml ${d}/PQWorking.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQScrollManager.qml)

SET(d "qml/shared/image")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQImage.qml ${d}/PQImageDisplay.qml)
SET(d "qml/shared/image/imageitems")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQImageNormal.qml ${d}/PQImageAnimated.qml ${d}/PQVideoMpv.qml ${d}/PQVideoQt.qml ${d}/PQArchive.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQPhotoSphere.qml ${d}/PQDocument.qml ${d}/PQSVG.qml)
SET(d "qml/shared/image/components")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQKenBurnsSlideshowEffect.qml ${d}/PQKenBurnsSlideshowBackground.qml ${d}/PQBarCodes.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQMinimap.qml ${d}/PQAnimatedImageControls.qml ${d}/PQArchiveControls.qml ${d}/PQVideoControls.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQPhotoSphereControls.qml ${d}/PQDocumentControls.qml ${d}/PQMotionPhotoControls.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQFaceTracker.qml ${d}/PQFaceTagger.qml)

SET(d "qml/shared/settingsmanager")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQSettingsManager.qml ${d}/PQCategory.qml)

SET(d "qml/shared/settingsmanager/popout")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQSettingsManagerPopout.qml)

SET(d "qml/shared/settingsmanager/settings/filetypes")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQFileTypesSettings.qml ${d}/PQBehaviorSettings.qml ${d}/PQAdvancedSettings.qml)

SET(d "qml/shared/settingsmanager/settings/imageview")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQShareOnlineSettings.qml ${d}/PQImageSettings.qml ${d}/PQInteractionSettings.qml ${d}/PQFolderSettings.qml ${d}/PQMetadataSettings.qml)

SET(d "qml/shared/settingsmanager/settings/interface")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQBackgroundSettings.qml ${d}/PQContextMenuSettings.qml ${d}/PQPopoutSettings.qml ${d}/PQInterfaceSettings.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQStatusInfoSettings.qml ${d}/PQEdgesSettings.qml)

SET(d "qml/shared/settingsmanager/settings/shortcuts")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQShortcutsSettings.qml ${d}/PQNewActionSettings.qml ${d}/PQNewShortcutSettings.qml ${d}/PQShortcutsBehaviorSettings.qml)

SET(d "qml/shared/settingsmanager/settings/thumbnails")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQThumbnailImageSettings.qml ${d}/PQAllThumbnailsSettings.qml ${d}/PQThumbnailManageSettings.qml)

SET(d "qml/shared/settingsmanager/settings/manage")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQSessionSettings.qml ${d}/PQConfigurationSettings.qml)

SET(d "qml/shared/settingsmanager/settings/other")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQFileDialogSettings.qml ${d}/PQSlideshowSettings.qml ${d}/PQExtensionsSettings.qml)

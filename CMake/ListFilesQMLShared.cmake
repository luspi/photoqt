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

##############################
#### MODERN QML INTERFACE ####
##############################

SET(photoqt_shared_QML "")

SET(d "qml/shared/elements")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQShadowEffect.qml)

SET(d "qml/shared/image")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQImage.qml ${d}/PQImageDisplay.qml)
SET(d "qml/shared/image/imageitems")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQImageNormal.qml ${d}/PQImageAnimated.qml ${d}/PQVideoMpv.qml ${d}/PQVideoQt.qml ${d}/PQArchive.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQPhotoSphere.qml ${d}/PQDocument.qml ${d}/PQSVG.qml)
SET(d "qml/shared/image/components")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQKenBurnsSlideshowEffect.qml ${d}/PQKenBurnsSlideshowBackground.qml ${d}/PQBarCodes.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQMinimap.qml ${d}/PQAnimatedImageControls.qml ${d}/PQArchiveControls.qml ${d}/PQVideoControls.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQPhotoSphereControls.qml ${d}/PQDocumentControls.qml ${d}/PQMotionPhotoControls.qml)

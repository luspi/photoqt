##############################
#### MODERN QML INTERFACE ####
##############################

SET(photoqt_shared_QML "")

SET(d "qml/shared/image")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQImage.qml ${d}/PQImageDisplay.qml)
SET(d "qml/shared/image/imageitems")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQImageNormal.qml ${d}/PQImageAnimated.qml ${d}/PQVideoMpv.qml ${d}/PQVideoQt.qml ${d}/PQArchive.qml)
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQPhotoSphere.qml ${d}/PQDocument.qml ${d}/PQSVG.qml)
SET(d "qml/shared/image/components")
SET(photoqt_shared_QML ${photoqt_shared_QML} ${d}/PQKenBurnsSlideshowEffect.qml ${d}/PQKenBurnsSlideshowBackground.qml ${d}/PQBarCodes.qml)

##################################
#### INTEGRATED QML INTERFACE ####
##################################

SET(photoqt_integrated_QML "")

SET(d "qml/integrated")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMainWindow.qml)

SET(d "qml/integrated/elements")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMouseArea.qml ${d}/PQWorking.qml ${d}/PQMenu.qml ${d}/PQMenuItem.qml ${d}/PQMenuSeparator.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQText.qml ${d}/PQTextS.qml ${d}/PQTextL.qml ${d}/PQTextXL.qml ${d}/PQTextXXL.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQSlider.qml ${d}/PQComboBox.qml ${d}/PQButton.qml ${d}/PQLineEdit.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQShadowEffect.qml ${d}/PQToolTip.qml ${d}/PQMultiEffect.qml)

SET(d "qml/integrated/image")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQImageControls.qml)

SET(d "qml/integrated/image/controls")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMotionPhotoControls.qml ${d}/PQAnimatedImageControls.qml ${d}/PQDocumentControls.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQArchiveControls.qml ${d}/PQPhotoSphereControls.qml ${d}/PQVideoControls.qml)

SET(d "qml/integrated/other")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMasterItem.qml ${d}/PQBackgroundMessage.qml ${d}/PQShortcuts.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMenuBar.qml ${d}/PQFooter.qml)

SET(d "qml/integrated/ongoing")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQTrayIcon.qml)

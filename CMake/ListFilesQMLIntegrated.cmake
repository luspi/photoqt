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
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQToolTip.qml ${d}/PQMultiEffect.qml)

SET(d "qml/integrated/other")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMasterItem.qml ${d}/PQBackgroundMessage.qml ${d}/PQLoader.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMenuBar.qml ${d}/PQFooter.qml ${d}/PQToolTipDisplay.qml)

SET(d "qml/integrated/ongoing")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQTrayIcon.qml)

SET(d "qml/integrated/contextmenus")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMinimapContextMenu.qml ${d}/PQArchiveControlsContextMenu.qml ${d}/PQDocumentControlsContextMenu.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQVideoControlsContextMenu.qml)

SET(d "qml/integrated/actions")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQAbout.qml)

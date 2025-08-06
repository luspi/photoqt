##################################
#### INTEGRATED QML INTERFACE ####
##################################

SET(photoqt_integrated_QML "")

SET(d "qml/integrated")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMainWindow.qml)

SET(d "qml/integrated/elements")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMouseArea.qml ${d}/PQMenu.qml ${d}/PQMenuItem.qml ${d}/PQMenuSeparator.qml ${d}/PQButtonIcon.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQText.qml ${d}/PQTextS.qml ${d}/PQTextL.qml ${d}/PQTextXL.qml ${d}/PQTextXXL.qml ${d}/PQLineEdit.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQSlider.qml ${d}/PQComboBox.qml ${d}/PQButton.qml ${d}/PQButtonElement.qml ${d}/PQCheckBox.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQToolTip.qml ${d}/PQMultiEffect.qml ${d}/PQVerticalScrollBar.qml ${d}/PQHorizontalScrollBar.qml)

SET(d "qml/integrated/other")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMasterItem.qml ${d}/PQBackgroundMessage.qml ${d}/PQLoader.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMenuBar.qml ${d}/PQFooter.qml ${d}/PQToolTipDisplay.qml)

SET(d "qml/integrated/actions")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQAbout.qml)

#####################
#### QML SOURCES ####
#####################

SET(d "qml")
SET(photoqt_QML ${photoqt_QML} ${d}/mainwindow.qml ${d}/PQLoader.qml ${d}/PQVariables.qml)

SET(d "qml/mainwindow")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImage.qml ${d}/PQFileDialog.qml ${d}/PQQuickInfo.qml ${d}/PQCloseButton.qml)

SET(d "qml/mainwindow/image")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImageNormal.qml ${d}/PQImageAnimated.qml ${d}/PQLoading.qml)

SET(d "qml/mainwindow/filedialog")
SET(photoqt_QML ${photoqt_QML} ${d}/PQPlaces.qml ${d}/PQDevices.qml ${d}/PQFileView.qml ${d}/PQStandard.qml ${d}/PQTweaks.qml ${d}/PQBreadCrumbs.qml ${d}/PQPreview.qml ${d}/PQRightClickMenu.qml)

SET(d "qml/elements")
SET(photoqt_QML ${photoqt_QML} ${d}/PQSlider.qml ${d}/PQCheckbox.qml ${d}/PQButton.qml ${d}/PQMenu.qml ${d}/PQMenuItem.qml ${d}/PQToolTip.qml ${d}/PQMouseArea.qml ${d}/PQComboBox.qml ${d}/PQScrollBar.qml)

SET(d "qml/shortcuts")
SET(photoqt_QML ${photoqt_QML} ${d}/PQKeyShortcuts.qml ${d}/PQMouseShortcuts.qml ${d}/handleshortcuts.js)

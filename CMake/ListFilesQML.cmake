#####################
#### C++ SOURCES ####
#####################

SET(photoqt_QML "")

SET(d "qml")
SET(photoqt_QML ${photoqt_QML} ${d}/PQMainWindow.qml)

SET(d "qml/elements")
SET(photoqt_QML ${photoqt_QML} ${d}/PQText.qml ${d}/PQTextS.qml ${d}/PQTextL.qml ${d}/PQTextXL.qml ${d}/PQMouseArea.qml ${d}/PQButtonIcon.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQSlider.qml ${d}/PQComboBox.qml ${d}/PQButtonElement.qml ${d}/PQVerticalScrollBar.qml ${d}/PQMenu.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQMenuItem.qml ${d}/PQMultiEffect.qml ${d}/PQMenuSeparator.qml ${d}/PQButton.qml ${d}/PQCheckBox.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQToolTip.qml)

SET(d "qml/filedialog")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFileDialog.qml ${d}/PQPlaces.qml ${d}/PQBreadCrumbs.qml ${d}/PQFileView.qml ${d}/PQTweaks.qml ${d}/PQPreview.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQPasteExistingConfirm.qml ${d}/PQSettingsMenu.qml)

SET(d "qml/manage")
SET(photoqt_QML ${photoqt_QML} ${d}/PQLoader.qml)

SET(d "qml/other")
SET(photoqt_QML ${photoqt_QML} ${d}/PQShortcuts.qml ${d}/PQBackgroundMessage.qml ${d}/PQTemplateFullscreen.qml)

SET(d "qml/scripts")
SET(photoqt_QML ${photoqt_QML} ${d}/pq_shortcuts.js)

#####################
#### C++ SOURCES ####
#####################

SET(photoqt_QML "")

SET(d "qml")
SET(photoqt_QML ${photoqt_QML} ${d}/PQMainWindow.qml)

SET(d "qml/elements")
SET(photoqt_QML ${photoqt_QML} ${d}/PQText.qml ${d}/PQTextS.qml ${d}/PQTextL.qml ${d}/PQTextXL.qml ${d}/PQToolTip.qml ${d}/PQButtonIcon.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQSlider.qml ${d}/PQComboBox.qml ${d}/PQButtonElement.qml ${d}/PQVerticalScrollBar.qml)

SET(d "qml/filedialog")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFileDialog.qml ${d}/PQPlaces.qml ${d}/PQBreadCrumbs.qml ${d}/PQFileView.qml ${d}/PQTweaks.qml)

SET(d "qml/manage")
SET(photoqt_QML ${photoqt_QML} ${d}/PQLoader.qml)

SET(d "qml/other")
SET(photoqt_QML ${photoqt_QML} ${d}/PQShortcuts.qml ${d}/PQBackgroundMessage.qml)

SET(d "qml/scripts")
SET(photoqt_QML ${photoqt_QML} ${d}/pq_shortcuts.js)

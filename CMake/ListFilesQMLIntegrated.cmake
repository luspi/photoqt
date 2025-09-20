##################################
#### INTEGRATED QML INTERFACE ####
##################################

SET(photoqt_integrated_QML "")

SET(d "qml/integrated")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMainWindow.qml)

SET(d "qml/integrated/elements/basics")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMouseArea.qml ${d}/PQMenu.qml ${d}/PQMenuItem.qml ${d}/PQMenuSeparator.qml ${d}/PQButtonIcon.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQText.qml ${d}/PQTextS.qml ${d}/PQTextL.qml ${d}/PQTextXL.qml ${d}/PQTextXXL.qml ${d}/PQLineEdit.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQSlider.qml ${d}/PQComboBox.qml ${d}/PQButton.qml ${d}/PQButtonElement.qml ${d}/PQCheckBox.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQToolTip.qml ${d}/PQVerticalScrollBar.qml ${d}/PQHorizontalScrollBar.qml ${d}/PQRadioButton.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQSpinBox.qml ${d}/PQSliderSpinBox.qml ${d}/PQTextArea.qml ${d}/PQTabButton.qml ${d}/PQTabBar.qml ${d}/PQTabSeparator.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQCheckableComboBox.qml)

SET(d "qml/integrated/elements/extensions")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQTemplateExtensionFloatingPopout.qml ${d}/PQTemplateExtensionSettings.qml ${d}/PQTemplateExtension.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQTemplateExtensionFloating.qml ${d}/PQTemplateExtensionContainer.qml ${d}/PQTemplateExtensionModalPopout.qml)

SET(d "qml/integrated/elements/templates")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQTemplate.qml ${d}/PQTemplateModal.qml ${d}/PQTemplateModalPopout.qml)

SET(d "qml/integrated/other")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMasterItem.qml ${d}/PQBackgroundMessage.qml ${d}/PQLoader.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMenuBar.qml ${d}/PQFooter.qml ${d}/PQToolTipDisplay.qml)

SET(d "qml/integrated/actions")
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQAbout.qml ${d}/PQRename.qml ${d}/PQDelete.qml ${d}/PQCopy.qml)
SET(photoqt_integrated_QML ${photoqt_integrated_QML} ${d}/PQMove.qml)

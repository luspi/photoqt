##############################
#### MODERN QML INTERFACE ####
##############################

SET(photoqt_modern_QML "")

SET(d "qml/modern")
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQMainWindow.qml)

SET(d "qml/modern/elements/basics")
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQText.qml ${d}/PQTextS.qml ${d}/PQTextL.qml ${d}/PQTextXL.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQSlider.qml ${d}/PQComboBox.qml ${d}/PQButtonElement.qml ${d}/PQVerticalScrollBar.qml ${d}/PQMenu.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQMenuItem.qml ${d}/PQMenuSeparator.qml ${d}/PQButton.qml ${d}/PQCheckBox.qml ${d}/PQButtonIcon.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQToolTip.qml ${d}/PQHorizontalScrollBar.qml ${d}/PQTextXXL.qml ${d}/PQSliderSpinBox.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQSpinBox.qml ${d}/PQRadioButton.qml ${d}/PQTabBar.qml ${d}/PQTextArea.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQMouseArea.qml ${d}/PQLineEdit.qml ${d}/PQTabButton.qml ${d}/PQCheckableComboBox.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQHighlightMarker.qml)

SET(d "qml/modern/elements/compounds")
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQMainMenuEntry.qml ${d}/PQMainMenuIcon.qml ${d}/PQMetaDataEntry.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQModal.qml ${d}/PQTemplateFullscreen.qml ${d}/PQTemplatePopout.qml ${d}/PQTemplateFloating.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQResizeRect.qml)

SET(d "qml/modern/elements/extensions")
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQTemplateExtensionFloatingPopout.qml ${d}/PQTemplateExtensionSettings.qml ${d}/PQTemplateExtension.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQTemplateExtensionFloating.qml ${d}/PQTemplateExtensionContainer.qml ${d}/PQTemplateExtensionModal.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQTemplateExtensionModalPopout.qml)

SET(d "qml/modern/elements/templates")
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQTemplate.qml ${d}/PQTemplateModal.qml ${d}/PQTemplateModalPopout.qml)

SET(d "qml/modern/other")
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQMainWindowBackground.qml ${d}/PQBackgroundMessage.qml ${d}/PQMasterItem.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQLoader.qml ${d}/PQGestureTouchAreas.qml ${d}/PQToolTipDisplay.qml)

SET(d "qml/modern/ongoing")
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQStatusInfo.qml ${d}/PQMainMenu.qml ${d}/PQMetaData.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQWindowButtons.qml ${d}/PQWindowHandles.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQChromeCast.qml)

SET(d "qml/modern/ongoing/popout")
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQMainMenuPopout.qml ${d}/PQMetaDataPopout.qml ${d}/PQSlideshowControlsPopout.qml)

SET(d "qml/modern/actions")
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQDelete.qml ${d}/PQCopy.qml ${d}/PQMove.qml ${d}/PQRename.qml)
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQChromeCastManager.qml)

SET(d "qml/modern/actions/popout")
SET(photoqt_modern_QML ${photoqt_modern_QML} ${d}/PQDeletePopout.qml ${d}/PQRenamePopout.qml ${d}/PQChromeCastManagerPopout.qml)

#####################
#### C++ SOURCES ####
#####################

SET(photoqt_QML "")

SET(d "qml")
SET(photoqt_QML ${photoqt_QML} ${d}/PQMainWindowModern.qml)

SET(d "qml/modern/elements")
SET(photoqt_QML ${photoqt_QML} ${d}/PQText.qml ${d}/PQTextS.qml ${d}/PQTextL.qml ${d}/PQTextXL.qml ${d}/PQMouseArea.qml ${d}/PQButtonIcon.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQSlider.qml ${d}/PQComboBox.qml ${d}/PQButtonElement.qml ${d}/PQVerticalScrollBar.qml ${d}/PQMenu.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQMenuItem.qml ${d}/PQMultiEffect.qml ${d}/PQMultiEffect_real.qml ${d}/PQMultiEffect_fake.qml ${d}/PQMenuSeparator.qml ${d}/PQButton.qml ${d}/PQCheckBox.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQToolTip.qml ${d}/PQHorizontalScrollBar.qml ${d}/PQMainMenuEntry.qml ${d}/PQMainMenuIcon.qml ${d}/PQMetaDataEntry.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQModal.qml ${d}/PQTextXXL.qml ${d}/PQTemplateFullscreen.qml ${d}/PQTemplatePopout.qml ${d}/PQTemplateFloating.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQSpinBox.qml ${d}/PQWorking.qml ${d}/PQLineEdit.qml ${d}/PQRadioButton.qml ${d}/PQTabBar.qml ${d}/PQTextArea.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQSettingsSeparator.qml ${d}/PQSetting.qml ${d}/PQSliderSpinBox.qml ${d}/PQShadowEffect.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQResizeRect.qml ${d}/PQScrollManager.qml ${d}/PQTemplateExtension.qml ${d}/PQTemplateExtensionFloating.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQTemplateExtensionPopout.qml ${d}/PQTemplateExtensionSettings.qml)

SET(d "qml/modern/filedialog")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFileDialog.qml ${d}/PQPlaces.qml ${d}/PQBreadCrumbs.qml ${d}/PQFileView.qml ${d}/PQTweaks.qml ${d}/PQPreview.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQPasteExistingConfirm.qml ${d}/PQSettingsMenu.qml)

SET(d "qml/modern/filedialog/fileviews")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFileViewList.qml ${d}/PQFileViewGrid.qml ${d}/PQFileViewMasonry.qml)

SET(d "qml/modern/filedialog/fileviews/parts")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFolderThumb.qml ${d}/PQFileThumb.qml ${d}/PQFileIcon.qml)

SET(d "qml/modern/filedialog/popout")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFileDialogPopout.qml)

SET(d "qml/modern/other")
SET(photoqt_QML ${photoqt_QML} ${d}/PQMainWindowBackground.qml ${d}/PQBackgroundMessage.qml ${d}/PQShortcuts.qml ${d}/PQMasterItem.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQLoader.qml ${d}/PQSlideshowHandler.qml ${d}/PQGestureTouchAreas.qml)

SET(d "qml/modern/image")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImage.qml ${d}/PQImageDisplay.qml)
SET(d "qml/modern/image/imageitems")
SET(photoqt_QML ${photoqt_QML} ${d}/PQImageNormal.qml ${d}/PQImageAnimated.qml ${d}/PQVideoMpv.qml ${d}/PQVideoQt.qml ${d}/PQArchive.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQPhotoSphere.qml ${d}/PQDocument.qml ${d}/PQSVG.qml)
SET(d "qml/modern/image/components")
SET(photoqt_QML ${photoqt_QML} ${d}/PQVideoControls.qml ${d}/PQFaceTracker.qml ${d}/PQFaceTagger.qml ${d}/PQBarCodes.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQImageAnimatedControls.qml ${d}/PQDocumentControls.qml ${d}/PQArchiveControls.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQMinimap.qml ${d}/PQMinimapPopout.qml ${d}/PQKenBurnsSlideshowEffect.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQPhotoSphereControls.qml ${d}/PQKenBurnsSlideshowBackground.qml)

SET(d "qml/modern/ongoing")
SET(photoqt_QML ${photoqt_QML} ${d}/PQContextMenu.qml ${d}/PQStatusInfo.qml ${d}/PQMainMenu.qml ${d}/PQMetaData.qml ${d}/PQThumbnails.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQTrayIcon.qml ${d}/PQWindowButtons.qml ${d}/PQWindowHandles.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQNotification.qml ${d}/PQChromeCast.qml ${d}/PQSlideshowControls.qml)

SET(d "qml/modern/ongoing/popout")
SET(photoqt_QML ${photoqt_QML} ${d}/PQMainMenuPopout.qml ${d}/PQMetaDataPopout.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQLoggingPopout.qml ${d}/PQSlideshowControlsPopout.qml)

SET(d "qml/modern/actions")
SET(photoqt_QML ${photoqt_QML} ${d}/PQAbout.qml ${d}/PQDelete.qml ${d}/PQCopy.qml ${d}/PQMove.qml ${d}/PQRename.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQAdvancedSort.qml ${d}/PQFilter.qml ${d}/PQSlideshowSetup.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQChromeCastManager.qml ${d}/PQMapExplorer.qml)

SET(d "qml/modern/actions/popout")
SET(photoqt_QML ${photoqt_QML} ${d}/PQAboutPopout.qml ${d}/PQDeletePopout.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQRenamePopout.qml ${d}/PQFilterPopout.qml ${d}/PQAdvancedSortPopout.qml ${d}/PQSlideshowSetupPopout.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQChromeCastManagerPopout.qml ${d}/PQMapExplorerPopout.qml)

SET(d "qml/modern/actions/mapexplorerparts")
SET(photoqt_QML ${photoqt_QML} ${d}/PQMapExplorerImages.qml ${d}/PQMapExplorerImagesTweaks.qml ${d}/PQMapExplorerMap.qml ${d}/PQMapExplorerMapTweaks.qml)

SET(d "qml/modern/settingsmanager")
SET(photoqt_QML ${photoqt_QML} ${d}/PQSettingsManager.qml ${d}/PQCategory.qml)

SET(d "qml/modern/settingsmanager/popout")
SET(photoqt_QML ${photoqt_QML} ${d}/PQSettingsManagerPopout.qml)

SET(d "qml/modern/settingsmanager/settings/filetypes")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFileTypesSettings.qml ${d}/PQBehaviorSettings.qml ${d}/PQAdvancedSettings.qml)

SET(d "qml/modern/settingsmanager/settings/imageview")
SET(photoqt_QML ${photoqt_QML} ${d}/PQShareOnlineSettings.qml ${d}/PQImageSettings.qml ${d}/PQInteractionSettings.qml ${d}/PQFolderSettings.qml ${d}/PQMetadataSettings.qml)

SET(d "qml/modern/settingsmanager/settings/interface")
SET(photoqt_QML ${photoqt_QML} ${d}/PQBackgroundSettings.qml ${d}/PQContextMenuSettings.qml ${d}/PQPopoutSettings.qml ${d}/PQInterfaceSettings.qml)
SET(photoqt_QML ${photoqt_QML} ${d}/PQStatusInfoSettings.qml ${d}/PQEdgesSettings.qml)

SET(d "qml/modern/settingsmanager/settings/shortcuts")
SET(photoqt_QML ${photoqt_QML} ${d}/PQShortcutsSettings.qml ${d}/PQNewActionSettings.qml ${d}/PQNewShortcutSettings.qml ${d}/PQShortcutsBehaviorSettings.qml)

SET(d "qml/modern/settingsmanager/settings/thumbnails")
SET(photoqt_QML ${photoqt_QML} ${d}/PQThumbnailImageSettings.qml ${d}/PQAllThumbnailsSettings.qml ${d}/PQThumbnailManageSettings.qml)

SET(d "qml/modern/settingsmanager/settings/manage")
SET(photoqt_QML ${photoqt_QML} ${d}/PQSessionSettings.qml ${d}/PQConfigurationSettings.qml)

SET(d "qml/modern/settingsmanager/settings/other")
SET(photoqt_QML ${photoqt_QML} ${d}/PQFileDialogSettings.qml ${d}/PQSlideshowSettings.qml ${d}/PQExtensionsSettings.qml)


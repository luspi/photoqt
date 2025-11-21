#######################
#### QML INTERFACE ####
#######################

SET(photoqt_QML qml/PQMainWindow.qml

                qml/elements/basics/PQButton.qml
                qml/elements/basics/PQButtonElement.qml
                qml/elements/basics/PQButtonIcon.qml
                qml/elements/basics/PQCheckableComboBox.qml
                qml/elements/basics/PQCheckBox.qml
                qml/elements/basics/PQComboBox.qml
                qml/elements/basics/PQHighlightMarker.qml
                qml/elements/basics/PQHorizontalScrollBar.qml
                qml/elements/basics/PQLineEdit.qml
                qml/elements/basics/PQMenu.qml
                qml/elements/basics/PQMenuItem.qml
                qml/elements/basics/PQMenuSeparator.qml
                qml/elements/basics/PQMouseArea.qml
                qml/elements/basics/PQRadioButton.qml
                qml/elements/basics/PQSlider.qml
                qml/elements/basics/PQSliderSpinBox.qml
                qml/elements/basics/PQSpinBox.qml
                qml/elements/basics/PQTabBar.qml
                qml/elements/basics/PQTabButton.qml
                qml/elements/basics/PQTabSeparator.qml
                qml/elements/basics/PQText.qml
                qml/elements/basics/PQTextArea.qml
                qml/elements/basics/PQTextL.qml
                qml/elements/basics/PQTextS.qml
                qml/elements/basics/PQTextXL.qml
                qml/elements/basics/PQTextXXL.qml
                qml/elements/basics/PQToolTip.qml
                qml/elements/basics/PQVerticalScrollBar.qml

                qml/elements/compounds/PQMainMenuEntry.qml
                qml/elements/compounds/PQMainMenuIcon.qml
                qml/elements/compounds/PQMetaDataEntry.qml
                qml/elements/compounds/PQTemplatePopout.qml

                qml/elements/extensions/PQTemplateExtension.qml
                qml/elements/extensions/PQTemplateExtensionContainer.qml
                qml/elements/extensions/PQTemplateExtensionFloating.qml
                qml/elements/extensions/PQTemplateExtensionFloatingPopout.qml
                qml/elements/extensions/PQTemplateExtensionModal.qml
                qml/elements/extensions/PQTemplateExtensionModalPopout.qml
                qml/elements/extensions/PQTemplateExtensionSettings.qml

                qml/elements/templates/PQTemplate.qml
                qml/elements/templates/PQTemplateModal.qml
                qml/elements/templates/PQTemplateModalPopout.qml

                qml/filedialog/PQFileDialog.qml
                qml/filedialog/PQFileDialogNative.qml

                qml/filedialog/parts/PQPlaces.qml
                qml/filedialog/parts/PQFileView.qml
                qml/filedialog/parts/PQTweaks.qml
                qml/filedialog/parts/PQPreview.qml
                qml/filedialog/parts/PQPasteExistingConfirm.qml
                qml/filedialog/parts/PQFileDialogSettingsMenu.qml
                qml/filedialog/parts/PQBreadCrumbs.qml

                qml/filedialog/elements/PQFileDialogButtonElement.qml
                qml/filedialog/elements/PQFileDeleteConfirm.qml
                qml/filedialog/elements/PQFileDialogComboBox.qml
                qml/filedialog/elements/PQFileDialogButton.qml
                qml/filedialog/elements/PQFileDialogScrollBar.qml
                qml/filedialog/elements/PQFileDialogSlider.qml

                qml/filedialog/parts/fileviews/PQFileViewList.qml
                qml/filedialog/parts/fileviews/PQFileViewGrid.qml
                qml/filedialog/parts/fileviews/PQFileViewMasonry.qml

                qml/filedialog/parts/fileviews/parts/PQFolderThumb.qml
                qml/filedialog/parts/fileviews/parts/PQFileThumb.qml
                qml/filedialog/parts/fileviews/parts/PQFileIcon.qml

                qml/actions/PQFilter.qml
                qml/actions/PQSlideshowSetup.qml
                qml/actions/PQAdvancedSort.qml
                qml/actions/PQAbout.qml
                qml/actions/PQChromeCastManager.qml
                qml/actions/PQCopy.qml
                qml/actions/PQMove.qml
                qml/actions/PQRename.qml
                qml/actions/PQDelete.qml

                qml/ongoing/PQThumbnails.qml
                qml/ongoing/PQTrayIcon.qml
                qml/ongoing/PQContextMenu.qml
                qml/ongoing/PQNotification.qml
                qml/ongoing/PQSlideshowControls.qml
                qml/ongoing/PQLogging.qml
                qml/ongoing/PQChromeCast.qml

                qml/ongoing/modern/PQStatusInfoModern.qml
                qml/ongoing/modern/PQMainMenuModern.qml
                qml/ongoing/modern/PQMetaDataModern.qml
                qml/ongoing/modern/PQWindowButtonsModern.qml
                qml/ongoing/modern/PQWindowHandlesModern.qml
                qml/ongoing/modern/PQMainMenuModernPopout.qml
                qml/ongoing/modern/PQMetaDataModernPopout.qml
                qml/ongoing/modern/PQSlideshowControlsModernPopout.qml

                qml/other/PQShortcuts.qml
                qml/other/PQMultiEffect.qml
                qml/other/PQShadowEffect.qml
                qml/other/PQWorking.qml
                qml/other/PQScrollManager.qml
                qml/other/PQSlideshowHandler.qml
                qml/other/PQCommonFunctions.js
                qml/other/PQGenericStuff.qml
                qml/other/PQToolTipDisplay.qml
                qml/other/PQLoader.qml
                qml/other/PQMasterItem.qml

                qml/other/integrated/PQSideBarIntegrated.qml
                qml/other/integrated/PQMenuBarIntegrated.qml
                qml/other/integrated/PQFooterIntegrated.qml
                qml/other/integrated/PQBackgroundMessageIntegrated.qml

                qml/other/modern/PQMainWindowBackgroundModern.qml
                qml/other/modern/PQBackgroundMessageModern.qml
                qml/other/modern/PQGestureTouchAreasModern.qml

                qml/image/PQImage.qml
                qml/image/PQImageDisplay.qml

                qml/image/imageitems/PQImageNormal.qml
                qml/image/imageitems/PQImageAnimated.qml
                qml/image/imageitems/PQVideoMpv.qml
                qml/image/imageitems/PQVideoQt.qml
                qml/image/imageitems/PQArchive.qml
                qml/image/imageitems/PQPhotoSphere.qml
                qml/image/imageitems/PQDocument.qml
                qml/image/imageitems/PQSVG.qml

                qml/image/components/PQKenBurnsSlideshowEffect.qml
                qml/image/components/PQKenBurnsSlideshowBackground.qml
                qml/image/components/PQBarCodes.qml
                qml/image/components/PQMinimap.qml
                qml/image/components/PQAnimatedImageControls.qml
                qml/image/components/PQArchiveControls.qml
                qml/image/components/PQVideoControls.qml
                qml/image/components/PQPhotoSphereControls.qml
                qml/image/components/PQDocumentControls.qml
                qml/image/components/PQMotionPhotoControls.qml
                qml/image/components/PQFaceTracker.qml
                qml/image/components/PQFaceTagger.qml

                qml/settingsmanager/PQSettingsManager.qml
                qml/settingsmanager/PQSettingsTabs.qml
                qml/settingsmanager/PQSettingsConfirmUnsaved.qml

                qml/settingsmanager/elements/PQSettingsSeparator.qml
                qml/settingsmanager/elements/PQSetting.qml
                qml/settingsmanager/elements/PQSettingSubtitle.qml
                qml/settingsmanager/elements/PQSettingSpacer.qml
                qml/settingsmanager/elements/PQSettingsResetButton.qml

                qml/settingsmanager/interface/PQSettingsInterfaceAccentColor.qml
                qml/settingsmanager/interface/PQSettingsInterfaceBackground.qml
                qml/settingsmanager/interface/PQSettingsInterfaceContextMenu.qml
                qml/settingsmanager/interface/PQSettingsInterfaceEdges.qml
                qml/settingsmanager/interface/PQSettingsInterfaceFontWeight.qml
                qml/settingsmanager/interface/PQSettingsInterfaceOverallInterface.qml
                qml/settingsmanager/interface/PQSettingsInterfaceNotification.qml
                qml/settingsmanager/interface/PQSettingsInterfacePopout.qml
                qml/settingsmanager/interface/PQSettingsInterfaceStatusInfo.qml
                qml/settingsmanager/interface/PQSettingsInterfaceWindowButtons.qml
                qml/settingsmanager/interface/PQSettingsInterfaceWindowMode.qml

                qml/settingsmanager/imageview/PQSettingsImageViewCache.qml
                qml/settingsmanager/imageview/PQSettingsImageViewImageProcessing.qml
                qml/settingsmanager/imageview/PQSettingsImageViewMetadata.qml
                qml/settingsmanager/imageview/PQSettingsImageViewFaceTags.qml
                qml/settingsmanager/imageview/PQSettingsImageViewFileList.qml
                qml/settingsmanager/imageview/PQSettingsImageViewLook.qml
                qml/settingsmanager/imageview/PQSettingsImageViewShareOnline.qml
                qml/settingsmanager/imageview/PQSettingsImageViewInteraction.qml

                qml/settingsmanager/thumbnails/PQSettingsThumbnailsBar.qml
                qml/settingsmanager/thumbnails/PQSettingsThumbnailsImage.qml
                qml/settingsmanager/thumbnails/PQSettingsThumbnailsInfo.qml
                qml/settingsmanager/thumbnails/PQSettingsThumbnailsManage.qml

                qml/settingsmanager/filetypes/PQSettingsFiletypesList.qml
                qml/settingsmanager/filetypes/PQSettingsFiletypesAnimated.qml
                qml/settingsmanager/filetypes/PQSettingsFiletypesArchives.qml
                qml/settingsmanager/filetypes/PQSettingsFiletypesDocuments.qml
                qml/settingsmanager/filetypes/PQSettingsFiletypesMotion.qml
                qml/settingsmanager/filetypes/PQSettingsFiletypesRAW.qml
                qml/settingsmanager/filetypes/PQSettingsFiletypesSpheres.qml
                qml/settingsmanager/filetypes/PQSettingsFiletypesVideos.qml

                qml/settingsmanager/manage/PQSettingsManageSession.qml
                qml/settingsmanager/manage/PQSettingsManageTrayIcon.qml
                qml/settingsmanager/manage/PQSettingsManageManage.qml

                qml/settingsmanager/shortcuts/PQSettingsShortcutsList.qml
                qml/settingsmanager/shortcuts/PQSettingsShortcutsExtraMouse.qml
                qml/settingsmanager/shortcuts/PQSettingsShortcutsExtraKeys.qml
                qml/settingsmanager/shortcuts/PQSettingsShortcutsDetectNew.qml
                qml/settingsmanager/shortcuts/PQSettingsShortcutsExternalShortcuts.qml
                qml/settingsmanager/shortcuts/PQSettingsShortcutsDuplicateShortcuts.qml

                qml/settingsmanager/shortcuts/settings/PQSettingsShortcutsSiblingSettings.qml

                qml/settingsmanager/extensions/PQSettingsExtensionsManage.qml
                qml/settingsmanager/extensions/PQSettingsExtensionsShortcuts.qml

                qml/settingsmanager/other/PQSettingsOtherFileDialog.qml
                qml/settingsmanager/other/PQSettingsOtherSlideshow.qml

                qml/mapexplorer/PQMapExplorer.qml

                qml/mapexplorer/parts/PQMapExplorerImages.qml
                qml/mapexplorer/parts/PQMapExplorerImagesTweaks.qml
                qml/mapexplorer/parts/PQMapExplorerMap.qml
                qml/mapexplorer/parts/PQMapExplorerMapTweaks.qml)

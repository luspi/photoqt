/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick
import PQCExtensionsHandler
import PhotoQt

Item {

    id: loader_top

    anchors.fill: parent

    /*********************************************************************/

    Loader {
        id: loader_metadata
        active: false
        asynchronous: true
        sourceComponent: ((PQCSettings.interfacePopoutMetadata || PQCWindowGeometry.metadataForcePopout) ? comp_metadata_popout : comp_metadata)
    }
    Component { id: comp_metadata; PQMetaDataModern {} }
    Component { id: comp_metadata_popout; PQMetaDataModernPopout {} }

    /*********************************************************************/

    Loader {
        id: loader_settingsmanager
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutSettingsManager || PQCWindowGeometry.settingsmanagerForcePopout) ? comp_settingsmanager_popout : comp_settingsmanager)
    }
    Component {
        id: comp_settingsmanager
        PQTemplateModal {
            id: smmod
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            content: PQSettingsManager {
                id: tmpl
                button1: smmod.button1
                button2: smmod.button2
                button3: smmod.button3
                bottomLeft: smmod.bottomLeft
                popInOutButton: smmod.popInOutButton
                availableHeight: smmod.contentHeight-smmod.bottomrowHeight-smmod.toprowHeight
                Component.onCompleted: {
                    smmod.elementId = elementId
                    smmod.title = title
                    smmod.letElementHandleClosing = letMeHandleClosing
                    smmod.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }
    Component {
        id: comp_settingsmanager_popout
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.settingsmanagerGeometry
            defaultPopoutMaximized: PQCWindowGeometry.settingsmanagerMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            onRectUpdated: (r) => {
                PQCWindowGeometry.settingsmanagerGeometry = r
            }
            onMaximizedUpdated: (m) => {
                PQCWindowGeometry.settingsmanagerMaximized = m
            }
            content: PQSettingsManager {
                id: tmpl
                button1: smpop.button1
                button2: smpop.button2
                button3: smpop.button3
                bottomLeft: smpop.bottomLeft
                popInOutButton: smpop.popInOutButton
                availableHeight: smpop.contentHeight-smpop.bottomrowHeight-smpop.toprowHeight
                Component.onCompleted: {
                    smpop.elementId = elementId
                    smpop.title = title
                    smpop.letElementHandleClosing = letMeHandleClosing
                    smpop.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }

    /*********************************************************************/

    // Loader {
    //     id: loader_filerename
    //     active: false
    //     anchors.fill: parent
    //     sourceComponent: ((PQCSettings.interfacePopoutFileRename || PQCWindowGeometry.filerenameForcePopout) ? comp_filerename_popout : comp_filerename)
    // }
    // Component {
    //     id: comp_filerename
    //     PQTemplateModal {
    //         id: smmod
    //         onShowing: tmpl.showing()
    //         onHiding: tmpl.hiding()
    //         content: PQRename {
    //             id: tmpl
    //             button1: smmod.button1
    //             button2: smmod.button2
    //             button3: smmod.button3
    //             bottomLeft: smmod.bottomLeft
    //             popInOutButton: smmod.popInOutButton
    //             availableHeight: smmod.contentHeight
    //             Component.onCompleted: {
    //                 smmod.elementId = elementId
    //                 smmod.title = title
    //                 smmod.letElementHandleClosing = letMeHandleClosing
    //                 smmod.bottomLeftContent = bottomLeftContent
    //             }
    //         }
    //     }
    // }
    // Component {
    //     id: comp_filerename_popout
    //     PQTemplateModalPopout {
    //         id: smpop
    //         defaultPopoutGeometry: PQCWindowGeometry.filerenameGeometry
    //         defaultPopoutMaximized: PQCWindowGeometry.filerenameMaximized
    //         onShowing: tmpl.showing()
    //         onHiding: tmpl.hiding()
    //         onRectUpdated: (r) => {
    //             PQCWindowGeometry.filerenameGeometry = r
    //         }
    //         onMaximizedUpdated: (m) => {
    //             PQCWindowGeometry.filerenameMaximized = m
    //         }
    //         content: PQRename {
    //             id: tmpl
    //             button1: smpop.button1
    //             button2: smpop.button2
    //             button3: smpop.button3
    //             bottomLeft: smpop.bottomLeft
    //             popInOutButton: smpop.popInOutButton
    //             availableHeight: smpop.contentHeight
    //             Component.onCompleted: {
    //                 smpop.elementId = elementId
    //                 smpop.title = title
    //                 smpop.letElementHandleClosing = letMeHandleClosing
    //                 smpop.bottomLeftContent = bottomLeftContent
    //             }
    //         }
    //     }
    // }

    /*********************************************************************/

    Loader {
        id: loader_mapexplorer
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutMapExplorer || PQCWindowGeometry.mapexplorerForcePopout) ? comp_mapexplorer_popout : comp_mapexplorer)
    }
    Component {
        id: comp_mapexplorer
        PQTemplateModal {
            id: smmod
            showTopBottom: false
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            content: PQMapExplorer {
                id: tmpl
                button1: smmod.button1
                button2: smmod.button2
                button3: smmod.button3
                bottomLeft: smmod.bottomLeft
                popInOutButton: smmod.popInOutButton
                availableHeight: smmod.contentHeight
                Component.onCompleted: {
                    smmod.elementId = elementId
                    smmod.title = title
                    smmod.letElementHandleClosing = letMeHandleClosing
                    smmod.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }
    Component {
        id: comp_mapexplorer_popout
        PQTemplateModalPopout {
            id: smpop
            showTopBottom: false
            defaultPopoutGeometry: PQCWindowGeometry.mapexplorerGeometry
            defaultPopoutMaximized: PQCWindowGeometry.mapexplorerMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            onRectUpdated: (r) => {
                PQCWindowGeometry.mapexplorerGeometry = r
            }
            onMaximizedUpdated: (m) => {
                PQCWindowGeometry.mapexplorerMaximized = m
            }
            content: PQMapExplorer {
                id: tmpl
                button1: smpop.button1
                button2: smpop.button2
                button3: smpop.button3
                bottomLeft: smpop.bottomLeft
                popInOutButton: smpop.popInOutButton
                availableHeight: smpop.contentHeight
                Component.onCompleted: {
                    smpop.elementId = elementId
                    smpop.title = title
                    smpop.letElementHandleClosing = letMeHandleClosing
                    smpop.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }

    /*********************************************************************/

    Loader {
        id: loader_filter
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutFilter || PQCWindowGeometry.filterForcePopout) ? comp_filter_popout : comp_filter)
    }
    Component {
        id: comp_filter
        PQTemplateModal {
            id: smmod
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            content: PQFilter {
                id: tmpl
                button1: smmod.button1
                button2: smmod.button2
                button3: smmod.button3
                bottomLeft: smmod.bottomLeft
                popInOutButton: smmod.popInOutButton
                availableHeight: smmod.contentHeight
                Component.onCompleted: {
                    smmod.elementId = elementId
                    smmod.title = title
                    smmod.letElementHandleClosing = letMeHandleClosing
                    smmod.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }
    Component {
        id: comp_filter_popout
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.filterGeometry
            defaultPopoutMaximized: PQCWindowGeometry.filterMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            onRectUpdated: (r) => {
                PQCWindowGeometry.filterGeometry = r
            }
            onMaximizedUpdated: (m) => {
                PQCWindowGeometry.filterMaximized = m
            }
            content: PQFilter {
                id: tmpl
                button1: smpop.button1
                button2: smpop.button2
                button3: smpop.button3
                bottomLeft: smpop.bottomLeft
                popInOutButton: smpop.popInOutButton
                availableHeight: smpop.contentHeight
                Component.onCompleted: {
                    smpop.elementId = elementId
                    smpop.title = title
                    smpop.letElementHandleClosing = letMeHandleClosing
                    smpop.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }

    /*********************************************************************/

    Loader {
        id: loader_slideshowsetup
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutSlideshowSetup || PQCWindowGeometry.slideshowSetupForcePopout) ? comp_slideshowsetup_popout : comp_slideshowsetup)
    }
    Component {
        id: comp_slideshowsetup
        PQTemplateModal {
            id: smmod
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            content: PQSlideshowSetup {
                id: tmpl
                button1: smmod.button1
                button2: smmod.button2
                button3: smmod.button3
                bottomLeft: smmod.bottomLeft
                popInOutButton: smmod.popInOutButton
                availableHeight: smmod.contentHeight
                Component.onCompleted: {
                    smmod.elementId = elementId
                    smmod.title = title
                    smmod.letElementHandleClosing = letMeHandleClosing
                    smmod.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }
    Component {
        id: comp_slideshowsetup_popout
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.slideshowsetupGeometry
            defaultPopoutMaximized: PQCWindowGeometry.slideshowsetupMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            onRectUpdated: (r) => {
                PQCWindowGeometry.filterGeometry = r
            }
            onMaximizedUpdated: (m) => {
                PQCWindowGeometry.filterMaximized = m
            }
            content: PQSlideshowSetup {
                id: tmpl
                button1: smpop.button1
                button2: smpop.button2
                button3: smpop.button3
                bottomLeft: smpop.bottomLeft
                popInOutButton: smpop.popInOutButton
                availableHeight: smpop.contentHeight
                Component.onCompleted: {
                    smpop.elementId = elementId
                    smpop.title = title
                    smpop.letElementHandleClosing = letMeHandleClosing
                    smpop.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }

    /*********************************************************************/

    Loader {
        id: loader_advancedsort
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutAdvancedSort || PQCWindowGeometry.advancedsortForcePopout) ? comp_advancedsort_popout : comp_advancedsort)
    }
    Component {
        id: comp_advancedsort
        PQTemplateModal {
            id: smmod
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            content: PQAdvancedSort {
                id: tmpl
                button1: smmod.button1
                button2: smmod.button2
                button3: smmod.button3
                bottomLeft: smmod.bottomLeft
                popInOutButton: smmod.popInOutButton
                availableHeight: smmod.contentHeight
                Component.onCompleted: {
                    smmod.elementId = elementId
                    smmod.title = title
                    smmod.letElementHandleClosing = letMeHandleClosing
                    smmod.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }
    Component {
        id: comp_advancedsort_popout
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.advancedsortGeometry
            defaultPopoutMaximized: PQCWindowGeometry.advancedsortMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            onRectUpdated: (r) => {
                PQCWindowGeometry.advancedsortGeometry = r
            }
            onMaximizedUpdated: (m) => {
                PQCWindowGeometry.advancedsortMaximized = m
            }
            content: PQAdvancedSort {
                id: tmpl
                button1: smpop.button1
                button2: smpop.button2
                button3: smpop.button3
                bottomLeft: smpop.bottomLeft
                popInOutButton: smpop.popInOutButton
                availableHeight: smpop.contentHeight
                Component.onCompleted: {
                    smpop.elementId = elementId
                    smpop.title = title
                    smpop.letElementHandleClosing = letMeHandleClosing
                    smpop.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }

    /*********************************************************************/

    Loader {
        id: loader_about
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutAbout || PQCWindowGeometry.aboutForcePopout) ? comp_about_popout : comp_about)
    }
    Component {
        id: comp_about
        PQTemplateModal {
            id: smmod
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            content: PQAbout {
                id: tmpl
                button1: smmod.button1
                button2: smmod.button2
                button3: smmod.button3
                bottomLeft: smmod.bottomLeft
                popInOutButton: smmod.popInOutButton
                availableHeight: smmod.contentHeight
                Component.onCompleted: {
                    smmod.elementId = elementId
                    smmod.title = title
                    smmod.letElementHandleClosing = letMeHandleClosing
                    smmod.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }
    Component {
        id: comp_about_popout
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.aboutGeometry
            defaultPopoutMaximized: PQCWindowGeometry.aboutMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            onRectUpdated: (r) => {
                PQCWindowGeometry.aboutGeometry = r
            }
            onMaximizedUpdated: (m) => {
                PQCWindowGeometry.aboutMaximized = m
            }
            content: PQAbout {
                id: tmpl
                button1: smpop.button1
                button2: smpop.button2
                button3: smpop.button3
                bottomLeft: smpop.bottomLeft
                popInOutButton: smpop.popInOutButton
                availableHeight: smpop.contentHeight
                Component.onCompleted: {
                    smpop.elementId = elementId
                    smpop.title = title
                    smpop.letElementHandleClosing = letMeHandleClosing
                    smpop.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }

    /*********************************************************************/

    Loader {
        id: loader_mainmenu
        active: false
        asynchronous: true
        sourceComponent: ((PQCSettings.interfacePopoutMainMenu|| PQCWindowGeometry.mainmenuForcePopout) ? comp_mainmenu_popout : comp_mainmenu)
    }
    Component { id: comp_mainmenu; PQMainMenuModern {} }
    Component { id: comp_mainmenu_popout; PQMainMenuModernPopout {} }

    /*********************************************************************/

    // Loader {
    //     id: loader_filedelete
    //     active: false
    //     anchors.fill: parent
    //     sourceComponent: ((PQCSettings.interfacePopoutFileDelete || PQCWindowGeometry.filedeleteForcePopout) ? comp_filedelete_popout : comp_filedelete)
    // }
    // Component {
    //     id: comp_filedelete
    //     PQTemplateModal {
    //         id: smmod
    //         onShowing: tmpl.showing()
    //         onHiding: tmpl.hiding()
    //         content: PQDelete {
    //             id: tmpl
    //             button1: smmod.button1
    //             button2: smmod.button2
    //             button3: smmod.button3
    //             bottomLeft: smmod.bottomLeft
    //             popInOutButton: smmod.popInOutButton
    //             availableHeight: smmod.contentHeight
    //             Component.onCompleted: {
    //                 smmod.elementId = elementId
    //                 smmod.title = title
    //                 smmod.letElementHandleClosing = letMeHandleClosing
    //                 smmod.bottomLeftContent = bottomLeftContent
    //             }
    //         }
    //     }
    // }
    // Component {
    //     id: comp_filedelete_popout
    //     PQTemplateModalPopout {
    //         id: smpop
    //         defaultPopoutGeometry: PQCWindowGeometry.filedeleteGeometry
    //         defaultPopoutMaximized: PQCWindowGeometry.filedeleteMaximized
    //         onShowing: tmpl.showing()
    //         onHiding: tmpl.hiding()
    //         onRectUpdated: (r) => {
    //             PQCWindowGeometry.filedeleteGeometry = r
    //         }
    //         onMaximizedUpdated: (m) => {
    //             PQCWindowGeometry.filedeleteMaximized = m
    //         }
    //         content: PQDelete {
    //             id: tmpl
    //             button1: smpop.button1
    //             button2: smpop.button2
    //             button3: smpop.button3
    //             bottomLeft: smpop.bottomLeft
    //             popInOutButton: smpop.popInOutButton
    //             availableHeight: smpop.contentHeight
    //             Component.onCompleted: {
    //                 smpop.elementId = elementId
    //                 smpop.title = title
    //                 smpop.letElementHandleClosing = letMeHandleClosing
    //                 smpop.bottomLeftContent = bottomLeftContent
    //             }
    //         }
    //     }
    // }

    Loader {
        id: loader_rename
        active: false
        anchors.fill: parent
        sourceComponent: PQRename {}
    }

    Loader {
        id: loader_delete
        active: false
        anchors.fill: parent
        sourceComponent: PQDelete {}
    }

    /*********************************************************************/

    Loader {
        id: loader_filecopy
        active: false
        sourceComponent: PQCopy {}
    }

    /*********************************************************************/

    Loader {
        id: loader_filemove
        active: false
        sourceComponent: PQMove {}
    }

    /*********************************************************************/

    Loader {
        id: loader_logging
        active: false
        sourceComponent: PQLogging {}
    }

    /*********************************************************************/

    Loader {
        id: loader_slideshowhandler
        active: false
        sourceComponent: PQSlideshowHandler {}
    }

    /*********************************************************************/

    Loader {
        id: loader_slideshowcontrols
        active: false
        sourceComponent: ((PQCSettings.interfacePopoutSlideshowControls || PQCWindowGeometry.slideshowcontrolsForcePopout) ? comp_slideshowcontrols_popout : comp_slideshowcontrols)
    }
    Component { id: comp_slideshowcontrols; PQSlideshowControls {} }
    Component { id: comp_slideshowcontrols_popout; PQSlideshowControlsModernPopout {} }

    /*********************************************************************/

    Loader {
        id: loader_notification
        active: false
        sourceComponent: PQNotification {}
    }

    /*********************************************************************/

    Loader {
        id: loader_chromecastmanager
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutChromecast || PQCWindowGeometry.chromecastmanagerForcePopout) ? comp_chromecastmanager_popout : comp_chromecastmanager)
    }
    Component {
        id: comp_chromecastmanager
        PQTemplateModal {
            id: smmod
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            content: PQChromeCastManager {
                id: tmpl
                button1: smmod.button1
                button2: smmod.button2
                button3: smmod.button3
                bottomLeft: smmod.bottomLeft
                popInOutButton: smmod.popInOutButton
                availableHeight: smmod.contentHeight
                Component.onCompleted: {
                    smmod.elementId = elementId
                    smmod.title = title
                    smmod.letElementHandleClosing = letMeHandleClosing
                    smmod.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }
    Component {
        id: comp_chromecastmanager_popout
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.chromecastmanagerGeometry
            defaultPopoutMaximized: PQCWindowGeometry.chromecastmanagerMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            onRectUpdated: (r) => {
                PQCWindowGeometry.chromecastmanagerGeometry = r
            }
            onMaximizedUpdated: (m) => {
                PQCWindowGeometry.chromecastmanagerMaximized = m
            }
            content: PQChromeCastManager {
                id: tmpl
                button1: smpop.button1
                button2: smpop.button2
                button3: smpop.button3
                bottomLeft: smpop.bottomLeft
                popInOutButton: smpop.popInOutButton
                availableHeight: smpop.contentHeight
                Component.onCompleted: {
                    smpop.elementId = elementId
                    smpop.title = title
                    smpop.letElementHandleClosing = letMeHandleClosing
                    smpop.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }

    /*********************************************************************/

    Loader {
        id: loader_chromecast
        active: false
        sourceComponent: PQChromeCast {}
    }

    /*********************************************************************/

    property var idToLoader: {
        "About" :               [loader_about,              true],
        "MetaData" :            [loader_metadata,           false],
        "MainMenu" :            [loader_mainmenu,           false],
        "SettingsManager" :     [loader_settingsmanager,    true],
        "FileDelete" :          [loader_delete,         true],
        "FileRename" :          [loader_rename,         true],
        "FileCopy" :            [loader_filecopy,           true],
        "FileMove" :            [loader_filemove,           true],
        "Filter" :              [loader_filter,             true],
        "AdvancedSort" :        [loader_advancedsort,       true],
        "Logging" :             [loader_logging,            false],
        "SlideshowSetup" :      [loader_slideshowsetup,     true],
        "SlideshowHandler" :    [loader_slideshowhandler,   true],
        "SlideshowControls" :   [loader_slideshowcontrols,  false],
        "Notification" :        [loader_notification,       false],
        "MapExplorer" :         [loader_mapexplorer,        true],
        "ChromecastManager" :   [loader_chromecastmanager,  true],
        "Chromecast" :          [loader_chromecast,         false],
    }

    // source, loader id, modal, popout, force popout
    property var loadermapping: ({})

    function show(ele : string, additional : list<var>) : void {

        if(ele === "Chromecast" && PQCConstants.idOfVisibleItem === "ChromecastManager") {
            ensureItIsReady(ele)
            return
        }

        if(ele === "ChromecastManager" && !PQCScriptsConfig.isChromecastEnabled()) {
            console.log("Feature unavailable: The chromecast feature is not available in this build of PhotoQt.")
            PQCNotify.showNotificationMessage(qsTranslate("unavailable", "Feature unavailable"), qsTranslate("unavailable", "The chromecast feature is not available in this build of PhotoQt."))
            return
        } else if(ele === "MapExplorer" && !PQCScriptsConfig.isLocationSupportEnabled()) {
            console.log("Feature unavailable: The location feature is not available in this build of PhotoQt.")
            PQCNotify.showNotificationMessage(qsTranslate("unavailable", "Feature unavailable"), qsTranslate("unavailable", "The location feature is not available in this build of PhotoQt."))
            return
        }

        var ind = PQCExtensionsHandler.getExtensions().indexOf(ele)
        if(ind > -1) {

            if(PQCExtensionsHandler.getExtensionModalMake(ele)) {
                if(PQCConstants.idOfVisibleItem !== "")
                    return
                else
                    PQCConstants.idOfVisibleItem = ele
            }
            ensureExtensionIsReady(ele, ind)

            if(!loader_extensions.itemAt(ind).item) {
                if(showWhenReady.args.length == 0) {
                    showWhenReady.theloader = loader_extensions.itemAt(ind)
                    if(additional.length === 0)
                        showWhenReady.args = [ele]
                    else
                        showWhenReady.args = [ele, additional]
                    showWhenReady.start()
                } else if(showWhenReady2.args.length == 0) {
                    showWhenReady2.theloader = loader_extensions.itemAt(ind)
                    if(additional.length === 0)
                        showWhenReady2.args = [ele]
                    else
                        showWhenReady2.args = [ele, additional]
                    showWhenReady2.start()
                } else
                    console.error("Unable to set up extension, too few timers available.")
            } else {
                if(additional.length === 0)
                    PQCNotify.loaderPassOn("show", [ele])
                else
                    PQCNotify.loaderPassOn("show", [ele, additional])
            }

        } else if(!(ele in idToLoader)) {
            console.log("Unknown element encountered:", ele)
            return
        } else {

            var config = idToLoader[ele]

            if(config[1] && PQCConstants.idOfVisibleItem !== "")
                return

            if(config[1] &&
                (ele !== "MapExplorer" || !PQCSettings.interfacePopoutMapExplorer || (PQCSettings.interfacePopoutMapExplorer && !PQCSettings.interfacePopoutMapExplorerNonModal)) &&
                (ele !== "SettingsManager" || !PQCSettings.interfacePopoutSettingsManager || (PQCSettings.interfacePopoutSettingsManager && !PQCSettings.interfacePopoutSettingsManagerNonModal)))
                PQCConstants.idOfVisibleItem = ele

            if(config[0].status !== Loader.Ready) {

                if(showWhenReady.args.length == 0) {
                    showWhenReady.theloader = config[0]
                    if(additional.length === 0)
                        showWhenReady.args = [ele]
                    else
                        showWhenReady.args = [ele, additional]
                    showWhenReady.start()
                } else if(showWhenReady2.args.length == 0) {
                    showWhenReady2.theloader = config[0]
                    if(additional.length === 0)
                        showWhenReady2.args = [ele]
                    else
                        showWhenReady2.args = [ele, additional]
                    showWhenReady2.start()
                } else
                    console.error("Unable to set up item, too few timers available.")
            } else {
                if(additional.length === 0)
                    PQCNotify.loaderPassOn("show", [ele])
                else
                    PQCNotify.loaderPassOn("show", [ele, additional])
            }

        }

    }

    Timer {
        id: showWhenReady
        property Loader theloader
        property list<var> args: []
        interval: 10
        triggeredOnStart: true
        onTriggered: {
            if(theloader.status !== Loader.Ready) {
                showWhenReady.start()
                return
            }
            PQCNotify.loaderPassOn("show", args)
            args = []
        }
    }

    Timer {
        id: showWhenReady2
        property Loader theloader
        property list<var> args: []
        interval: 10
        triggeredOnStart: true
        onTriggered: {
            if(theloader.status !== Loader.Ready) {
                showWhenReady2.start()
                return
            }
            PQCNotify.loaderPassOn("show", args)
            args = []
        }
    }

    function elementOpened(ele : string) {
        PQCConstants.idOfVisibleItem = ele
    }

    function elementClosed(ele : string) {
        PQCConstants.idOfVisibleItem = ""
    }

    function ensureItIsReady(ele : string) {

        console.log("args: ele =", ele)

        if(ele in idToLoader)
            idToLoader[ele][0].active = true

    }

    function ensureExtensionIsReady(ele : string, ind : int) {

        console.log("args: ele =", ele)
        console.log("args: ind =", ind)

        loader_extensions.itemAt(ind).active = true

        // modal elements need to be shown on top, above things like mainmenu or metadata
        // The value should be high but lower than that of the window buttons that are shown on top (currently set to 999)
        if(PQCExtensionsHandler.getExtensionModalMake(ele))
            loader_extensions.itemAt(ind).z = 888

    }

    function resetAll() {
        console.warn("## TODO: implement PQLoader::resetAll()")
    }

    property string visibleItemBackup: ""

    Connections {

        target: PQCNotify

        function onShowNotificationMessage(title : string, msg : string) {
            if(!loader_notification.active)
                loader_notification.active = true
            loader_top.show("Notification", [title, msg])
        }

    }

    Connections {

        target: PQCNotify

        function onOpenSettingsManagerAt(category : string, subcategory : string) {
            loader_top.ensureItIsReady("SettingsManager")
            PQCNotify.loaderPassOn("showSettings", [subcategory])
        }

    }

    Connections {

        target: PQCNotify

        function onLoaderRegisterOpen(ele : string) {
            loader_top.elementOpened(ele)
        }

        function onLoaderRegisterClose(ele : string) {
            loader_top.elementClosed(ele)
        }

        function onLoaderShow(ele : string) {
            loader_top.ensureItIsReady(ele)
            loader_top.show(ele, [])
        }

        function onLoaderShowExtension(ele : string) {
            loader_top.ensureExtensionIsReady(ele, PQCExtensionsHandler.getExtensions().indexOf(ele))
            loader_top.show(ele, [])
        }

        function onLoaderSetup(ele : string) {
            loader_top.ensureItIsReady(ele)
        }

        function onLoaderSetupExtension(ele : string) {
            loader_top.ensureExtensionIsReady(ele, PQCExtensionsHandler.getExtensions().indexOf(ele))
        }

        function onLoaderOverrideVisibleItem(ele : string) {
            loader_top.visibleItemBackup = PQCConstants.idOfVisibleItem
            PQCConstants.idOfVisibleItem = ele
        }

        function onLoaderRestoreVisibleItem() {
            if(loader_top.visibleItemBackup != "") {
                PQCConstants.idOfVisibleItem = loader_top.visibleItemBackup
                loader_top.visibleItemBackup = ""
            }
        }

    }

}

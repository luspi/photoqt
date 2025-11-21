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
import PhotoQt
import PQCExtensionsHandler

Item {

    id: loader_top

    anchors.fill: parent

    signal showExtension(var ele)

    property bool isModern: PQCSettings.generalInterfaceVariant==="modern"
    property bool isIntegrated: !isModern

    Component.onCompleted: {
        isModern = isModern
        isIntegrated = isIntegrated
    }

    /*********************************************************************/

    /**************************************/
    // MODERN INTERFACE ONLY
        Loader {
            id: windowbuttons
            asynchronous: true
            active: loader_top.isModern
            sourceComponent: PQWindowButtonsModern {}
        }
        Loader {
            id: windowbuttons_ontop
            asynchronous: true
            active: loader_top.isModern
            sourceComponent: PQWindowButtonsModern {}
            visible: opacity>0
            opacity: PQCConstants.idOfVisibleItem!=="" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            z: PQCConstants.idOfVisibleItem!=="FileDialog" ? 999 : 0
            onStatusChanged: {
                if(windowbuttons_ontop.status == Loader.Ready)
                    windowbuttons_ontop.item.visibleAlways = true
            }
        }
        Loader {
            id: statusinfo
            active: loader_top.isModern
            asynchronous: true
            sourceComponent: PQStatusInfoModern {}
        }
    /**************************************/

    /*********************************************************************/

    Loader {
        id: loader_about
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutAbout || PQCWindowGeometry.aboutForcePopout || loader_top.isIntegrated) ? comp_about_popout : comp_about)
    }
    Component {
        id: comp_about
        PQTemplateModal {
            id: smmod
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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

    Loader {
        id: loader_copy
        active: false
        sourceComponent: PQCopy {}
    }

    Loader {
        id: loader_move
        active: false
        sourceComponent: PQMove {}
    }

    /*********************************************************************/

    Loader {
        id: loader_settingsmanager
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutSettingsManager || PQCWindowGeometry.settingsmanagerForcePopout || loader_top.isIntegrated) ? comp_settingsmanager_popout : comp_settingsmanager)
    }
    Component {
        id: comp_settingsmanager
        PQTemplateModal {
            id: smmod
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
            content: PQSettingsManager {
                id: tmpl
                button1: smmod.button1
                button2: smmod.button2
                button3: smmod.button3
                bottomLeft: smmod.bottomLeft
                popInOutButton: smmod.popInOutButton
                availableHeight: smmod.contentHeight - (loader_top.isModern ? (smmod.bottomrowHeight+smmod.toprowHeight) : 0)
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
            popInOutButton.visible: loader_top.isModern
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
                availableHeight: smpop.contentHeight - (loader_top.isModern ? (smpop.bottomrowHeight+smpop.toprowHeight) : 0)
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
        id: loader_mapexplorer
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutMapExplorer || PQCWindowGeometry.mapexplorerForcePopout || loader_top.isIntegrated) ? comp_mapexplorer_popout : comp_mapexplorer)
    }
    Component {
        id: comp_mapexplorer
        PQTemplateModal {
            id: smmod
            showTopBottom: false
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
        sourceComponent: ((PQCSettings.interfacePopoutFilter || PQCWindowGeometry.filterForcePopout || loader_top.isIntegrated) ? comp_filter_popout : comp_filter)
    }
    Component {
        id: comp_filter
        PQTemplateModal {
            id: smmod
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
        sourceComponent: ((PQCSettings.interfacePopoutSlideshowSetup || PQCWindowGeometry.slideshowSetupForcePopout || loader_top.isIntegrated) ? comp_slideshowsetup_popout : comp_slideshowsetup)
    }
    Component {
        id: comp_slideshowsetup
        PQTemplateModal {
            id: smmod
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
        id: loader_slideshowhandler
        active: false
        sourceComponent: PQSlideshowHandler {}
    }

    /*********************************************************************/

    Loader {
        id: loader_slideshowcontrols
        active: false
        sourceComponent: ((loader_top.isModern && (PQCSettings.interfacePopoutSlideshowControls || PQCWindowGeometry.slideshowcontrolsForcePopout)) ? comp_slideshowcontrols_popout : comp_slideshowcontrols)
    }
    Component { id: comp_slideshowcontrols; PQSlideshowControls {} }
    Component { id: comp_slideshowcontrols_popout; PQSlideshowControlsModernPopout {} }

    /*********************************************************************/

    Loader {
        id: loader_advancedsort
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutAdvancedSort || PQCWindowGeometry.advancedsortForcePopout || loader_top.isIntegrated) ? comp_advancedsort_popout : comp_advancedsort)
    }
    Component {
        id: comp_advancedsort
        PQTemplateModal {
            id: smmod
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
        id: loader_notification
        active: false
        anchors.fill: parent
        sourceComponent: PQNotification {}
    }

    /*********************************************************************/

    Loader {
        id: loader_logging
        active: false
        anchors.fill: parent
        sourceComponent: PQLogging {}
    }

    /*********************************************************************/

    Loader {
        id: loader_chromecastmanager
        active: false
        anchors.fill: parent
        sourceComponent: ((PQCSettings.interfacePopoutChromecast || PQCWindowGeometry.chromecastmanagerForcePopout || loader_top.isIntegrated) ? comp_chromecastmanager_popout : comp_chromecastmanager)
    }
    Component {
        id: comp_chromecastmanager
        PQTemplateModal {
            id: smmod
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
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

    Connections {

        target: PQCNotify

        function onOpenSettingsManagerAt(category : string, subcategory : string) {
            if(PQCConstants.idOfVisibleItem !== "")
                return
            if(!loader_settingsmanager.active)
                loader_settingsmanager.active = true
            PQCConstants.idOfVisibleItem = "SettingsManager"
            PQCNotify.loaderPassOn("show", ["SettingsManager"])
            PQCNotify.loaderPassOn("showSettings", [category, subcategory])
        }

        function onShowSettingsForExtension(id : string) {
            if(PQCConstants.idOfVisibleItem !== "")
                return
            if(!loader_settingsmanager.active)
                loader_settingsmanager.active = true
            PQCConstants.idOfVisibleItem = "SettingsManager"
            PQCNotify.loaderPassOn("show", ["SettingsManager"])
            PQCConstants.settingsManagerStartWithExtensionOpen = id
            PQCNotify.loaderPassOn("showExtensionSettings", [id])
        }

        function onLoaderShow(ele : string) {

            console.log("args: ele =", ele)

            if(PQCConstants.idOfVisibleItem !== "")
                return

            var ind = PQCExtensionsHandler.getExtensions().indexOf(ele)
            if(ind > -1) {
                // we emit a signal that is picked up in PQMasterItem where the actual extensions are located
                loader_top.showExtension(ele)
                return
            }

            // Note: the file dialog is handled directly in PQMasterItem
            var allele = {
                "About" : loader_about,
                "SettingsManager" : loader_settingsmanager,
                "FileRename" : loader_rename,
                "FileDelete" : loader_delete,
                "FileCopy" : loader_copy,
                "FileMove" : loader_move,
                "MapExplorer" : loader_mapexplorer,
                "Filter" : loader_filter,
                "SlideshowSetup" : loader_slideshowsetup,
                "SlideshowControls" : loader_slideshowcontrols,
                "SlideshowHandler" : loader_slideshowhandler,
                "AdvancedSort" : loader_advancedsort,
                "Logging" : loader_logging,
                "ChromecastManager" : loader_chromecastmanager,
                "Chromecast" : loader_chromecast
            }

            var notModal = ["SlideshowControls", "SlideshowHandler"]

            if(ele in allele) {
                if(!allele[ele].active)
                    allele[ele].active = true
                if(notModal.indexOf(ele) == -1)
                    PQCConstants.idOfVisibleItem = ele
                PQCNotify.loaderPassOn("show", [ele])
            } else
                console.warn("Warning: element not found:", ele)

        }

        function onShowNotificationMessage(title : string, msg : string) {
            if(!loader_notification.active)
                loader_notification.active = true
            PQCNotify.loaderPassOn("show", ["Notification", [title, msg]])
        }

        function onLoaderRegisterOpen(ele : string) {
            PQCConstants.idOfVisibleItem = ele
        }

        function onLoaderRegisterClose(ele : string) {
            PQCConstants.idOfVisibleItem = ""
        }

        // onLoaderSetupExtension() and onLoaderShowExtension() are handled in PQMasterItem
        // as we need access to the loader_extension repeater inside of a sourceComponent there

    }

}

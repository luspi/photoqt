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
import PhotoQt.CPlusPlus
import PhotoQt.Integrated
import PQCImageFormats
import PQCExtensionsHandler

Item {

    id: loader_top

    anchors.fill: parent

    signal showExtension(var ele)

    /*********************************************************************/

    Loader {
        id: loader_about
        active: false
        anchors.fill: parent
        sourceComponent:
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.aboutGeometry
            defaultPopoutMaximized: PQCWindowGeometry.aboutMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            popInOutButton.visible: false
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
        anchors.fill: parent
        sourceComponent: PQCopy {}
    }

    Loader {
        id: loader_move
        active: false
        anchors.fill: parent
        sourceComponent: PQMove {}
    }

    /*********************************************************************/

    Loader {
        id: loader_settingsmanager
        active: false
        anchors.fill: parent
        sourceComponent:
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.settingsmanagerGeometry
            defaultPopoutMaximized: PQCWindowGeometry.settingsmanagerMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            popInOutButton.visible: false
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
        id: loader_mapexplorer
        active: false
        anchors.fill: parent
        sourceComponent:
        PQTemplateModalPopout {
            id: smpop
            showTopBottom: false
            defaultPopoutGeometry: PQCWindowGeometry.settingsmanagerGeometry
            defaultPopoutMaximized: PQCWindowGeometry.settingsmanagerMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            popInOutButton.visible: false
            onRectUpdated: (r) => {
                PQCWindowGeometry.settingsmanagerGeometry = r
            }
            onMaximizedUpdated: (m) => {
                PQCWindowGeometry.settingsmanagerMaximized = m
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
        sourceComponent:
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.filterGeometry
            defaultPopoutMaximized: PQCWindowGeometry.filterMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            popInOutButton.visible: false
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
        sourceComponent:
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.slideshowsetupGeometry
            defaultPopoutMaximized: PQCWindowGeometry.slideshowsetupMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            popInOutButton.visible: false
            onRectUpdated: (r) => {
                PQCWindowGeometry.slideshowsetupGeometry = r
            }
            onMaximizedUpdated: (m) => {
                PQCWindowGeometry.slideshowsetupMaximized = m
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
        sourceComponent: comp_slideshowcontrols
    }
    Component { id: comp_slideshowcontrols; PQSlideshowControls {} }

    /*********************************************************************/

    Loader {
        id: loader_notification
        active: false
        anchors.fill: parent
        sourceComponent: PQNotification {}
    }

    /*********************************************************************/

    Connections {

        target: PQCNotify

        function onLoaderShow(ele : string) {

            console.log("args: ele =", ele)

            var ind = PQCExtensionsHandler.getExtensions().indexOf(ele)
            if(ind > -1) {
                // we emit a signal that is picked up in PQMasterItem where the actual extensions are located
                loader_top.showExtension(ele)
                return
            }

            if(ele === "about") {
                if(!loader_about.active)
                    loader_about.active = true
                PQCConstants.idOfVisibleItem = "about"
                PQCNotify.loaderPassOn("show", ["about"])
            } else if(ele === "SettingsManager") {
                if(!loader_settingsmanager.active)
                    loader_settingsmanager.active = true
                PQCConstants.idOfVisibleItem = "SettingsManager"
                PQCNotify.loaderPassOn("show", ["SettingsManager"])
            } else if(ele === "FileRename") {
                if(!loader_rename.active)
                    loader_rename.active = true
                PQCConstants.idOfVisibleItem = "FileRename"
                PQCNotify.loaderPassOn("show", ["FileRename"])
            } else if(ele === "FileDelete") {
                if(!loader_delete.active)
                    loader_delete.active = true
                PQCConstants.idOfVisibleItem = "FileDelete"
                PQCNotify.loaderPassOn("show", ["FileDelete"])
            } else if(ele === "FileCopy") {
                if(!loader_copy.active)
                    loader_copy.active = true
                PQCConstants.idOfVisibleItem = "FileCopy"
                PQCNotify.loaderPassOn("show", ["FileCopy"])
            } else if(ele === "FileMove") {
                if(!loader_move.active)
                    loader_move.active = true
                PQCConstants.idOfVisibleItem = "FileMove"
                PQCNotify.loaderPassOn("show", ["FileMove"])
            } else if(ele === "MapExplorer") {
                if(!loader_mapexplorer.active)
                    loader_mapexplorer.active = true
                PQCConstants.idOfVisibleItem = "MapExplorer"
                PQCNotify.loaderPassOn("show", ["MapExplorer"])
            } else if(ele === "Filter") {
                if(!loader_filter.active)
                    loader_filter.active = true
                PQCConstants.idOfVisibleItem = "Filter"
                PQCNotify.loaderPassOn("show", ["Filter"])
            } else if(ele === "SlideshowSetup") {
                if(!loader_slideshowsetup.active)
                    loader_slideshowsetup.active = true
                PQCConstants.idOfVisibleItem = "SlideshowSetup"
                PQCNotify.loaderPassOn("show", ["SlideshowSetup"])
            } else if(ele === "SlideshowControls") {
                if(!loader_slideshowcontrols.active)
                    loader_slideshowcontrols.active = true
                PQCConstants.idOfVisibleItem = "SlideshowControls"
                PQCNotify.loaderPassOn("show", ["SlideshowControls"])
            } else if(ele === "SlideshowHandler") {
                if(!loader_slideshowhandler.active)
                    loader_slideshowhandler.active = true
                PQCConstants.idOfVisibleItem = "SlideshowHandler"
                PQCNotify.loaderPassOn("show", ["SlideshowHandler"])
            }

        }

        function onShowNotificationMessage(title : string, msg : string) {
            if(!loader_notification.active)
                loader_notification.active = true
            PQCNotify.loaderPassOn("show", ["notification", [title, msg]])
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

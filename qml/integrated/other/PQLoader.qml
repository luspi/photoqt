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
            showTopBottom: false
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
        id: loader_advancedsort
        active: false
        anchors.fill: parent
        sourceComponent:
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.advancedsortGeometry
            defaultPopoutMaximized: PQCWindowGeometry.advancedsortMaximized
            onShowing: tmpl.showing()
            onHiding: tmpl.hiding()
            popInOutButton.visible: false
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
                "AdvancedSort" : loader_advancedsort
            }

            if(ele in allele) {
                if(!allele[ele].active)
                    allele[ele].active = true
                PQCConstants.idOfVisibleItem = ele
                PQCNotify.loaderPassOn("show", [ele])
            } else
                console.warn("Warning: element not found:", ele)

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

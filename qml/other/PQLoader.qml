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

    /*********************************************************************/

        // MODERN INTERFACE ONLY
        PQLoaderWindowButtons { id: windowbuttons }
        PQLoaderWindowButtonsOnTop { id: windowbuttons_ontop }
        PQLoaderStatusInfo { id: statusinfo }

    /*********************************************************************/

    PQLoaderAbout { id: loader_about }

    /*********************************************************************/

    PQLoaderRename { id: loader_rename }
    PQLoaderDelete { id: loader_delete }
    PQLoaderCopy { id: loader_copy }
    PQLoaderMove { id: loader_move }

    /*********************************************************************/

    PQLoaderSettingsManager { id: loader_settingsmanager }

    /*********************************************************************/

    PQLoaderMapExplorer { id: loader_mapexplorer }

    /*********************************************************************/

    PQLoaderFilter { id: loader_filter }

    /*********************************************************************/

    PQLoaderSlideshowSetup { id: loader_slideshowsetup }
    PQLoaderSlideshowHandler { id: loader_slideshowhandler }
    PQLoaderSlideshowControls { id: loader_slideshowcontrols }

    /*********************************************************************/

    PQLoaderAdvancedSort { id: loader_advancedsort }

    /*********************************************************************/

    PQLoaderNotification { id: loader_notification }

    /*********************************************************************/

    PQLoaderLogging { id: loader_logging }

    /*********************************************************************/

    PQLoaderChromecastManager { id: loader_chromecastmanager }
    PQLoaderChromecast { id: loader_chromecast }

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

            console.warn(PQCExtensionsHandler.getExtensions())

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

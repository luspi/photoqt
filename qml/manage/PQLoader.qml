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

import PQCWindowGeometry
import PQCScriptsConfig
import PQCExtensionsHandler

Item {

    id: loader_top

    // source, loader id, modal, popout, force popout
    property var loadermapping: {
        "export"              : ["actions","PQExport", loader_export, 1, PQCSettings.interfacePopoutExport, PQCWindowGeometry.exportForcePopout], // qmllint disable unqualified
        "about"               : ["actions","PQAbout", loader_about, 1, PQCSettings.interfacePopoutAbout, PQCWindowGeometry.aboutForcePopout],
        "mainmenu"            : ["ongoing","PQMainMenu", loader_mainmenu, 0, PQCSettings.interfacePopoutMainMenu, PQCWindowGeometry.mainmenuForcePopout],
        "metadata"            : ["ongoing","PQMetaData", loader_metadata, 0, PQCSettings.interfacePopoutMetadata, PQCWindowGeometry.metadataForcePopout],
        "filedialog"          : ["filedialog","PQFileDialog", loader_filedialog, 1, PQCSettings.interfacePopoutFileDialog, PQCWindowGeometry.filedialogForcePopout],
        "thumbnails"          : ["ongoing", "PQThumbnails", loader_thumbnails, 0, false, false],
        "filedelete"          : ["actions","PQDelete", loader_filedelete, 1, PQCSettings.interfacePopoutFileDelete, PQCWindowGeometry.filedeleteForcePopout],
        "filerename"          : ["actions","PQRename", loader_filerename, 1, PQCSettings.interfacePopoutFileRename, PQCWindowGeometry.filerenameForcePopout],
        "filecopy"            : ["actions","PQCopy", loader_copy, 1, false, false],
        "filemove"            : ["actions","PQMove", loader_move, 1, false, false],
        "filter"              : ["actions","PQFilter", loader_filter, 1, PQCSettings.interfacePopoutFilter, PQCWindowGeometry.filterForcePopout],
        "advancedsort"        : ["actions","PQAdvancedSort", loader_advancedsort, 1, PQCSettings.interfacePopoutAdvancedSort, PQCWindowGeometry.advancedsortForcePopout],
        "logging"             : ["ongoing","PQLogging", loader_logging, 0, true, true],
        "slideshowsetup"      : ["actions","PQSlideshowSetup", loader_slideshowsetup, 1, PQCSettings.interfacePopoutSlideshowSetup, PQCWindowGeometry.slideshowsetupForcePopout],
        "slideshowhandler"    : ["other","PQSlideshowHandler", loader_slideshowhandler, 1, false, false],
        "slideshowcontrols"   : ["ongoing","PQSlideshowControls", loader_slideshowcontrols, 0, PQCSettings.interfacePopoutSlideshowControls, PQCWindowGeometry.slideshowcontrolsForcePopout],
        "notification"        : ["ongoing","PQNotification", loader_notification, 0, false, false],
        "imgur"               : ["actions","PQImgur", loader_imgur, 1, PQCSettings.interfacePopoutImgur, PQCWindowGeometry.imgurForcePopout],
        "wallpaper"           : ["actions","PQWallpaper", loader_wallpaper, 1, PQCSettings.interfacePopoutWallpaper, PQCWindowGeometry.wallpaperForcePopout],
        "mapexplorer"         : ["actions","PQMapExplorer", loader_mapexplorer, 1, PQCSettings.interfacePopoutMapExplorer, PQCWindowGeometry.mapexplorerForcePopout],
        "chromecast"          : ["ongoing","PQChromeCast", loader_chromecast, 0, false, false],
        "chromecastmanager"   : ["actions","PQChromeCastManager", loader_chromecastmanager, 1, PQCSettings.interfacePopoutChromecast, PQCWindowGeometry.chromecastmanagerForcePopout],
        "settingsmanager"     : ["settingsmanager","PQSettingsManager", loader_settingsmanager, 1, PQCSettings.interfacePopoutSettingsManager, PQCWindowGeometry.settingsmanagerForcePopout],
        "crop"                : ["actions","PQCrop", loader_crop, 1, PQCSettings.interfacePopoutCrop, PQCWindowGeometry.cropForcePopout],
    }

    property string visibleItem: ""
    onVisibleItemChanged: {
        PQCConstants.idOfVisibleItem = visibleItem
        PQCConstants.modalWindowOpen = (visibleItem!="")
    }

    function show(ele : string, additional = undefined) : void {

        if(ele === "chromecast" && visibleItem === "chromecastmanager") {
            ensureItIsReady(ele, loadermapping[ele])
            return
        }

        if(ele === "chromecastmanager" && !PQCScriptsConfig.isChromecastEnabled()) {
            loader_top.show("notification", [qsTranslate("unavailable", "Feature unavailable"), qsTranslate("unavailable", "The chromecast feature is not available in this build of PhotoQt.")])
            return
        } else if(ele === "mapexplorer" && !PQCScriptsConfig.isLocationSupportEnabled()) {
            loader_top.show("notification", [qsTranslate("unavailable", "Feature unavailable"), qsTranslate("unavailable", "The location feature is not available in this build of PhotoQt.")])
            return
        }

        var ind = PQCExtensionsHandler.getExtensions().indexOf(ele)
        if(ind > -1) {
            if(PQCExtensionsHandler.getIsModal(ele) && visibleItem != "")
                return
            visibleItem = ele
            ensureExtensionIsReady(ele, ind)
        } else if(!(ele in loadermapping)) {
            console.log("Unknown element encountered:", ele)
            return
        } else {

            var config = loadermapping[ele]

            if(config[3] === 1 && visibleItem != "")
                return

            // these checks make sure to ignore the blocking value when the interfacePopoutFileDialogNonModal setting is set
            if(config[3] === 1 &&
                (ele !== "filedialog" || !PQCSettings.interfacePopoutFileDialog || (PQCSettings.interfacePopoutFileDialog && !PQCSettings.interfacePopoutFileDialogNonModal)) &&
                (ele !== "mapexplorer" || !PQCSettings.interfacePopoutMapExplorer || (PQCSettings.interfacePopoutMapExplorer && !PQCSettings.interfacePopoutMapExplorerNonModal)) &&
                (ele !== "settingsmanager" || !PQCSettings.interfacePopoutSettingsManager || (PQCSettings.interfacePopoutSettingsManager && !PQCSettings.interfacePopoutSettingsManagerNonModal)))
                visibleItem = ele

            ensureItIsReady(ele, config)

        }

        if(additional === undefined) {
            PQCNotify.loaderPassOn("show", [ele])
        } else {
            PQCNotify.loaderPassOn("show", [ele, additional])
        }

    }

    function elementClosed(ele : string) {

        if((ele in loadermapping && loadermapping[ele][3] === 1) || PQCExtensionsHandler.getExtensions().indexOf(ele)>-1 || ele === "facetagger") {

            // these are the same checks as above when setting this property
            if((ele !== "filedialog" || !PQCSettings.interfacePopoutFileDialog || (PQCSettings.interfacePopoutFileDialog && !PQCSettings.interfacePopoutFileDialogNonModal)) && // qmllint disable unqualified
                    (ele !== "mapexplorer" || !PQCSettings.interfacePopoutMapExplorer || (PQCSettings.interfacePopoutMapExplorer && !PQCSettings.interfacePopoutMapExplorerNonModal)) &&
                    (ele !== "settingsmanager" || !PQCSettings.interfacePopoutSettingsManager || (PQCSettings.interfacePopoutSettingsManager && !PQCSettings.interfacePopoutSettingsManagerNonModal))) {

                if(visibleItem === ele) {
                    console.log("Closing item:", ele)
                    visibleItem = ""
                } else
                    console.warn("Closed item not item recoreded as open:", ele, "=!=", visibleItem)

            }
        }

    }

    function ensureItIsReady(ele : string, config : var) {

        console.log("args: ele =", ele)
        console.log("args: config =", config)

        var src
        if(config[4] || config[5])
            src = config[0] + "/popout/" + config[1] + "Popout.qml"
        else
            src = config[0] + "/" + config[1] + ".qml"

        if(src !== config[2].source)
            config[2].source = src

    }

    function ensureExtensionIsReady(ele : string, ind : int) {

        console.log("args: ele =", ele)
        console.log("args: ind =", ind)

        var minreq = PQCExtensionsHandler.getMinimumRequiredWindowSize(ele)
        if(PQCExtensionsHandler.getAllowPopout(ele) &&
                (PQCSettings["extensions"+PQCExtensionsHandler.getPopoutSettingName(ele)] ||
                 minreq.width > PQCConstants.windowWidth || minreq.height > PQCConstants.windowHeight))
            loader_extensions.itemAt(ind).source = "../extensions/" + ele + "/" + PQCExtensionsHandler.getQmlBaseName(ele) + "Popout.qml"
        else
            loader_extensions.itemAt(ind).source = "../extensions/" + ele + "/" + PQCExtensionsHandler.getQmlBaseName(ele) + ".qml"

    }

    function resetAll() {
        console.warn("## TODO: implement PQLoader::resetAll()")
    }

    property string visibleItemBackup: ""

    Connections {

        target: PQCNotify // qmllint disable unqualified

        function onShowNotificationMessage(title : string, msg : string) {
            loader_top.show("notification", [title, msg])
        }

        function onOpenSettingsManagerAt(category : string, subcategory : string) {
            loader_top.ensureItIsReady(category, loader_top.loadermapping[category]) // qmllint disable unqualified
            PQCNotify.loaderPassOn("showSettings", [subcategory])
        }

        function onLoaderRegisterClose(ele : string) {
            loader_top.elementClosed(ele)
        }

        function onLoaderShow(ele : string) {
            loader_top.ensureItIsReady(ele, loader_top.loadermapping[ele])
            loader_top.show(ele)
        }

        function onLoaderShowExtension(ele : string) {
            loader_top.ensureExtensionIsReady(ele, PQCExtensionsHandler.getExtensions().indexOf(ele))
            loader_top.show(ele)
        }

        function onLoaderSetup(ele : string) {
            loader_top.ensureItIsReady(ele, loader_top.loadermapping[ele])
        }

        function onLoaderSetupExtension(ele : string) {
            loader_top.ensureExtensionIsReady(ele, PQCExtensionsHandler.getExtensions().indexOf(ele))
        }

        function onLoaderOverrideVisibleItem(ele : string) {
            loader_top.visibleItemBackup = loader_top.visibleItem
            loader_top.visibleItem = ele
        }

        function onLoaderRestoreVisibleItem() {
            if(loader_top.visibleItemBackup != "") {
                loader_top.visibleItem = loader_top.visibleItemBackup
                loader_top.visibleItemBackup = ""
            }
        }

    }

}

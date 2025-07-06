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
import PQCScriptsConfig
import PQCExtensionsHandler
import PhotoQt

Item {

    id: loader_top

    // source, loader id, modal, popout, force popout
    property var loadermapping: {
        "about"               : ["actions","PQAbout", loader_about, 1, PQCSettings.interfacePopoutAbout, PQCWindowGeometry.aboutForcePopout],
        "mainmenu"            : ["ongoing", "PQMainMenu", loader_mainmenu, 0, PQCSettings.interfacePopoutMainMenu, PQCWindowGeometry.mainmenuForcePopout],
        "metadata"            : ["ongoing", "PQMetaData", loader_metadata, 0, PQCSettings.interfacePopoutMetadata, PQCWindowGeometry.metadataForcePopout],
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
        "mapexplorer"         : ["actions","PQMapExplorer", loader_mapexplorer, 1, PQCSettings.interfacePopoutMapExplorer, PQCWindowGeometry.mapexplorerForcePopout],
        "chromecast"          : ["ongoing","PQChromeCast", loader_chromecast, 0, false, false],
        "chromecastmanager"   : ["actions","PQChromeCastManager", loader_chromecastmanager, 1, PQCSettings.interfacePopoutChromecast, PQCWindowGeometry.chromecastmanagerForcePopout],
        "settingsmanager"     : ["settingsmanager","PQSettingsManager", loader_settingsmanager, 1, PQCSettings.interfacePopoutSettingsManager, PQCWindowGeometry.settingsmanagerForcePopout],
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

            if(PQCExtensionsHandler.getIsModal(ele)) {
                if(visibleItem != "")
                    return
                else
                    visibleItem = ele
            }
            ensureExtensionIsReady(ele, ind)

            if(!loader_extensions.itemAt(ind).item) {
                if(showWhenReady.args.length == 0) {
                    showWhenReady.theloader = loader_extensions.itemAt(ind)
                    if(additional === undefined)
                        showWhenReady.args = [ele]
                    else
                        showWhenReady.args = [ele, additional]
                    showWhenReady.start()
                } else if(showWhenReady2.args.length == 0) {
                    showWhenReady2.theloader = loader_extensions.itemAt(ind)
                    if(additional === undefined)
                        showWhenReady2.args = [ele]
                    else
                        showWhenReady2.args = [ele, additional]
                    showWhenReady2.start()
                } else
                    console.error("Unable to set up extension, too few timers available.")
            } else {
                if(additional === undefined)
                    PQCNotify.loaderPassOn("show", [ele])
                else
                    PQCNotify.loaderPassOn("show", [ele, additional])
            }

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

            if(!config[2].item) {
                if(showWhenReady.args.length == 0) {
                    showWhenReady.theloader = config[2]
                    if(additional === undefined)
                        showWhenReady.args = [ele]
                    else
                        showWhenReady.args = [ele, additional]
                    showWhenReady.start()
                } else if(showWhenReady2.args.length == 0) {
                    showWhenReady2.theloader = config[2]
                    if(additional === undefined)
                        showWhenReady2.args = [ele]
                    else
                        showWhenReady2.args = [ele, additional]
                    showWhenReady2.start()
                } else
                    console.error("Unable to set up item, too few timers available.")
            } else {
                if(additional === undefined)
                    PQCNotify.loaderPassOn("show", [ele])
                else
                    PQCNotify.loaderPassOn("show", [ele, additional])
            }

        }

    }

    Timer {
        id: showWhenReady
        property var theloader: Loader
        property list<var> args: []
        interval: 10
        triggeredOnStart: true
        onTriggered: {
            if(!theloader.item) {
                showWhenReady.start()
                return
            }
            PQCNotify.loaderPassOn("show", args)
            args = []
        }
    }

    Timer {
        id: showWhenReady2
        property var theloader: Loader
        property list<var> args: []
        interval: 10
        triggeredOnStart: true
        onTriggered: {
            if(!theloader.item) {
                showWhenReady2.start()
                return
            }
            PQCNotify.loaderPassOn("show", args)
            args = []
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

        if((ele === "chromecastmanager" && !PQCScriptsConfig.isChromecastEnabled()) ||
                (ele === "mapexplorer" && !PQCScriptsConfig.isLocationSupportEnabled()))
            return

        var src
        if(config[4] || config[5])
            src = "qrc:/qt/qml/PhotoQt/qml/modern/" + config[0] + "/popout/" + config[1] + "Popout.qml"
        else
            src = "qrc:/qt/qml/PhotoQt/qml/modern/" + config[0] + "/" + config[1] + ".qml"

        if(src !== config[2].source)
            config[2].source = src

    }

    function ensureExtensionIsReady(ele : string, ind : int) {

        console.log("args: ele =", ele)
        console.log("args: ind =", ind)

        var src

        var minreq = PQCExtensionsHandler.getMinimumRequiredWindowSize(ele)
        if(PQCSettings.extensions[ele+"Popout"] || minreq.width > PQCConstants.windowWidth || minreq.height > PQCConstants.windowHeight)
            src = "file:/" + PQCExtensionsHandler.getExtensionLocation(ele) + "/modern/PQ" + ele + "Popout.qml"
        else
            src = "file:/" + PQCExtensionsHandler.getExtensionLocation(ele) + "/modern/PQ" + ele + ".qml"

        if(src !== loader_extensions.itemAt(ind).source)
            loader_extensions.itemAt(ind).source = src

        // modal elements need to be shown on top, above things like mainmenu or metadata
        // The value should be high but lower than that of the window buttons that are shown on top (currently set to 999)
        if(PQCExtensionsHandler.getIsModal(ele))
            loader_extensions.itemAt(ind).z = 888

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
            loader_top.ensureItIsReady("settingsmanager", loader_top.loadermapping["settingsmanager"]) // qmllint disable unqualified
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

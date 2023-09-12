import QtQuick

import PQCPopoutGeometry
import PQCScriptsConfig

Item {

    id: loader_top

    // source, loader id, modal, popout, force popout
    property var loadermapping: {
        "export"              : ["actions","PQExport", loader_export, 1, PQCSettings.interfacePopoutExport, PQCPopoutGeometry.exportForcePopout],
        "about"               : ["actions","PQAbout", loader_about, 1, PQCSettings.interfacePopoutAbout, PQCPopoutGeometry.aboutForcePopout],
        "mainmenu"            : ["ongoing","PQMainMenu", loader_mainmenu, 0, PQCSettings.interfacePopoutMainMenu, PQCPopoutGeometry.mainmenuForcePopout],
        "metadata"            : ["ongoing","PQMetaData", loader_metadata, 0, PQCSettings.interfacePopoutMetadata, PQCPopoutGeometry.metadataForcePopout],
        "filedialog"          : ["filedialog","PQFileDialog", loader_filedialog, 1, PQCSettings.interfacePopoutFileDialog, PQCPopoutGeometry.filedialogForcePopout],
        "thumbnails"          : ["ongoing", "PQThumbnails", loader_thumbnails, 0, false, false],
        "histogram"           : ["ongoing","PQHistogram", loader_histogram, 0, PQCSettings.interfacePopoutHistogram, PQCPopoutGeometry.histogramForcePopout],
        "mapcurrent"          : ["ongoing","PQMapCurrent", loader_mapcurrent, 0, PQCSettings.interfacePopoutMapCurrent, PQCPopoutGeometry.mapcurrentForcePopout],
        "navigationfloating"  : ["ongoing","PQNavigation", loader_navigationfloating, 0, false, false],
        "scale"               : ["actions","PQScale", loader_scale, 1, PQCSettings.interfacePopoutScale, PQCPopoutGeometry.scaleForcePopout],
        "filedelete"          : ["actions","PQDelete", loader_filedelete, 1, PQCSettings.interfacePopoutFileDelete, PQCPopoutGeometry.filedeleteForcePopout],
        "filerename"          : ["actions","PQRename", loader_filerename, 1, PQCSettings.interfacePopoutFileRename, PQCPopoutGeometry.filerenameForcePopout],
        "filecopy"            : ["actions","PQCopy", loader_copy, 1, false, false],
        "filemove"            : ["actions","PQMove", loader_move, 1, false, false],
        "filter"              : ["actions","PQFilter", loader_filter, 1, PQCSettings.interfacePopoutFilter, PQCPopoutGeometry.filterForcePopout],
        "advancedsort"        : ["actions","PQAdvancedSort", loader_advancedsort, 1, PQCSettings.interfacePopoutAdvancedSort, PQCPopoutGeometry.advancedsortForcePopout],
        "logging"             : ["ongoing","PQLogging", loader_logging, 0, true, true],

        "advancedsortbusy"    : ["actions","PQAdvancedSortBusy", loader_advancedsortbusy, 1, false, false],
        "chromecast"          : ["ongoing","PQChromecast", loader_chromecast, 1, false, false],
        "filesaveas"          : ["actions","PQSaveAs", loader_filesaveas, 1, false, false],
        "imgur"               : ["actions","PQImgur", loader_imgur, 1, false, false],
        "imguranonym"         : ["actions","PQImgurAnonym", loader_imguranonym, 1, false, false],
        "mapexplorer"         : ["map","PQMapExplorer", loader_mapexplorer, 1, false, false],
        "settingsmanager"     : ["settings","PQSettingsManager", loader_settingsmanager, 1, false, false],
        "slideshowcontrols"   : ["ongoing","PQSlideShowControls", loader_slideshowcontrols, 0, false, false],
        "slideshowsettings"   : ["ongoing","PQSlideShowSettings", loader_slideshowsettings, 1, false, false],
        "unavailable"         : ["other","PQUnavailable", loader_unavailable, 1, false, false],
        "wallpaper"           : ["actions","PQWallpaper", loader_wallpaper, 1, false, false]
    }

    property string visibleItem: ""

    signal passOn(var what, var param)

    function show(ele) {

        var e = ele

        if(ele === "chromecast" && !PQCScriptsConfig.isChromecastEnabled()) {
            e = "unavailable"
        } else if((ele === "mapcurrent" || ele === "mapexplorer") && !PQCScriptsConfig.isLocationSupportEnabled())
            return

        if(!(e in loadermapping))
            return

        var config = loadermapping[e]

        if(config[3] === 1 && visibleItem != "")
            return

        // these checks make sure to ignore the blocking value when the interfacePopoutFileDialogKeepOpen setting is set
        if(config[3] === 1 && (e !== "filedialog" || !PQCSettings.interfacePopoutFileDialog || (PQCSettings.interfacePopoutFileDialog && !PQCSettings.interfacePopoutFileDialogKeepOpen)))
            visibleItem = e

        ensureItIsReady(e, config)

        passOn("show", e)

    }

    function elementClosed(ele) {
        if(ele in loadermapping && loadermapping[ele][3] === 1) {
            if(visibleItem === ele)
                visibleItem = ""
            else
                console.warn("Closed item not item recoreded as open:", ele, "=!=", visibleItem)
        }
    }

    function ensureItIsReady(ele, config) {

        var src
        if(config[4] || config[5])
            src = config[0] + "/popout/" + config[1] + "Popout.qml"
        else
            src = config[0] + "/" + config[1] + ".qml"

        if(src !== config[2].source)
            config[2].source = src

    }

    function resetAll() {
        for(var e in ele)
            console.log(e)
    }

}

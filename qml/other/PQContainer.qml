import QtQuick

Item {

    id: container_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property var loadermapping: {
        "about"               : ["actions/PQAbout", loader_about, 1],
        "advancedsort"        : ["actions/PQAdvancedSort", loader_advancedsort, 1],
        "advancedsortbusy"    : ["actions/PQAdvancedSortBusy", loader_advancedsortbusy, 1],
        "chromecast"          : ["ongoing/PQChromecast", loader_chromecast, 1],
        "copymove"            : ["actions/PQCopyMove", loader_copymove, 1],
        "filedelete"          : ["actions/PQDelete", loader_filedelete, 1],
        "filedialog"          : ["filedialog/PQFileDialog", loader_filedialog, 1],
        "filerename"          : ["actions/PQRename", loader_filerename, 1],
        "filesaveas"          : ["actions/PQSaveAs", loader_filesaveas, 1],
        "filter"              : ["actions/PQFilter", loader_filter, 1],
        "histogram"           : ["ongoing/PQHistogram", loader_histogram, 0],
        "imgur"               : ["actions/PQImgur", loader_imgur, 1],
        "imguranonym"         : ["actions/PQImgurAnonym", loader_imguranonym, 1],
        "logging"             : ["ongoing/PQLogging", loader_logging, 0],
        "mainmenu"            : ["ongoing/PQMainMenu", loader_mainmenu, 0],
        "mapcurrent"          : ["map/PQMapCurrent", loader_mapcurrent, 0],
        "mapexplorer"         : ["map/PQMapExplorer", loader_mapexplorer, 1],
        "metadata"            : ["ongoing/PQMetaData", loader_metadata, 0],
        "navigationfloating"  : ["other/PQNavigation", loader_navigationfloating, 0],
        "scale"               : ["actions/PQScale", loader_scale, 1],
        "settingsmanager"     : ["settings/PQSettingsManager", loader_settingsmanager, 1],
        "slideshowcontrols"   : ["ongoing/PQSlideShowControls", loader_slideshowcontrols, 0],
        "slideshowsettings"   : ["ongoing/PQSlideShowSettings", loader_slideshowsettings, 1],
        "unavailable"         : ["other/PQUnavailable", loader_unavailable, 1],
        "wallpaper"           : ["actions/PQWallpaper", loader_wallpaper, 1]
    }

    property int numVisible: 0

    signal passOn(var ele, var what, var param)

    Loader { id: loader_about }
    Loader { id: loader_advancedsort }
    Loader { id: loader_advancedsortbusy }
    Loader { id: loader_chromecast }
    Loader { id: loader_copymove }
    Loader { id: loader_filedelete }
    Loader { id: loader_filedialog }
    Loader { id: loader_filerename }
    Loader { id: loader_filesaveas }
    Loader { id: loader_filter }
    Loader { id: loader_histogram }
    Loader { id: loader_imgur }
    Loader { id: loader_imguranonym }
    Loader { id: loader_logging }
    Loader { id: loader_mainmenu }
    Loader { id: loader_mapcurrent }
    Loader { id: loader_mapexplorer }
    Loader { id: loader_metadata }
    Loader { id: loader_navigationfloating }
    Loader { id: loader_scale }
    Loader { id: loader_settingsmanager }
    Loader { id: loader_slideshowcontrols }
    Loader { id: loader_slideshowsettings }
    Loader { id: loader_unavailable }
    Loader { id: loader_wallpaper }

    function show(ele) {

        var e = ele

        if(ele === "chromecast" && !PQCScriptsConfig.isChromecastEnabled()) {
            e = "unavailable"
        } else if((ele === "mapcurrent" || ele === "mapexplorer") && !PQCScriptsConfig.isLocationSupportEnabled())
            return

        if(!(e in loadermapping))
            return

        if(loadermapping[e][2] == 1 && numVisible > 0)
            return
        numVisible += 1


        ensureItIsReady(e)

        passOn(e, "show", undefined)

        // this should be animated
        opacity = 1

    }

    function elementClosed(ele) {
        if(ele in loadermapping && loadermapping[ele][2] == 1)
            numVisible -= 1
    }

    function ensureItIsReady(ele) {

        if(ele in loadermapping) {
            var m = loadermapping[ele]
            m[1].source = "../"+m[0]+".qml"
        }

    }

    function resetAll() {
        for(var e in ele)
            console.log(e)
    }

}

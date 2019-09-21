import QtQuick 2.9

Item {

    id: load_top

    signal filedialogPassOn(var what, var param)
    signal metadataPassOn(var what, var param)
    signal slideshowPassOn(var what, var param)

    function show(component) {

        ensureItIsReady(component)

        if(component == "filedialog")
            filedialogPassOn("show", undefined)

        else if(component == "slideshowsettings")
            slideshowPassOn("show", undefined)

    }

    function passOn(component, what, param) {

        if(component == "metadata")
            metadataPassOn(what, param)

    }

    function passKeyEvent(component, key, mod) {

        ensureItIsReady(component)

        if(component == "filedialog")
            filedialogPassOn("keyevent", [key, mod])

        else if(component == "slideshowsettings")
            slideshowPassOn("keyevent", [key, mod])

    }

    function ensureItIsReady(component) {

        if(component == "filedialog") {

            if(PQSettings.openPopoutElement && filedialog.source != "filedialog/PQFileDialogPopout.qml")
                filedialog.source = "filedialog/PQFileDialogPopout.qml"

            else if(!PQSettings.openPopoutElement && filedialog.source != "filedialog/PQFileDialog.qml")
                filedialog.source = "filedialog/PQFileDialog.qml"

        } else if(component == "mainmenu") {

            if(PQSettings.mainMenuPopoutElement && mainmenu.source != "menumeta/PQMainMenuPopout.qml")
                mainmenu.source = "menumeta/PQMainMenuPopout.qml"

            else if(!PQSettings.mainMenuPopoutElement && mainmenu.source != "menumeta/PQMainMenu.qml")
                mainmenu.source = "menumeta/PQMainMenu.qml"

        } else if(component == "metadata") {

            if(PQSettings.metadataPopoutElement && metadata.source != "menumeta/PQMetaDataPopout.qml")
                metadata.source = "menumeta/PQMetaDataPopout.qml"

            else if(!PQSettings.metadataPopoutElement && metadata.source != "menumeta/PQMetaData.qml")
                metadata.source = "menumeta/PQMetaData.qml"

        } else if(component == "histogram") {

            if(PQSettings.histogramPopoutElement && histogram.source != "histogram/PQHistogramPopout.qml")
                histogram.source = "histogram/PQHistogramPopout.qml"

            else if(!PQSettings.histogramPopoutElement && histogram.source != "histogram/PQHistogram.qml")
                histogram.source = "histogram/PQHistogram.qml"

        } else if(component == "slideshowsettings") {

            if(PQSettings.slideShowSettingsPopoutElement && slideshowsettings.source != "slideshow/PQSlideShowSettingsPopout.qml")
                slideshowsettings.source = "slideshow/PQSlideShowSettingsPopout.qml"

            else if(!PQSettings.slideShowSettingsPopoutElement && slideshowsettings.source != "slideshow/PQSlideShowSettings.qml")
                slideshowsettings.source = "slideshow/PQSlideShowSettings.qml"

        }

    }

}

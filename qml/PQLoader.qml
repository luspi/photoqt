import QtQuick 2.9

Item {

    id: load_top

    signal filedialogPassOn(var what, var param)
    signal metadataPassOn(var what, var param)
    signal slideshowPassOn(var what, var param)
    signal slideshowControlsPassOn(var what, var param)
    signal fileRenamePassOn(var what, var param)
    signal fileDeletePassOn(var what, var param)
    signal scalePassOn(var what, var param)
    signal aboutPassOn(var what, var param)
    signal imgurPassOn(var what, var param)

    function show(component) {

        ensureItIsReady(component)

        if(component == "filedialog")
            filedialogPassOn("show", undefined)

        else if(component == "slideshowsettings")
            slideshowPassOn("show", undefined)

        else if(component == "slideshowcontrols")
            slideshowControlsPassOn("show", undefined)

        else if(component == "filerename")
            fileRenamePassOn("show", undefined)

        else if(component == "filedelete")
            fileDeletePassOn("show", undefined)

        else if(component == "scale")
            scalePassOn("show", undefined)

        else if(component == "about")
            aboutPassOn("show", undefined)

        else if(component == "imgur")
            imgurPassOn("show", undefined)

        else if(component == "imguranonym")
            imgurPassOn("show_anonym", undefined)

    }

    function passOn(component, what, param) {

        if(component == "metadata")
            metadataPassOn(what, param)

        else if(component == "slideshowcontrols")
            slideshowControlsPassOn(what, param)

    }

    function passKeyEvent(component, key, mod) {

        ensureItIsReady(component)

        if(component == "filedialog")
            filedialogPassOn("keyevent", [key, mod])

        else if(component == "slideshowsettings")
            slideshowPassOn("keyevent", [key, mod])

        else if(component == "slideshowcontrols")
            slideshowControlsPassOn("keyevent", [key, mod])

        else if(component == "filedelete")
            fileDeletePassOn("keyevent", [key, mod])

        else if(component == "scale")
            scalePassOn("keyevent", [key, mod])

        else if(component == "about")
            aboutPassOn("keyevent", [key, mod])

        else if(component == "imgur" || component == "imguranonym")
            imgurPassOn("keyevent", [key, mod])

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

        } else if(component == "slideshowcontrols") {

            if(PQSettings.slideShowControlsPopoutElement && slideshowcontrols.source != "slideshow/PQSlideShowControlsPopout.qml")
                slideshowcontrols.source = "slideshow/PQSlideShowControlsPopout.qml"

            else if(!PQSettings.slideShowControlsPopoutElement && slideshowcontrols.source != "slideshow/PQSlideShowControls.qml")
                slideshowcontrols.source = "slideshow/PQSlideShowControls.qml"

        } else if(component == "filerename") {

            if(PQSettings.fileRenamePopoutElement && filerename.source != "filemanagement/PQRenamePopout.qml")
                filerename.source = "filemanagement/PQRenamePopout.qml"

            else if(!PQSettings.fileRenamePopoutElement && filerename.source != "filemanagement/PQRename.qml")
                filerename.source = "filemanagement/PQRename.qml"

        } else if(component == "filedelete") {

            if(PQSettings.fileDeletePopoutElement && filedelete.source != "filemanagement/PQDeletePopout.qml")
                filedelete.source = "filemanagement/PQDeletePopout.qml"

            else if(!PQSettings.fileDeletePopoutElement && filedelete.source != "filemanagement/PQDelete.qml")
                filedelete.source = "filemanagement/PQDelete.qml"

        } else if(component == "scale") {

            if(PQSettings.scalePopoutElement && scaleimage.source != "scale/PQScalePopout.qml")
                scaleimage.source = "scale/PQScalePopout.qml"

            else if(!PQSettings.scalePopoutElement && scaleimage.source != "scale/PQScale.qml")
                scaleimage.source = "scale/PQScale.qml"

        } else if(component == "about") {

            if(PQSettings.aboutPopoutElement && about.source != "about/PQAboutPopout.qml")
                about.source = "about/PQAboutPopout.qml"

            else if(!PQSettings.aboutPopoutElement && about.source != "about/PQAbout.qml")
                about.source = "about/PQAbout.qml"

        } else if(component == "imgur" || component == "imguranonym") {

            if(PQSettings.imgurPopoutElement && imgur.source != "imgur/PQImgurPopout.qml")
                imgur.source = "imgur/PQImgurPopout.qml"

            else if(!PQSettings.imgurPopoutElement && imgur.source != "imgur/PQImgur.qml")
                imgur.source = "imgur/PQImgur.qml"

        }

    }

}

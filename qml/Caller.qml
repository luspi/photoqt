import QtQuick 2.6

Item {

    /***********************************************************/
    /***********************************************************/
    // These signals are used to interact with loaded elements.

    signal openfileShow()
    signal openfileHide()

    signal thumbnailsShow()
    signal thumbnailsHide()
    signal thumbnailsLoadDirectory(var filename, var filter)

    signal settingsmanagerShow()
    signal settingsmanagerHide()
    signal settingsmanagerSave()
    signal settingsmanagerNextTab()
    signal settingsmanagerPrevTab()
    signal settingsmanagerGoToTab(var index)

    signal slideshowSettingsShow()
    signal slideshowSettingsHide()
    signal slideshowBarShow()
    signal slideshowBarHide()
    signal slideshowStartFromSettings()
    signal slideshowStart()
    signal slideshowStop()
    signal slideshowQuickStart()
    signal slideshowPause()

    signal histogramShow()
    signal histogramHide()

    signal filemanagementShow(var category)
    signal filemanagementHide()
    signal permanentDeleteFile()
    signal filemanagementPerformRename()
    signal filemanagementDeleteImage()

    signal aboutShow()
    signal aboutHide()

    signal imgurfeedbackShow()
    signal imgurfeedbackAnonymShow()
    signal imgurfeedbackHide()

    signal filterShow()
    signal filterHide()
    signal filterAccept()

    signal wallpaperShow()
    signal wallpaperHide()
    signal wallpaperAccept()

    signal scaleShow()
    signal scaleHide()
    signal scaleunsupportedShow()
    signal scaleunsupportedHide()

    signal startupShow(var type, var filename)
    signal startupHide()

    /***********************************************************/
    /***********************************************************/

    // This is written to by the individual elements to keep track of which one is shown/hidden.
    // We have to let the elements handle it as a call to hide does not always result in the element being hidden...
    property alias whatisshown: whatisshown_
    Item {
        id: whatisshown_
        property bool thumbnails: false
        property bool openfile: false
        property bool settingsmanager: false
        property bool slideshowsettings: false
        property bool slideshowbar: false
        property bool histogram: false
        property bool filemanagement: false
        property bool about: false
        property bool imgurfeedback: false
        property bool filter: false
        property bool wallpaper: false
        property bool scale: false
        property bool scaleunsupported: false
        property bool startup: false
    }

    // Load and show a component
    function show(component) {

        ensureElementSetup(component)

        if(component == "openfile")
            openfileShow()
        else if(component == "thumbnails")
            thumbnailsShow()
        else if(component == "settingsmanager")
            settingsmanagerShow()
        else if(component == "slideshowsettings")
            slideshowSettingsShow()
        else if(component == "slideshowbar")
            slideshowBarShow()
        else if(component == "histogram")
            histogramShow()
        else if(component == "about")
            aboutShow()
        else if(component == "imgurfeedback")
            imgurfeedbackShow()
        else if(component == "imgurfeedbackanonym")
            imgurfeedbackAnonymShow()
        else if(component == "filter")
            filterShow()
        else if(component == "wallpaper")
            wallpaperShow()
        else if(component == "scale")
            scaleShow()
        else if(component == "scaleunsupported")
            scaleunsupportedShow()
        else if(component == "startup")
            startupShow(variables.startupUpdateStatus, variables.startupFilenameAfter)
    }

    // Hide a component
    function hide(component) {
        if(component == "openfile")
            openfileHide()
        else if(component == "thumbnails")
            thumbnailsHide()
        else if(component == "settingsmanager")
            settingsmanagerHide()
        else if(component == "slideshowsettings")
            slideshowSettingsHide()
        else if(component == "slideshowbar")
            slideshowBarHide()
        else if(component == "histogram")
            histogramHide()
        else if(component == "filemanagement")
            filemanagementHide()
        else if(component == "about")
            aboutHide()
        else if(component == "imgurfeedback")
            imgurfeedbackHide()
        else if(component == "filter")
            filterHide()
        else if(component == "wallpaper")
            wallpaperHide()
        else if(component == "scale")
            scaleHide()
        else if(component == "scaleunsupported")
            scaleunsupportedHide()
        else if(component == "startup")
            startupHide()
    }

    // Load some function
    function load(func) {

        if(func == "thumbnailLoadDirectory")
            thumbnailsLoadDirectory(variables.currentFile, variables.filter)
        else if(func == "settingsmanagerSave")
            settingsmanagerSave()
        else if(func == "settingsmanagerNextTab")
            settingsmanagerNextTab()
        else if(func == "settingsmanagerPrevTab")
            settingsmanagerPrevTab()
        else if(func == "settingsmanagerPrevTab")
            settingsmanagerPrevTab()
        else if(func == "settingsmanagerGoToTab1")
            settingsmanagerGoToTab(0)
        else if(func == "settingsmanagerGoToTab2")
            settingsmanagerGoToTab(1)
        else if(func == "settingsmanagerGoToTab3")
            settingsmanagerGoToTab(2)
        else if(func == "settingsmanagerGoToTab4")
            settingsmanagerGoToTab(3)
        else if(func == "settingsmanagerGoToTab5")
            settingsmanagerGoToTab(4)
        else if(func == "settingsmanagerGoToTab6")
            settingsmanagerGoToTab(5)
        else if(func == "slideshowStart")
            slideshowStart()
        else if(func == "slideshowStop")
            slideshowStop()
        else if(func == "slideshowStartFromSettings")
            slideshowStartFromSettings()
        else if(func == "slideshowQuickStart") {
            ensureElementSetup("slideshowsettings")
            slideshowQuickStart()
        } else if(func == "slideshowPause")
            slideshowPause()
        else if(func == "filemanagementCopyShow") {
            ensureElementSetup("filemanagement")
            filemanagementShow("cp")
        } else if(func == "filemanagementDeleteShow") {
            ensureElementSetup("filemanagement")
            filemanagementShow("del")
        } else if(func == "filemanagementMoveShow") {
            ensureElementSetup("filemanagement")
            filemanagementShow("mv")
        } else if(func == "filemanagementRenameShow") {
            ensureElementSetup("filemanagement")
            filemanagementShow("rn")
        } else if(func == "permanentDeleteFile") {
            ensureElementSetup("filemanagement")
            permanentDeleteFile()
        } else if(func == "filemanagementPerformRename")
            filemanagementPerformRename()
        else if(func == "filemanagementDeleteImage")
            filemanagementDeleteImage()
        else if(func == "filterAccept")
            filterAccept()
        else if(func == "wallpaperAccept")
            wallpaperAccept()
    }

    function ensureElementSetup(component) {

        if(component == "openfile" && openfile.status == Loader.Null)
            openfile.source = "openfile/OpenFile.qml"
        else if(component == "thumbnails" && thumbnails.status == Loader.Null)
            thumbnails.source = "mainview/Thumbnails.qml"
        else if(component == "settingsmanager" && settingsmanager.status == Loader.Null)
            settingsmanager.source = "settingsmanager/SettingsManager.qml"
        else if(component == "slideshowsettings" && slideshowsettings.status == Loader.Null && slideshowbar.status == Loader.Null) {
            slideshowsettings.source = "slideshow/SlideshowSettings.qml"
            slideshowbar.source = "slideshow/SlideshowBar.qml"
        } else if(component == "slideshowbar" && slideshowsettings.status == Loader.Null && slideshowbar.status == Loader.Null) {
            slideshowsettings.source = "slideshow/SlideshowSettings.qml"
            slideshowbar.source = "slideshow/SlideshowBar.qml"
        } else if(component == "histogram" && histogram.status == Loader.Null)
            histogram.source = "mainview/Histogram.qml"
        else if(component == "filemanagement" && filemanagement.status == Loader.Null)
            filemanagement.source = "filemanagement/Management.qml"
        else if(component == "about" && about.status == Loader.Null)
            about.source = "other/About.qml"
        else if((component == "imgurfeedback" || component == "imgurfeedbackanonym") && imgurfeedback.status == Loader.Null)
            imgurfeedback.source = "other/ImgurFeedback.qml"
        else if(component == "filter" && filter.status == Loader.Null)
            filter.source = "other/Filter.qml"
        else if(component == "wallpaper" && wallpaper.status == Loader.Null)
            wallpaper.source = "wallpaper/Wallpaper.qml"
        else if(component == "scale" && scaleimage.status == Loader.Null)
            scaleimage.source = "other/Scale.qml"
        else if(component == "scaleunsupported" && scaleimageunsupported.status == Loader.Null)
            scaleimageunsupported.source = "other/ScaleUnsupported.qml"
        else if(component == "startup" && startup.status == Loader.Null)
            startup.source = "other/Startup.qml"

    }

}

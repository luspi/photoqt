import QtQuick 2.5

Item {

    // These are currently only used for showing when a shortcut is also already used for others (in DetectShortcut element)
    // To avoid triggering a re-translation of all these strings after the translation process has already started, leave them untranslated for the upcomoing release.
    // This is okay, as they play only a very minor role!! They will eventually be used (localised) not only in DetectShortcut but also TabShortcuts!

    property var text: ({"__open" : "Open New File",
                         "__filterImages" : "Filter Images in Folder",
                         "__next" : "Next Image",
                         "__prev" : "Previous Image",
                         "__gotoFirstThb" : "Go to first Image",
                         "__gotoLastThb" : "Go to last Image",
                         "__hide" : "Hide to System Tray",
                         "__close" : "Quit PhotoQt",

                         "__zoomIn" : "Zoom In",
                         "__zoomOut" : "Zoom Out",
                         "__zoomActual" : "Zoom to Actual Size",
                         "__zoomReset" : "Reset Zoom",
                         "__rotateR" : "Rotate Right",
                         "__rotateL" : "Rotate Left",
                         "__rotate0" : "Reset Rotation",
                         "__flipH" : "Flip Horizontally",
                         "__flipV" : "Flip Vertically",
                         "__scale" : "Scale Image",
                         "__playPauseAni" : "Play/Pause image animation",

                         "__rename" : "Rename File",
                         "__delete" : "Delete File",
                         "__deletePermanent" : "Delete File (without confirmation)",
                         "__copy" : "Copy File to a New Location",
                         "__move" : "Move File to a New Location",

                         "__stopThb" : "Interrupt Thumbnail Creation",
                         "__reloadThb" : "Reload Thumbnails",
                         "__hideMeta" : "Hide/Show Exif Info",
                         "__settings" : "Show Settings",
                         "__slideshow" : "Start Slideshow",
                         "__slideshowQuick" : "Start Slideshow (Quickstart)",
                         "__about" : "About PhotoQt",
                         "__wallpaper" : "Set as Wallpaper",
                         "__imgurAnonym" : "Upload to imgur.com (anonymously)",
                         "__imgur" : "Upload to imgur.com user account"})

    function get(key) {
        if(key in text)
            return text[key]
        return key
    }

}

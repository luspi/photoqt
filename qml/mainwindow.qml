import QtQuick 2.5
//import QtQuick.Controls 1.2
import QtQuick.Window 2.2

import PSettings 1.0
import PFileFormats 1.0
import PGetAndDoStuff 1.0
import PGetMetaData 1.0
import PToolTip 1.0
import PColour 1.0
import QtGraphicalEffects 1.0
import PImageWatch 1.0
import PImgur 1.0
import PShortcutsNotifier 1.0
import PThumbnailManagement 1.0
import PShortcutsHandler 1.0
import PWatcher 1.0

import "./mainview"
import "./shortcuts"
import "./openfile"
import "./vars"
import "./elements"

import "./loadfile.js" as Load

Rectangle {

    id: mainwindow

    // Some signals for communicating back to the C++ code base
    signal verboseMessage(string loc, string msg)
    signal setOverrideCursor()
    signal restoreOverrideCursor()

    signal closePhotoQt()
    signal quitPhotoQt()

    // tell the c++ code to update the tray icon
    // We need to pass on the value as there is a delay for writing a change of the settings to file, thus it might not be updated on harddrive when we get to this point
    signal trayIconValueChanged(int icon)

    anchors.fill: parent

    // Transparent background, the Background element handles the actual background
    color: "transparent"

    // Without this nothing will be visible
    visible: true

    /**************************************************************
     *                                                            *
     * SOME INVISIBLE ELEMENTS FOR INTERACTING WITH C++ CODE BASE *
     *                                                            *
     **************************************************************/

    // All the permanent settings
    PSettings { id: settings }

    // The fileformats known to PhotoQt
    PFileFormats { id: fileformats; }

    // The colouring of PhotoQt
    PColour { id: colour; }

    // A whole bunch of C++ helper functions for QML
    PGetAndDoStuff { id: getanddostuff; }

    // Read the Exif/IPTC metadata of images
    PGetMetaData { id: getmetadata; }

    // Watch for changes to images in the currently loaded folder
    PImageWatch { id: imagewatch }

    // Share images to imgur.com
    PImgur { id: shareonline_imgur; }

    // Provide some management of the thumbnails database
    PThumbnailManagement { id: thumbnailmanagement; }

    // Load the shortcuts from file and provide some shortcut related convenience functions
    PShortcutsHandler { id: shortcutshandler }

    PWatcher { id: watcher }

    //////////////////////////////////////////////
    // THE TOOLTIP HAS A SPECIAL ROLE: IT'S NOT //
    // DIRECTLY A VISUAL ITEM BUT RELAYS BACK   //
    // TO A QWIDGETS BASED QTOOLTIP
    //////////////////////////////////////////////
    PToolTip {
        id: globaltooltip;
        Component.onCompleted: {
            setBackgroundColor(colour.tooltip_bg)
            setTextColor(colour.tooltip_text)
        }
    }


    /*******************************************
     *                                         *
     * SOME INVISIBLE ELEMENTS FOR QML CLASSES *
     *                                         *
     *******************************************/

    // The shortcuts engine
    Shortcuts { id: shortcuts }

    // Some of the variables used in various places
    Variables { id: variables }

    // Some strings for keys and mouse shortcuts
    Strings { id: strings }

    // Used to show and hide elements that are loaded when needed
    Caller { id: call }


    /************************************
     *                                  *
     * THE VISIBLE ELEMENTS FOR THE GUI *
     *                                  *
     ************************************/

    // Managing the background begind everything
    Background { id: background }

    // The item for displaying the main image
    MainImage { id: imageitem }

    // This mousearea sits below fadeable events to show/hide them appropriately
    HandleMouseMovements { id: handlemousemovements }

    // The quickinfo element displays some information about the currently visible image and its position in the folder
    QuickInfo { id: quickinfo }

    // An 'x' in the top right corner for closing PhotoQt
    ClosingX { id: closingx }

    /**************************/
    // ITEMS THAT FADE IN/OUT

    // The thumbnail bar
    Loader { id: thumbnails }

    // A floating, movable element showing the histogram for the currently loaded image
    Loader { id: histogram }

    // The mainmenu, right screen edge
    MainMenu { id: mainmenu }

    // The metadata about the currently loaded image, left screen edge
    MetaData { id: metadata }

    // An element for browsing and opening files (loaded as needed)
    Loader { id: openfile }

    // The settings manager for tweaking PhotoQt
    Loader { id: settingsmanager }

    // An element to tweak the settings of a slideshow and then start one
    Loader { id: slideshowsettings }

    // A bar handling the actualy slideshow, providing ways to pause/quit the slideshow and adjust the music volume
    Loader { id: slideshowbar }

    // Some file management features, such as copy, move, rename, delete
    Loader { id: filemanagement }

    // Some information about me and PhotoQt
    Loader { id: about }

    // Shows status and result information about uploading images to imgur.com
    Loader { id: imgurfeedback }

    // Filter the currently loaded folder
    Loader { id: filter }

    // Set the currently loaded image as wallpaper (if available)
    Loader { id: wallpaper }

    // Scale the currently loaded image (or inform that it can't be scaled)
    Loader { id: scaleimage }
    Loader { id: scaleimageunsupported }

    // A small message at first startup after an update/install
    Loader { id: startup }

    // The shortcut notifier element
    PShortcutsNotifier { id: sh_notifier; }


    /********************************************************************************
     *                                                                              *
     * SOME SETTINGS NEED TO BE APPLIED PROPERLY WHEN THEY CHANGE AND/OR AT STARTUP *
     *                                                                              *
     ********************************************************************************/

    Connections {
        target: settings
        onThumbnailKeepVisibleChanged:
            if(settings.thumbnailKeepVisible) {
                call.ensureElementSetup("thumbnails")
                call.show("thumbnails")
            }
        onThumbnailKeepVisibleWhenNotZoomedInChanged:
            if(settings.thumbnailKeepVisibleWhenNotZoomedIn) {
                call.ensureElementSetup("thumbnails")
                call.show("thumbnails")
            }
        onThumbnailDisableChanged:
            if(!settings.thumbnailDisable) {
                call.ensureElementSetup("thumbnails")
                call.load("thumbnailLoadDirectory")
            }
        onTrayIconChanged:
            trayIconValueChanged(settings.trayIcon)
        onSortbyChanged:
            Load.loadFile(variables.currentFile, variables.filter, true)
        onSortbyAscendingChanged:
            Load.loadFile(variables.currentFile, variables.filter, true)
    }

    Component.onCompleted: {
        if(settings.thumbnailKeepVisible || settings.thumbnailKeepVisibleWhenNotZoomedIn)
            call.show("thumbnails")
    }


    /**************************************************
     *                                                *
     * A WHOLE BUNCH OF FUNCTIONS TO DO GENERAL STUFF *
     *                                                *
     **************************************************/

    function windowXYchanged(x, y) {
        variables.windowXY = Qt.point(x, y)
    }

    function processShortcut(sh) {
        shortcuts.processString(sh)
    }

    function keysRelease() {
        call.load("keysReleased")
    }

    // Called from c++ code to open a new file (needed for remote controlling)
    function openfileShow() {
        call.show("openfile")
    }

    // Called from c++ code to load an image file (needed for remote controlling)
    function loadFile(filename) {
        variables.filter = ""
        Load.loadFile(filename, "", false)
    }

    // Called from c++ code to get the filename of the currently loaded image file (needed for remote controlling)
    function getCurrentFile() {
        return variables.currentFile
    }

    // Close any possibly open element. This is needed for remote controlling, e.g., for loading an image while there is an element open in PhotoQt.
    // We use the system shortcut for closing elements, Escape. As there might be multiple levels of elements open, we use a timer to call Escape
    // repeatedly until any element is closed and the GUI is unblocked.
    function closeAnyElement() {
        call.load("closeAnyElement")
    }

    // Manage the startup event, called from c++ after everything is set up with filename and update state.
    function manageStartup(filename, update) {

        // If thumbnails are not disabled, we ensure the element is set up, but no need to actually show the bar
        if(!settings.thumbnailDisable)
            call.ensureElementSetup("thumbnails")

        // Same for the histogram, but it we actually show
        if(settings.histogram)
            call.ensureElementSetup("histogram")

        // The first time after an update/install, we display an update/install message before processing the received filename
        if(update != 0) {
            variables.startupUpdateStatus = update
            variables.startupFilenameAfter = filename
            call.show("startup")
        } else {
            // If no filename has been passed, show the OpenFile element
            if(filename == "")
                call.show("openfile")
            // Otherwise just load the received file
            else
                Load.loadFile(filename)
        }

    }

}

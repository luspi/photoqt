import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

    id: mainmenu

    // Background/Border color
    color: colour.fadein_slidein_bg
    border.width: 1
    border.color: colour.fadein_slidein_border

    // Set position (we pretend that rounded corners are along the bottom edge only, that's why visible y is off screen)
    x: (background.width-width)+1
    y: -1

    // Adjust size
    width: settings.mainMenuWindowWidth
    height: background.height+2

    opacity: 0
    visible: opacity != 0
    Behavior on opacity { NumberAnimation { duration: 250; } }

    property var allitems_static: [
        //: This is an entry in the mainmenu on the right
        [["open", "open", qsTr("Open File")]],
        //: This is an entry in the mainmenu on the right
        [["settings", "settings", qsTr("Settings")]],
        //: This is an entry in the mainmenu on the right
        [["wallpaper", "settings", qsTr("Set as Wallpaper")]],
        //: This is an entry in the mainmenu on the right
        [["slideshow","slideshow",qsTr("Slideshow")],
                //: This is an entry in the mainmenu on the right, used as 'setting up a slideshow'
                ["slideshow","",qsTr("setup")],
                //: This is an entry in the mainmenu on the right, used as in 'quickstarting a slideshow'
                ["slideshowquickstart","",qsTr("quickstart")]],
        //: This is an entry in the mainmenu on the right
        [["filter", "filter", qsTr("Filter Images in Folder")]],
        //: This is an entry in the mainmenu on the right
        [["metadata", "metadata", qsTr("Show/Hide Metadata")]],
        //: This is an entry in the mainmenu on the right
        [["histogram", "histogram", qsTr("Show/Hide Histogram")]],
        //: This is an entry in the mainmenu on the right
        [["about", "about", qsTr("About PhotoQt")]],
        //: This is an entry in the mainmenu on the right
        [["hide", "hide", qsTr("Hide (System Tray)")]],
        //: This is an entry in the mainmenu on the right
        [["quit", "quit", qsTr("Quit")]],

        [["heading","",""]],

        //: This is an entry in the mainmenu on the right, used as in 'Go To some image'
        [["","goto",qsTr("Go to")],
                //: This is an entry in the mainmenu on the right, used as in 'go to previous image'
                ["prev","",qsTr("previous")],
                //: This is an entry in the mainmenu on the right, used as in 'go to next image'
                ["next","",qsTr("next")],
                //: This is an entry in the mainmenu on the right, used as in 'go to first image'
                ["first","",qsTr("first")],
                //: This is an entry in the mainmenu on the right, used as in 'go to last image'
                ["last","",qsTr("last")]],
        //: This is an entry in the mainmenu on the right, used as in 'Zoom image'
        [["zoom","zoom",qsTr("Zoom")],
                //: This is an entry in the mainmenu on the right, used as in 'Zoom in on image'
                ["zoomin","",qsTr("in")],
                //: This is an entry in the mainmenu on the right, used as in 'Zoom out of image'
                ["zoomout","",qsTr("out")],
                //: This is an entry in the mainmenu on the right, used as in 'Reset zoom of image'
                ["zoomreset","",qsTr("reset")],
                //: This is an entry in the mainmenu on the right, used as in 'Zoom image to actual size (1:1, one-to-one)'
                ["zoomactual","","1:1"]],
        //: This is an entry in the mainmenu on the right, used as in 'Rotate image'
        [["rotate","rotate",qsTr("Rotate")],
                //: This is an entry in the mainmenu on the right, used as in 'Rotate image left'
                ["rotateleft","",qsTr("left")],
                //: This is an entry in the mainmenu on the right, used as in 'Rotate image right'
                ["rotateright","",qsTr("right")],
                //: This is an entry in the mainmenu on the right, used as in 'Reset rotation of image'
                ["rotatereset","",qsTr("reset")]],
        //: This is an entry in the mainmenu on the right, used as in 'Flip/Mirror image'
        [["flip","flip",qsTr("Flip")],
                //: This is an entry in the mainmenu on the right, used as in 'Flip/Mirror image horizontally'
                ["flipH","",qsTr("horizontal")],
                //: This is an entry in the mainmenu on the right, used as in 'Flip/Mirror image vertically'
                ["flipV","",qsTr("vertical")],
                //: This is an entry in the mainmenu on the right, used as in 'Reset flip/mirror of image'
                ["flipReset","",qsTr("reset")]],
        //: This is an entry in the mainmenu on the right, used to refer to the current file (specifically the file, not directly the image)
        [["","copy",qsTr("File")],
                //: This is an entry in the mainmenu on the right, used as in 'rename file'
                ["rename","",qsTr("rename")],
                //: This is an entry in the mainmenu on the right, used as in 'copy file'
                ["copy","",qsTr("copy")],
                //: This is an entry in the mainmenu on the right, used as in 'move file'
                ["move","",qsTr("move")],
                //: This is an entry in the mainmenu on the right, used as in 'delete file'
                ["delete","",qsTr("delete")]],

        [["heading","",""]],

        //: This is an entry in the mainmenu on the right
        [["scale","scale",qsTr("Scale Image")]],
        //: This is an entry in the mainmenu on the right
        [["default","open",qsTr("Open in default file manager")]]
    ]
    property var allitems_external: []
    property var allitems: []

    // An 'x' to close photoqt
    Rectangle {

        // Position it
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 1
        anchors.topMargin: 1

        // Width depends on type of 'x'
        width: 3*settings.closeXsize
        height: 3*settings.closeXsize

        // Invisible rectangle
        color: "#00000000"

        // Fancy 'x'
        Image {

            id: img_x

            anchors.right: parent.right
            anchors.top: parent.top

            source: "qrc:/img/closingx.png"
            sourceSize: Qt.size(3*settings.closeXsize,3*settings.closeXsize)

        }

        // Click on it
        ToolTip {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            text: qsTr("Close PhotoQt")
            onClicked: {
                if(settings.trayicon)
                    hideToSystemTray()
                else
                    quitPhotoQt()
            }
        }

    }


    Text {

        id: heading
        y: 10
        x: (parent.width-width)/2
        font.pointSize: 15
        color: colour.text
        font.bold: true
        text: qsTr("Main Menu")

    }

    Rectangle {
        id: spacingbelowheader
        x: 5
        y: heading.y+heading.height+10
        height: 1
        width: parent.width-10
        color: "#88ffffff"
    }

    ListView {

        id: mainlistview
        x: 10
        y: spacingbelowheader.y + spacingbelowheader.height+10
        height: parent.height-y-(helptext.height+5)
        width: maxw+20
        model: allitems.length
        delegate: maindeleg
        clip: true

        orientation: ListView.Vertical

    }

    property int maxw: 0

    Component {

        id: maindeleg

        ListView {

            Component.onCompleted:
                if(width > maxw) maxw = width

            id: subview

            property int mainindex: index
            height: 25
            width: childrenRect.width

            interactive: false

            orientation: Qt.Horizontal
            spacing: 5

            model: allitems[mainindex].length
            delegate: Row {

                spacing: 5

                Text {
                    id: sep
                    lineHeight: 1.5

                    color: colour.text_inactive
                    visible: allitems[subview.mainindex].length > 1 && index > 1
                    font.bold: true
                    text: "/"
                }

                Image {
                    y: 2.5
                    width: ((source!="" || allitems[subview.mainindex][index][0]==="heading") ? val.height*0.5 : 0)
                    height: val.height*0.5
                    sourceSize.width: width
                    sourceSize.height: height
                    source: allitems[subview.mainindex][index][1]===""
                            ? "" : (allitems[subview.mainindex][index][0].slice(0,8)=="_:_EX_:_"
                                    ? getanddostuff.getIconPathFromTheme(allitems[subview.mainindex][index][1]) : "qrc:/img/mainmenu/" + allitems[subview.mainindex][index][1] + ".png")
                    opacity: (settings.trayicon || allitems[subview.mainindex][index][0] !== "hide") ? 1 : 0.5
                    visible: (source!="" || allitems[subview.mainindex][index][0]==="heading")
                }

                Text {

                    id: val;

                    color: (allitems[subview.mainindex][index][0]==="heading") ? "white" : colour.text_inactive
                    lineHeight: 1.5

                    font.capitalization: (allitems[subview.mainindex][index][0]==="heading") ? Font.SmallCaps : Font.MixedCase

                    opacity: enabled ? 1 : 0.5

                    font.pointSize: 10
                    font.bold: true

                    enabled: (settings.trayicon || (allitems[subview.mainindex][index][0] !== "hide" && allitems[subview.mainindex][index][0] !=="heading" && (allitems[subview.mainindex].length === 1 || index > 0)))

                    // The spaces guarantee a bit of space betwene icon and text
                    text: allitems[subview.mainindex][index][2] + ((allitems[subview.mainindex].length > 1 && index == 0) ? ":" : "")

                    MouseArea {

                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: (allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0)) ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onEntered: {
                            if(allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0))
                                val.color = colour.text
                        }
                        onExited: {
                            if(allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0))
                                val.color = colour.text_inactive
                        }
                        onClicked: {
                            if(allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0))
                                mainmenuDo(allitems[subview.mainindex][index][0])
                        }

                    }

                }

            }

        }

    }

    Rectangle {
        anchors {
            bottom: helptext.top
            left: parent.left
            right: parent.right
        }
        height: 1
        color: "#22ffffff"

    }

    Text {

        id: helptext

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: 100

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: "grey"
        wrapMode: Text.WordWrap

        //: This message is shown at the bottom of the mainmenu
        text: qsTr("Click here to go to the online manual for help regarding shortcuts, settings, features, ...")

        ToolTip {
            anchors.fill: parent
            text: "http://photoqt.org/man"
            cursorShape: Qt.PointingHandCursor
            onClicked: getanddostuff.openLink("http://photoqt.org/man")
        }

    }

    MouseArea {
        x: 0
        width: 8
        y: 0
        height: parent.height
        cursorShape: Qt.SplitHCursor
        property int oldMouseX

        onPressed:
            oldMouseX = mouseX

        onReleased:
            settings.mainMenuWindowWidth = parent.width

        onPositionChanged: {
            if (pressed) {
                var w = parent.width + (oldMouseX-mouseX)
                if(w >= 300 && w <= background.width/2)
                    parent.width = w
            }
        }
    }

    Component.onCompleted: setupExternalApps()

    function setupExternalApps() {

        allitems_external = []

        var c = getanddostuff.getContextMenu()

        for(var i = 0; i < c.length/3; ++i) {
            var bin = getanddostuff.trim(c[3*i].replace("%f","").replace("%u","").replace("%d",""))
            // The icon for Krita is called 'calligrakrita'
            if(bin === "krita")
                allitems_external.push([["_:_EX_:_" + c[3*i+1] + "___" + c[3*i], "calligrakrita", c[3*i+2]]])
            else
                allitems_external.push([["_:_EX_:_" + c[3*i+1] + "___" + c[3*i], bin, c[3*i+2]]])
        }

        allitems = allitems_static.concat(allitems_external)
    }

    // Do stuff on clicking on an entry
    function mainmenuDo(what) {

        verboseMessage("MainMenu::mainmenuDo()",what)

        if(what === "open") {

            hideMainmenu.start()
            openFile()

        } else if(what === "quit") {

            hideMainmenu.start()
            quitPhotoQt()

        } else if(what === "about") {

            hideMainmenu.start()
            about.showAbout()

        } else if(what === "settings") {

            hideMainmenu.start()
            settingsmanager.showSettings()

        } else if(what === "wallpaper") {

            hideMainmenu.start()
            wallpaper.showWallpaper()

        } else if(what === "slideshow") {

            hideMainmenu.start()
            slideshow.showSlideshow()

        } else if(what === "slideshowquickstart") {

            hideMainmenu.start()
            slideshow.quickstart()

        } else if(what === "filter") {

            hideMainmenu.start()
            filter.showFilter()

        } else if(what === "metadata") {
            if(metaData.opacity != 0) {
                metaData.uncheckCheckbox()
                background.hideMetadata()
            } else {
                metaData.checkCheckbox()
                background.showMetadata(true)
            }

        } else if(what == "histogram") {

            if(settings.histogram == false)
                settings.histogram = true
            else
                settings.histogram = false

        } else if(what === "scale") {

            hideMainmenu.start()
            scaleImage.showScale()

        } else if(what === "zoomin")

            mainview.zoomIn(true)

        else if(what === "zoomout")

            mainview.zoomOut(true)

        else if(what === "zoomreset")

            mainview.resetZoom()

        else if(what === "zoomactual")

            mainview.zoomActual()

        else if(what === "rotateleft")

            mainview.rotateLeft()

        else if(what === "rotateright")

            mainview.rotateRight()

        else if(what === "rotatereset")

            mainview.resetRotation()

        else if(what === "flipH")

            mainview.mirrorHorizontal()

        else if(what === "flipV")

            mainview.mirrorVertical()

        else if(what === "flipReset")

            mainview.resetMirror()

        else if(what === "rename") {

            if(thumbnailBar.currentFile !== "") {
                hideMainmenu.start()
                rename.showRename()
            }

        } else if(what === "copy") {

            if(thumbnailBar.currentFile !== "") {
                hideMainmenu.start()
                getanddostuff.copyImage(thumbnailBar.currentFile)
            }

        } else if(what === "move") {

            if(thumbnailBar.currentFile !== "") {
                hideMainmenu.start()
                getanddostuff.moveImage(thumbnailBar.currentFile)
            }

        } else if(what === "delete") {

            if(thumbnailBar.currentFile !== "") {
                hideMainmenu.start()
                deleteImage.showDelete()
            }

        } else if(what === "prev") {

            if(thumbnailBar.currentFile !== "")
                thumbnailBar.previousImage()

        } else if(what === "next") {

            if(thumbnailBar.currentFile !== "")
                thumbnailBar.nextImage()

        } else if(what === "first") {

            if(thumbnailBar.currentFile !== "")
                thumbnailBar.gotoFirstImage()

        } else if(what === "last") {

            if(thumbnailBar.currentFile !== "")
                thumbnailBar.gotoLastImage()

        } else if(what === "default") {

            if(thumbnailBar.currentFile !== "")
                getanddostuff.openInDefaultFileManager(thumbnailBar.currentFile)

        } else if(what.slice(0,8) === "_:_EX_:_") {

            var parts = (what.split("_:_EX_:_")[1]).split("___")
            var close = parts[0];
            var exe = parts[1];

            verboseMessage("MainMenu::executeExternal()",close + " - " + exe)
            if(thumbnailBar.currentFile !== "") {
                getanddostuff.executeApp(exe,thumbnailBar.currentFile,close)
                if(close*1 == 1)
                    if(settings.trayicon)
                        hideToSystemTray()
                    else
                        quitPhotoQt()
            }

        }

    }

    function show() {
        if(opacity != 1) verboseMessage("MainMenu::show()", opacity + " to 1")
        opacity = 1
    }
    function hide() {
        if(opacity != 0) verboseMessage("MainMenu::hide()", opacity + " to 0")
        opacity = 0
    }

    function clickInMainMenu(pos) {
        var ret = mainmenu.contains(mainmenu.mapFromItem(toplevel,pos.x,pos.y))
        verboseMessage("MainMenu::clickInMainMenu()", pos)
        return ret
    }

}

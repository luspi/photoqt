import QtQuick 2.5
import QtQuick.Controls 1.4

import "../elements"
import "../loadfile.js" as Load

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
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    // This mouseare catches all mouse movements and prevents them from being passed on to the background
    MouseArea { anchors.fill: parent; hoverEnabled: true }

    property var allitems_static: [
        //: This is an entry in the main menu on the right. Keep short!
        [["__open", "open", em.pty+qsTr("Open File"), "hide"]],
        //: This is an entry in the main menu on the right. Keep short!
        [["__settings", "settings", em.pty+qsTr("Settings"), "hide"]],
        //: This is an entry in the main menu on the right. Keep short!
        [["__wallpaper", "settings", em.pty+qsTr("Set as Wallpaper"), "hide"]],
        //: This is an entry in the main menu on the right. Keep short!
        [["slideshow","slideshow",em.pty+qsTr("Slideshow")],
                //: This is an entry in the main menu on the right, used as in 'setting up a slideshow'. Keep short!
                ["__slideshow","",em.pty+qsTr("setup"), "hide"],
                //: This is an entry in the main menu on the right, used as in 'quickstarting a slideshow'. Keep short!
                ["__slideshowQuick","",em.pty+qsTr("quickstart"), "hide"]],
        //: This is an entry in the main menu on the right. Keep short!
        [["__filterImages", "filter", em.pty+qsTr("Filter Images in Folder"), "hide"]],
        //: This is an entry in the main menu on the right. Keep short!
        [["__hideMeta", "metadata", em.pty+qsTr("Show/Hide Metadata"), "donthide"]],
        //: This is an entry in the main menu on the right. Keep short!
        [["__histogram", "histogram", em.pty+qsTr("Show/Hide Histogram"), "donthide"]],
        //: This is an entry in the main menu on the right. Keep short!
        [["__about", "about", em.pty+qsTr("About PhotoQt"), "hide"]],
        //: This is an entry in the main menu on the right. Keep short!
        [["__hide", "hide", em.pty+qsTr("Hide (System Tray)"), "hide"]],
        //: This is an entry in the main menu on the right. Keep short!
        [["__close", "quit", em.pty+qsTr("Quit"), "hide"]],

        [["heading","",""]],

        //: This is an entry in the main menu on the right, used as in 'Go To some image'. Keep short!
        [["","goto",em.pty+qsTr("Go to")],
                //: This is an entry in the main menu on the right, used as in 'go to previous image'. Keep short!
                ["__prev","",em.pty+qsTr("previous"), "donthide"],
                //: This is an entry in the main menu on the right, used as in 'go to next image'. Keep short!
                ["__next","",em.pty+qsTr("next"), "donthide"],
                //: This is an entry in the main menu on the right, used as in 'go to first image'. Keep short!
                ["__gotoFirstThb","",em.pty+qsTr("first"), "donthide"],
                //: This is an entry in the main menu on the right, used as in 'go to last image'. Keep short!
                ["__gotoLastThb","",em.pty+qsTr("last"), "donthide"]],
        //: This is an entry in the main menu on the right, used as in 'Zoom image'. Keep short!
        [["zoom","zoom",em.pty+qsTr("Zoom")],
                ["__zoomIn","","+", "donthide"],
                ["__zoomOut","","-", "donthide"],
                ["__zoomReset","","0", "donthide"],
                ["__zoomActual","","1:1", "donthide"]],
        //: This is an entry in the main menu on the right, used as in 'Rotate image'. Keep short!
        [["rotate","rotate",em.pty+qsTr("Rotate")],
                //: This is an entry in the main menu on the right, used as in 'Rotate image left'. Keep short!
                ["__rotateL","",em.pty+qsTr("left"), "donthide"],
                //: This is an entry in the main menu on the right, used as in 'Rotate image right'. Keep short!
                ["__rotateR","",em.pty+qsTr("right"), "donthide"],
                //: This is an entry in the main menu on the right, used as in 'Reset rotation of image'. Keep short!
                ["__rotate0","",em.pty+qsTr("reset"), "donthide"]],
        //: This is an entry in the main menu on the right, used as in 'Flip/Mirror image'. Keep short!
        [["flip","flip",em.pty+qsTr("Flip")],
                //: This is an entry in the main menu on the right, used as in 'Flip/Mirror image horizontally'. Keep short!
                ["__flipH","",em.pty+qsTr("horizontal"), "donthide"],
                //: This is an entry in the main menu on the right, used as in 'Flip/Mirror image vertically'. Keep short!
                ["__flipV","",em.pty+qsTr("vertical"), "donthide"],
                //: This is an entry in the main menu on the right, used as in 'Reset flip/mirror of image'. Keep short!
                ["__flipReset","",em.pty+qsTr("reset"), "donthide"]],
        //: This is an entry in the main menu on the right, used to refer to the current file (specifically the file, not directly the image). Keep short!
        [["","copy",em.pty+qsTr("File")],
                //: This is an entry in the main menu on the right, used as in 'rename file'. Keep short!
                ["__rename","",em.pty+qsTr("rename"), "hide"],
                //: This is an entry in the main menu on the right, used as in 'copy file'. Keep short!
                ["__copy","",em.pty+qsTr("copy"), "hide"],
                //: This is an entry in the main menu on the right, used as in 'move file'. Keep short!
                ["__move","",em.pty+qsTr("move"), "hide"],
                //: This is an entry in the main menu on the right, used as in 'delete file'. Keep short!
                ["__delete","",em.pty+qsTr("delete"), "hide"]],

        [["heading","",""]],

        //: This is an entry in the main menu on the right. Keep short!
        [["__scale","scale",em.pty+qsTr("Scale Image"), "hide"]],
        //: This is an entry in the main menu on the right. Keep short!
        [["__defaultFileManager","open",em.pty+qsTr("Open in default file manager"), "donthide"]]
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
        width: 3*settings.quickInfoCloseXSize
        height: 3*settings.quickInfoCloseXSize

        // Invisible rectangle
        color: "#00000000"

        // Fancy 'x'
        Image {

            id: img_x

            anchors.right: parent.right
            anchors.top: parent.top

            source: "qrc:/img/closingx.png"
            sourceSize: Qt.size(3*settings.quickInfoCloseXSize,3*settings.quickInfoCloseXSize)

        }

        // Click on it
        ToolTip {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            text: em.pty+qsTr("Close PhotoQt")
            onClicked:
                mainwindow.closePhotoQt()
        }

    }


    Text {

        id: heading
        y: 10
        x: (parent.width-width)/2
        font.pointSize: 15
        color: colour.text
        font.bold: true
        text: em.pty+qsTr("Main Menu")

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
            height: 30
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
                    font.pointSize: 11
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
                    opacity: (settings.trayIcon || allitems[subview.mainindex][index][0] !== "hide") ? 1 : 0.5
                    visible: (source!="" || allitems[subview.mainindex][index][0]==="heading")
                }

                Text {

                    id: val;

                    color: (allitems[subview.mainindex][index][0]==="heading") ? "white" : colour.text_inactive
                    lineHeight: 1.5

                    font.capitalization: (allitems[subview.mainindex][index][0]==="heading") ? Font.SmallCaps : Font.MixedCase

                    opacity: enabled ? 1 : 0.5

                    font.pointSize: 11
                    font.bold: true

                    enabled: (settings.trayIcon || (allitems[subview.mainindex][index][0] !== "hide" && allitems[subview.mainindex][index][0] !=="heading" && (allitems[subview.mainindex].length === 1 || index > 0)))

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
                            if(allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0)) {
                                if(allitems[subview.mainindex][index][3] === "hide")
                                    hide()
                                var cmd = allitems[subview.mainindex][index][0]
                                var close = 0
                                if(cmd.slice(0,8) === "_:_EX_:_") {
                                    var parts = (cmd.split("_:_EX_:_")[1]).split("___")
                                    close = parts[0];
                                    cmd = parts[1];
                                }
                                shortcuts.executeShortcut(cmd, close)
                            }
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

        text: em.pty+qsTr("Click here to go to the online manual for help regarding shortcuts, settings, features, ...")

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
                bin = "calligrakrita"
            allitems_external.push([["_:_EX_:_" + c[3*i+1] + "___" + c[3*i], bin, c[3*i+2], "donthide"]])
        }

        allitems = allitems_static.concat(allitems_external)
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
        var ret = mainmenu.contains(mainmenu.mapFromItem(mainwindow,pos.x,pos.y))
        verboseMessage("MainMenu::clickInMainMenu()", pos)
        return ret
    }

    Connections {
        target: variables
        onGuiBlockedChanged: {
            if(variables.guiBlocked && mainmenu.opacity == 1)
                mainmenu.opacity = 0.2
            else if(!variables.guiBlocked && mainmenu.opacity == 0.2)
                mainmenu.opacity = 1
        }
    }

}

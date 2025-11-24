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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt
import PQCExtensionsHandler

Rectangle {

    id: mainmenu_top

    x: setVisible ? visiblePos[0] : invisiblePos[0]
    y: (PQCSettings.mainmenuElementHeightDynamic ? statusinfoOffset : 0) + (setVisible ? visiblePos[1] : invisiblePos[1])
    Behavior on x { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: dragrightMouse.enabled&&dragrightMouse.clickStart!=-1&&!animateResize ? 0 : 200 } }

    property bool animateResize: false
    onAnimateResizeChanged: {
        if(animateResize)
            resetAnimateResize.restart()
    }

    SystemPalette { id: pqtPalette }

    Timer {
        id: resetAnimateResize
        interval: 250
        onTriggered: {
            mainmenu_top.animateResize = false
        }
    }

    onYChanged: {
        if(dragmouse.drag.active)
            saveXY.restart()
    }

    onOpacityChanged: {
        PQCConstants.mainmenuOpacity = mainmenu_top.opacity
    }

    Timer {
        id: saveXY
        interval: 200
        onTriggered:
            PQCSettings.mainmenuElementPosition = Qt.point(Math.round(mainmenu_top.x),Math.round(mainmenu_top.y))
    }

    color: pqtPalette.base

    radius: PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 5

    // visibility status
    opacity: setVisible&&windowSizeOkay ? 1 : 0
    visible: opacity>0
    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

    property int parentWidth
    property int parentHeight
    width: Math.max(400, PQCSettings.mainmenuElementSize.width)
    height: isPopout ?
                mainmenu_popout.height :
                PQCSettings.mainmenuElementHeightDynamic ?
                    PQCConstants.availableHeight-2*gap-statusinfoOffset :
                    Math.min(PQCConstants.availableHeight, PQCSettings.mainmenuElementSize.height)

    property bool setVisible: false
    property var visiblePos: [0,0]
    property var invisiblePos: [0, 0]
    property int hotAreaSize: PQCSettings.interfaceHotEdgeSize*5
    property rect hotArea: Qt.rect(0, PQCConstants.availableHeight-hotAreaSize, PQCConstants.availableWidth, hotAreaSize)
    property bool windowSizeOkay: true

    // this is set to true/false by the popout window
    // this is a way to reliably detect whether it is used
    property bool popoutWindowUsed: false

    onSetVisibleChanged: {
        if(!setVisible && menu.item !== null)
            menu.item.dismiss()
    }

    property bool isPopout: PQCSettings.interfacePopoutMainMenu||PQCWindowGeometry.mainmenuForcePopout

    state: isPopout
           ? "popout"
           : (PQCSettings.interfaceEdgeLeftAction==="mainmenu"
              ? "left"
              : (PQCSettings.interfaceEdgeRightAction==="mainmenu"
                 ? "right"
                 : "disabled" ))

    property int gap: 40
    property int statusinfoOffset: PQCConstants.statusinfoIsVisible&&state==="left" ? (PQCConstants.statusInfoCurrentRect.height+PQCConstants.statusInfoCurrentRect.y) : 0

    PQShadowEffect { masterItem: mainmenu_top }

    // the four states corresponding to screen edges
    states: [
        State {
            name: "left"
            PropertyChanges {
                mainmenu_top.visiblePos: [mainmenu_top.gap,
                                          (PQCSettings.mainmenuElementHeightDynamic ? mainmenu_top.gap : Math.max(0, Math.min(PQCConstants.availableHeight-mainmenu_top.height, PQCSettings.mainmenuElementPosition.y)))]
                mainmenu_top.invisiblePos: [-mainmenu_top.width,
                                            (PQCSettings.mainmenuElementHeightDynamic ? mainmenu_top.gap : Math.max(0, Math.min(PQCConstants.availableHeight-mainmenu_top.height, PQCSettings.mainmenuElementPosition.y)))]
                mainmenu_top.hotArea: Qt.rect(0,0,mainmenu_top.hotAreaSize, PQCConstants.availableHeight)
                mainmenu_top.windowSizeOkay: PQCConstants.availableWidth>500 && PQCConstants.availableHeight>500
            }
        },
        State {
            name: "right"
            PropertyChanges {
                mainmenu_top.visiblePos: [PQCConstants.availableWidth-mainmenu_top.width-mainmenu_top.gap,
                                          (PQCSettings.mainmenuElementHeightDynamic ? mainmenu_top.gap : Math.max(0, Math.min(PQCConstants.availableHeight-mainmenu_top.height, PQCSettings.mainmenuElementPosition.y)))]
                mainmenu_top.invisiblePos: [PQCConstants.availableWidth,
                                            (PQCSettings.mainmenuElementHeightDynamic ? mainmenu_top.gap : Math.max(0, Math.min(PQCConstants.availableHeight-mainmenu_top.height, PQCSettings.mainmenuElementPosition.y)))]
                mainmenu_top.hotArea: Qt.rect(PQCConstants.availableWidth-mainmenu_top.hotAreaSize, 0, mainmenu_top.hotAreaSize, PQCConstants.availableHeight)
                mainmenu_top.windowSizeOkay: PQCConstants.availableWidth>500 && PQCConstants.availableHeight>500
            }
        },
        State {
            name: "popout"
            PropertyChanges {
                mainmenu_top.setVisible: true
                mainmenu_top.hotArea: Qt.rect(0,0,0,0)
                mainmenu_top.width: mainmenu_top.parentWidth
                mainmenu_top.height: mainmenu_top.parentHeight
                mainmenu_top.windowSizeOkay: true
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                mainmenu_top.setVisible: false
                mainmenu_top.hotArea: Qt.rect(0,0,0,0)
            }
        }
    ]

    Component.onCompleted: {
        if(isPopout) {
            mainmenu_top.opacity = 1
        }
        if(PQCConstants.mainmenuShowWhenReady) {
            mainmenu_top.ignoreMouseMoveShortly = true
            mainmenu_top.setVisible = true
            resetIgnoreMouseMoveShortly.restart()
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: (wheel) =>{
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                menu.item.popup()
        }
    }

    MultiPointTouchArea {

        id: toucharea

        anchors.fill: parent
        anchors.topMargin: 50
        mouseEnabled: false

        maximumTouchPoints: 1

        property point touchPos

        onPressed: (touchPoints) => {
            touchPos = touchPoints[0]
            touchShowMenu.start()
        }

        onUpdated: (touchPoints) => {
            if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                touchShowMenu.stop()
            }
        }

        onReleased: (touchPoints) => {
            touchShowMenu.stop()
        }

        Timer {
            id: touchShowMenu
            interval: 1000
            onTriggered: {
                menu.item.popup(toucharea.mapToItem(mainmenu_top, toucharea.touchPos))
            }
        }

    }

    property bool anythingLoaded: PQCFileFolderModel.countMainView>0

    property int colwidth: width-2*flickable.anchors.margins

    property int normalEntryHeight: 20


    MouseArea {
        id: dragmouse
        width: parent.width
        height: 20
        hoverEnabled: true
        cursorShape: Qt.SizeAllCursor
        acceptedButtons: Qt.RightButton|Qt.LeftButton
        onWheel: (wheel) =>{
            wheel.accepted = true
        }
        drag.target: mainmenu_top
        drag.axis: Drag.YAxis
        drag.minimumY: 0
        drag.maximumY: PQCConstants.availableHeight-mainmenu_top.height
    }

    Flickable {

        id: flickable

        anchors.fill: parent
        anchors.margins: 10
        anchors.topMargin: 20

        contentHeight: flickable_col.height

        clip: true

        ScrollBar.vertical: PQVerticalScrollBar { }

        Column {

            id: flickable_col

            spacing: 20

            /*************************/
            // Navigation

            Item {

                width: flickable.width
                height: nav_txt.height+10
                Rectangle {
                    anchors.fill: parent
                    color: pqtPalette.alternateBase
                    opacity: 0.8
                    radius: 5
                }

                PQTextL {
                    id: nav_txt
                    x: 5
                    y: 5
                    //: This is a category in the main menu.
                    text: qsTranslate("MainMenu", "navigation")
                    font.weight: PQCLook.fontWeightBold
                    opacity: 0.8
                }

            }

            Column {

                id: nav_col

                spacing: 5

                Row {

                    PQMainMenuEntry {
                        id: prevarrow
                        img: "previous.svg"
                        //: as in: PREVIOUS image. Please keep short.
                        txt: qsTranslate("MainMenu", "previous")
                        cmd: "__prev"
                        smallestWidth: mainmenu_top.colwidth/2
                        font.pointSize: PQCLook.fontSizeL
                        font.weight: PQCLook.fontWeightBold
                        alignCenter: true
                        menuColWidth: mainmenu_top.colwidth
                    }

                    PQMainMenuEntry {
                        id: nextarrow
                        img_end: "next.svg"
                        //: as in: NEXT image. Please keep short.
                        txt: qsTranslate("MainMenu", "next")
                        cmd: "__next"
                        smallestWidth: mainmenu_top.colwidth/2
                        font.pointSize: PQCLook.fontSizeL
                        font.weight: PQCLook.fontWeightBold
                        alignCenter: true
                        menuColWidth: mainmenu_top.colwidth
                    }

                }

                Row {

                    PQMainMenuEntry {
                        img: "first.svg"
                        //: as in: FIRST image. Please keep short.
                        txt: qsTranslate("MainMenu", "first")
                        cmd: "__goToFirst"
                        smallestWidth: prevarrow.width
                        alignCenter: true
                        menuColWidth: mainmenu_top.colwidth
                    }

                    PQMainMenuEntry {
                        img_end: "last.svg"
                        //: as in: LAST image. Please keep short.
                        txt: qsTranslate("MainMenu", "last")
                        cmd: "__goToLast"
                        smallestWidth: nextarrow.width
                        alignCenter: true
                        menuColWidth: mainmenu_top.colwidth
                    }

                }

                PQMainMenuEntry {
                    img: "browse.svg"
                    txt: qsTranslate("MainMenu", "Browse images")
                    cmd: "__open"
                    closeMenu: true
                    menuColWidth: mainmenu_top.colwidth
                    onHeightChanged:
                        mainmenu_top.normalEntryHeight = height
                }

                PQMainMenuEntry {
                    img: "mapmarker.svg"
                    txt: qsTranslate("MainMenu", "Map Explorer")
                    cmd: "__showMapExplorer"
                    closeMenu: true
                    menuColWidth: mainmenu_top.colwidth
                    visible: PQCScriptsConfig.isLocationSupportEnabled()
                }

            }

            /*************************/
            // image view

            Item {

                width: flickable.width
                height: view_txt.height+10
                Rectangle {
                    anchors.fill: parent
                    color: pqtPalette.alternateBase
                    opacity: 0.8
                    radius: 5
                }

                PQTextL {
                    id: view_txt
                    x: 5
                    y: 5
                    //: This is a category in the main menu.
                    text: qsTranslate("MainMenu", "current image")
                    font.weight: PQCLook.fontWeightBold
                    opacity: 0.8
                }

            }

            Column {

                id: view_col

                spacing: 5

                // ZOOM

                Row {

                    spacing: 10

                    Item {
                        width: Math.max(zoom_txt.width, Math.max(rotate_txt.width, flip_txt.width))
                        height: zoom_txt.height
                        PQText {
                            id: zoom_txt
                            x: (parent.width-width)
                            y: (zoomin_icn.height-height)/2
                            //: Entry in main menu. Please keep short.
                            text: qsTranslate("MainMenu", "Zoom") + ":"
                            opacity: 0.6
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    PQMainMenuIcon {
                        id: zoomin_icn
                        img: "zoomin.svg"
                        cmd: "__zoomIn"
                        scaleFactor: 1
                        active: mainmenu_top.anythingLoaded
                        normalEntryHeight: mainmenu_top.normalEntryHeight
                    }

                    PQMainMenuIcon {
                        y: (zoomin_icn.height-height)/2
                        img: "zoomout.svg"
                        cmd: "__zoomOut"
                        scaleFactor: 1
                        active: mainmenu_top.anythingLoaded
                        normalEntryHeight: mainmenu_top.normalEntryHeight
                    }

                    PQMainMenuEntry {
                        y: (zoomin_icn.height-height)/2
                        img: "actualsize.svg"
                        txt: "100%"
                        cmd: "__zoomActual"
                        smallestWidth: 10
                        active: mainmenu_top.anythingLoaded
                        menuColWidth: mainmenu_top.colwidth
                    }

                    PQMainMenuEntry {
                        y: (zoomin_icn.height-height)/2
                        img: "reset.svg"
                        //: Used as in RESET zoom.
                        txt: qsTranslate("MainMenu", "reset")
                        cmd: "__zoomReset"
                        smallestWidth: 10
                        active: mainmenu_top.anythingLoaded
                        menuColWidth: mainmenu_top.colwidth
                    }

                    PQMainMenuEntry {
                        y: (zoomin_icn.height-height)/2
                        img: "padlock.svg"
                        smallestWidth: 10
                        menuColWidth: mainmenu_top.colwidth
                        opacity: PQCSettings.imageviewPreserveZoom ? 1 : 0.1
                        tooltip: qsTranslate("MainMenu", "Enable to preserve zoom levels across images")
                        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                        onClicked: PQCSettings.imageviewPreserveZoom = !PQCSettings.imageviewPreserveZoom
                    }

                }

                // ROTATION

                Row {

                    spacing: 10

                    Item {
                        width: Math.max(zoom_txt.width, Math.max(rotate_txt.width, flip_txt.width))
                        height: rotate_txt.height
                        PQText {
                            id: rotate_txt
                            x: (parent.width-width)
                            y: (rotate_left.height-height)/2
                            //: Entry in main menu. Please keep short.
                            text: qsTranslate("MainMenu", "Rotation")
                            opacity: 0.6
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    PQMainMenuIcon {
                        id: rotate_left
                        img: "rotateleft.svg"
                        cmd: "__rotateL"
                        scaleFactor: 1
                        active: mainmenu_top.anythingLoaded
                        normalEntryHeight: mainmenu_top.normalEntryHeight
                    }

                    PQMainMenuIcon {
                        y: (rotate_left.height-height)/2
                        img: "rotateright.svg"
                        cmd: "__rotateR"
                        scaleFactor: 1
                        active: mainmenu_top.anythingLoaded
                        normalEntryHeight: mainmenu_top.normalEntryHeight
                    }

                    PQMainMenuEntry {
                        y: (rotate_left.height-height)/2
                        img: "reset.svg"
                        //: Used as in RESET rotation.
                        txt: qsTranslate("MainMenu", "reset")
                        cmd: "__rotate0"
                        smallestWidth: 10
                        active: mainmenu_top.anythingLoaded
                        menuColWidth: mainmenu_top.colwidth
                    }

                    PQMainMenuEntry {
                        y: (zoomin_icn.height-height)/2
                        img: "padlock.svg"
                        smallestWidth: 10
                        menuColWidth: mainmenu_top.colwidth
                        opacity: PQCSettings.imageviewPreserveRotation ? 1 : 0.1
                        tooltip: qsTranslate("MainMenu", "Enable to preserve rotation angle across images")
                        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                        onClicked: PQCSettings.imageviewPreserveRotation = !PQCSettings.imageviewPreserveRotation
                    }

                }

                // FLIP

                Row {

                    spacing: 10

                    Item {
                        width: Math.max(zoom_txt.width, Math.max(rotate_txt.width, flip_txt.width))
                        height: flip_txt.height
                        PQText {
                            id: flip_txt
                            x: (parent.width-width)
                            y: (flip_ver.height-height)/2
                            //: Mirroring (or flipping) an image. Please keep short.
                            text: qsTranslate("MainMenu", "Mirror")
                            opacity: 0.6
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    PQMainMenuIcon {
                        y: (flip_ver.height-height)/2
                        img: "leftrightarrow.svg"
                        cmd: "__flipH"
                        scaleFactor: 1
                        active: mainmenu_top.anythingLoaded
                        normalEntryHeight: mainmenu_top.normalEntryHeight
                    }

                    PQMainMenuIcon {
                        id: flip_ver
                        img: "updownarrow.svg"
                        cmd: "__flipV"
                        scaleFactor: 1
                        active: mainmenu_top.anythingLoaded
                        normalEntryHeight: mainmenu_top.normalEntryHeight
                    }

                    PQMainMenuEntry {
                        y: (flip_ver.height-height)/2
                        img: "reset.svg"
                        //: Used as in RESET mirroring.
                        txt: qsTranslate("MainMenu", "reset")
                        cmd: "__flipReset"
                        smallestWidth: 10
                        active: mainmenu_top.anythingLoaded
                        menuColWidth: mainmenu_top.colwidth
                    }

                    PQMainMenuEntry {
                        y: (zoomin_icn.height-height)/2
                        img: "padlock.svg"
                        smallestWidth: 10
                        menuColWidth: mainmenu_top.colwidth
                        opacity: PQCSettings.imageviewPreserveMirror ? 1 : 0.1
                        tooltip: qsTranslate("MainMenu", "Enable to preserve mirror across images")
                        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                        onClicked: PQCSettings.imageviewPreserveMirror = !PQCSettings.imageviewPreserveMirror
                    }

                }

            }



            /*************************/
            // Folder Actions

            Item {

                width: flickable.width
                height: folder_txt.height+10
                Rectangle {
                    anchors.fill: parent
                    color: pqtPalette.alternateBase
                    opacity: 0.8
                    radius: 5
                }

                PQTextL {
                    id: folder_txt
                    x: 5
                    y: 5
                    //: This is a category in the main menu.
                    text: qsTranslate("MainMenu", "all images")
                    font.weight: PQCLook.fontWeightBold
                    opacity: 0.8
                }

            }

            Column {

                id: folder_col

                spacing: 5

                // SLIDESHOW

                Row {

                    spacing: 10

                    Item {
                        width: Math.max(advanced_txt.width, slideshow_txt.width)
                        height: slideshow_txt.height
                        PQText {
                            id: slideshow_txt
                            x: parent.width-width
                            y: (slideshow_start.height-height)/2
                            //: Entry in main menu. Please keep short.
                            text: qsTranslate("MainMenu", "Slideshow") + ":"
                            opacity: 0.6
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    PQMainMenuEntry {
                        id: slideshow_start
                        img: "slideshow.svg"
                        //: Used as in START slideshow. Please keep short
                        txt: qsTranslate("MainMenu", "Start")
                        cmd: "__slideshowQuick"
                        smallestWidth: (mainmenu_top.colwidth-slideshow_txt.parent.width-20)/2
                        closeMenu: true
                        active: mainmenu_top.anythingLoaded
                        menuColWidth: mainmenu_top.colwidth
                    }

                    PQMainMenuEntry {
                        img: "setup.svg"
                        //: Used as in SETUP slideshow. Please keep short
                        txt: qsTranslate("MainMenu", "Setup")
                        cmd: "__slideshow"
                        smallestWidth: slideshow_start.width
                        closeMenu: true
                        active: mainmenu_top.anythingLoaded
                        menuColWidth: mainmenu_top.colwidth
                    }

                }

                // ADVANCED SORT

                Row {

                    spacing: 10

                    Item {
                        width: Math.max(advanced_txt.width, slideshow_txt.width)
                        height: advanced_txt.height
                        PQText {
                            id: advanced_txt
                            x: parent.width-width
                            y: (advanced_start.height-height)/2
                            //: Entry in main menu. Please keep short.
                            text: qsTranslate("MainMenu", "Sort") + ":"
                            opacity: 0.6
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    PQMainMenuEntry {
                        id: advanced_start
                        img: "sort.svg"
                        //: Used as in START advanced sort. Please keep short
                        txt: qsTranslate("MainMenu", "Start")
                        cmd: "__advancedSortQuick"
                        smallestWidth: (mainmenu_top.colwidth-advanced_txt.parent.width-20)/2
                        closeMenu: true
                        active: mainmenu_top.anythingLoaded
                        menuColWidth: mainmenu_top.colwidth
                    }

                    PQMainMenuEntry {
                        img: "setup.svg"
                        //: Used as in SETUP advanced sort. Please keep short
                        txt: qsTranslate("MainMenu", "Setup")
                        cmd: "__advancedSort"
                        smallestWidth: advanced_start.width
                        closeMenu: true
                        active: mainmenu_top.anythingLoaded
                        menuColWidth: mainmenu_top.colwidth
                    }

                }

                // FILTER/STREAMING/DEFAULT

                PQMainMenuEntry {
                    img: "filter.svg"
                    txt: qsTranslate("MainMenu", "Filter images")
                    cmd: "__filterImages"
                    closeMenu: true
                    active: mainmenu_top.anythingLoaded
                    menuColWidth: mainmenu_top.colwidth
                }

                PQMainMenuEntry {
                    visible: PQCScriptsConfig.isChromecastEnabled()
                    img: "streaming.svg"
                    txt: qsTranslate("MainMenu", "Streaming (Chromecast)")
                    cmd: "__chromecast"
                    closeMenu: true
                    active: mainmenu_top.anythingLoaded
                    menuColWidth: mainmenu_top.colwidth
                }

                PQMainMenuEntry {
                    img: "browse.svg"
                    txt: qsTranslate("MainMenu", "Open in default file manager")
                    cmd: "__defaultFileManager"
                    closeMenu: true
                    active: mainmenu_top.anythingLoaded
                    menuColWidth: mainmenu_top.colwidth
                }

            }



            /*************************/
            // Extensions

            Loader {

                active: PQCExtensionsHandler.mainmenu.length>0

                sourceComponent:
                Item {

                    width: flickable.width
                    height: ext_txt.height+10
                    Rectangle {
                        anchors.fill: parent
                        color: pqtPalette.alternateBase
                        opacity: 0.8
                        radius: 5
                    }

                    PQTextL {
                        id: ext_txt
                        x: 5
                        y: 5
                        //: This is a category in the main menu.
                        text: qsTranslate("MainMenu", "extensions")
                        font.weight: PQCLook.fontWeightBold
                        opacity: 0.8
                    }

                }

            }

            Loader {

                active: PQCExtensionsHandler.mainmenu.length>0

                sourceComponent:
                Column {

                    id: photoqt_col

                    spacing: 5

                    Repeater {

                        model: PQCExtensionsHandler.mainmenu.length

                        PQMainMenuEntry {
                            id: dele
                            required property int index
                            property string eId: PQCExtensionsHandler.mainmenu[index]

                            property string sourceSVG: PQCExtensionsHandler.getExtensionLocation(eId) + "/img/" + PQCLook.iconShade + "/extension.svg"
                            property string sourcePNG: PQCExtensionsHandler.getExtensionLocation(eId) + "/img/" + PQCLook.iconShade + "/extension.png"
                            property string sourceJPG: PQCExtensionsHandler.getExtensionLocation(eId) + "/img/" + PQCLook.iconShade + "/extension.jpg"
                            property bool haveSVG: PQCScriptsFilesPaths.doesItExist(sourceSVG)
                            property bool havePNG: PQCScriptsFilesPaths.doesItExist(sourcePNG)
                            property bool haveJPG: PQCScriptsFilesPaths.doesItExist(sourceJPG)
                            img: haveSVG ?
                                           "image://svg/" + sourceSVG :
                                            (havePNG||haveJPG ? ("file://" + (havePNG ? sourcePNG : sourceJPG)) : "")

                            txt: PQCExtensionsHandler.getExtensionLongName(eId)
                            extensionId: eId
                            closeMenu: true
                            active: mainmenu_top.anythingLoaded
                            menuColWidth: mainmenu_top.colwidth

                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                onTriggered: {
                                    console.warn(">>>", dele.eId, dele.sourceSVG, dele.haveSVG)
                                }
                            }

                        }

                    }

                }

            }

            /*************************/
            // PhotoQt

            Item {

                width: flickable.width
                height: photoqt_txt.height+10
                Rectangle {
                    anchors.fill: parent
                    color: pqtPalette.alternateBase
                    opacity: 0.8
                    radius: 5
                }

                PQTextL {
                    id: photoqt_txt
                    x: 5
                    y: 5
                    //: This is a category in the main menu.
                    text: qsTranslate("MainMenu", "general")
                    font.weight: PQCLook.fontWeightBold
                    opacity: 0.8
                }

            }

            Column {

                id: photoqt_col

                spacing: 5

                Row {

                    PQMainMenuEntry {
                        img: "setup.svg"
                        txt: qsTranslate("MainMenu", "Settings")
                        cmd: "__settings"
                        smallestWidth: flickable.width/2
                        closeMenu: true
                        menuColWidth: mainmenu_top.colwidth
                    }

                    PQMainMenuEntry {
                        img: "about.svg"
                        txt: qsTranslate("MainMenu", "About")
                        cmd: "__about"
                        smallestWidth: flickable.width/2
                        closeMenu: true
                        menuColWidth: mainmenu_top.colwidth
                    }

                }

                Row {

                    PQMainMenuEntry {
                        img: "help.svg"
                        txt: qsTranslate("MainMenu", "Online help")
                        cmd: "__onlineHelp"
                        smallestWidth: flickable.width/2
                        closeMenu: true
                        menuColWidth: mainmenu_top.colwidth
                    }

                    PQMainMenuEntry {
                        img: "quit.svg"
                        txt: qsTranslate("MainMenu", "Quit")
                        cmd: "__quit"
                        smallestWidth: flickable.width/2
                        menuColWidth: mainmenu_top.colwidth
                    }

                }

            }

            /*************************/
            // Custom

            Item {

                width: flickable.width
                height: custom_txt.height+10
                Rectangle {
                    anchors.fill: parent
                    color: pqtPalette.alternateBase
                    opacity: 0.8
                    radius: 5
                }

                visible: PQCSettings.mainmenuShowExternal

                PQTextXL {
                    id: custom_txt
                    x: 5
                    y: 5
                    //: This is a category in the main menu.
                    text: qsTranslate("MainMenu", "custom")
                    font.weight: PQCLook.fontWeightBold
                    opacity: 0.8
                }

            }

            Column {

                id: custom_col

                visible: PQCSettings.mainmenuShowExternal

                spacing: 5

                property list<var> entries: []

                Repeater {

                    model: custom_col.entries.length

                    PQMainMenuEntry {

                        id: deleg

                        required property int modelData

                        property var cur: custom_col.entries[modelData]

                        customEntry: true

                        img: cur[0]==="" ? "application.svg" : ("data:image/png;base64," + cur[0])
                        txt: cur[2]
                        cmd: cur[1]
                        custom_close: cur[3]
                        custom_args: cur[4]

                        smallestWidth: flickable.width
                        closeMenu: true

                        menuColWidth: mainmenu_top.colwidth
                    }

                }

                Component.onCompleted: {
                    if(PQCSettings.mainmenuShowExternal)
                        custom_col.entries = PQCScriptsContextMenu.getEntries()
                }

                Connections {
                    target: PQCSettings
                    function onMainmenuShowExternalChanged() {
                        if(PQCSettings.mainmenuShowExternal)
                            custom_col.entries = PQCScriptsContextMenu.getEntries()
                        else
                            custom_col.entries = []
                    }
                }

                Connections {
                    target: PQCScriptsContextMenu
                    function onCustomEntriesChanged() {
                        if(PQCSettings.mainmenuShowExternal)
                            custom_col.entries = PQCScriptsContextMenu.getEntries()
                        else
                            custom_col.entries = []
                    }
                }

            }

        }

    }

    Loader {

        id: menu
        asynchronous: true

        sourceComponent:
        PQMenu {

            id: menudeleg

            PQMenuItem {
                enabled: false
                font.italic: true
                moveToRightABit: true
                text: qsTranslate("MainMenu", "Main menu")
            }

            PQMenuSeparator {}

            PQMenuItem {
                checkable: true
                checked: PQCSettings.mainmenuElementHeightDynamic
                text: qsTranslate("MainMenu", "Adjust height dynamically")
                onCheckedChanged: {
                    mainmenu_top.animateResize = true
                    if(checked) {
                        mainmenu_top.y = Qt.binding(function() { return (PQCSettings.mainmenuElementHeightDynamic ? statusinfoOffset : 0) + (setVisible ? visiblePos[1] : invisiblePos[1]) })
                        mainmenu_top.height = Qt.binding(function() { return PQCConstants.availableHeight-2*gap-statusinfoOffset })
                        PQCSettings.mainmenuElementHeightDynamic = true
                    } else {
                        mainmenu_top.y = mainmenu_top.y
                        mainmenu_top.height = mainmenu_top.height
                        PQCSettings.mainmenuElementPosition.y = mainmenu_top.y
                        PQCSettings.mainmenuElementSize.height = mainmenu_top.height
                        PQCSettings.mainmenuElementHeightDynamic = false
                    }
                    checked = Qt.binding(function() { return PQCSettings.mainmenuElementHeightDynamic })
                }
            }

            PQMenuItem {
                text: qsTranslate("MainMenu", "Reset size to default")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                onTriggered: {
                    PQCSettings.setDefaultForMainmenuElementSize()
                    PQCSettings.setDefaultForMainmenuElementPosition()
                    mainmenu_top.animateResize = true
                    mainmenu_top.y = Qt.binding(function() { return (PQCSettings.mainmenuElementHeightDynamic ? statusinfoOffset : 0) + (setVisible ? visiblePos[1] : invisiblePos[1]) })
                    mainmenu_top.width = Qt.binding(function() { return Math.max(400, PQCSettings.mainmenuElementSize.width) })
                    mainmenu_top.height = Qt.binding(function() { return PQCConstants.availableHeight-2*gap-statusinfoOffset })
                    PQCSettings.mainmenuElementHeightDynamic = true
                }
            }

            onAboutToHide:
                recordAsClosed.restart()
            onAboutToShow:
                PQCConstants.addToWhichContextMenusOpen("mainmenu")

            Timer {
                id: recordAsClosed
                interval: 200
                onTriggered: {
                    if(!menudeleg.visible)
                        PQCConstants.removeFromWhichContextMenusOpen("mainmenu")
                }
            }

        }

    }

    // drag vertically
    MouseArea {
        y: (parent.height-height)
        width: parent.width
        height: 10
        cursorShape: Qt.SizeVerCursor

        property int clickStart: -1
        property int origHeight: PQCSettings.mainmenuElementSize.height
        onPressed: (mouse) => {
            clickStart = mouse.y
        }
        onReleased:
            clickStart = -1

        onPositionChanged: (mouse) => {
            if(clickStart == -1)
                return
            var diff = mouse.y-clickStart
            mainmenu_top.height = mainmenu_top.height
            mainmenu_top.y = mainmenu_top.y
            PQCSettings.mainmenuElementSize.height = mainmenu_top.height
            mainmenu_top.height = Qt.binding(function() { return Math.min(PQCConstants.availableHeight, PQCSettings.mainmenuElementSize.height) } )
            PQCSettings.mainmenuElementSize.height = Math.round(origHeight+diff)
            PQCSettings.mainmenuElementHeightDynamic = false
        }

    }

    // drag from left to right
    MouseArea {
        x: (parent.width-width)
        width: 10
        height: parent.height
        cursorShape: enabled ? Qt.SizeHorCursor : Qt.ArrowCursor
        enabled: parent.state==="left"

        property int clickStart: -1
        property int origWidth: mainmenu_top.width
        onPressed: (mouse) => {
            clickStart = mouse.x
        }
        onReleased:
            clickStart = -1

        onPositionChanged: (mouse) => {
            if(clickStart == -1)
                return
            var diff = mouse.x-clickStart
            mainmenu_top.width = mainmenu_top.width
            PQCSettings.mainmenuElementSize.width = Math.round(Math.min(PQCConstants.availableWidth/2, Math.max(200, origWidth+diff)))
            mainmenu_top.width = Qt.binding(function() { return Math.max(400, PQCSettings.mainmenuElementSize.width) })
        }

    }

    MouseArea {
        id: dragrightMouse
        x: 0
        width: 10
        height: parent.height
        cursorShape: enabled ? Qt.SizeHorCursor : Qt.ArrowCursor
        enabled: parent.state==="right"

        property int clickStart: -1
        property int origWidth: mainmenu_top.width
        onPressed: (mouse) => {
            clickStart = mouse.x
        }
        onReleased:
            clickStart = -1

        onPositionChanged: (mouse) => {
            if(clickStart == -1)
                return
            var diff = clickStart-mouse.x
            mainmenu_top.width = mainmenu_top.width
            PQCSettings.mainmenuElementSize.width = Math.round(Math.min(PQCConstants.availableWidth/2, Math.max(200, origWidth+diff)))
            mainmenu_top.width = Qt.binding(function() { return Math.max(400, PQCSettings.mainmenuElementSize.width) })
        }

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        visible: !PQCWindowGeometry.mainmenuForcePopout
        enabled: visible
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: PQCSettings.interfacePopoutMainMenu ?
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(!PQCSettings.interfacePopoutMainMenu)
                    PQCSettings.interfacePopoutMainMenu = true
                else
                    mainmenu_popout.close()
                PQCScriptsShortcuts.executeInternalCommand("__showMainMenu")
            }
        }
    }

    // if a small play/pause button is shown then moving the mouse to the screen edge around it does not trigger the main menu
    property int ignoreBottomMotion: PQCConstants.currentImageIsMotionPhoto&&PQCSettings.filetypesMotionPhotoPlayPause ? 100 : 0

    Timer {
        id: hideElementWithDelay
        interval: 1000
        onTriggered: {
            mainmenu_top.setVisible = false
        }
    }

    property bool ignoreMouseMoveShortly: false

    Connections {

        target: PQCNotify

        function onMouseMove(posx : int, posy : int) {

            if(ignoreMouseMoveShortly || PQCConstants.modalWindowOpen)
                return

            if(PQCConstants.slideshowRunning || PQCConstants.faceTaggingMode) {
                mainmenu_top.setVisible = false
                return
            }

            if(menu.item != null && menu.item.opened) {
                mainmenu_top.setVisible = true
                return
            }

            if(!mainmenu_top.windowSizeOkay && !mainmenu_top.isPopout) {
                mainmenu_top.setVisible = false
                return
            }

            if(mainmenu_top.setVisible) {
                if(posx < mainmenu_top.x-50 || posx > mainmenu_top.x+mainmenu_top.width+50 || posy < mainmenu_top.y-50 || posy > mainmenu_top.y+mainmenu_top.height+50)
                    mainmenu_top.setVisible = false
            } else {
                if(mainmenu_top.hotArea.x <= posx && mainmenu_top.hotArea.x+mainmenu_top.hotArea.width > posx && mainmenu_top.hotArea.y < posy && mainmenu_top.hotArea.height+mainmenu_top.hotArea.y-mainmenu_top.ignoreBottomMotion > posy)
                    mainmenu_top.setVisible = true
            }
        }

        function onMouseWindowExit() {
            hideElementWithDelay.restart()
        }

        function onMouseWindowEnter() {
            hideElementWithDelay.stop()
        }

        function onCloseAllContextMenus() {
            menu.item.dismiss()
        }

    }

    Connections {
        target: PQCConstants
        function onAvailableWidthChanged() {
            mainmenu_top.setVisible = false
        }
        function onAvailableHeightChanged() {
            mainmenu_top.setVisible = false
        }
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {
                if(param[0] === "MainMenu") {
                    mainmenu_top.showMainMenu()
                }
            } else if(what === "toggle") {
                if(param[0] === "MainMenu") {
                    mainmenu_top.toggle()
                }
            } else if(what === "forceshow" && param[0] === "MainMenu") {
                mainmenu_top.ignoreMouseMoveShortly = true
                mainmenu_top.setVisible = true
                resetIgnoreMouseMoveShortly.restart()
            } else if(what === "forcehide" && param[0] === "MainMenu") {
                mainmenu_top.ignoreMouseMoveShortly = true
                mainmenu_top.setVisible = false
                resetIgnoreMouseMoveShortly.restart()
            }

        }

    }

    Timer {
        id: resetIgnoreMouseMoveShortly
        interval: 250
        onTriggered: {
            mainmenu_top.ignoreMouseMoveShortly = false
        }
    }

    function toggle() {
        mainmenu_top.setVisible = !mainmenu_top.setVisible
    }

    function hideMainMenu() {
        mainmenu_top.setVisible = false
        if(popoutWindowUsed)
            mainmenu_popout.visible = false
    }

    function showMainMenu() {
        mainmenu_top.setVisible = true
        if(popoutWindowUsed)
            mainmenu_popout.visible = true
    }

}

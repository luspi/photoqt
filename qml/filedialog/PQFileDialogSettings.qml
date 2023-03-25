/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2
import "../elements"

Rectangle {

    anchors.fill: parent

    color: "#88000000"

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        //: Tooltip behind filedialog settings element.
        tooltip: em.pty+qsTranslate("filedialog", "Close settings")
        onClicked:
            hide()
        onWheel: {}
    }

    Rectangle {

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        color: "#2f2f2f"
        radius: 10
        border.width: 1
        border.color: "#666666"

        width: Math.min(600, parent.width)
        height: Math.min(800, parent.height)

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        /***********************************************/
        // top row with heading

        PQTextXL {

            id: heading
            height: 75
            width: parent.width

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            text: em.pty+qsTranslate("filedialog", "File Dialog Settings")

            font.weight: baselook.boldweight

        }

        Rectangle {
            id: sep1
            color: "#666666"
            width: parent.width
            height: 1
            x: 0
            y: heading.height
        }

        PQText {
            id: subtitle
            x: 10
            y: sep1.y + 10
            width: parent.width-20
            text: em.pty+qsTranslate("filedialog", "Settings are automatically saved when changed.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: sep2
            color: "#666666"
            width: parent.width
            height: 1
            x: 0
            y: subtitle.y+subtitle.height+10
        }

        /***********************************************/
        // settings

        Flickable {

            x: 0
            y: sep2.y+20

            width: parent.width
            height: parent.height-sep2.y-buttons.height - 40

            contentHeight: col.height

            clip: true

            ScrollBar.vertical: PQScrollBar { id: scroll }

            Column {

                spacing: 15

                x: 10

                width: parent.width-20

                id: col

                property int leftcolwidth: 100

                // DefaultView
                Row {

                    spacing: 25

                    PQTextL {
                        id: defaultview_txt
                        font.weight: baselook.boldweight
                        //: This refers to the files listed in the file dialog. Please keep short.
                        text: em.pty+qsTranslate("filedialog", "Files view")
                        horizontalAlignment: Text.AlignRight

                        height: fileviewcol.height
                        verticalAlignment: Text.AlignVCenter

                        Component.onCompleted: {
                            if(width > col.leftcolwidth)
                                col.leftcolwidth = width
                            width = Qt.binding(function() { return col.leftcolwidth; })
                        }
                    }

                    Column {

                        id: fileviewcol

                        spacing: 15

                        Row {
                            spacing: 15
                            PQRadioButton {
                                id: view_list
                                //: This is a type of view in the file dialog
                                text: em.pty+qsTranslate("filedialog", "list view")
                                onCheckedChanged: {
                                    if(checked)
                                        PQSettings.openfileDefaultView="list"
                                }
                            }
                            PQRadioButton {
                                id: view_icon
                                //: This is a type of view in the file dialog
                                text: em.pty+qsTranslate("filedialog", "icon view")
                                onCheckedChanged: {
                                    if(checked)
                                        PQSettings.openfileDefaultView="icons"
                                }
                            }
                        }

                        PQCheckbox {
                            id: view_remember
                            //: The last location is the last location of the file dialog.
                            text: em.pty+qsTranslate("filedialog", "remember last location between sessions")
                            onCheckedChanged:
                                PQSettings.openfileKeepLastLocation = checked
                        }

                        PQCheckbox {
                            id: view_hidden
                            text: em.pty+qsTranslate("filedialog", "show hidden files")
                            onCheckedChanged:
                                PQSettings.openfileShowHiddenFilesFolders = checked
                        }

                        PQCheckbox {
                            id: view_thumb
                            //: These thumbnails are the thumbnails shown in the file dialog
                            text: em.pty+qsTranslate("filedialog", "show thumbnails")
                            onCheckedChanged:
                                PQSettings.openfileThumbnails = checked
                        }

                        PQCheckbox {
                            id: view_tooltip
                            //: This is the tooltip in the file dialog with details about the hovered file
                            text: em.pty+qsTranslate("filedialog", "show tooltip with details")
                            onCheckedChanged:
                                PQSettings.openfileDetailsTooltip = checked
                        }

                        PQCheckbox {
                            id: view_folderthumbs
                            //: These thumbnails are shown as folder icon and rotate through folder contents
                            text: em.pty+qsTranslate("filedialog", "show thumbnails of images inside folders")
                            onCheckedChanged:
                                PQSettings.openfileFolderContentThumbnails = checked
                        }

                        PQCheckbox {
                            id: view_folderthumbsfirst
                            //: These thumbnails are shown as folder icon and rotate through folder contents
                            text: em.pty+qsTranslate("filedialog", "always show first thumbnail of images inside folders")
                            onCheckedChanged:
                                PQSettings.openfileFolderContentThumbnailsAlwaysLoadFirst = checked
                        }

                        Row {
                            spacing: 15
                            Item {
                                width: 1
                                height: 1
                            }

                            PQText {
                                y: (view_folderthumbs_speed.height-height)/2
                                text: em.pty+qsTranslate("filedialog", "speed")
                            }
                            PQComboBox {
                                id: view_folderthumbs_speed
                                model: ["2 seconds", "1 second", "half a second"]
                                onCurrentIndexChanged: {
                                    PQSettings.openfileFolderContentThumbnailsSpeed = currentIndex+1
                                }
                            }
                        }

                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#888888"
                }

                // DefaultView
                Row {

                    spacing: 25

                    PQTextL {
                        id: rightcol_txt
                        font.weight: baselook.boldweight
                        //: This refers to the left column of the file dialog (standard, favorites, devices). Please keep short!
                        text: em.pty+qsTranslate("filedialog", "Places")
                        horizontalAlignment: Text.AlignRight

                        height: placescol.height
                        verticalAlignment: Text.AlignVCenter

                        Component.onCompleted: {
                            if(width > col.leftcolwidth)
                                col.leftcolwidth = width
                            width = Qt.binding(function() { return col.leftcolwidth; })
                        }
                    }

                    Column {

                        id: placescol

                        spacing: 15

                        PQCheckbox {
                            id: places_standard
                            //: The standard locations are the ones that are set on the system
                            text: em.pty+qsTranslate("filedialog", "show standard locations")
                            onCheckedChanged:
                                PQSettings.openfileUserPlacesStandard = checked
                        }

                        PQCheckbox {
                            id: places_favorites
                            //: The favorites are the locations that can be customized by the user in the left column
                            text: em.pty+qsTranslate("filedialog", "show favorites")
                            onCheckedChanged:
                                PQSettings.openfileUserPlacesUser = checked
                        }

                        PQCheckbox {
                            id: places_devices
                            //: Devices here are storage volumes/partitions/harddrives
                            text: em.pty+qsTranslate("filedialog", "show devices")
                            onCheckedChanged:
                                PQSettings.openfileUserPlacesVolumes = checked
                        }


                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#888888"
                }

                // DefaultView
                Row {

                    spacing: 25

                    PQTextL {
                        id: preview_txt
                        font.weight: baselook.boldweight
                        //: The preview is the image behind all files when the mouse is hovering a file. Please keep short!
                        text: em.pty+qsTranslate("filedialog", "Preview")
                        horizontalAlignment: Text.AlignRight

                        height: previewcol.height
                        verticalAlignment: Text.AlignVCenter

                        Component.onCompleted: {
                            if(width > col.leftcolwidth)
                                col.leftcolwidth = width
                            width = Qt.binding(function() { return col.leftcolwidth; })
                        }
                    }

                    Column {

                        id: previewcol

                        spacing: 15

                        PQCheckbox {
                            id: preview_show
                            text: em.pty+qsTranslate("filedialog", "show preview behind files")
                            onCheckedChanged:
                                PQSettings.openfilePreview = checked
                        }

                        PQCheckbox {
                            id: preview_highres
                            //: The higher resolution is used for the preview image
                            text: em.pty+qsTranslate("filedialog", "use higher resolution (slower)")
                            onCheckedChanged:
                                PQSettings.openfilePreviewHigherResolution = checked
                        }

                        PQCheckbox {
                            id: preview_blur
                            text: em.pty+qsTranslate("filedialog", "blur preview")
                            onCheckedChanged:
                                PQSettings.openfilePreviewBlur = checked
                        }

                        PQCheckbox {
                            id: preview_crop
                            text: em.pty+qsTranslate("filedialog", "scale and crop to fill area")
                            onCheckedChanged:
                                PQSettings.openfilePreviewCropToFit = checked
                        }

                        Row {

                            spacing: 10

                            PQText {
                                y: (preview_colintense.height-height)/2
                                text: "Color intensity:"
                            }

                            PQComboBox {
                                id: preview_colintense
                                model: ["100%", "90%", "80%", "70%", "60%", "50%", "40%", "30%", "20%", "10%"]
                                property bool watchForChanges: false
                                onCurrentIndexChanged: {
                                    if(watchForChanges)
                                        PQSettings.openfilePreviewColorIntensity = 10-currentIndex
                                }
                                // We need a delay as this signal otherwise will be called during creationg (re-)setting that value to 10 every time
                                Timer {
                                    running: true
                                    repeat: false
                                    interval: 500
                                    onTriggered:
                                        preview_colintense.watchForChanges = true
                                }
                            }

                        }


                    }
                }

            }

        }



        /***********************************************/
        // bottom row with buttons

        Rectangle {
            color: "#666666"
            width: parent.width
            height: 1
            x: 0
            y: buttons.y
        }

        Item {

            id: buttons

            x: 0
            y: parent.height-height

            width: parent.width
            height: 75

            Row {

                spacing: 5

                x: (parent.width-width)/2
                y: (parent.height-height)/2

                PQButton {
                    text: genericStringClose
                    onClicked: {
                        hide()
                    }
                }

                PQButton {
                    text: em.pty+qsTranslate("filedialog", "Open global settings")
                    onClicked: {
                        loader.show("settingsmanager")
                    }
                }

            }

        }

    }

    function load() {

        view_icon.checked = (PQSettings.openfileDefaultView=="icons")
        view_list.checked = (PQSettings.openfileDefaultView=="list")
        view_remember.checked = PQSettings.openfileKeepLastLocation
        view_hidden.checked = PQSettings.openfileShowHiddenFilesFolders
        view_thumb.checked = PQSettings.openfileThumbnails
        view_tooltip.checked = PQSettings.openfileDetailsTooltip
        view_folderthumbs.checked = PQSettings.openfileFolderContentThumbnails
        view_folderthumbsfirst.checked = PQSettings.openfileFolderContentThumbnailsAlwaysLoadFirst
        view_folderthumbs_speed.currentIndex = PQSettings.openfileFolderContentThumbnailsSpeed-1

        places_standard.checked = PQSettings.openfileUserPlacesStandard
        places_favorites.checked = PQSettings.openfileUserPlacesUser
        places_devices.checked = PQSettings.openfileUserPlacesVolumes

        preview_show.checked = PQSettings.openfilePreview
        preview_highres.checked = PQSettings.openfilePreviewHigherResolution
        preview_blur.checked = PQSettings.openfilePreviewBlur
        preview_colintense.currentIndex = 10-PQSettings.openfilePreviewColorIntensity

    }

    function show() {
        load()
        opacity = 1
    }

    function isOpen() {
        return opacity>0
    }

    function hide() {
        opacity = 0
    }

}

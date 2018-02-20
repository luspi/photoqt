/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            // The background of PhotoQt behind the main image
            title: em.pty+qsTr("Background")
            helptext: em.pty+qsTr("The background of PhotoQt is the part, that is not covered by an image. It can be made either real (half-)transparent (using a compositor), or faked transparent (instead of the actual desktop a screenshot of it is shown), or a custom background image can be set, or none of the above. Please note: Fake transparency currently only really works when PhotoQt is run in fullscreen/maximised!")

        }

        EntrySetting {

            Row {

                spacing: 10

                Column {

                    spacing: 10

                    // Ascending or Descending
                    ExclusiveGroup { id: radiobuttons_background }
                    CustomRadioButton {
                        id: background_halftrans
                        text: em.pty+qsTr("(Half-)Transparent background")
                        exclusiveGroup: radiobuttons_background
                        checked: true
                    }
                    CustomRadioButton {
                        id: background_fakedtrans
                        text: em.pty+qsTr("Faked transparency")
                        exclusiveGroup: radiobuttons_background
                    }
                    CustomRadioButton {
                        id: background_image
                        text: em.pty+qsTr("Custom background image")
                        exclusiveGroup: radiobuttons_background
                    }
                    CustomRadioButton {
                        id: background_onecoloured
                        text: em.pty+qsTr("Monochrome, non-transparent background")
                        exclusiveGroup: radiobuttons_background
                    }
                }

                Rectangle { color: "transparent"; width: 50; height: 1; }

                Row {

                    spacing: 20
                    enabled: background_image.checked
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed/2 } }

                    // DIsplay background image preview
                    Image {
                        id: background_image_select
                        width: bg_col.height*(4/3)
                        height: bg_col.height
                        fillMode: background_image_scale.checked
                            ? Image.PreserveAspectFit : (background_image_stretch.checked
                                ? Image.Stretch : (background_image_scalecrop.checked
                                    ? Image.PreserveAspectCrop : (background_image_tile.checked
                                        ? Image.Tile : Image.Pad)))
                        source: ""
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                            var f = getanddostuff.getFilenameQtImage()
                            if(f !== "")
                                parent.source = "file:/" + f
                            }
                        }

                        // This is an 'empty' rectangle on top of image above - only visible when image source is empty
                        Rectangle {
                            anchors.fill: parent
                            color: "#99222222"
                            visible: (background_image_select.source == "")
                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Qt.AlignHCenter
                                verticalAlignment: Qt.AlignVCenter
                                color: "white"
                                font.pointSize: 10
                                text: em.pty+qsTr("No image selected")
                            }
                        }
                    }

                    Rectangle {

                        height: bg_col.height
                        width: bg_col.width

                        y: (parent.height-height)/2

                        color: "#00000000"

                        Column {

                            id: bg_col

                            spacing: 5

                            ExclusiveGroup { id: radiobuttons_image }

                            CustomRadioButton {
                                id: background_image_scale
                                //: Refers to a background image, scale it to fit
                                text: em.pty+qsTr("Scale to fit")
                                exclusiveGroup: radiobuttons_image
                                checked: true
                            }
                            CustomRadioButton {
                                id: background_image_scalecrop
                                //: Refers to a background image, crop and scale it to fit perfectly
                                text: em.pty+qsTr("Scale and Crop to fit")
                                exclusiveGroup: radiobuttons_image
                            }
                            CustomRadioButton {
                                id: background_image_stretch
                                //: Refers to a background image, stretch it to fit perfectly
                                text: em.pty+qsTr("Stretch to fit")
                                exclusiveGroup: radiobuttons_image
                            }
                            CustomRadioButton {
                                id: background_image_center
                                //: Refers to a background image, center it
                                text: em.pty+qsTr("Center image")
                                exclusiveGroup: radiobuttons_image
                            }
                            CustomRadioButton {
                                id: background_image_tile
                                //: Refers to a background image, tile it to fill everything
                                text: em.pty+qsTr("Tile image")
                                exclusiveGroup: radiobuttons_image
                            }

                        }

                    }

                }

            }

        }

    }

    function setData() {

        background_halftrans.checked = settings.composite
        background_fakedtrans.checked = settings.backgroundImageScreenshot
        background_image.checked = settings.backgroundImageUse
        background_onecoloured.checked = (!settings.composite && !settings.backgroundImageScreenshot && !settings.backgroundImageUse)

        background_image_select.source = settings.backgroundImagePath

        background_image_scale.checked = settings.backgroundImageScale
        background_image_scalecrop.checked = settings.backgroundImageScaleCrop
        background_image_stretch.checked = settings.backgroundImageStretch
        background_image_center.checked = settings.backgroundImageCenter
        background_image_tile.checked = settings.backgroundImageTile

    }

    function saveData() {

        settings.composite = background_halftrans.checked
        settings.backgroundImageScreenshot = background_fakedtrans.checked
        settings.backgroundImageUse = background_image.checked

        settings.backgroundImagePath = background_image_select.source

        settings.backgroundImageScale = background_image_scale.checked
        settings.backgroundImageScaleCrop = background_image_scalecrop.checked
        settings.backgroundImageStretch = background_image_stretch.checked
        settings.backgroundImageCenter = background_image_center.checked
        settings.backgroundImageTile = background_image_tile.checked

    }

}

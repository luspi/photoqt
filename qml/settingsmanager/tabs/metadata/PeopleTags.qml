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

            title: em.pty+qsTr("Tagging of people's faces")
            helptext: em.pty+qsTr("Connecting faces with names helps remember the context of photos. A variety of software stores such information in the image's XMP metadata. PhotoQt can both find and display such information, and it also allows the tagging of new faces. When the tagging mode is enabled, rectangles around faces can be drawn followed by entering the connected name. To enable the tagging mode, use either the shortcut feature or the entry in the main menu.")

        }

        EntrySetting {

            id: entry

            ExclusiveGroup { id: visiblegrp; }

            Column {

                spacing: 15

                Row {
                    spacing: 5
                    CustomCheckBox {
                        id: tagsEnable
                        y: (parent.height-height)/2
                        text: em.pty+qsTr("Enable")
                        tooltip: em.pty+qsTr("Find and display face tags")
                    }
                    Item {
                        width: 10
                        height: 2
                    }
                    SettingsText {
                        y: (parent.height-height)/2
                        enabled: tagsEnable.checkedButton
                        text: em.pty+qsTr("Border around tags:")
                    }
                    Item {
                        width: 5
                        height: 2
                    }
                    CustomCheckBox {
                        id: tagsBorderShow
                        y: (parent.height-height)/2
                        enabled: tagsEnable.checkedButton
                        //: Used as in: 'Show border around face tags'
                        text: em.pty+qsTr("Show")
                    }
                    Item {
                        width: 10
                        height: 2
                    }
                    SettingsText {
                        y: (parent.height-height)/2
                        enabled: tagsEnable.checkedButton
                        //: Refers to the width of the border around face tags
                        text: em.pty+qsTr("Width:")
                    }
                    CustomSpinBox {
                        id: tagsBorderWidth
                        y: (parent.height-height)/2
                        enabled: tagsEnable.checkedButton
                        minimumValue: 2
                        maximumValue: 99
                        suffix: "px"
                        width: 75
                    }
                    Item {
                        width: 10
                        height: 2
                    }
                    SettingsText {
                        y: (parent.height-height)/2
                        enabled: tagsEnable.checkedButton
                        //: Refers to the color of the border around face tags
                        text: em.pty+qsTr("Color:")
                    }
                    Image {
                        y: (parent.height-height)/2
                        enabled: tagsEnable.checkedButton
                        opacity: enabled ? 1 : 0.4
                        Behavior on opacity { NumberAnimation { duration: variables.animationSpeed/2 } }
                        source: "qrc:/img/transparent.png"
                        width: 75
                        height: 30
                        fillMode: Image.Tile
                        Rectangle {
                            id: tagsBorderColor
                            anchors.fill: parent
                            color: "#88ff0000"
                        }
                        ToolTip {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            text: em.pty+qsTr("Click to change color")
                            onClicked:
                                tagsBorderColor.color = getanddostuff.selectColor(tagsBorderColor.color)
                        }
                    }
                }

                Row {
                    spacing: 5
                    SettingsText {
                        enabled: tagsEnable.checkedButton
                        //: 'tags' refers to face tags
                        text: em.pty+qsTr("Visibility of tags:")
                    }
                    Item {
                        width: 5
                        height: 2
                    }
                    CustomRadioButton {
                        id: tagsHybridMode
                        enabled: tagsEnable.checkedButton
                        text: em.pty+qsTr("Hybrid Mode")
                        tooltip: em.pty+qsTr("Show all tags when mouse anywhere over image, and show only an individual label when mouse on top of it.")
                        exclusiveGroup: visiblegrp
                    }
                    CustomRadioButton {
                        id: tagsShowAllAlways
                        enabled: tagsEnable.checkedButton
                        //: Shortened string from: 'Always show all face tags'
                        text: em.pty+qsTr("Always show all")
                        tooltip: em.pty+qsTr("Always show all face tags")
                        exclusiveGroup: visiblegrp
                    }
                    CustomRadioButton {
                        id: tagsShowAllHover
                        enabled: tagsEnable.checkedButton
                        //: Shortened string for 'Show all tags when mouse anywhere over image'
                        text: em.pty+qsTr("Show all on hover")
                        tooltip: em.pty+qsTr("Show all tags when mouse anywhere over image")
                        exclusiveGroup: visiblegrp
                    }
                    CustomRadioButton {
                        id: tagsShowOneHover
                        enabled: tagsEnable.checkedButton
                        //: Shortened string for 'Show a tag when hovered by mouse'
                        text: em.pty+qsTr("Show one on hover")
                        tooltip: em.pty+qsTr("Show a tag when hovered by mouse")
                        exclusiveGroup: visiblegrp
                    }
                }

                Row {
                    spacing: 5
                    SettingsText {
                        y: (parent.height-height)/2
                        enabled: tagsEnable.checkedButton
                        //: The name label refers to the label with the name shown for face tags on a photo
                        text: em.pty+qsTr("Font size of name label:")
                    }
                    CustomSpinBox {
                        id: tagsFontSize
                        y: (parent.height-height)/2
                        enabled: tagsEnable.checkedButton
                        minimumValue: 1
                        maximumValue: 99
                        suffix: "pt"
                        width: 75
                    }
                }

            }

        }

    }

    function setData() {
        tagsEnable.checkedButton = settings.peopleTagInMetaDisplay
        tagsBorderShow.checkedButton = settings.peopleTagInMetaBorderAroundFace
        tagsBorderWidth.value = settings.peopleTagInMetaBorderAroundFaceWidth
        tagsBorderColor.color = settings.peopleTagInMetaBorderAroundFaceColor
        tagsShowAllAlways.checked = settings.peopleTagInMetaAlwaysVisible
        tagsShowOneHover.checked = settings.peopleTagInMetaIndependentLabels
        tagsHybridMode.checked = settings.peopleTagInMetaHybridMode
        tagsShowAllHover.checked = (!settings.peopleTagInMetaAlwaysVisible && !settings.peopleTagInMetaIndependentLabels && !settings.peopleTagInMetaHybridMode)
        tagsFontSize.value = settings.peopleTagInMetaFontSize
    }

    function saveData() {
        settings.peopleTagInMetaDisplay = tagsEnable.checkedButton
        settings.peopleTagInMetaBorderAroundFace = tagsBorderShow.checkedButton
        settings.peopleTagInMetaBorderAroundFaceWidth = tagsBorderWidth.value
        settings.peopleTagInMetaBorderAroundFaceColor = tagsBorderColor.color
        settings.peopleTagInMetaAlwaysVisible = tagsShowAllAlways.checked
        settings.peopleTagInMetaIndependentLabels = tagsShowOneHover.checked
        settings.peopleTagInMetaHybridMode = tagsHybridMode.checked
        settings.peopleTagInMetaFontSize = tagsFontSize.value
    }

}

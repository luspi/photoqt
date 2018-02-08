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

import "../elements"
import "../handlestuff.js" as Handle

FadeInTemplate {

    id: scale_top

    heading: ""
    showSeperators: false

    marginTopBottom: (background.height-500)/2
    clipContent: false

    property string lastClicked: "w"

    content: [

        // Header
        Text {
            text: em.pty+qsTr("Scale Image")
            color: colour.text
            font.pointSize: 18*2
            font.bold: true
            x: (scale_top.contentWidth-width)/2
        },

        // Current dimension
        Rectangle {
            color: "#00000000"
            width: childrenRect.width
            height: childrenRect.height
            x: (scale_top.contentWidth-width)/2
            Row {
                spacing: 5
                Text {
                    //: 'Size" here refers to the dimensions (numbers of pixel), expressed here as 'width x height', NOT the filesize
                    text: em.pty+qsTr("Current Size:")
                    font.pointSize: 13
                    color: colour.text
                }
                Text {
                    id: currentwidth
                    text: "4000"
                    font.pointSize: 13
                    color: colour.text
                }
                Text {
                    text: "x"
                    font.pointSize: 13
                    color: colour.text
                }
                Text {
                    id: currentheight
                    text: "3000"
                    font.pointSize: 13
                    color: colour.text
                }
            }
        },

        Rectangle {
            color: "transparent"
            width: parent.width
            height: 1
        },

        Text {
            id: error
            x: (scale_top.contentWidth-width)/2
            color: colour.text_warning
            font.pointSize: 13
            font.bold: true
            text: em.pty+qsTr("Error! Something went wrong, unable to scale image...")
        },

        Rectangle {
            color: "transparent"
            width: parent.width
            height: 1
        },

        // New settings
        Rectangle {

            color: "#00000000"
            width: parent.width
            height: scalerow.height
            x: (scale_top.contentWidth-scalerow.width)/2

            Row {

                id: scalerow
                spacing: 5

                // The labels on the left
                Rectangle {
                    id: rowlabels
                    color: "#00000000"
                    width: childrenRect.width
                    height: childrenRect.height
                    Text {
                        color: colour.text
                        //: The width (number of pixels) of the image
                        text: em.pty+qsTr("New width:")
                        font.pointSize: 15
                        horizontalAlignment: Text.AlignRight
                        y: (newwidth.height-height)/2+5
                    }
                    Text {
                        color: colour.text
                        //: The height (number of pixels) of the image
                        text: em.pty+qsTr("New height:")
                        font.pointSize: 15
                        horizontalAlignment: Text.AlignRight
                        y: newwidth.height+10+(newheight.height-height)/2
                    }
                }

                // The spinboxes for the new dimension
                Rectangle {
                    id: rowedits
                    color: "#00000000"
                    width: childrenRect.width
                    height: childrenRect.height
                    // new width
                    CustomSpinBox {
                        id: newwidth
                        width: 100
                        height: 35
                        value: 4000
                        maximumValue: 99999
                        minimumValue: 1
                        y: 5
                        onValueChanged: {
                            if(aspect_image.keepaspectratio)
                                adjustHeight()
                        }
                        onFocusChanged: {
                            if(focus) lastClicked = "w"
                        }
                    }
                    // new height
                    CustomSpinBox {
                        id: newheight
                        width: 100
                        height: 35
                        value: 3000
                        maximumValue: 99999
                        minimumValue: 1
                        y: newwidth.height+10
                        onValueChanged: {
                            if(aspect_image.keepaspectratio)
                                adjustWidth()
                        }
                        onFocusChanged: {
                            if(focus) lastClicked = "h"
                        }
                    }
                }

                // Image keeping the aspect ratio
                Image {
                    id: aspect_image
                    source: "qrc:/img/ratioKeep.png"
                    sourceSize: Qt.size(0.9*aspect_text.height,0.9*aspect_text.height)
                    y: (rowedits.height-height)/2+5
                    property bool keepaspectratio: true
                    opacity: keepaspectratio ? 1 : 0.3
                    // Click triggers keeping of aspect ratio
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            verboseMessage("Other/Scale","Trigger aspect ratio")
                            parent.keepaspectratio = !parent.keepaspectratio
                            parent.source = parent.keepaspectratio ? "qrc:/img/ratioKeep.png" : "qrc:/img/ratioDontKeep.png"
                            if(parent.keepaspectratio) reenableKeepAspectRatio()
                        }
                    }
                }

                // Text explaining the current aspect ratio setting
                Text {
                    id: aspect_text
                    color: colour.text
                    opacity: aspect_image.keepaspectratio ? 1 : 0.3
                    //: This is the ratio of the image = width/height
                    text: em.pty+qsTr("Aspect Ratio")
                    font.pointSize: 15
                    font.strikeout: !aspect_image.keepaspectratio
                    y: (rowedits.height-height)/2+5
                    // Click triggers keeping of aspect ratio
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            verboseMessage("Other/Scale","Trigger aspect ratio")
                            aspect_image.keepaspectratio = !aspect_image.keepaspectratio
                            aspect_image.source = aspect_image.keepaspectratio ? "qrc:/img/ratioKeep.png" : "qrc:/img/ratioDontKeep.png"
                            if(aspect_image.keepaspectratio) reenableKeepAspectRatio()
                        }
                    }
                }
            }
        },

        Rectangle {
            color: "transparent"
            width: parent.width
            height: 1
        },

        // Quality setting
        Rectangle {
            color: "#00000000"
            width: childrenRect.width
            height: childrenRect.height
            x: (scale_top.contentWidth-width)/2
            Row {
                spacing: 5
                Text {
                    color: colour.text
                    font.pointSize: 13
                    //: Refers to the quality of scaling an image
                    text: em.pty+qsTr("Quality")
                }
                CustomSlider {
                    id: quality_slider
                    minimumValue: 1
                    maximumValue: 100
                    width: 250
                    value: 90
                    stepSize: 1

                    y: (quality_text.height-height)/2
                }
                // Display quality percentage
                Text {
                    id: quality_text
                    font.pointSize: 13
                    color: colour.text
                    text: quality_slider.value.toString()
                }
            }
        },

        Rectangle {
            color: "transparent"
            width: parent.width
            height: 10
        },

        // The three buttons
        Rectangle {

            x: (scale_top.contentWidth-width)/2
            width: childrenRect.width
            height: childrenRect.height

            color: "#00000000"

            Row {

                spacing: 5

                CustomButton {
                    id: scale_inplace
                    //: Scale as in "Scale image"
                    text: em.pty+qsTr("Scale in place")
                    fontsize: 15
                    onClickedButton: {
                        verboseMessage("Other/Scale","Scale in place")
                        if(getanddostuff.scaleImage(variables.currentDir + "/" + variables.currentFile, newwidth.value, newheight.value,
                                                    quality_slider.value, variables.currentDir + "/" + variables.currentFile)) {
                            Handle.loadFile(variables.currentDir + "/" + variables.currentFile, variables.filter, true)
                            hide()
                        } else
                            error.visible = true

                    }
                }
                CustomButton {
                    id: scale_innewfile
                    //: Scale as in "Scale image"
                    text: em.pty+qsTr("Scale into new file")
                    fontsize: 15
                    onClickedButton: {
                        var fname = getanddostuff.getSaveFilename(em.pty+qsTr("Save file as..."),variables.currentDir + "/" + variables.currentFile);
                        verboseMessage("Other/Scale","Scale into new file: " + fname)
                        if(fname !== "") {
                            if(getanddostuff.scaleImage(variables.currentDir + "/" + variables.currentFile,newwidth.value, newheight.value,
                                                        quality_slider.value, fname)) {
                                if(variables.currentDir === getanddostuff.removeFilenameFromPath(fname))
                                    Handle.loadFile(fname, variables.filter, true)
                                hide()
                            } else
                                error.visible = true

                        }
                    }
                }
                CustomButton {
                    id: scale_dont
                    //: Scale as in "scale image"
                    text: em.pty+qsTr("Don't scale")
                    fontsize: 15
                    onClickedButton: hide()
                }
            }
        }

    ]

    function adjustWidth() {
        newwidth.value = newheight.value*((currentwidth.text*1)/(currentheight.text*1));
    }
    function adjustHeight() {
        newheight.value = newwidth.value*((currentheight.text*1)/(currentwidth.text*1));
    }
    function reenableKeepAspectRatio() {
        verboseMessage("Other/Scale", "reenableKeepAspectRatio(): " + lastClicked)
        if(lastClicked == "w")
            adjustHeight()
        else
            adjustWidth()
    }

    function showScale() {

        verboseMessage("Other/Scale", "showScale()")

        if(!getanddostuff.canBeScaled(variables.currentDir + "/" + variables.currentFile)) {
            call.show("scaleunsupported")
            hide()
            return;
        }

        var s = imageitem.getCurrentSourceSize()
        currentheight.text = s.height
        newheight.value = s.height
        currentwidth.text = s.width
        newwidth.value = s.width
        error.visible = false
        show()
    }

    Connections {
        target: call
        onScaleShow: {
            if(variables.currentFile === "") return
            showScale()
        }
        onShortcut: {
            if(!scale_top.visible) return
            if(sh == "Escape")
                hide()
        }
        onCloseAnyElement:
            if(scale_top.visible)
                hide()
    }

}

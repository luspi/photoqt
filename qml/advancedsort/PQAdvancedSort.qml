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

import "../templates"
import "../elements"

PQTemplateFullscreen {

    id: advancedsort_top

    spacing: 20

    popout: PQSettings.interfacePopoutAdvancedSort
    shortcut: "__advancedSort"
    title: em.pty+qsTranslate("advancedsort", "Advanced Image Sort")

    buttonFirstText: em.pty+qsTranslate("advancedsort", "Sort images")
    buttonSecondShow: true
    buttonSecondText: genericStringCancel

    maxWidth: 600

    onPopoutChanged:
        PQSettings.interfacePopoutAdvancedSort = popout

    onButtonFirstClicked: {
        saveSettings()
        advancedsort_top.opacity = 0
        variables.visibleItem = ""
        loader.show("advancedsortbusy")
        filefoldermodel.advancedSortMainView()
    }

    onButtonSecondClicked: {
        advancedsort_top.opacity = 0
        variables.visibleItem = ""
    }

    content: [
        PQText {
            id: description1
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: em.pty+qsTranslate("advancedsort", "It is possible to sort the images in the current folder by color properties. Depending on the number of images and the settings, this might take a few seconds.")

        },

        Row {
            id: sortbyrow
            x: (parent.width-width)/2
            spacing: 10
            PQText {
                id: sortbytxt
                y: (sortby.height-height)/2
                //: Used as 'sort by dominant/average color'
                text: em.pty+qsTranslate("advancedsort", "Sort by:")
            }
            PQComboBox {

                id: sortby

                property var props: ["resolution", "dominantcolor", "averagecolor", "luminosity", "exifdate"]

                        //: The image resolution (width/height in pixels)
                model: [em.pty+qsTranslate("advancedsort", "Resolution"),
                        //: The color that is most common in the image
                        em.pty+qsTranslate("advancedsort", "Dominant color"),
                        //: the average color of the image
                        em.pty+qsTranslate("advancedsort", "Average color"),
                        //: the average color of the image
                        em.pty+qsTranslate("advancedsort", "Luminosity"),
                        em.pty+qsTranslate("advancedsort", "Exif date")]
            }

        },

        Row {
            x: sortbyrow.x
            spacing: 10
            Item {
                width: sortbytxt.width
                height: 1
            }
            PQRadioButton {
                id: asc
                //: sort order, i.e., 'ascending order'
                text: em.pty+qsTranslate("advancedsort", "ascending")
            }
            PQRadioButton {
                id: desc
                //: sort order, i.e., 'descending order'
                text: em.pty+qsTranslate("advancedsort", "descending")
            }
        },

        Row {
            x: (parent.width-width)/2
            spacing: 10
            height: (sortby.currentIndex>0 && sortby.currentIndex!=4) ? childrenRect.height : 0
            Behavior on height { NumberAnimation { duration: 250 } }
            clip: true
            PQText {
                enabled: sortby.currentIndex>0
                id: qualtxt
                y: (qual.height-height)/2
                Behavior on color { ColorAnimation { duration: 250; } }
                //: Please keep short! Sorting images by color comes with a speed vs quality tradeoff.
                text: em.pty+qsTranslate("advancedsort", "speed vs quality:")
            }
            PQComboBox {
                enabled: sortby.currentIndex>0
                id: qual
                        //: quality and speed of sorting image by color
                model: [em.pty+qsTranslate("advancedsort", "low quality (fast)"),
                        //: quality and speed of sorting image by color
                        em.pty+qsTranslate("advancedsort", "medium quality"),
                        //: quality and speed of sorting image by color
                        em.pty+qsTranslate("advancedsort", "high quality (slow)")]
            }

        },

        Column {
            spacing: 10
            width: parent.width
            height: sortby.currentIndex==4 ? description2.height : 0
            Behavior on height { NumberAnimation { duration: 250 } }
            clip: true
            PQText {
                id: description2
                enabled: sortby.currentIndex==4
                y: (qual.height-height)/2
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Behavior on color { ColorAnimation { duration: 250; } }
                //: Please keep short! Sorting images by color comes with a speed vs quality tradeoff.
                text: em.pty+qsTranslate("advancedsort", "Select the order of priority. If a date value cannot be found, PhotoQt will proceed to the next item in the list.")
            }
        },

        // this is only visible when respective item is selected
        ListView {
            id: exifdatacol

            property int checkw: 0
            property int cellheight: 0

            property var dataorder: [0,1,2,3]

            property var name2order: {
                "exiforiginal": 0,
                "exifdigital": 1,
                "filecreation": 2,
                "filemodification": 3
            }

            property var data: {0 : [em.pty+qsTranslate("advancedsort", "Exif tag: Original date/time"), "exiforiginal"],
                                1 : [em.pty+qsTranslate("advancedsort", "Exif tag: Digitized date/time"), "exifdigital"],
                                2 : [em.pty+qsTranslate("advancedsort", "File creation date"), "filecreation"],
                                3 : [em.pty+qsTranslate("advancedsort", "File modification date"), "filemodification"]}
            property var datachecked: {0: true,
                                       1: true,
                                       2: true,
                                       3: true}

            orientation: ListView.Vertical
            width: parent.width
            height: sortby.currentIndex==4 ? 4*cellheight : 0
            Behavior on height { NumberAnimation { duration: 250 } }
            clip: true
            model: 4
            boundsBehavior: ListView.StopAtBounds
            delegate: Row {
                id: row
                x: (parent.width-width)/2
                width: childrenRect.width
                height: childrenRect.height
                property int dataindex: exifdatacol.dataorder[index]
                Component.onCompleted:
                    exifdatacol.cellheight = height

                PQText {
                    y: (check.height-height)/2
                    text: (index+1)+". "
                }

                Item {
                    id: check
                    width: exifdatacol.checkw+10
                    height: checkbox.height+10
                    PQCheckbox {
                        id: checkbox
                        y: 5
                        text: exifdatacol.data[row.dataindex][0]
                        checked: exifdatacol.datachecked[row.dataindex]
                        Component.onCompleted: {
                            if(exifdatacol.checkw < width)
                                exifdatacol.checkw = width
                        }
                        onCheckedChanged: {
                            if(exifdatacol.datachecked[row.dataindex] != checked) {
                                exifdatacol.datachecked[row.dataindex] = checked
                                exifdatacol.datacheckedChanged()
                            }
                        }
                    }
                }
                PQButton {
                    height: check.height
                    width: height
                    imageButtonSource: "/filedialog/upwards.svg"
                    onClicked: {
                        if(index > 0) {
                            [exifdatacol.dataorder[index], exifdatacol.dataorder[index-1]] = [exifdatacol.dataorder[index-1], exifdatacol.dataorder[index]];
                            exifdatacol.dataorderChanged()
                        }
                    }
                }
                PQButton {
                    height: check.height
                    width: height
                    imageButtonSource: "/filedialog/downwards.svg"
                    onClicked: {
                        if(index < 3) {
                            [exifdatacol.dataorder[index+1], exifdatacol.dataorder[index]] = [exifdatacol.dataorder[index], exifdatacol.dataorder[index+1]];
                            exifdatacol.dataorderChanged()
                        }
                    }
                }
            }
        },

        PQText {
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: em.pty+qsTranslate("advancedsort", "There is also a quickstart shortcut that immediately starts the sorting using the latest settings.")
        }
    ]

    Connections {
        target: loader
        onAdvancedSortPassOn: {
            if(what == "show") {
                if(filefoldermodel.current == -1)
                    return

                loadSettings()

                opacity = 1
                variables.visibleItem = "advancedsort"

            } else if(what == "hide") {
                closeElement()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    buttonSecondClicked()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    buttonFirstClicked()
            }
        }
    }

    function loadSettings() {

        var curindex = 0
        for(var i = 0; i < sortby.props.length; ++i) {
            if(sortby.props[i] == PQSettings.imageviewAdvancedSortCriteria) {
                curindex = i
                break;
            }
        }
        sortby.currentIndex = curindex

        asc.checked = (PQSettings.imageviewAdvancedSortAscending)
        desc.checked = (!PQSettings.imageviewAdvancedSortAscending)

        qual.currentIndex = (PQSettings.imageviewAdvancedSortQuality=="low" ? 0 : (PQSettings.imageviewAdvancedSortQuality=="high" ? 2 : 1))

        // load exif data settings
        var neworder = []
        for(var j = 0; j < PQSettings.imageviewAdvancedSortExifDateCriteria.length/2; ++j) {
            var tmp = exifdatacol.name2order[PQSettings.imageviewAdvancedSortExifDateCriteria[2*j]]
            neworder.push(tmp)
            exifdatacol.datachecked[tmp] = PQSettings.imageviewAdvancedSortExifDateCriteria[2*j +1]
        }
        exifdatacol.dataorder = neworder

    }

    function saveSettings() {

        PQSettings.imageviewAdvancedSortCriteria = sortby.props[sortby.currentIndex]
        PQSettings.imageviewAdvancedSortAscending = asc.checked
        var opt = ["low", "medium", "high"]
        PQSettings.imageviewAdvancedSortQuality = opt[qual.currentIndex]

        var savelist = []
        for(var j = 0; j < 4; ++j) {
            var curorder = exifdatacol.dataorder[j]
            savelist.push(exifdatacol.data[curorder][1])
            savelist.push(exifdatacol.datachecked[curorder] ? 1 : 0)
        }
        PQSettings.imageviewAdvancedSortExifDateCriteria = savelist

    }

}


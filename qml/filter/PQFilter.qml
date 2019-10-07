import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "../elements"
import "../loadfiles.js" as LoadFiles

Rectangle {

    id: filter_top

    color: "#dd000000"

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked:
            button_cancel.clicked()
    }

    Item {

        id: insidecont

        y: ((parent.height-height)/2)
        width: parent.width
        height: childrenRect.height

        clip: true

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        Column {

            spacing: 20

            Text {
                id: heading
                x: (insidecont.width-width)/2
                color: "white"
                font.pointSize: 20
                font.bold: true
                text: em.pty+qsTranslate("filter", "Filter images in current directory")
            }

            Text {
                id: description1
                x: 10
                width: insidecont.width-20
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: "white"
                font.pointSize: 12
                text: em.pty+qsTranslate("filter", "Enter here the terms you want to filter the images by. Separate multiple terms by a space.")
            }

            Text {
                id: description2
                x: 10
                width: insidecont.width-20
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: "white"
                font.pointSize: 12
                text: em.pty+qsTranslate("filter", "If you want to filter by file extension, put a dot '.' in front of the term.")
            }


            PQLineEdit {

                id: filteredit

                x: (insidecont.width-width)/2
                width: 300
                height: 40

                placeholderText: em.pty+qsTranslate("filter", "Enter filter term")

            }

            Item {

                id: butcont

                x: 0
                width: insidecont.width
                height: childrenRect.height

                Row {

                    spacing: 5

                    x: (parent.width-width)/2

                    PQButton {
                        id: button_ok
                        //: Written on a clickable button - please keep short
                        text: em.pty+qsTranslate("filter", "Filter")
                        onClicked: {
                            filter_top.opacity = 0
                            variables.visibleItem = ""
                            if(filteredit.text == "")
                                removeFilter()
                            else
                                setFilter(filteredit.text)
                        }
                    }
                    PQButton {
                        id: button_cancel
                        text: genericStringCancel
                        onClicked: {
                            filter_top.opacity = 0
                            variables.visibleItem = ""
                        }
                    }
                    PQButton {
                        scale: 0.8
                        id: button_removefilter
                        //: Written on a clickable button - please keep short
                        text: em.pty+qsTranslate("filter", "Remove filter")
                        onClicked: {
                            filter_top.opacity = 0
                            variables.visibleItem = ""
                            removeFilter()
                        }
                    }

                }

            }

        }

    }

    Connections {
        target: loader
        onFilterPassOn: {
            if(what == "show") {
                if(variables.indexOfCurrentImage == -1 && !variables.filterSet)
                    return
                opacity = 1
                variables.visibleItem = "filter"
                filteredit.setFocus()
            } else if(what == "hide") {
                button_cancel.clicked()
            } else if(what == "removeFilter") {
                removeFilter()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    button_cancel.clicked()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    button_ok.clicked()
            }
        }
    }

    function setFilter(term) {

        variables.filterStrings = []
        variables.filterSuffixes = []

        var filterStr = ""

        // filter out search terms and search suffixes
        var spl = filteredit.text.split(" ")
        for(var iSpl = 0; iSpl < spl.length; ++iSpl) {
            if(spl[iSpl][0] == ".") {
                variables.filterSuffixes.push(spl[iSpl].slice(1))
                filterStr += ", ." + spl[iSpl].slice(1)
            } else {
                variables.filterStrings.push(spl[iSpl])
                filterStr += ", " + spl[iSpl]
            }
        }
        variables.filterStringConcat = filterStr.slice(2)

        var filteredlist = []

        // deep copy image list
        if(!variables.filterSet) {
            variables.allImageFilesInOrderFilterBackup = []
            for(var i = 0; i < variables.allImageFilesInOrder.length; ++i)
                variables.allImageFilesInOrderFilterBackup.push(variables.allImageFilesInOrder[i])
            variables.filterSet = true
        }


        // we check for filenames that satisfies all filter terms

        for(var j = 0; j < variables.allImageFilesInOrderFilterBackup.length; ++j) {

            var suf = handlingFileDialog.getSuffix(variables.allImageFilesInOrderFilterBackup[j], false)
            var bas = handlingFileDialog.getBaseName(variables.allImageFilesInOrderFilterBackup[j])

            var allgood = true

            // check search term
            for(var k = 0; k < variables.filterStrings.length; ++k) {
                if(bas.indexOf(variables.filterStrings[k]) == -1) {
                    allgood = false
                    break
                }
            }

            if(allgood) {
                for(var l = 0; l < variables.filterSuffixes.length; ++l) {
                    if(suf != variables.filterSuffixes[l]) {
                        allgood = false
                        break;
                    }
                }
            }

            if(allgood)
                filteredlist.push(variables.allImageFilesInOrderFilterBackup[j])

        }

        var newindex = filteredlist.indexOf(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
        if(filteredlist.length > 0 && newindex == -1)
            newindex = 0

        variables.filterSet = true
        variables.allImageFilesInOrder = filteredlist
        variables.indexOfCurrentImage = -1
        variables.indexOfCurrentImage = newindex
        thumbnails.reloadThumbnails()

    }

    function removeFilter() {

        var newindex = variables.allImageFilesInOrderFilterBackup.indexOf(variables.allImageFilesInOrder[variables.indexOfCurrentImage])

        variables.allImageFilesInOrder = []
        for(var i = 0; i < variables.allImageFilesInOrderFilterBackup.length; ++i)
            variables.allImageFilesInOrder.push(variables.allImageFilesInOrderFilterBackup[i]);

        variables.filterSet = false
        variables.filterStrings = []
        variables.filterSuffixes = []
        filteredit.text = ""

        variables.indexOfCurrentImage = -1
        variables.indexOfCurrentImage = (newindex==-1 ? 0 : newindex)

        thumbnails.reloadThumbnails()

    }

}

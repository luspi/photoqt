import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

import "../elements"

ListView {

    id: listview

    anchors.fill: parent

    focus: true

    property int prev_highlight: -1
    highlight: Rectangle { color: "#DD5d5d5d"; radius: 5 }
    highlightMoveDuration: 50

    model: ListModel { id: listviewmodel; }
    delegate: listviewDelegate

    spacing: 2
    opacity: settings.openDefaultView==="list" ? 1: 0
    Behavior on opacity { SmoothedAnimation { velocity: 10; } }
    onOpacityChanged: {
        if(opacity == 0)
            visible = false
    }

    onCurrentIndexChanged: {

        edit_rect.focusOnInput()

        if(opacity == 1)
            gridview.currentIndex = currentIndex
        else
            return

        if(currentIndex == -1 || !type_preview || files[2*currentIndex] === "")
            preview.source = ""
        else {
            if(previous_width != top.width || tweaks.getMode() !== previous_mode)
                updatePreviewSourceSize()
            preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[2*currentIndex])
        }

    }

    Component {

        id: listviewDelegate

        Rectangle {
            width: listview.width-listview_scrollbar.width
            height: files_txt.height
            color: index%2==0 ? "#22ffffff" : "#11ffffff"

            Image {
                id: files_img
                opacity: icon.thumbnailLoaded&&tweaks.getThumbnailEnabled() ? 0 : 0.6
                width: files_txt.height-4
                x: 7
                verticalAlignment: Image.AlignVCenter
                height: width
                asynchronous: true
                source: "image://icon/image-" + getanddostuff.getSuffix(dir_path + "/" + files[2*index])
                fillMode: Image.PreserveAspectFit
            }

            Image {
                id: icon
                property bool hovered: false
                opacity: hovered ? 1 : 0.8
                Behavior on opacity { NumberAnimation { duration: 100 } }
                width: files_txt.height-4
                x: 7
                verticalAlignment: Image.AlignVCenter
                height: width
                asynchronous: true
                cache: false
                source: files[2*index]===undefined||opacity==0 || (!tweaks.getThumbnailEnabled()) || opacity == 0
                        ? ""
                        : "image://thumb/" + dir_path + "/" + files[2*index]
                mipmap: true
                fillMode: Image.PreserveAspectFit
                property bool thumbnailLoaded: false
                onStatusChanged: {
                    if(status == Image.Ready && source != "") {
                        thumbnailLoaded = true
                    }
                }
            }

            Text {
                id: files_txt
                x: 5 + files_img.width+5
                width: listview.width-15-files_size.width-icon.width
                text: "<b>" + filename + "</b>"
                color: "white"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: tweaks.zoomlevel
                elide: Text.ElideRight
            }
            Text {
                id:files_size
                x: (files_txt.x + files_txt.width)
                anchors.right: parent.right
                anchors.rightMargin: 5
                text: filesize
                color: "white"
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: tweaks.zoomlevel
            }

            ToolTip {
                anchors.fill: parent
                hoverEnabled: true
                text: (files.length > 2*index && files[2*index] !== undefined) ? files[2*index] : ""
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onEntered: {
                    icon.hovered = true
                    currentIndex = index
                }
                onExited: {
                    icon.hovered = false
                }
                onClicked: {
                    if(mouse.button == Qt.LeftButton) {
                        hideOpenAni.start()
                        reloadDirectory(dir_path + "/" + files[2*index],"")
                        if(settings.openKeepLastLocation)
                            getanddostuff.setOpenFileLastLocation(dir_path)
                    } else
                        edit_rect.setEditText(files[2*index])
                }
            }
        }
    }

    function displayIcons() {
        opacity = 1
        opacity = 0
    }

    function displayList() {
        opacity = 0
        visible = true
        opacity = 1
    }

    function loadFiles(files) {
        verboseMessage("FilesViewList::loadFiles()", files.length)
        listviewmodel.clear()
        contentY = 0
        for(var j = 0; j < files.length; j+=2)
            listviewmodel.append({"filename" : files[j], "filesize" : files[j+1]})

    }

    function focusOnFile(filename) {

        verboseMessage("FilesViewList::focusOnFile()", filename)

        var pattern = new RegExp(escapeRegExp(filename) + ".*","i")
        if(pattern.test(files[2*currentIndex])) return
        var index = -1
        for(var i = 0; i < files.length; i+=2) {
            if(pattern.test(files[i])) {
                index = i/2
                break;
            }
        }
        if(index != -1)
            currentIndex = index

    }

}

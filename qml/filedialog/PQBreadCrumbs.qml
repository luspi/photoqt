import QtQuick
import "../elements"

Item {

    id: breadcrumbs_top

    width: parent.width
    height: 50

    Row {

        Item {
            width: placesWidth
            height: breadcrumbs_top.height

            Row {

                x: 5

                Component.onCompleted: {
                    filedialog_top.leftColMinWidth = width+10
                }

                y: (parent.height-height)/2
                spacing: 5

                PQButtonIcon {
                    source: "/generic/backwards.svg"
                    enabled: filedialog_top.historyIndex>0
                    onClicked:
                        filedialog_top.goBackInHistory()
                }
                PQButtonIcon {
                    source: "/generic/upwards.svg"
                    onClicked:
                        filedialog_top.loadNewPath(PQCScriptsFilesPaths.goUpOneLevel(PQCFileFolderModel.folderFileDialog))
                }
                PQButtonIcon {
                    source: "/generic/forwards.svg"
                    enabled: filedialog_top.historyIndex<filedialog_top.history.length-1
                    onClicked:
                        filedialog_top.goForwardsInHistory()
                }

                Item {

                    width: 5
                    height: 40

                    Rectangle {
                        x: 2
                        width: 1
                        height: 40
                        color: PQCLook.baseColorActive
                    }

                }

                PQButtonIcon {
                    id: iconview
                    checkable: true
                    checked: PQCSettings.filedialogDefaultView==="icons"
                    source: "/generic/iconview.svg"
                    tooltip: qsTranslate("filedialog", "Show files as icons")
                    onCheckedChanged: {
                        if(checked)
                            listview.checked = false
                        else if(!listview.checked)
                            checked = true

                        if(checked)
                            PQCSettings.filedialogDefaultView = "icons"
                    }
                }

                PQButtonIcon {
                    id: listview
                    checkable: true
                    checked: PQCSettings.filedialogDefaultView!=="icons"
                    source: "/generic/listview.svg"
                    tooltip: qsTranslate("filedialog", "Show files as list")
                    onCheckedChanged: {
                        if(checked)
                            iconview.checked = false
                        else if(!iconview.checked)
                            checked = true

                        if(checked)
                            PQCSettings.filedialogDefaultView = "list"
                    }
                }

                Item {

                    width: 5
                    height: 40

                    Rectangle {
                        x: 2
                        width: 1
                        height: 40
                        color: PQCLook.baseColorActive
                    }

                }

                PQButtonIcon {
                    id: remember
                    checkable: true
                    checked: true
                    source: "/generic/remember.svg"
                }


            }

        }

        Item {
            width: 8
            height: breadcrumbs_top.height
        }

        Rectangle {
            width: fileviewWidth
            height: breadcrumbs_top.height
            color: "#aa0000"
        }

    }

    Rectangle {
        y: parent.height-1
        width: parent.width
        height: 1
        color: PQCLook.baseColorActive
    }

}

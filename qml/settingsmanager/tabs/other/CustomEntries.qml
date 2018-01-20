import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

import "../../../elements"
import "../../"
import "./"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: title
            title: em.pty+qsTr("Custom Entries in Main Menu")
            helptext: em.pty+qsTr("Here you can adjust the custom entries in the main menu. You can simply drag and drop the entries, edit them, add a new one and remove an existing one.")

        }

        EntrySetting {

            id: entry

            Row {

                spacing: 15

                Rectangle {

                    id: contextrect

                    width: 650
                    height: 200
    //				x: (parent.width-width)/2

                    radius: variables.global_item_radius

                    color: colour.tiles_inactive

                    Rectangle {

                        id: headContext

                        color: colour.tiles_active

                        width: parent.width-10
                        height: 30

                        x: 5
                        y: 5
                        radius: variables.global_item_radius

                        Text {

                            x: context.binaryX
                            y: (parent.height-height)/2
                            width: context.textEditWidth

                            font.bold: true
                            font.pointSize: 10
                            color: colour.tiles_text_active
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter

                            text: em.pty+qsTr("Executable")

                        }

                        Text {

                            x: context.descriptionX
                            y: (parent.height-height)/2
                            width: context.textEditWidth

                            font.bold: true
                            font.pointSize: 10
                            color: colour.tiles_text_active
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter

                            text: em.pty+qsTr("Menu Text")

                        }

                    }

                    CustomEntriesInteractive {
                        id: context
                        x: 5
                        y: headContext.height+10
                        width: parent.width-10
                        height: parent.height-headContext.height-20
                    }

                }

                Rectangle {

                    color: "transparent"
                    width: childrenRect.width
                    height: childrenRect.height
                    y: (parent.height-height)/2

                    Column {

                        spacing: 20

                        CustomButton {
                            id: contextadd
                            width: 150
                            wrapMode: Text.WordWrap
                            text: em.pty+qsTr("Add new entry")
                            onClickedButton: context.addNewItem()
                        }


                        CustomButton {
                            id: contextreset
                            text: em.pty+qsTr("Set default entries")
                            width: 150
                            onClickedButton: {
                                getanddostuff.setDefaultContextMenuEntries()
                                context.setData()
                            }
                        }

                    }

                }

            }

        }

    }

    function setData() {
        context.setData()
    }

    function saveData() {
        context.saveData()
    }

}

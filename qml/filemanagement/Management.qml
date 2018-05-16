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
import QtQuick.Layouts 1.2

import "../elements"

FadeInTemplate {

    id: management_top

    visible: (opacity!=0)
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    width: mainwindow.width
    height: mainwindow.height

    marginLeftRight: 0
    marginTopBottom: 0
    hideButtons: true
    hideTitle: true

    showSeperators: false

    property string current: ""

    signal hideAllItems()

    content: [

        RowLayout {

            id: layout
            spacing: 6

            Rectangle {

                id: category

                width: 300
                height: management_top.height-250
                color: "transparent"

                ColumnLayout {

                    anchors.centerIn: category

                    spacing: 10

                    ManagementNavigation {
                        //: As in 'Copy current image to a new location'. Keep string short!
                        text: em.pty+qsTr("Copy")
                        category: "cp"
                    }
                    ManagementNavigation {
                        //: As in 'Delete current image'. Keep string short!
                        text: em.pty+qsTr("Delete")
                        category: "del"
                    }
                    ManagementNavigation {
                        //: As in 'Move current image to a new location'. Keep string short!
                        text: em.pty+qsTr("Move")
                        category: "mv"
                    }
                    ManagementNavigation {
                        //: As in 'Rename current image'. Keep string short!
                        text: em.pty+qsTr("Rename")
                        category: "rn"
                    }

                }

            }

            Item {

                id: management_item

                width: management_top.width
                height: management_top.height//-250

                ManagementContainer {
                    category: "cp"
                    itemSource: "Copy.qml"
                }
                ManagementContainer {
                    category: "del"
                    itemSource: "Delete.qml"
                }
                ManagementContainer {
                    category: "mv"
                    itemSource: "Move.qml"
                }
                ManagementContainer {
                    category: "rn"
                    itemSource: "Rename.qml"
                }

            }

        }

    ]

    signal permanentDeleteFile()

    Connections {
        target: call
        onFilemanagementShow: {
            if(variables.currentFile === "") return
            management_top.current = category
            show()
        }
        onShortcut: {
            if(!management_top.visible) return
            if(sh == "Escape")
                hide()
        }
        onCloseAnyElement:
            if(management_top.visible)
                hide()
    }

}

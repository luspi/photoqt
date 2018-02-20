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

import "./"

CustomConfirm {

    signal closed()

    fillAnchors: parent

    //: Keep short!
    header: em.pty+qsTr("Shortcuts")
    property string intro: em.pty+qsTr("You can use the following shortcuts for navigation") + ":"
    property var shortcuts: ({})
    property string area: ""

    actAsInfoMessage: true
    //: In the sense of 'I understand it'
    confirmbuttontext: em.pty+qsTr("Got it!")
    showDontAskAgain: true
    //: In the sense of 'Don't show me that confirmation element again'
    customisedDontAskAgainMessage: em.pty+qsTr("Don't show again")
    dontAskAgainChecked: true

    Component.onCompleted: {

        var desc = "<style type='text/css'>table { margin: 0 auto 0 auto } td { padding:5px }</style>"
        desc += intro + "<br>"
        desc += "<table>"
        for(var ele in shortcuts)
            desc += "<tr><td>" + ele + "</td><td>" + shortcuts[ele] + "</td></tr>"
        desc += "</table>"

        description = desc
    }

    Keys.onPressed:
        if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
            accept()

    onAccepted: storeState()
    onRejected: closed()

    function display() {

        if(sh_notifier.isShown(area))
            show()
        else
            closed()
    }

    function storeState() {

        if(alwaysDoThis && area != "")
            sh_notifier.setHidden(area)

        closed()

    }

}

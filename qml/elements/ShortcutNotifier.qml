import QtQuick 2.3

import "./"

CustomConfirm {

	signal closed()

	fillAnchors: parent

	header: "Shortcuts"
	property string intro: "You can use the following shortcuts for navigation:"
	property var shortcuts: ({})
	property string area: ""

	actAsErrorMessage: true
	rejectbuttontext: "Got it!"
	showDontAskAgain: true
	customisedDontAskAgainMessage: "Don't show again"
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
	onRejected: storeState()

	function storeState() {

		if(alwaysDoThis && area != "")
			sh_notifier.setHidden(area)

		closed()

	}

}

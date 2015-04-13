import QtQuick 2.3;

Item {

	id: scrollbar;

	height: (handleSize + 2 * (backScrollbar.border.width +1));
	visible: (flickable.visibleArea.widthRatio < 1.0);

	anchors {
		left: flickable.left;
		right: flickable.right;
		bottom: flickable.bottom;
		margins: 1;
	}

	property Flickable flickable: null;
	property int handleSize: 8;

	property real opacityVisible: 0.8
	property real opacityHidden: 0.1

	signal scrollFinished();

	Binding {
		target: handle;
		property: "x";
		value: (flickable.contentX * clicker.drag.maximumX / (flickable.contentWidth - flickable.width));
		when: (!clicker.drag.active);
	}

	Binding {
		target: flickable;
		property: "contentX";
		value: (handle.x * (flickable.contentWidth - flickable.width) / clicker.drag.maximumX);
		when: (clicker.drag.active || clicker.pressed);
	}

	Rectangle {
		id: backScrollbar;
		antialiasing: true;
		color: Qt.rgba(0, 0, 0, 0.2);
		anchors.fill: parent;
	}

	Item {

		id: groove;
		clip: true;

		anchors {
			fill: parent;
			topMargin: (backScrollbar.border.width +1);
			leftMargin: (backScrollbar.border.width +1);
			rightMargin: (backScrollbar.border.width +1);
			bottomMargin: (backScrollbar.border.width +1);
		}

		MouseArea {

			id: clicker;

			anchors.fill: parent;
			cursorShape: (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor)
			hoverEnabled: true

			drag {
				target: handle;
				minimumX: 0;
				maximumX: (groove.width - handle.width);
				axis: Drag.XAxis;
			}

			onClicked: flickable.contentX = (mouse.x / groove.width * (flickable.contentWidth - flickable.width));
			onReleased: scrollFinished();

		}

		Item {

			id: handle;

			width: Math.max (20, (flickable.visibleArea.widthRatio * groove.width));

			anchors {
				top: parent.top;
				bottom: parent.bottom;
			}

			Rectangle {

				id: backHandle;

				anchors.fill: parent;
				color: ((clicker.containsMouse || clicker.pressed) ? "black" : "black");
				border.color: "white"
				border.width: 1
				opacity: ((clicker.containsMouse || clicker.pressed) ? opacityVisible : opacityHidden);

				Behavior on opacity { NumberAnimation { duration: 50; } }

			}
		}
	}
}

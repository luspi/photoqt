import QtQuick 2.3
import QtQml.Models 2.1

import "../elements"

/*******************************************************************/
/* Code inspired by: http://qt-project.org/forums/viewthread/45015 */
/*******************************************************************/

Rectangle {

	id: rect

	width: 600
	height: 450

	clip: true
	color: "#00000000"

	property int binaryX: 0
	property int descriptionX: 0
	property int textEditWidth: 0

	property var modelData: []
	signal requestUpdateModelData()

	ListView {

		id: root

		width: parent.width
		height: parent.height

		orientation: ListView.Vertical
		boundsBehavior: ListView.StopAtBounds
		displaced: Transition { NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad } }

		PropertyAnimation {

			id: ani

			property bool bForward: false
			target: root
			property: "contentY"

			from: root.contentY
			to: bForward ? root.contentHeight-root.height : 0
			duration: bForward ? (root.contentHeight-root.height-root.contentY)*2 : root.contentY*2

		}

		cacheBuffer: model.count*1000
		spacing: 10

		property bool forward: false
		property bool dragActive: false

		model: DelegateModel {

			id: visualModel

			model: ListModel { id: contextmodel; }

			delegate: MouseArea {

				id: delegateRoot

				x: 5

				width: root.width-10
				height: 30

				property int posInList: _posInList

				property int visualIndex: DelegateModel.itemsIndex
				drag.target: icon


				// Containing rectangle
				Rectangle {

					id: icon

					width: root.width-10
					height: 30

					radius: 5
					color: "#88000000"

					// These are needed, otherwise the rectangle wont "snap back" into its spot, but stays exactly were it is left
					anchors {
						horizontalCenter: parent.horizontalCenter;
						verticalCenter: parent.verticalCenter
					}

					// Before saving all data, we request them to update us with their current setting
					Connections {
						target: rect
						onRequestUpdateModelData: updateModelData(delegateRoot.posInList,delegateRoot.visualIndex, binary.text,description.text,quit.checkedButton)
					}

					Row {

						spacing: 5

						// Just some spacing at the beginning
						Rectangle { width: 1; height: 1; color: "#00000000" }

						// A label for dragging the rectangle
						Text {

							id: dragger

							height: icon.height
							verticalAlignment: Qt.AlignVCenter
							text: "Click here to drag"

							color: "white"

							MouseArea {
								anchors.fill: parent
								cursorShape: Qt.SizeAllCursor
								acceptedButtons: Qt.NoButton
							}
						}

						// Seperate from rest by thin white line
						Rectangle {

							id: seperator1

							color: "white"
							height: parent.height-4
							y: 2
							width: 1
						}

						// Another sub-element for editing the executable
						TabOtherContextTextEdit {

							id: binary

							y: 3
							width: (root.width-(dragger.width+seperator1.width+quit.width+seperator2.width+del.width+10*parent.spacing))/2
							height: parent.height-6

							text: _binary

							// We use this in order to position the header labels in the upper class (file: TabOther.qml)
							onXChanged: binaryX = binary.x
							onWidthChanged: textEditWidth = binary.width

						}

						// Another sub-element for editing the menu text
						TabOtherContextTextEdit {

							id: description

							y: 3
							width: (root.width-(dragger.width+seperator1.width+quit.width+seperator2.width+del.width+10*parent.spacing))/2
							height: parent.height-6

							text: _description

							// As the width of both textedits is the same, we don't need to check for it here
							onXChanged: descriptionX = description.x

						}

						// Quit after executing shortcut?
						CustomCheckBox {

							id: quit

							y: (parent.height-height)/2

							text: "quit"

							checkedButton: _quit

						}

						// Another small seperator
						Rectangle {

							id: seperator2

							color: "white"
							height: parent.height-4
							y: 2
							width: 1
						}

						// And a label for deleting the current item
						Text {

							id: del

							y: (parent.height-height)/2

							color: "white"
							text: "x"

							MouseArea {
								anchors.fill: parent
								cursorShape: Qt.PointingHandCursor
								onClicked: deleteItem(visualIndex)
							}

						}
					}


					Drag.active: delegateRoot.drag.active
					Drag.source: delegateRoot
					Drag.hotSpot.x: width/2
					Drag.hotSpot.y: height/2

					states: [
						State {
							when: icon.Drag.active
							ParentChange {
								target: icon
								parent: root
							}

							AnchorChanges {
								target: icon;
								anchors.horizontalCenter: undefined;
								anchors.verticalCenter: undefined
							}
						}
					]
				}

				DropArea {
					id:dropArea
					anchors { fill: parent; margins: 5 }
					onEntered:visualModel.items.move(drag.source.visualIndex, delegateRoot.visualIndex)
				}

				onReleased: ani.stop()

				onMouseYChanged: {

					root.dragActive = true

					if(mapToItem(root, mouseX, mouseY).y > root.height-5) {

						if(!root.atYEnd) {
							ani.bForward = true
							ani.start()
						}

					} else if(mapToItem(root, mouseX, mouseY).y < 5) {

						if(!root.atYBeginning) {
							ani.bForward = false
							ani.start()
						}

					} else if (mapToItem(root, mouseX, mouseY).y >= 5 && mapToItem(root, mouseX, mouseY).y <= root.height-5)
						ani.stop()

				}
			}
		}
	}

	// Update the model data (requested right before saving the data)
	function updateModelData(pos, posView, bin, desc, q) {
		modelData[pos] = {"posInList" : pos , "posInView" : posView , "binary" : bin, "description" : desc, "quit" : q }
	}

	// Delete an item
	function deleteItem(index) {
		contextmodel.remove(index)
	}

	// Add an item
	function addItem(bin, desc, q) {
		var pos = contextmodel.count
		modelData[pos] = {"posInList" : pos , "posInView" : pos , "binary" : bin, "description" : desc, "quit" : q }
		contextmodel.append({_posInList : pos, _binary: bin, _description: desc, _quit: q })
	}

	// Add an empty item
	function addNewItem() {
		contextmodel.append({_binary: "executable", _description: "menu text", _quit: false })
	}


	// Load current items
	function setData() {
		contextmodel.clear()
		var con = getanddostuff.getContextMenu()
		for(var j = 0; j < con.length; j+=3)
			addItem(con[j],con[j+2],con[j+1]*1)
	}

	// Save current items
	function saveData() {
		requestUpdateModelData()
		getanddostuff.saveContextMenu(modelData)
	}

}

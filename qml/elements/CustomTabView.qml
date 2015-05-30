import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

TabView {

	id: view

	// subtab=false means, that the tabbar will cover the full width
	// subtab=true means, that the tabbar will cover half of the width, centered
	property bool subtab: false

	// The number of tabs in the tabview
	property int tabCount: 2

	style: TabViewStyle {

		// Some spacing between the elements
		frameOverlap: -8

		// Slightly darker overall background
		frame: Rectangle {
			color: subtab ? colour.subtab_bg_color : colour.tab_bg_color
		}

		// Invisible main background of tabbar
		tabBar: Rectangle {
			height: childrenRect.height
			width: subtab ? view.width/2 : view.width
			color: "#00000000"
		}

		// ALign tabs in center
		tabsAlignment: Qt.AlignHCenter

		// The tab
		tab: Rectangle {

			// The color depending on state
			color: (styleData.selected || styleData.pressed) ? colour.tab_color_selected : (styleData.hovered ? colour.tab_color_active : colour.tab_color_inactive)

			// Width and Height
			implicitWidth: (subtab ? view.width*2/5 : view.width)/tabCount
			implicitHeight: 30

			// The tab text
			Text {
				color: (styleData.selected || styleData.pressed) ? colour.tab_text_selected : (styleData.hovered ? colour.tab_text_active : colour.tab_text_inactive)
				font.bold: true
				font.pointSize: global_fontsize_normal
				anchors.centerIn: parent
				text: styleData.title
			}
			// Line at TOP of tab (sub-tab only)
			Rectangle {
				x: 0
				y: 0
				width: parent.width
				height: 1
				color: colour.subtab_line_top
				visible: subtab
			}
			// Line at BOTTOM of tab (sub-tab only)
			Rectangle {
				x: 0
				y: parent.height-1
				width: parent.width
				height: 1
				color: colour.subtab_line_bottom
				visible: subtab
			}
			// Change cursor to pointing hand
			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: view.currentIndex = styleData.index
			}
		}

	}

	function nextTab() {
		if(view.currentIndex < view.count-1)
			++view.currentIndex
	}
	function prevTab() {
		if(view.currentIndex > 0)
			--view.currentIndex
	}

}

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
//import QtQuick.Layouts 1.0

Menu {
	id: contextmenu

	style: MenuStyle {
		frame: menuFrame
		itemDelegate.background: menuHighlight
	}

	Component {
		id: menuFrame
		Rectangle {
			color: colour.menu_frame
		}
	}
	Component {
		id: menuHighlight
		Rectangle {
			color: (styleData.selected ? colour.menu_bg_highlight : colour.menu_bg)
		}
	}
}

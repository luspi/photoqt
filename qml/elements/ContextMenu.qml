import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
//import QtQuick.Layouts 1.0

Menu {
	id: contextmenu

	style: MenuStyle {
		frame: Rectangle { color: colour.menu_frame }
		itemDelegate.background: Rectangle { color: (styleData.selected ? colour.menu_bg_highlight : colour.menu_bg) }
		itemDelegate.label: Text { color: colour.menu_text; text: styleData.text }
	}
}

import QtQuick 2.3

Rectangle {

	id: background
	color: "#AA000000"

    // Show thumbnail bar
	MouseArea {

        x: 0
        y: background.height-50

		width: background.width
		height: 50

		hoverEnabled: true

        onEntered:
            PropertyAnimation {
                    target:  thumbnailBar
                    property: (settings.value("Thumbnail/ThumbnailKeepVisible")*1 == 0 ? "y" : "");
                    to: background.height-settings.value("Thumbnail/ThumbnailSize")*1-thumbnailbarheight_addon
            }
	}

    // Hide thumbnail bar
	MouseArea {

        x: 0
        y: 0

		width: background.width
		height: background.height-settings.value("Thumbnail/ThumbnailSize")*1-thumbnailbarheight_addon-50

		hoverEnabled: true

		onEntered:
			PropertyAnimation {
				target: thumbnailBar
				property: "y"
				to: background.height-(settings.value("Thumbnail/ThumbnailKeepVisible")*1 ? settings.value("Thumbnail/ThumbnailSize")*1+thumbnailbarheight_addon : 0)
		}
	}

}

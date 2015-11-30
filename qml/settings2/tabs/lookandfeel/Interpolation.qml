import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Interpolation"

		}

		EntrySetting {

			Row {

				spacing: 10

				Text {

					color: colour.text
					text: qsTr("Threshold:")
					font.pointSize: 10
					y: (parent.height-height)/2

				}

				CustomSpinBox {

					id: interpolationthreshold

					width: 100

					minimumValue: 0
					maximumValue: 99999

					stepSize: 5

					value: 100
					suffix: " px"

				}

				Rectangle { color: "transparent"; width: 1; height: 1; }
				Rectangle { color: "transparent"; width: 1; height: 1; }
				Rectangle { color: "transparent"; width: 1; height: 1; }

				CustomCheckBox {

					id: interpolationupscale
					text: qsTr("Use 'Nearest Neighbour' algorithm for upscaling")

				}

			}

		}

	}

	function setData() {
		interpolationthreshold.value = settings.interpolationNearestNeighbourThreshold
		interpolationupscale.checkedButton = settings.interpolationNearestNeighbourUpscale
	}

	function saveData() {
		settings.interpolationNearestNeighbourThreshold = interpolationthreshold.value
		settings.interpolationNearestNeighbourUpscale = interpolationupscale.checkedButton
	}

}

import QtQuick 2.9

Item {

    id: facetracker_top

    property string filename: ""
    property var faceTags: []
    property int indexOfLabelHovered: -1

    onFilenameChanged: {
        if(PQSettings.peopleTagInMetaDisplay)
            faceTags = handlingFaceTags.getFaceTags(filename)
    }

    Repeater {

        id: repeat

        model: faceTags.length/6

        delegate: Item {

            id: deleg

            x: facetracker_top.width*faceTags[6*index+1]
            y: facetracker_top.height*faceTags[6*index+2]
            width: facetracker_top.width*faceTags[6*index+3]
            height: facetracker_top.height*faceTags[6*index+4]

            property bool labelMouseHovered: false
            property bool fullMouseHovered: false

            visible: opacity>0
            opacity: (PQSettings.peopleTagInMetaAlwaysVisible ||
                      (PQSettings.peopleTagInMetaIndependentLabels && labelMouseHovered) ||
                      (!PQSettings.peopleTagInMetaIndependentLabels && !PQSettings.peopleTagInMetaHybridMode && fullMouseHovered) ||
                      (PQSettings.peopleTagInMetaHybridMode && fullMouseHovered && (indexOfLabelHovered == index || indexOfLabelHovered == -1))) ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Rectangle {
                visible: PQSettings.peopleTagInMetaBorderAroundFace
                anchors.fill: parent
                color: "transparent"
                border.width: PQSettings.peopleTagInMetaBorderAroundFaceWidth/facetracker_top.scale
                border.color: PQSettings.peopleTagInMetaBorderAroundFaceColor
            }

            // This is the background of the text (semi-transparent black rectangle)
            Rectangle {
                x: (parent.width-width)/2
                y: parent.height
                width: faceLabel.width+8
                height: faceLabel.height+8
                color: "#bb000000"

                // This holds the person's name
                Text {
                    id: faceLabel
                    x: 4
                    y: 4
                    font.pointSize: PQSettings.peopleTagInMetaFontSize/facetracker_top.scale
                    color: "white"
                    text: " "+faceTags[6*index+5]+" "
                }

            }

            Connections {

                target: variables

                onMousePosChanged:
                    deleg.handleMouseMove()

            }

            function handleMouseMove() {

                var p = deleg.mapFromItem(bgimage, variables.mousePos.x, variables.mousePos.y)
                deleg.labelMouseHovered = !(p.x < 0 || p.x > deleg.width || p.y < 0 || p.y > deleg.height)
                if(deleg.labelMouseHovered)
                    facetracker_top.indexOfLabelHovered = index
                else if(!deleg.labelMouseHovered && facetracker_top.indexOfLabelHovered == index)
                    facetracker_top.indexOfLabelHovered = -1

                p = facetracker_top.mapFromItem(bgimage, variables.mousePos.x, variables.mousePos.y)
                deleg.fullMouseHovered = !(p.x < 0 || p.x > facetracker_top.width || p.y < 0 || p.y > facetracker_top.height)

            }

        }

    }

    Connections {
        target: PQSettings
        onPeopleTagInMetaDisplayChanged:
            faceTags = (PQSettings.peopleTagInMetaDisplay ? handlingFaceTags.getFaceTags(filename) : [])

    }

}

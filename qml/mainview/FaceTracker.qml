import QtQuick 2.5

Item {

    id: top

    // This displays info about people/faces in the current photo (stored in metadata)
    Repeater {

        // The list contains 5 entries for each tag
        model: variables.peopleFaceTags.length/5

        delegate: Item {

            id: labelitemdelegate

            // This is set to true/false depending on whether the mouse is hovering this face tag
            property bool showThisLabel: false

            visible: (opacity!=0)
            opacity: (settings.peopleTagInMetaAlwaysVisible||showThisLabel ? 1 : 0)
            Behavior on opacity { NumberAnimation { duration: 100 } }

            // The first two values are x and y ratios
            x: imageContainer.width*variables.peopleFaceTags[5*index]
            y: imageContainer.height*variables.peopleFaceTags[5*index+1]
            // The folowing two entries are the width and height ratios
            width: imageContainer.width*variables.peopleFaceTags[5*index+2]
            height: imageContainer.height*variables.peopleFaceTags[5*index+3]

            // The border around the face
            Rectangle {
                visible: settings.peopleTagInMetaShowBorderAroundFace
                anchors.fill: parent
                color: "transparent"
                border.width: 2
                border.color: "red"
                opacity: 0.3
            }

            // This is the background of the text (semi-transparent black rectangle)
            Rectangle {
                x: (parent.width-width)/2
                y: parent.height
                width: faceLabel.width
                height: faceLabel.height
                color: "black"
                opacity: 0.8
            }

            // This holds the person's name
            Text {
                id: faceLabel
                font.pointSize: settings.peopleTagInMetaFontSize/(settings.peopleTagInMetaLabelsIgnoreScale ? imageContainer.scale : 1)
                x: (parent.width-width)/2
                y: parent.height
                color: "white"
                text: " "+variables.peopleFaceTags[5*index+4]+" "
            }

            // If the mouse position has changed, update visibility of labels
            Connections {

                target: variables

                onMouseCurrentPosChanged: {

                    // Consider only this individual label
                    if(settings.peopleTagInMetaIndependentLabels) {

                        var p = labelitemdelegate.mapFromItem(mainwindow, variables.mouseCurrentPos.x, variables.mouseCurrentPos.y)
                        labelitemdelegate.showThisLabel = !(p.x < 0 || p.x > labelitemdelegate.width || p.y < 0 || p.y > labelitemdelegate.height)

                    // Consider the image as a whole
                    } else {

                        var p = imageContainer.mapFromItem(mainwindow, variables.mouseCurrentPos.x, variables.mouseCurrentPos.y)
                        labelitemdelegate.showThisLabel = !(p.x < 0 || p.x > imageContainer.width || p.y < 0 || p.y > imageContainer.height)

                    }

                }

            }

        }

    }

    // If the tags for the persons are dis-/enabled, update the visibility of the labels
    Connections {

        target: settings

        onPeopleTagInMetaDisplayChanged: {
            variables.peopleFaceTags = settings.peopleTagInMetaDisplay ?
                        getpeopletag.getPeopleLocations(variables.currentDir+"/"+variables.currentFileWithoutExtras) :
                        []

        }

    }

}

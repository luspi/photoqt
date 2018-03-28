import QtQuick 2.5

Item {

    id: top

    Connections {
        target: variables
        onPeopleFaceTagsChanged: resetModel()
        onCurrentFileChanged: resetModel()
    }

    function resetModel() {
        repeatermodel.clear()
        for(var i = 0; i < variables.peopleFaceTags.length/6; ++i)
            repeatermodel.append({"index" : i})
    }

    // This displays info about people/faces in the current photo (stored in metadata)
    Repeater {

        id: repeat

        // The list contains 6 entries for each tag
        model: ListModel{ id: repeatermodel }

        delegate: Item {

            id: labelitemdelegate

            // This is set to true/false depending on whether the mouse is hovering this face tag
            property bool showThisLabel: false
            property bool mouseInsideThisLabel: false
            onMouseInsideThisLabelChanged:
                variables.mouseHoveringFaceTag = mouseInsideThisLabel

            visible: (opacity!=0)
            opacity: (settings.peopleTagInMetaAlwaysVisible||variables.taggingFaces||showThisLabel ? 1 : 0)
            Behavior on opacity { NumberAnimation { duration: 100 } }

            // The first two values are x and y ratios
            x: imageContainer.width*variables.peopleFaceTags[6*index+1]
            y: imageContainer.height*variables.peopleFaceTags[6*index+2]
            // The folowing two entries are the width and height ratios
            width: imageContainer.width*variables.peopleFaceTags[6*index+3]
            height: imageContainer.height*variables.peopleFaceTags[6*index+4]

            property int myIndex: variables.peopleFaceTags[6*index]

            // The border around the face
            Rectangle {
                visible: settings.peopleTagInMetaBorderAroundFace
                anchors.fill: parent
                color: (mouseInsideThisLabel&&variables.taggingFaces ? "#bb000000" : "transparent")
                border.width: settings.peopleTagInMetaBorderAroundFaceWidth/imageContainer.scale
                border.color: settings.peopleTagInMetaBorderAroundFaceColor
                Text {
                    visible: (mouseInsideThisLabel&&variables.taggingFaces)
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 10/imageContainer.scale
                    font.bold: true
                    color: "white"
                    text: em.pty+qsTr("Delete")
                }
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
                font.pointSize: settings.peopleTagInMetaFontSize/imageContainer.scale
                x: (parent.width-width)/2
                y: parent.height
                color: "white"
                text: " "+variables.peopleFaceTags[6*index+5]+" "
            }

            // If the mouse position has changed, update visibility of labels
            Connections {

                target: variables

                onMouseCurrentPosChanged: {

                    var p = labelitemdelegate.mapFromItem(mainwindow, variables.mouseCurrentPos.x, variables.mouseCurrentPos.y)
                    labelitemdelegate.mouseInsideThisLabel = !(p.x < 0 || p.x > labelitemdelegate.width || p.y < 0 || p.y > labelitemdelegate.height)

                    // Consider only this individual label
                    if(settings.peopleTagInMetaIndependentLabels)
                        labelitemdelegate.showThisLabel = labelitemdelegate.mouseInsideThisLabel
                    // Consider the image as a whole
                    else {
                        p = imageContainer.mapFromItem(mainwindow, variables.mouseCurrentPos.x, variables.mouseCurrentPos.y)
                        labelitemdelegate.showThisLabel = !(p.x < 0 || p.x > imageContainer.width || p.y < 0 || p.y > imageContainer.height)
                    }

                }

                onMousePressedChanged: {
                    if(labelitemdelegate.mouseInsideThisLabel&&variables.taggingFaces) {
                        var newfacedata = []
                        for(var i = 0; i < variables.peopleFaceTags.length/6; ++i) {
                            if(variables.peopleFaceTags[6*i] != labelitemdelegate.myIndex) {
                                newfacedata.push(variables.peopleFaceTags[6*i])
                                newfacedata.push(variables.peopleFaceTags[6*i+1])
                                newfacedata.push(variables.peopleFaceTags[6*i+2])
                                newfacedata.push(variables.peopleFaceTags[6*i+3])
                                newfacedata.push(variables.peopleFaceTags[6*i+4])
                                newfacedata.push(variables.peopleFaceTags[6*i+5])
                            }
                        }
                        managepeopletags.setFaceTags(variables.currentDir+"/"+variables.currentFileWithoutExtras, newfacedata)
                        variables.peopleFaceTags = newfacedata
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
                        managepeopletags.getFaceTags(variables.currentDir+"/"+variables.currentFileWithoutExtras) :
                        []

        }

    }

}

import QtQuick 2.5

Item {

    id: top

    function resetModel() {
        repeatermodel.clear()
        for(var i = 0; i < variables.peopleFaceTags.length/6; ++i)
            repeatermodel.append({"index" : i})
    }

    property bool mouseInsideFullImage: false
    property int mouseOverLabelWithIndex: -1

    // This displays info about people/faces in the current photo (stored in metadata)
    Repeater {

        id: repeat

        // The list contains 6 entries for each tag
        model: ListModel{ id: repeatermodel }

        delegate: Item {

            id: labelitemdelegate

            // This is set to true/false depending on whether the mouse is hovering this face tag
            property bool mouseInsideThisLabel: false
            onMouseInsideThisLabelChanged: {
                variables.mouseHoveringFaceTag = mouseInsideThisLabel
                if(mouseInsideThisLabel)
                    mouseOverLabelWithIndex = index
                else {
                    if(mouseOverLabelWithIndex == index)
                        mouseOverLabelWithIndex = -1
                }
            }

            visible: (opacity!=0)
            opacity: ((settings.peopleTagInMetaAlwaysVisible || variables.taggingFaces ||
                      (settings.peopleTagInMetaIndependentLabels && mouseInsideThisLabel) ||
                      (!settings.peopleTagInMetaIndependentLabels && !settings.peopleTagInMetaHybridMode && mouseInsideFullImage) ||
                      (settings.peopleTagInMetaHybridMode && mouseInsideFullImage &&
                                    (mouseOverLabelWithIndex==index || mouseOverLabelWithIndex == -1))) ? 1 : 0)
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
                visible: settings.peopleTagInMetaBorderAroundFace||variables.taggingFaces
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
                    text: em.pty+qsTranslate("PeopleFaceTags", "Delete")
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

            property point mousePressStarted: Qt.point(-1,-1)

            // If the mouse position has changed, update visibility of labels
            Connections {

                target: variables

                onMouseCurrentPosChanged: {

                    handleMouseMove()
                }

                onMousePressedChanged: {

                    if(!imageContainer.visible) return

                    if(variables.mousePressed) {
                        labelitemdelegate.mousePressStarted = variables.mouseCurrentPos
                    } else {
                        var dx = Math.abs(variables.mouseCurrentPos.x-labelitemdelegate.mousePressStarted.x)
                        var dy = Math.abs(variables.mouseCurrentPos.y-labelitemdelegate.mousePressStarted.y)
                        if(labelitemdelegate.mouseInsideThisLabel&&variables.taggingFaces&&dx < 20 && dy < 20) {
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

            function handleMouseMove() {
                if(!imageContainer.visible) return

                var p = labelitemdelegate.mapFromItem(mainwindow, variables.mouseCurrentPos.x, variables.mouseCurrentPos.y)
                labelitemdelegate.mouseInsideThisLabel = !(p.x < 0 || p.x > labelitemdelegate.width || p.y < 0 || p.y > labelitemdelegate.height)

                p = imageContainer.mapFromItem(mainwindow, variables.mouseCurrentPos.x, variables.mouseCurrentPos.y)
                mouseInsideFullImage = !(p.x < 0 || p.x > imageContainer.width || p.y < 0 || p.y > imageContainer.height)

            }

            Connections {
                target: imageContainer
                onHideOther: handleMouseMove()
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

    Connections {
        target: variables
        onPeopleFaceTagsChanged: resetModel()
        onCurrentFileChanged: resetModel()
    }

}

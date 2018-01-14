import QtQuick 2.5
import QtQuick.Controls 1.4

import "../elements"
import "../loadfile.js" as Load

FadeInTemplate {

    id: filter_top

    heading: ""
    showSeperators: false

    marginTopBottom: (background.height-400)/2
    clipContent: false

    content: [

        // Heading
        Text {
            text: qsTr("Filter images in current directory")
            color: colour.text
            font.bold: true
            font.pointSize: 30
            x: (filter_top.contentWidth-width)/2
        },

        // This one (and the following ones) are simply space adders...
        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        Text {
            text: qsTr("Enter here the term you want to filter the images by. Separate multiple terms by a space.")
            x: (filter_top.contentWidth-width)/2
            color: colour.text
            font.pointSize: 12
        },

        Text {
            text: qsTr("If you want to limit a term to file extensions, prepend a dot '.' to the term.")
            x: (filter_top.contentWidth-width)/2
            color: colour.text
            font.pointSize: 12
        },

        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        CustomLineEdit {

            id: term
            width: Math.min(filter_top.contentWidth/2,500)
            height: 35
            x: (filter_top.contentWidth-width)/2

        },

        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        // Two main buttons
        Rectangle {

            color: "#00000000"

            x: (filter_top.contentWidth-width)/2
            width: childrenRect.width
            height: childrenRect.height

            Row {

                spacing: 5

                Rectangle {
                    color: "#00000000"
                    width: 10+remove.width
                    height: 1
                }

                CustomButton {
                    id: enter
                    //: As in 'Go ahead and filter images'
                    text: qsTr("Filter")
                    fontsize: 15
                    onClickedButton: {
                        verboseMessage("Filter","Accept filter")
                        simulateEnter()
                    }
                }

                CustomButton {
                    text: qsTr("Cancel")
                    fontsize: 15
                    onClickedButton: {
                        verboseMessage("Filter","Cancel filter")
                        hide()
                    }
                }

                Rectangle {
                    color: "#00000000"
                    width: 10
                    height: 1
                }

                CustomButton {
                    id: remove
                    text: qsTr("Remove Filter")
                    fontsize: 13
                    enabled: variables.filter != ""
                    y: (parent.height-height)/2
                    onClickedButton: {
                        verboseMessage("Filter","Remove filter")
                        variables.filter = ""
                        Load.loadFile(variables.currentDir+"/"+variables.currentFile, "", true)
                        hide()
                    }
                }

            }
        }
    ]

    Connections {
        target: call
        onFilterShow: {
            if(variables.currentFile == "") return
            showFilter()
        }
        onShortcut: {
            if(!filter_top.visible) return
            if(sh == "Escape")
                hide()
            else if(sh == "Enter" || sh == "Return")
                simulateEnter()
        }
        onCloseAnyElement:
            if(filter_top.visible)
                hide()
    }

    // These two 'simulate' functions can be called via shortcuts
    function simulateEnter() {
        verboseMessage("Filter::simulateEnter()","")
        variables.filter = term.getText()
        var newfilename = Load.getFilenameMatchingFilter(term.getText())
        if(newfilename == "")
            variables.filterNoMatch = true
        else
            Load.loadFile(variables.currentDir+"/"+newfilename, term.getText(), true)
        hide()
    }

    function showFilter() {
        verboseMessage("Filter::showFilter()","")
        term.text = variables.filter
        term.forceActiveFocus()
        term.selectAll()
        show()
    }
}

import QtQuick 2.6

Item {

    property var elementssetup: []

    // The loaded elements connect to these signals to show/hide
    signal openfileShow()
    signal openfileHide()
    signal thumbnailsShow()
    signal thumbnailsHide()
    signal thumbnailsLoadDirectory(var filename, var filter)
    signal loadNext()
    signal loadPrev()

    property var whatisshown: ({"thumbnails" : false,
                               "openfile" : false})

    // Load and show a component
    function show(component) {

        if(component == "openfile") {
            if(elementssetup.indexOf(component) < 0) {
                openfile.source = "openfile/OpenFile.qml"
                elementssetup.push(component)
            }
            openfileShow()
            whatisshown["openfile"] = true
        } else if(component == "thumbnails") {
            if(elementssetup.indexOf(component) < 0) {
                thumbnails.source = "mainview/Thumbnails.qml"
                elementssetup.push(component)
            }
            thumbnailsShow()
            whatisshown["thumbnails"] = true
        }

    }

    // Hide a component
    function hide(component) {
        if(component == "openfile") {
            openfileHide()
            whatisshown["openfile"] = false
        } else if(component == "thumbnails") {
            thumbnailsHide()
            whatisshown["thumbnails"] = false
        }
    }

    // Load some function
    function load(func) {

        if(func == "thumbnailLoadDirectory")
            thumbnailsLoadDirectory(variables.currentFile, variables.filter)
        else if(func == "loadnext")
            loadNext()
        else if(func == "loadprev")
            loadPrev()

    }

}

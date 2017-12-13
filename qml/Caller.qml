import QtQuick 2.6

Item {

    property var elementssetup: []

    // The loaded elements connect to these signals to show/hide
    signal openfileShow()
    signal openfileHide()

    // Load and show a component
    function show(component) {

        if(component == "openfile") {
            if(elementssetup.indexOf(component) < 0) {
                openfile.source = "openfile/OpenFile.qml"
                elementssetup.push(component)
            }
            openfileShow()

        }

    }

    // Hide a component
    function hide(component) {
        if(component == "openfile")
            openfileHide()
    }

}

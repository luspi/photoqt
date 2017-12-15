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

    signal settingsmanagerShow()
    signal settingsmanagerHide()
    signal settingsmanagerSave()
    signal settingsmanagerNextTab()
    signal settingsmanagerPrevTab()
    signal settingsmanagerGoToTab(var index)

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
        } else if(component == "settingsmanager") {
            if(elementssetup.indexOf(component) < 0) {
                settingsmanager.source = "settingsmanager/SettingsManager.qml"
                elementssetup.push(component)
            }
            settingsmanagerShow()
            whatisshown["settingsmanager"] = true
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
        } else if(component == "settingsmanager") {
            settingsmanagerHide()
            whatisshown["settingsmanager"] = false
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
        else if(func == "settingsmanagerSave")
            settingsmanagerSave()
        else if(func == "settingsmanagerNextTab")
            settingsmanagerNextTab()
        else if(func == "settingsmanagerPrevTab")
            settingsmanagerPrevTab()
        else if(func == "settingsmanagerPrevTab")
            settingsmanagerPrevTab()
        else if(func == "settingsmanagerGoToTab1")
            settingsmanagerGoToTab(0)
        else if(func == "settingsmanagerGoToTab2")
            settingsmanagerGoToTab(1)
        else if(func == "settingsmanagerGoToTab3")
            settingsmanagerGoToTab(2)
        else if(func == "settingsmanagerGoToTab4")
            settingsmanagerGoToTab(3)
        else if(func == "settingsmanagerGoToTab5")
            settingsmanagerGoToTab(4)
        else if(func == "settingsmanagerGoToTab6")
            settingsmanagerGoToTab(5)

    }

}

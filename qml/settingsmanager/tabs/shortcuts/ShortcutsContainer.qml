import QtQuick 2.4

Rectangle {

    id: shortcutscontainer

    color: "transparent"

    x: 5
    width: parent.width-10
    height: childrenRect.height

    // These are the ones that this element is responsible for
    property var allAvailableItems: []
    // This array is filled in the setData() function containing all commands of allAvailableItems
    property var allAvailableCommands: []

    property string category: ""

    // An external shortcut shows a TextEdit instead of a title to edit a custom command
    property bool external: false

    // A title above the two lists
    Text {
        id: heading
        x: (parent.width-width)/2
        color: colour.text
        font.bold: true
        text: category
    }

    // the two lists
    Row {

        id: rowabove

        y: heading.height+4
        spacing: 10

        // This is picked up by the children
        property int w: parent.width

        // The set shortcuts
        Set {
            id: set
            // The width is adjusted according to the width of the parent widget (above row)
            width: parent.w/2-5
        }

        // The available shortcuts
        Available {

            id: avail

            // The width is adjusted according to the width of the parent widget (above row)
            width: parent.w/2-5

            // This is set to the list by the setData() function
            shortcuts: []

        }

    }

    // Set the data
    function setData(shortcuts) {

        // Load available shortcuts if not loaded yet
        if(allAvailableCommands.length == 0) {

            // Filter out the keys for setData/saveData
            for(var k = 0; k < allAvailableItems.length; ++k)
                allAvailableCommands[allAvailableCommands.length] = allAvailableItems[k][0]

            if(external)
                avail.shortcuts = [["", qsTr("External")]]
            else
                // load the available shortcuts
                avail.shortcuts = allAvailableItems
        }

        // We use a temporary array because we'll sort the shortcuts according to their command first
        var shortcutsTmp = {}
        var shortcutsKeysTmp = []

        // Loop over all key shortcuts and filter out the ones we're interested in
        for(var i = 0; i < shortcuts.length; i+=3) {

            var sh = shortcuts[i]
            var close = shortcuts[i+1]
            var cmd = shortcuts[i+2]

            var ind = allAvailableCommands.indexOf(cmd)

            if(ind !== -1 || (external && cmd.slice(0,2) !== "__")) {

                if(!(cmd in shortcutsTmp)) {
                    shortcutsTmp[cmd] = []
                    shortcutsKeysTmp.push(cmd)
                }

                // Format: [desc, key, close, command]
                if(external)
                    shortcutsTmp[cmd].push([cmd, sh, close, cmd])
                else
                    shortcutsTmp[cmd].push([allAvailableItems[ind][1], sh, close, cmd])
            }

        }

        // Sort shortcuts commands
        shortcutsKeysTmp.sort()

        // The ones important for this element
        var setshortcuts = []

        // We have all key shortcuts first, sorted
        for(var key in shortcutsKeysTmp) {
            var curcmd = shortcutsKeysTmp[key];
            for(var l = 0; l < shortcutsTmp[curcmd].length; ++l)
                setshortcuts = setshortcuts.concat([shortcutsTmp[curcmd][l]])
        }

        // Update arrays
        set.setData(setshortcuts)

    }

    function saveData() {
        return set.saveData()
    }

}

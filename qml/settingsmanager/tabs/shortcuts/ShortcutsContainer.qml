import QtQuick 2.3

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
    function setData(key_shortcuts, mouse_shortcuts, touch_shortcuts) {

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
        var key__tmp = {}
        var key__tmp_keys = []

        // Loop over all key shortcuts and filter out the ones we're interested in
        for(var kkey in key_shortcuts) {

            var ind = allAvailableCommands.indexOf(key_shortcuts[kkey][1])

            if(ind !== -1 || (external && key_shortcuts[kkey][1].slice(0,2) !== "__")) {

                var k_cmd = key_shortcuts[kkey][1]
                // Format: [desc, key, close, command, type]
                if(!(k_cmd in key__tmp)) {
                    key__tmp[k_cmd] = []
                    key__tmp_keys = key__tmp_keys.concat(k_cmd)
                }

                if(external)
                    key__tmp[k_cmd].push([k_cmd,kkey,key_shortcuts[kkey][0], k_cmd, "key"])
                else
                    key__tmp[k_cmd].push([allAvailableItems[ind][1],kkey,key_shortcuts[kkey][0], k_cmd, "key"])
            }

        }

        // We use a temporary array because we'll sort the shortcuts according to their command first
        var mouse__tmp = {}
        var mouse__tmp_keys = []

        // Loop over all mouse shortcuts and filter out the ones we're interested in
        for(var mkey in mouse_shortcuts) {

            var ind = allAvailableCommands.indexOf(mouse_shortcuts[mkey][1])

            if(ind !== -1 || (external && mouse_shortcuts[mkey][1].slice(0,2) !== "__")) {

                var m_cmd = mouse_shortcuts[mkey][1]
                // Format: [desc, key, close, command, type]
                if(!(m_cmd in mouse__tmp)) {
                    mouse__tmp[m_cmd] = []
                    mouse__tmp_keys = mouse__tmp_keys.concat(m_cmd)
                }

                if(external)
                    mouse__tmp[m_cmd].push([m_cmd,mkey,mouse_shortcuts[mkey][0], m_cmd, "mouse"])
                else
                    mouse__tmp[m_cmd].push([allAvailableItems[ind][1],mkey,mouse_shortcuts[mkey][0], m_cmd, "mouse"])
            }

        }

        // We use a temporary array because we'll sort the shortcuts according to their command first
        var touch__tmp = {}
        var touch__tmp_keys = []

        // Loop over all touch shortcuts and filter out the ones we're interested in
        for(var tkey in touch_shortcuts) {

            var ind = allAvailableCommands.indexOf(touch_shortcuts[tkey][1])

            if(ind !== -1 || (external && touch_shortcuts[tkey][1].slice(0,2) !== "__")) {

                var t_cmd = touch_shortcuts[tkey][1]
                // Format: [desc, key, close, command, type]
                if(!(t_cmd in touch__tmp)) {
                    touch__tmp[t_cmd] = []
                    touch__tmp_keys = touch__tmp_keys.concat(t_cmd)
                }

                var p = tkey.split("::")
                var _key = p[0] + " fingers, " + p[1] + ": " + p[2]

                if(external)
                    touch__tmp[t_cmd].push([t_cmd,_key,touch_shortcuts[tkey][0], t_cmd, "touch"])
                else
                    touch__tmp[t_cmd].push([allAvailableItems[ind][1],_key,touch_shortcuts[tkey][0], t_cmd, "touch"])
            }

        }

        // Sort shortcuts commands
        key__tmp_keys.sort()
        mouse__tmp_keys.sort()
        touch__tmp_keys.sort()

        // The ones important for this element
        var setshortcuts = []

        // We have all key shortcuts first, sorted
        for(var key_k in key__tmp_keys) {
            var key_cur_key = key__tmp_keys[key_k];
            for(var l = 0; l < key__tmp[key_cur_key].length; ++l)
                setshortcuts = setshortcuts.concat([key__tmp[key_cur_key][l]])
        }
        // Then all mouse shortcuts, sorted
        for(var mouse_k in mouse__tmp_keys) {
            var mouse_cur_key = mouse__tmp_keys[mouse_k];
            for(var m = 0; m < mouse__tmp[mouse_cur_key].length; ++m)
                setshortcuts = setshortcuts.concat([mouse__tmp[mouse_cur_key][m]])
        }
        // And then all touch shortcuts, sorted
        for(var touch_k in touch__tmp_keys) {
            var touch_cur_key = touch__tmp_keys[touch_k];
            for(var n = 0; n < touch__tmp[touch_cur_key].length; ++n)
                setshortcuts = setshortcuts.concat([touch__tmp[touch_cur_key][n]])
        }

        // Update arrays
        set.setData(setshortcuts)

    }

    function saveData() {

        return set.getAllData()

    }

}

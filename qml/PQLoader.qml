import QtQuick 2.9

Item {

    id: load_top

    signal filedialogPassOn(var what, var param)
    signal metadataPassOn(var what, var param)

    function show(component) {

        ensureItIsReady(component)

        if(component == "filedialog")
            filedialogPassOn("show", undefined)

    }

    function passOn(component, what, param) {

        if(component == "metadata")
            metadataPassOn(what, param)

    }

    function passKeyEvent(component, key, mod) {

        ensureItIsReady(component)

        if(component == "filedialog")
            filedialogPassOn("keyevent", [key, mod])

    }

    function ensureItIsReady(component) {

        if(component == "filedialog") {

            if(PQSettings.openPopoutElement && filedialog.source != "filedialog/PQFileDialogPopout.qml")
                filedialog.source = "filedialog/PQFileDialogPopout.qml"

            else if(!PQSettings.openPopoutElement && filedialog.source != "filedialog/PQFileDialog.qml")
                filedialog.source = "filedialog/PQFileDialog.qml"

        } else if(component == "mainmenu") {

            if(PQSettings.mainMenuPopoutElement && mainmenu.source != "menumeta/PQMainMenuPopout.qml")
                mainmenu.source = "menumeta/PQMainMenuPopout.qml"

            else if(!PQSettings.mainMenuPopoutElement && mainmenu.source != "menumeta/PQMainMenu.qml")
                mainmenu.source = "menumeta/PQMainMenu.qml"

        } else if(component == "metadata") {

            if(PQSettings.metadataPopoutElement && metadata.source != "menumeta/PQMetaDataPopout.qml")
                metadata.source = "menumeta/PQMetaDataPopout.qml"

            else if(!PQSettings.metadataPopoutElement && metadata.source != "menumeta/PQMetaData.qml")
                metadata.source = "menumeta/PQMetaData.qml"

        }

    }

}

import QtQuick 2.9

Item {

    id: load_top

    signal filedialogPassOn(var what, var param)

    function show(component) {

        ensureItIsReady(component)

        if(component == "filedialog")
            filedialogPassOn("show", undefined)

    }

    function passKeyEvent(component, key, mod) {

        ensureItIsReady(component)

        if(component == "filedialog")
            filedialogPassOn("keyevent", [key, mod])

    }

    function ensureItIsReady(component) {
        if(component == "filedialog" && filedialog.status == Loader.Null) {
            filedialog.source = "mainwindow/PQFileDialog.qml"
        }
    }

}

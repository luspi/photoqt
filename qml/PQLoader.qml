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
        if(PQSettings.openPopoutElement) {
            if(component == "filedialog" && filedialog_popout.status == Loader.Null) {
                filedialog.source = ""
                filedialog_popout.source = "filedialog/PQFileDialogPopout.qml"
            }
        } else {
            if(component == "filedialog" && filedialog.status == Loader.Null) {
                filedialog.source = "filedialog/PQFileDialog.qml"
                filedialog_popout.source = ""
            }
        }
    }

}

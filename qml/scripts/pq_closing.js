function handleBeforeClosing() {

    // helps with deleting temporary animated image files on Windows at the end of function
//    if(handlingGeneral.amIOnWindows())
//        imageitem.resetImageView()

//    if(variables.chromecastConnected)
//        handlingchromecast.disconnectFromDevice()

//    if(variables.slideShowActive)
//        loader.passOn("slideshowcontrols", "quit", undefined)

//    filefoldermodel.advancedSortMainViewCANCEL()

//    if(PQSettings.interfaceSaveWindowGeometry) {
//        windowgeometry.mainWindowMaximized = (visibility==Window.Maximized)
//        windowgeometry.mainWindowGeometry = Qt.rect(toplevel.x, toplevel.y, toplevel.width, toplevel.height)
//    }
    if(PQCFileFolderModel.currentIndex > -1 && PQCSettings.interfaceRememberLastImage)
        PQCScriptsConfig.setLastLoadedImage(PQCFileFolderModel.currentFile)
    else
        PQCScriptsConfig.deleteLastLoadedImage()
//    handlingGeneral.cleanUpScreenshotsTakenAtStartup()

//    if(PQCScriptsConfig.amIOnWindows())
//        handlingFileDir.deleteTemporaryAnimatedImageFiles()

}

function quitPhotoQt() {
    handleBeforeClosing()
    Qt.quit()
}

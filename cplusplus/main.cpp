#include <QApplication>
#include "mainhandler.h"
#include "singleinstance/singleinstance.h"

int main(int argc, char *argv[]) {

    // We store this as a QString, as this way we don't have to explicitely cast VERSION to a QString below
    QString version = VERSION;

    // Set app name and version
    QApplication::setApplicationName("PhotoQt");
    QApplication::setApplicationVersion(version);

    // Create a new instance (includes handling of argc/argv)
    // This class ensures, that only one instance is running. If one is already running, we pass the commands to the main process and exit.
    // If no process is running yet, we create a LocalServer and continue below
    SingleInstance app(argc, argv);

    // Create a handler to manage the qml files
    MainHandler handle;

    // Register the qml types. This need to happen BEFORE creating the QQmlApplicationEngine!.
    handle.registerQmlTypes();

    // The qml engine. This needs to be created AFTER registering the qml types.
    QQmlApplicationEngine engine;
    engine.load(QUrl("qrc:/qml/mainwindow.qml"));

    // Pass the engine to the handler
    handle.setEngine(&engine);

    // Register the image providers
    handle.addImageProvider();

    // And execute
    return app.exec();

}

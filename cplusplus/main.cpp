#include <QApplication>
#include "mainhandler.h"

int main(int argc, char *argv[]) {

    // We store this as a QString, as this way we don't have to explicitely cast VERSION to a QString below
    QString version = VERSION;

    // Set app name and version
    QApplication::setApplicationName("PhotoQt");
    QApplication::setApplicationVersion(version);

    // The application instance
    QApplication app(argc, argv);

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

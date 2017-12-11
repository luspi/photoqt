#include "mainwindow.h"

MainWindow::MainWindow(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {

    this->engine = engine;

    // Add settings access to QML
    qmlRegisterType<Settings>("Settings", 1, 0, "Settings");
    qmlRegisterType<FileFormats>("FileFormats", 1, 0, "FileFormats");
    qmlRegisterType<Colour>("Colour", 1, 0, "Colour");

    this->engine->addImageProvider("thumb",new ImageProviderThumbnail);
    this->engine->addImageProvider("full",new ImageProviderFull);
    this->engine->addImageProvider("icon",new ImageProviderIcon);
    this->engine->addImageProvider("empty", new ImageProviderEmpty);
    this->engine->addImageProvider("hist", new ImageProviderHistogram);

}

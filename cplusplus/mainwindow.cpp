#include "mainwindow.h"

MainWindow::MainWindow(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {

    this->engine = engine;

    // Add settings access to QML
    qmlRegisterType<Settings>("Settings", 1, 0, "Settings");
    qmlRegisterType<FileFormats>("FileFormats", 1, 0, "FileFormats");
    qmlRegisterType<GetMetaData>("GetMetaData", 1, 0, "GetMetaData");
    qmlRegisterType<GetAndDoStuff>("GetAndDoStuff", 1, 0, "GetAndDoStuff");
    qmlRegisterType<ToolTip>("ToolTip", 1, 0, "ToolTip");
    qmlRegisterType<Colour>("Colour", 1, 0, "Colour");
    qmlRegisterType<ImageWatch>("ImageWatch", 1, 0, "ImageWatch");
    qmlRegisterType<ShareOnline::Imgur>("Imgur", 1, 0, "Imgur");
    qmlRegisterType<Clipboard>("Clipboard", 1, 0, "Clipboard");

    this->engine->addImageProvider("thumb",new ImageProviderThumbnail);
    this->engine->addImageProvider("full",new ImageProviderFull);
    this->engine->addImageProvider("icon",new ImageProviderIcon);
    this->engine->addImageProvider("empty", new ImageProviderEmpty);
    this->engine->addImageProvider("hist", new ImageProviderHistogram);

}

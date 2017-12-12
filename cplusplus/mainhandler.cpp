#include "mainhandler.h"

MainHandler::MainHandler(QObject *parent) : QObject(parent) {}

// Add settings/scripts access to QML
void MainHandler::registerQmlTypes() {
    qmlRegisterType<Settings>("PSettings", 1, 0, "PSettings");
    qmlRegisterType<FileFormats>("PFileFormats", 1, 0, "PFileFormats");
    qmlRegisterType<GetMetaData>("PGetMetaData", 1, 0, "PGetMetaData");
    qmlRegisterType<GetAndDoStuff>("PGetAndDoStuff", 1, 0, "PGetAndDoStuff");
    qmlRegisterType<ToolTip>("PToolTip", 1, 0, "PToolTip");
    qmlRegisterType<Colour>("PColour", 1, 0, "PColour");
    qmlRegisterType<ImageWatch>("PImageWatch", 1, 0, "PImageWatch");
    qmlRegisterType<ShareOnline::Imgur>("PImgur", 1, 0, "PImgur");
    qmlRegisterType<Clipboard>("PClipboard", 1, 0, "PClipboard");
}

// Add image providers to QML
void MainHandler::addImageProvider() {
    this->engine->addImageProvider("thumb",new ImageProviderThumbnail);
    this->engine->addImageProvider("full",new ImageProviderFull);
    this->engine->addImageProvider("icon",new ImageProviderIcon);
    this->engine->addImageProvider("empty", new ImageProviderEmpty);
    this->engine->addImageProvider("hist", new ImageProviderHistogram);
}

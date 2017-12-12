#include <QApplication>
#include "mainhandler.h"

int main(int argc, char *argv[]) {

    QApplication app(argc, argv);

    MainHandler handle;

    handle.registerQmlTypes();

    QQmlApplicationEngine engine;
    engine.load(QUrl("qrc:/qml/mainwindow.qml"));

    handle.setEngine(&engine);

    handle.addImageProvider();

    return app.exec();

}

#include <QApplication>
#include "mainhandler.h"

int main(int argc, char *argv[]) {

    QApplication app(argc, argv);

    MainWindow w;

    w.registerQmlTypes();

    QQmlApplicationEngine engine;
    engine.load(QUrl("qrc:/qml/mainwindow.qml"));

    w.setEngine(&engine);

    w.addImageProvider();

    return app.exec();

}

#include <QGuiApplication>
#include "mainwindow.h"

int main(int argc, char *argv[]) {

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine *engine = new QQmlApplicationEngine;
    engine->load(QUrl(QStringLiteral("qrc:/qml/mainwindow.qml")));

    MainWindow w(engine);

    int ret = app.exec();

    delete engine;

    return ret;
}

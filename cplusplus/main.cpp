#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "settings/settings.h"
#include "scripts/handlingfiledialog.h"
#include "scripts/handlinggeneral.h"
#include "scripts/localisation.h"
#include "scripts/imageproperties.h"
#include "scripts/imageformats.h"
#include "scripts/filewatcher.h"
#include "scripts/filefoldermodel.h"

#include "imageprovider/imageprovidericon.h"
#include "imageprovider/imageproviderthumb.h"
#include "imageprovider/imageproviderfull.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    // We store this as a QString, as this way we don't have to explicitely cast VERSION to a QString below
    QString version = VERSION;

    // Set app name and version
    QGuiApplication::setApplicationName("PhotoQt");
    QGuiApplication::setApplicationVersion(version);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/mainwindow.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    qmlRegisterType<PQSettings>("PQSettings", 1, 0, "PQSettings");
    qmlRegisterType<PQHandlingFileDialog>("PQHandlingFileDialog", 1, 0, "PQHandlingFileDialog");
    qmlRegisterType<PQHandlingGeneral>("PQHandlingGeneral", 1, 0, "PQHandlingGeneral");
    qmlRegisterType<PQLocalisation>("PQLocalisation", 1, 0, "PQLocalisation");
    qmlRegisterType<PQImageProperties>("PQImageProperties", 1, 0, "PQImageProperties");
    qmlRegisterType<PQImageFormats>("PQImageFormats", 1, 0, "PQImageFormats");
    qmlRegisterType<PQFileWatcher>("PQFileWatcher", 1, 0, "PQFileWatcher");

    qmlRegisterType<PQFileFolderModel>("PQFileFolderModel", 1, 0, "PQFileFolderModel");

    engine.addImageProvider("icon",new PQImageProviderIcon);
    engine.addImageProvider("thumb",new PQAsyncImageProviderThumb);
    engine.addImageProvider("full",new PQImageProviderFull);

    engine.load(url);

    return app.exec();
}

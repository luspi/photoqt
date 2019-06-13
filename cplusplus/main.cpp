#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>

#include "settings/settings.h"
#include "scripts/handlingfiledialog.h"
#include "scripts/handlinggeneral.h"
#include "scripts/handlingshortcuts.h"
#include "scripts/localisation.h"
#include "scripts/imageproperties.h"
#include "scripts/imageformats.h"
#include "scripts/filewatcher.h"
#include "scripts/filefoldermodel.h"
#include "singleinstance/singleinstance.h"
#include "scripts/windowgeometry.h"

#include "imageprovider/imageprovidericon.h"
#include "imageprovider/imageproviderthumb.h"
#include "imageprovider/imageproviderfull.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    PQSingleInstance app(argc, argv);

    if(app.exportAndQuit != "") {
        LOG << "export to: " << app.exportAndQuit.toStdString() << NL;
        std::exit(0);
    } else if(app.importAndQuit != "") {
        LOG << "import from: " << app.importAndQuit.toStdString() << NL;
        std::exit(0);
    }

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

    qmlRegisterType<PQHandlingFileDialog>("PQHandlingFileDialog", 1, 0, "PQHandlingFileDialog");
    qmlRegisterType<PQHandlingGeneral>("PQHandlingGeneral", 1, 0, "PQHandlingGeneral");
    qmlRegisterType<PQHandlingShortcuts>("PQHandlingShortcuts", 1, 0, "PQHandlingShortcuts");
    qmlRegisterType<PQLocalisation>("PQLocalisation", 1, 0, "PQLocalisation");
    qmlRegisterType<PQImageProperties>("PQImageProperties", 1, 0, "PQImageProperties");
    qmlRegisterType<PQImageFormats>("PQImageFormats", 1, 0, "PQImageFormats");
    qmlRegisterType<PQFileWatcher>("PQFileWatcher", 1, 0, "PQFileWatcher");
    qmlRegisterType<PQWindowGeometry>("PQWindowGeometry", 1, 0, "PQWindowGeometry");

    engine.rootContext()->setContextProperty("PQSettings", &PQSettings::get());

    qmlRegisterType<PQFileFolderModel>("PQFileFolderModel", 1, 0, "PQFileFolderModel");

    engine.addImageProvider("icon",new PQImageProviderIcon);
    engine.addImageProvider("thumb",new PQAsyncImageProviderThumb);
    engine.addImageProvider("full",new PQImageProviderFull);

    engine.load(url);

    return app.exec();
}

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>

#include "variables.h"
#include "startup.h"
#include "startup/exportimport.h"
#include "settings/settings.h"
#include "scripts/handlingfiledialog.h"
#include "scripts/handlinggeneral.h"
#include "scripts/handlingshortcuts.h"
#include "scripts/handlingfilemanagement.h"
#include "scripts/handlingmanipulation.h"
#include "scripts/handlingshareimgur.h"
#include "scripts/handlingwallpaper.h"
#include "scripts/handlingfacetags.h"
#include "scripts/handlingexternal.h"
#include "scripts/localisation.h"
#include "scripts/imageproperties.h"
#include "settings/imageformats.h"
#include "scripts/filewatcher.h"
#include "scripts/filefoldermodel.h"
#include "singleinstance/singleinstance.h"
#include "settings/windowgeometry.h"
#include "scripts/metadata.h"
#include "scripts/systemtrayicon.h"

#include "imageprovider/imageprovidericon.h"
#include "imageprovider/imageproviderthumb.h"
#include "imageprovider/imageproviderfull.h"
#include "imageprovider/imageproviderhistogram.h"

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#endif

#ifdef DEVIL
#include <IL/il.h>
#endif

int main(int argc, char **argv) {

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    PQSingleInstance app(argc, argv);

    // We store this as a QString, as this way we don't have to explicitely cast VERSION to a QString below
    QString version = VERSION;

    // Set app name and version
    QGuiApplication::setApplicationName("PhotoQt");
    QGuiApplication::setOrganizationName("");
    QGuiApplication::setOrganizationDomain("photoqt.org");
    QGuiApplication::setApplicationVersion(version);

    QGuiApplication::setQuitOnLastWindowClosed(true);

    if(app.exportAndQuit != "") {
        PQStartup::Export::perform(app.exportAndQuit);
        std::exit(0);
    } else if(app.importAndQuit != "") {
        PQStartup::Import::perform(app.importAndQuit);
        std::exit(0);
    }

#ifdef GM
    // Initialise Magick as early as possible
    Magick::InitializeMagick(*argv);
#endif

#ifdef DEVIL
    ilInit();
#endif

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/mainwindow.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    PQStartup::PQStartup();

    qmlRegisterType<PQHandlingFileDialog>("PQHandlingFileDialog", 1, 0, "PQHandlingFileDialog");
    qmlRegisterType<PQHandlingGeneral>("PQHandlingGeneral", 1, 0, "PQHandlingGeneral");
    qmlRegisterType<PQHandlingShortcuts>("PQHandlingShortcuts", 1, 0, "PQHandlingShortcuts");
    qmlRegisterType<PQHandlingFileManagement>("PQHandlingFileManagement", 1, 0, "PQHandlingFileManagement");
    qmlRegisterType<PQHandlingManipulation>("PQHandlingManipulation", 1, 0, "PQHandlingManipulation");
    qmlRegisterType<PQLocalisation>("PQLocalisation", 1, 0, "PQLocalisation");
    qmlRegisterType<PQImageProperties>("PQImageProperties", 1, 0, "PQImageProperties");
    qmlRegisterType<PQFileWatcher>("PQFileWatcher", 1, 0, "PQFileWatcher");
    qmlRegisterType<PQWindowGeometry>("PQWindowGeometry", 1, 0, "PQWindowGeometry");
    qmlRegisterType<PQMetaData>("PQCppMetaData", 1, 0, "PQCppMetaData");
    qmlRegisterType<PQHandlingShareImgur>("PQHandlingShareImgur", 1, 0, "PQHandlingShareImgur");
    qmlRegisterType<PQHandlingWallpaper>("PQHandlingWallpaper", 1, 0, "PQHandlingWallpaper");
    qmlRegisterType<PQHandlingFaceTags>("PQHandlingFaceTags", 1, 0, "PQHandlingFaceTags");
    qmlRegisterType<PQSystemTrayIcon>("PQSystemTrayIcon", 1, 0, "PQSystemTrayIcon");
    qmlRegisterType<PQHandlingExternal>("PQHandlingExternal", 1, 0, "PQHandlingExternal");

    engine.rootContext()->setContextProperty("PQSettings", &PQSettings::get());
    engine.rootContext()->setContextProperty("PQCppVariables", &PQVariables::get());
    engine.rootContext()->setContextProperty("PQImageFormats", &PQImageFormats::get());
    engine.rootContext()->setContextProperty("PQKeyPressChecker", &PQKeyPressChecker::get());

    qmlRegisterType<PQFileFolderModel>("PQFileFolderModel", 1, 0, "PQFileFolderModel");

    engine.addImageProvider("icon",new PQImageProviderIcon);
    engine.addImageProvider("thumb",new PQAsyncImageProviderThumb);
    engine.addImageProvider("full",new PQImageProviderFull);
    engine.addImageProvider("hist",new PQImageProviderHistogram);

    engine.load(url);

    app.rootQmlAddress = engine.rootObjects().at(0);

    return app.exec();

}

/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "passon.h"
#include "startup/startup.h"
#include "startup/validate.h"
#include "settings/settings.h"
#include "scripts/handlingfiledialog.h"
#include "scripts/handlinggeneral.h"
#include "scripts/handlingshortcuts.h"
#include "scripts/handlingfiledir.h"
#include "scripts/handlingmanipulation.h"
#include "scripts/handlingshareimgur.h"
#include "scripts/handlingwallpaper.h"
#include "scripts/handlingfacetags.h"
#include "scripts/handlingexternal.h"
#include "scripts/localisation.h"
#include "scripts/imageproperties.h"
#include "settings/imageformats.h"
#include "scripts/filewatcher.h"
#include "singleinstance/singleinstance.h"
#include "settings/windowgeometry.h"
#include "scripts/metadata.h"
#include "filefoldermodel/filefoldermodel.h"
#include "settings/shortcuts.h"
#include "logger.h"
#include "scripts/handlingchromecast.h"

#include "imageprovider/imageprovidericon.h"
#include "imageprovider/imageproviderthumb.h"
#include "imageprovider/imageproviderfull.h"
#include "imageprovider/imageproviderhistogram.h"

#ifdef GRAPHICSMAGICK
#include <GraphicsMagick/Magick++.h>
#endif

#ifdef IMAGEMAGICK
#include <Magick++.h>
#endif

#ifdef DEVIL
#include <IL/il.h>
#endif

int main(int argc, char **argv) {

    // needs to be set before Q*Application is created
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    // only a single instance (by default)
    PQSingleInstance app(argc, argv);

    // Set app information
    QApplication::setApplicationName("PhotoQt");
    QApplication::setOrganizationName("");
    QApplication::setOrganizationDomain("photoqt.org");
    QApplication::setApplicationVersion(VERSION);
    QApplication::setQuitOnLastWindowClosed(true);

    PQStartup startup;
    PQValidate validate;

    // handle export/import commands
    if(app.exportAndQuit != "") {
        startup.exportData(app.exportAndQuit);
        std::exit(0);
    } else if(app.importAndQuit != "") {
        startup.importData(app.importAndQuit);
        std::exit(0);
    }

    // perform some startup checks
    // return 1 on updates and 2 on fresh installs
    int checker = startup.check();

    // update or fresh install detected => show informational message
    if(checker != 0) {

        if(checker == 1 || checker == 2) {

            QQmlApplicationEngine engine;
            app.qmlEngine = &engine;
            qmlRegisterType<PQStartup>("PQStartup", 1, 0, "PQStartup");
            if(checker == 1)
                engine.load("qrc:/startup/PQStartupUpdate.qml");
            else
                engine.load("qrc:/startup/PQStartupFreshInstall.qml");

            app.exec();

        }

        // run consistency check
        // this value is when the user comes from a dev version, we need to make sure that the latest dev changes are applied
        if(checker == 3 || app.validateSettings)
            validate.validateSettingsDatabase();

    } else {

        if(app.validateSettings)
            validate.validateSettingsDatabase();

    }

    if(app.resetDefaults) {

        PQHandlingGeneral general;
        general.setDefaultSettings();

        PQShortcuts::get().setDefault();

    }

    // Get screenshots for fake transparency
    for(int i = 0; i < QApplication::screens().count(); ++i) {
        QScreen *screen = QApplication::screens().at(i);
        QRect r = screen->geometry();
        QPixmap pix = screen->grabWindow(0,r.x(),r.y(),r.width(),r.height());
        pix.save(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(i));
    }

// only one of them will be defined at a time
#if defined(GRAPHICSMAGICK) || defined(IMAGEMAGICK)
    // Initialise Magick as early as possible
    Magick::InitializeMagick(*argv);
#endif

#ifdef DEVIL
    ilInit();
#endif

#ifdef FREEIMAGE
    FreeImage_Initialise();
#endif

    QQmlApplicationEngine engine;
    app.qmlEngine = &engine;

    const QUrl url(QStringLiteral("qrc:/mainwindow.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    qmlRegisterType<PQHandlingFileDialog>("PQHandlingFileDialog", 1, 0, "PQHandlingFileDialog");
    qmlRegisterType<PQHandlingGeneral>("PQHandlingGeneral", 1, 0, "PQHandlingGeneral");
    qmlRegisterType<PQHandlingShortcuts>("PQHandlingShortcuts", 1, 0, "PQHandlingShortcuts");
    qmlRegisterType<PQHandlingFileDir>("PQHandlingFileDir", 1, 0, "PQHandlingFileDir");
    qmlRegisterType<PQHandlingManipulation>("PQHandlingManipulation", 1, 0, "PQHandlingManipulation");
    qmlRegisterType<PQLocalisation>("PQLocalisation", 1, 0, "PQLocalisation");
    qmlRegisterType<PQImageProperties>("PQImageProperties", 1, 0, "PQImageProperties");
    qmlRegisterType<PQFileWatcher>("PQFileWatcher", 1, 0, "PQFileWatcher");
    qmlRegisterType<PQWindowGeometry>("PQWindowGeometry", 1, 0, "PQWindowGeometry");
    qmlRegisterType<PQMetaData>("PQCppMetaData", 1, 0, "PQCppMetaData");
    qmlRegisterType<PQHandlingShareImgur>("PQHandlingShareImgur", 1, 0, "PQHandlingShareImgur");
    qmlRegisterType<PQHandlingWallpaper>("PQHandlingWallpaper", 1, 0, "PQHandlingWallpaper");
    qmlRegisterType<PQHandlingFaceTags>("PQHandlingFaceTags", 1, 0, "PQHandlingFaceTags");
    qmlRegisterType<PQHandlingExternal>("PQHandlingExternal", 1, 0, "PQHandlingExternal");
    qmlRegisterType<PQFileFolderModel>("PQFileFolderModel", 1, 0, "PQFileFolderModel");
    qmlRegisterType<PQHandlingChromecast>("PQHandlingChromecast", 1, 0, "PQHandlingChromecast");

    engine.rootContext()->setContextProperty("PQPassOn", &PQPassOn::get());
    engine.rootContext()->setContextProperty("PQImageFormats", &PQImageFormats::get());
    engine.rootContext()->setContextProperty("PQKeyPressMouseChecker", &PQKeyPressMouseChecker::get());
    engine.rootContext()->setContextProperty("PQSettings", &PQSettings::get());
    engine.rootContext()->setContextProperty("PQShortcuts", &PQShortcuts::get());
    engine.rootContext()->setContextProperty("PQDebugLog", &PQDebugLog::get());
    engine.rootContext()->setContextProperty("PQLogDebugMessage", &PQLogDebugMessage::get());

    engine.addImageProvider("icon",new PQImageProviderIcon);
    engine.addImageProvider("thumb",new PQAsyncImageProviderThumb);
    engine.addImageProvider("full",new PQImageProviderFull);
    engine.addImageProvider("hist",new PQImageProviderHistogram);

    engine.load(url);

    app.qmlWindowAddresses.push_back(engine.rootObjects().at(0));

    int ret = app.exec();

#ifdef FREEIMAGE
    FreeImage_DeInitialise();
#endif

    return ret;

}

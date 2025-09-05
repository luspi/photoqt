/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFileInfo>
#include <QSettings>
#include <QScreen>
#include <clocale>
#include <QSqlError>
#include <QSqlQuery>

#ifdef PQMEXIV2
#ifdef PQMEXIV2_ENABLE_BMFF
#define EXV_ENABLE_BMFF
#endif
#endif

// This needs to come early (in particular before the FreImage header)
#ifdef Q_OS_WIN
#include <windows.h>
#endif

#include <pqc_configfiles.h>
#include <pqc_singleinstance.h>
#include <pqc_startup.h>
#include <pqc_validate.h>
#include <pqc_notify_cpp.h>
#include <pqc_messagehandler.h>
#include <pqc_imageformats.h>
#include <pqc_providericon.h>
#include <pqc_providertheme.h>
#include <pqc_providerthumb.h>
#include <pqc_providertooltipthumb.h>
#include <pqc_providerfolderthumb.h>
#include <pqc_providerdragthumb.h>
#include <pqc_providerfull.h>
#include <pqc_providerimgurhistory.h>
#include <pqc_providersvg.h>
#include <pqc_providersvgcolor.h>
#include <pqc_resolutioncache.h>
#include <pqc_location.h>
#include <scripts/qmlcpp/pqc_scriptsshareimgur.h>
#include <pqc_extensionshandler.h>
#include <pqc_extensionsettings.h>
#include <pqc_look.h>

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
#include <Magick++.h>
#endif

#ifdef PQMDEVIL
#include <IL/il.h>
#endif

#ifdef PQMLIBVIPS
#include <vips/vips8>
#endif

#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

#ifdef PQMFREEIMAGE
#include <FreeImage.h>
#endif

#ifdef Q_OS_WIN
#include <QQuickWindow>
#include <QSGRendererInterface>
#endif

#ifdef PQMFLATPAKBUILD
#include <gio/gio.h>
#endif

/***************************************************/
// Setup the QQmlApplicationEngine.
// This is wrapped in a function because it is called during startup AND also when the interface variant changes
void setupEngine(QQmlApplicationEngine *engine, PQCSingleInstance *app, bool useModernInterface) {

    QObject::connect(engine, &QQmlApplicationEngine::objectCreationFailed, app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine->addImageProvider("icon", new PQCProviderIcon);
    engine->addImageProvider("theme", new PQCProviderTheme);
    engine->addImageProvider("thumb", new PQCAsyncImageProviderThumb);
    engine->addImageProvider("tooltipthumb", new PQCAsyncImageProviderTooltipThumb);
    engine->addImageProvider("folderthumb", new PQCAsyncImageProviderFolderThumb);
    engine->addImageProvider("dragthumb", new PQCAsyncImageProviderDragThumb);
    engine->addImageProvider("full", new PQCProviderFull);
    engine->addImageProvider("imgurhistory", new PQCAsyncImageProviderImgurHistory);
    engine->addImageProvider("svg", new PQCProviderSVG);
    engine->addImageProvider("svgcolor", new PQCProviderSVGColor);

    // These only need to be imported where needed
    qmlRegisterSingletonInstance("PQCImageFormats", 1, 0, "PQCImageFormats", &PQCImageFormats::get());
    qmlRegisterSingletonInstance("PQCResolutionCache", 1, 0, "PQCResolutionCache", &PQCResolutionCache::get());
    qmlRegisterSingletonInstance("PQCScriptsShareImgur", 1, 0, "PQCScriptsShareImgur", &PQCScriptsShareImgur::get());
    qmlRegisterSingletonInstance("PQCLocation", 1, 0, "PQCLocation", &PQCLocation::get());
    qmlRegisterSingletonInstance("PQCExtensionsHandler", 1, 0, "PQCExtensionsHandler", &PQCExtensionsHandler::get());

#if QT_VERSION >= QT_VERSION_CHECK(6, 5, 0)
    if(useModernInterface)
        engine->loadFromModule("PhotoQt.Modern", "PQMainWindow");
    else
        engine->loadFromModule("PhotoQt.Integrated", "PQMainWindow");
#else
    // In Qt 6.4 this path is not automatically added as import path meaning without this PhotoQt wont find any of its modules
    // We also cannot use loadFromModule() as that does not exist yet.
    engine->addImportPath(":/");
    if(useModernInterface)
        engine->load("qrc:/PhotoQt/Modern/qml/modern/PQMainWindow.qml");
    else
        engine->load("qrc:/PhotoQt/Integrated/qml/integrated/PQMainWindow.qml");
#endif

}
/***************************************************/

int main(int argc, char *argv[]) {

#ifdef Q_OS_WIN

#ifdef PQMEXIV2
    // Exiv2 0.28.x and above needs this locale in order to support proper unicode (e.g., CJK characters) in file names/paths
    setlocale(LC_ALL, ".UTF8");
#endif

    QFileInfo f(argv[0]);
    qputenv("PATH", QString("%1;%2").arg(qgetenv("PATH"),f.absolutePath().replace("/", "\\")).toLocal8Bit());
    qputenv("MAGICK_CODER_MODULE_PATH", QString("%1").arg(f.absolutePath().replace("/", "\\") + "\\imagemagick\\coders").toLocal8Bit());
    qputenv("MAGICK_FILTER_MODULE_PATH", QString("%1").arg(f.absolutePath().replace("/", "\\") + "\\imagemagick\\filters").toLocal8Bit());

    // This allows for semi-transparent windows
    // By default Qt6 uses Direct3D which does not seem to support this
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);
#ifndef PQMPORTABLETWEAKS
    // this is used, for exmaple, to add a directory for checking for extensions
    QFileInfo f(argv[0]);
    qputenv("PHOTOQT_EXE_BASEDIR", f.absolutePath().toLocal8Bit());
#endif
#endif

#ifdef PQMPORTABLETWEAKS
    if(argc > 1) {
        qputenv("PHOTOQT_EXE_BASEDIR", argv[1]);
        // create directory and set hidden attribute
#ifdef Q_OS_WIN
        QString folder = QString("%1/photoqt-data").arg(argv[1]);
        QDir dir;
        dir.mkdir(folder);
        SetFileAttributesA(dir.toNativeSeparators(folder).toLocal8Bit(), FILE_ATTRIBUTE_HIDDEN);
#else
        QString folder = QString("%1/.photoqt-data").arg(argv[1]);
        QDir dir;
        dir.mkdir(folder);
#endif
    } else {
        QFileInfo f(argv[0]);
        qputenv("PHOTOQT_EXE_BASEDIR", f.absolutePath().toLocal8Bit());
    }
#endif

#ifndef PQMPORTABLETWEAKS
    // this is used, for exmaple, to add a directory for
    QFileInfo f(argv[0]);
    qputenv("PHOTOQT_EXE_BASEDIR", f.absolutePath().toLocal8Bit());
#endif

    // avoids warning for customizing native styles (observed in particular on Windows)
    qputenv("QT_QUICK_CONTROLS_IGNORE_CUSTOMIZATION_WARNINGS", "1");

    // Set app information
    QApplication::setApplicationName("PhotoQt");
    QApplication::setOrganizationName("");
    QApplication::setOrganizationDomain("photoqt.org");
    QApplication::setApplicationVersion(PQMVERSION);
    QApplication::setQuitOnLastWindowClosed(true);

    // Set the desktop filename. On Wayland this is necessary to set the icon in the window title and panel
    QGuiApplication::setDesktopFileName("org.photoqt.PhotoQt");

    // custom message handler for qDebug/qLog/qInfo/etc.
    qInstallMessageHandler(pqcMessageHandler);

#ifdef PQMPORTABLETWEAKS
    if(argc > 1) {
        for(int i = 2; i < argc; ++i) {
            argv[i-1] = argv[i];
        }
        argc -= 1;
    }
#endif

    // only a single instance
    PQCSingleInstance app(argc, argv);

#ifdef PQMVIDEOMPV
    // Qt sets the locale in the QGuiApplication constructor, but libmpv
    // requires the LC_NUMERIC category to be set to "C", so change it back.
    std::setlocale(LC_NUMERIC, "C");
#endif

#ifdef PQMEXIV2
#if EXIV2_TEST_VERSION(0, 28, 0)
    // In this case Exiv2::enableBMFF() defaults to true
    // and the call to it is deprecated
#else
    #ifdef PQMEXIV2_ENABLE_BMFF
        Exiv2::enableBMFF(true);
    #endif
#endif
#endif

#ifdef PQMFLATPAKBUILD
#if !GLIB_CHECK_VERSION(2,35,0)
    g_type_init();
#endif
#endif

    PQCStartup startup;
    PQCValidate validate;

    // handle export/import commands
    if(app.exportAndQuit != "") {
        startup.exportData(app.exportAndQuit);
        std::exit(0);
    } else if(app.importAndQuit != "") {
        startup.importData(app.importAndQuit);
        std::exit(0);
    } else if(app.checkConfig) {
        validate.validate();
        std::exit(0);
    } else if(app.resetConfig) {
        startup.resetToDefaults();
        std::exit(0);
    } else if(app.showInfo) {
        startup.showInfo();
        std::exit(0);
    }

    // perform some startup checks
    // return 1 on updates and 2 on fresh installs
    const int checker = startup.check();

    // update or fresh install?
    if(checker == 1)
        validate.validate();


    // Get screenshots for fake transparency
    bool success = true;
    for(int i = 0; i < QApplication::screens().count(); ++i) {
        QScreen *screen = QApplication::screens().at(i);
        QRect r = screen->geometry();
        QPixmap pix = screen->grabWindow(0,r.x(),r.y(),r.width(),r.height());
        if(!pix.save(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(i))) {
            qDebug() << "Error taking screenshot for screen #" << i;
            success = false;
            break;
        }
    }
    PQCNotifyCPP::get().setHaveScreenshots(success);

// only one of them will be defined at a time
#if defined(PQMGRAPHICSMAGICK) || defined(PQMIMAGEMAGICK)
    // Initialise Magick as early as possible
    // this needs to happen BEFORE startup check as this might call into Magick
    Magick::InitializeMagick(*argv);
#endif

#ifdef PQMDEVIL
    ilInit();
#endif

#ifdef PQMFREEIMAGE
    FreeImage_Initialise();
#endif

#ifdef PQMLIBVIPS
    VIPS_INIT(argv[0]);
#endif

    /***************************************/
    // figure out modern vs integrated without use of PQCSettings

    bool useModernInterface = true;

    if(!app.forceModernInterface && !app.forceIntegratedInterface) {
        if(QFile::exists(PQCConfigFiles::get().USERSETTINGS_DB())) {
            QSqlDatabase dbtmp;
            if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
                dbtmp = QSqlDatabase::addDatabase("QSQLITE3", "settingsvariant2");
            else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
                dbtmp = QSqlDatabase::addDatabase("QSQLITE", "settingsvariant2");
            dbtmp.setConnectOptions("QSQLITE_OPEN_READONLY");
            dbtmp.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());
            if(!dbtmp.open()) {
                qWarning() << "Unable to check whether I should use the modern or integrated interface:" << dbtmp.lastError().text();
                qWarning() << "Assuming modern interface.";
            } else {
                QSqlQuery query(dbtmp);
                if(!query.exec("SELECT `value` FROM general WHERE `name`='InterfaceVariant'"))
                    qWarning() << "Unable to check for generalInterfaceVariant setting";
                else {
                    if(query.next()) {
                        const QString var = query.value(0).toString();
                        useModernInterface = (var=="modern");
                    }
                }
                query.clear();
                dbtmp.close();
            }
        }
    } else if(app.forceModernInterface || app.forceIntegratedInterface) {
        useModernInterface = !app.forceIntegratedInterface;
        // we need to update this value here as otherwise the styling in PQCLook might be wrong
        if(QFile::exists(PQCConfigFiles::get().USERSETTINGS_DB())) {
            QSqlDatabase dbtmp;
            if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
                dbtmp = QSqlDatabase::addDatabase("QSQLITE3", "settingsvariant2");
            else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
                dbtmp = QSqlDatabase::addDatabase("QSQLITE", "settingsvariant2");
            dbtmp.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());
            if(!dbtmp.open()) {
                qWarning() << "Unable to check whether I should use the modern or integrated interface:" << dbtmp.lastError().text();
                qWarning() << "Assuming modern interface.";
            } else {
                QSqlQuery query(dbtmp);
                query.prepare("INSERT OR REPLACE INTO `general` (`name`,`value`,`datatype`) VALUES ('InterfaceVariant', :val, 'string')");
                query.bindValue(":val", (useModernInterface ? "modern" : "integrated"));
                if(!query.exec())
                    qWarning() << "Unable to update value generalInterfaceVariant:" << query.lastError().text();
                query.clear();
                dbtmp.close();
            }
        }
    }

    /***************************************/

    QQmlApplicationEngine *engine = new QQmlApplicationEngine;


    // the extension settings item
    qmlRegisterType<ExtensionSettings>("ExtensionSettings", 1, 0, "ExtensionSettings");

    // setup the engine
    // this calls all the necessary addImageProvider() and qmlRegister*()
    setupEngine(engine, &app, useModernInterface);

    // This is called from the settings, reloading the QML file when the interface variant is changed
    QObject::connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::reloadMainQMLFile, &app, [&](QString interfaceVariant) {
        engine->deleteLater();
        engine = new QQmlApplicationEngine;
        setupEngine(engine, &app, interfaceVariant=="modern");
    });

    int currentExitCode = app.exec();

#ifdef PQMFREEIMAGE
    FreeImage_DeInitialise();
#endif

#ifdef PQMLIBVIPS
    vips_shutdown();
#endif

    delete engine;

    return currentExitCode;

}

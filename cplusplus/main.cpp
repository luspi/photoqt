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
#include <pqc_providersvg.h>
#include <pqc_providersvgcolor.h>
#include <pqc_providermipmap.h>
#include <pqc_extensionshandler.h>
#include <pqc_extensionsettings.h>
#include <pqc_look.h>
#include <pqc_startuphandler.h>
#include <pqc_settingscpp.h>

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

#ifdef PQMEXTENSIONS
#include <QtCrypto>
#endif

int main(int argc, char **argv) {

    QFileInfo info_exe(argv[0]);

#ifdef Q_OS_WIN

#ifdef PQMEXIV2
    // Exiv2 0.28.x and above needs this locale in order to support proper unicode (e.g., CJK characters) in file names/paths
    setlocale(LC_ALL, ".UTF8");
#endif

    qputenv("PATH", QString("%1;%2").arg(qgetenv("PATH"),info_exe.absolutePath().replace("/", "\\")).toLocal8Bit());
    qputenv("MAGICK_CODER_MODULE_PATH", QString("%1").arg(info_exe.absolutePath().replace("/", "\\") + "\\imagemagick\\coders").toLocal8Bit());
    qputenv("MAGICK_FILTER_MODULE_PATH", QString("%1").arg(info_exe.absolutePath().replace("/", "\\") + "\\imagemagick\\filters").toLocal8Bit());

    // This allows for semi-transparent windows
    // By default Qt6 uses Direct3D which does not seem to support this
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);
#endif

#ifdef PQMPORTABLETWEAKS
    // create directory and set hidden attribute
#ifdef Q_OS_WIN
    QString configLocation = argc > 1 ? QDir::fromNativeSeparators(argv[1]) : QCoreApplication::applicationDirPath();
    QFileInfo info(configLocation);
    if(info.isRelative())
        configLocation = info.absoluteFilePath();
    QString oldportablefolder = QString("%1/photoqt-data").arg(configLocation);
    QString portablefolder = QString("%1/PhotoQtData").arg(configLocation);
    QDir olddir(oldportablefolder);
    QDir newdir(portablefolder);
    if(olddir.exists() && !newdir.exists()) {
        SetFileAttributesA(olddir.absolutePath().toLocal8Bit(), FILE_ATTRIBUTE_NORMAL);
        // move old dir to new dir and remove hidden flag
        if(!olddir.rename(oldportablefolder, portablefolder))
            qWarning() << "Error renaming photoqt-data to PhotoQtData";
    } else {
        // make sure new dir exists
        newdir.mkdir(portablefolder);
    }
#else
    QString portablefolder = QString("%1/.PhotoQtData").arg(argc > 1 ? argv[1] : QCoreApplication::applicationDirPath());
    QDir dir;
    dir.mkdir(portablefolder);
#endif
    qputenv("PHOTOQT_PORTABLE_DATA_LOCATION", portablefolder.toLocal8Bit());
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
    QApplication::setDesktopFileName("org.photoqt.PhotoQt");

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

    /******************************************/

#ifdef PQMEXTENSIONS
    QCA::Initializer init;
#endif

    /******************************************/

    // only a single instance
    PQCSingleInstance app(argc, argv);

    /******************************************/
    // we take care of any startup checks and potential migrations

    PQCStartupHandler startupHandler(app.getForceShowWizard(), app.getForceSkipWizard());

    /******************************************/

#ifdef PQMVIDEOMPV
    // Qt sets the locale in the QApplication constructor, but libmpv
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

    // handle export/import commands
    if(app.exportAndQuit != "") {
        startupHandler.exportData(app.exportAndQuit);
        return 0;
    } else if(app.importAndQuit != "") {
        startupHandler.importData(app.importAndQuit);
        return 0;
    } else if(app.checkConfig) {
        startupHandler.setupDatabases();
        PQCValidate validate;
        validate.validate();
        return 0;
    } else if(app.resetConfig) {
        startupHandler.resetToDefaults();
        return 0;
    } else if(app.showInfo) {
        startupHandler.showInfo();
        return 0;
    } else if(app.installExtensionFileName != "") {
        PQCExtensionsHandler::get().installExtension(app.installExtensionFileName);
    }

    // setting up databases needs to happen here for the Release build
    startupHandler.setupDatabases();
    startupHandler.performChecksAndUpdates();

    /***************************************/
    // figure out modern vs integrated without use of PQCSettings

    bool useModernInterface = (startupHandler.getInterfaceVariant()=="modern");

    if(app.forceModernInterface || app.forceIntegratedInterface) {
        useModernInterface = !app.forceIntegratedInterface;
        QSqlDatabase dbtmp = QSqlDatabase::database("settings");
        QSqlQuery query(dbtmp);
        query.prepare("INSERT OR REPLACE INTO `general` (`name`,`value`,`datatype`) VALUES ('InterfaceVariant', :val, 'string')");
        query.bindValue(":val", (useModernInterface ? "modern" : "integrated"));
        if(!query.exec())
            qWarning() << "Unable to update value generalInterfaceVariant:" << query.lastError().text();
        query.clear();
        dbtmp.close();
        PQCSettingsCPP::get().forceInterfaceVariant((useModernInterface ? "modern" : "integrated"));
    }

    /***************************************/

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

    /***************************************/

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

    QQmlApplicationEngine engine;

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QApplication::exit(-1); }, Qt::QueuedConnection);

    engine.addImageProvider("icon", new PQCProviderIcon);
    engine.addImageProvider("theme", new PQCProviderTheme);
    engine.addImageProvider("thumb", new PQCAsyncImageProviderThumb);
    engine.addImageProvider("tooltipthumb", new PQCAsyncImageProviderTooltipThumb);
    engine.addImageProvider("folderthumb", new PQCAsyncImageProviderFolderThumb);
    engine.addImageProvider("dragthumb", new PQCAsyncImageProviderDragThumb);
    engine.addImageProvider("full", new PQCProviderFull);
    engine.addImageProvider("svg", new PQCProviderSVG);
    engine.addImageProvider("svgcolor", new PQCProviderSVGColor);
    engine.addImageProvider("mipmap", new PQCAsyncImageProviderMipMap);

    // These only need to be imported where needed
    qmlRegisterSingletonInstance("PQCExtensionsHandler", 1, 0, "PQCExtensionsHandler", &PQCExtensionsHandler::get());

    // the extension settings item
    qmlRegisterType<ExtensionSettings>("ExtensionSettings", 1, 0, "ExtensionSettings");

#if QT_VERSION >= QT_VERSION_CHECK(6, 5, 0)
    engine.loadFromModule("PhotoQt", "PQMainWindow");
#else
    // In Qt 6.4 this path is not automatically added as import path meaning without this PhotoQt wont find any of its modules
    // We also cannot use loadFromModule() as that does not exist yet.
    engine.addImportPath(":/");
    engine.load("qrc:/PhotoQt/Integrated/qml/PQMainWindow.qml");
#endif

    int currentExitCode = app.exec();

#ifdef PQMFREEIMAGE
    FreeImage_DeInitialise();
#endif

#ifdef PQMLIBVIPS
    vips_shutdown();
#endif

    return currentExitCode;

}

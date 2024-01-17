#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFileInfo>
#include <QSettings>
#include <QScreen>
#include <clocale>

#ifdef PQMEXIV2
    #ifdef PQMEXIV2_ENABLE_BMFF
        #define EXV_ENABLE_BMFF
    #endif
#endif

#include <pqc_configfiles.h>
#include <pqc_singleinstance.h>
#include <pqc_startup.h>
#include <pqc_validate.h>
#include <pqc_notify.h>
#include <pqc_messagehandler.h>
#include <pqc_settings.h>
#include <pqc_imageformats.h>
#include <pqc_shortcuts.h>
#include <pqc_look.h>
#include <pqc_providericon.h>
#include <pqc_providertheme.h>
#include <pqc_providerthumb.h>
#include <pqc_providertooltipthumb.h>
#include <pqc_providerfolderthumb.h>
#include <pqc_providerdragthumb.h>
#include <pqc_providerfull.h>
#include <pqc_providerimgurhistory.h>
#include <pqc_filefoldermodel.h>
#include <pqc_metadata.h>
#include <pqc_resolutioncache.h>
#include <pqc_windowgeometry.h>
#include <pqc_location.h>
#include <pqc_photosphere.h>
#include <scripts/pqc_scriptsconfig.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <scripts/pqc_scriptsfiledialog.h>
#include <scripts/pqc_scriptsclipboard.h>
#include <scripts/pqc_scriptsfilemanagement.h>
#include <scripts/pqc_scriptsother.h>
#include <scripts/pqc_scriptsimages.h>
#include <scripts/pqc_scriptsmetadata.h>
#include <scripts/pqc_scriptscontextmenu.h>
#include <scripts/pqc_scriptsshortcuts.h>
#include <scripts/pqc_scriptscrypt.h>
#include <scripts/pqc_scriptsshareimgur.h>
#include <scripts/pqc_scriptswallpaper.h>
#include <scripts/pqc_scriptschromecast.h>

#ifdef PQMGRAPHICSMAGICK
#include <GraphicsMagick/Magick++.h>
#endif

#ifdef PQMIMAGEMAGICK
#include <Magick++.h>
#endif

#ifdef PQMDEVIL
#include <IL/il.h>
#endif

#ifdef PQMLIBVIPS
#include <vips/vips8>
#endif

#ifdef PQMVIDEOMPV
#include <pqc_mpvobject.h>
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

int main(int argc, char *argv[]) {

#ifdef Q_OS_WIN
    QFileInfo f(argv[0]);
    qputenv("PATH", QString("%1;%2").arg(qgetenv("PATH"),f.absolutePath().replace("/", "\\")).toLocal8Bit());
    qputenv("MAGICK_CODER_MODULE_PATH", QString("%1").arg(f.absolutePath().replace("/", "\\") + "\\imagemagick\\coders").toLocal8Bit());
    qputenv("MAGICK_FILTER_MODULE_PATH", QString("%1").arg(f.absolutePath().replace("/", "\\") + "\\imagemagick\\filters").toLocal8Bit());

    // This allows for semi-transparent windows
    // By default Qt6 uses Direct3D which does not seem to support this
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);
#endif

    // avoids warning for customizing native styles (observed in particular on Windows)
    qputenv("QT_QUICK_CONTROLS_IGNORE_CUSTOMIZATION_WARNINGS", "1");

    // Set app information
    QApplication::setApplicationName("PhotoQt");
    QApplication::setOrganizationName("");
    QApplication::setOrganizationDomain("photoqt.org");
    QApplication::setApplicationVersion(PQMVERSION);
    QApplication::setQuitOnLastWindowClosed(true);

    // custom message handler for qDebug/qLog/qInfo/etc.
    qInstallMessageHandler(pqcMessageHandler);

    // needs to be set before Q*Application is created
    QFile opengl(PQCConfigFiles::CONFIG_DIR()+"/OpenGL");
    if(opengl.exists()) {
        if(opengl.open(QIODevice::ReadOnly)) {
            QTextStream in (&opengl);
            QString ogl = in.readAll().trimmed();
#ifndef Q_OS_WIN
            // these are not supported on Windows anymore
            if(ogl == "opengles")
                QApplication::setAttribute(Qt::AA_UseOpenGLES);
            else if(ogl == "desktopopengl")
                QApplication::setAttribute(Qt::AA_UseDesktopOpenGL);
            else if(ogl == "softwareopengl")
#else
            if(ogl == "softwareopengl")
#endif
                QApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);
        }
    }

    // only a single instance
    PQCSingleInstance app(argc, argv);

#ifdef PQMVIDEOMPV
    // Qt sets the locale in the QGuiApplication constructor, but libmpv
    // requires the LC_NUMERIC category to be set to "C", so change it back.
    std::setlocale(LC_NUMERIC, "C");
#endif

#ifdef PQMEXIV2
    #ifdef PQMEXIV2_ENABLE_BMFF
        Exiv2::enableBMFF(true);
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
    PQCNotify::get().setStartupCheck(checker);

    // update or fresh install?
    if(checker != 0) {

        if(checker == 2)
            startup.setupFresh();
        else {
            PQCSettings::get().migrate();
            PQCSettings::get().readDB();
            PQCShortcuts::get().migrate(PQCSettings::get()["generalVersion"].toString());
        }

        // run consistency check
        // this is done when updating or coming from dev version
        if(checker == 1 || checker == 3)
           validate.validate();

        PQCSettings::get().update("generalVersion", PQMVERSION);
        PQCSettings::get().readDB();

    }

    // after the checks above we can check for any possible settings update from the cli
    if(PQCNotify::get().getSettingUpdate().length() == 2)
        PQCSettings::get().updateFromCommandLine();

    // Get screenshots for fake transparency
    PQCNotify::get().setHaveScreenshots(PQCScriptsOther::get().takeScreenshots());

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

    // create the qml engine
    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/src/qml/PQMainWindow.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if(!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    // These only need to be imported where needed
    qmlRegisterSingletonInstance("PQCImageFormats", 1, 0, "PQCImageFormats", &PQCImageFormats::get());
    qmlRegisterSingletonInstance("PQCFileFolderModel", 1, 0, "PQCFileFolderModel", &PQCFileFolderModel::get());
    qmlRegisterSingletonInstance("PQCShortcuts", 1, 0, "PQCShortcuts", &PQCShortcuts::get());
    qmlRegisterSingletonInstance("PQCNotify", 1, 0, "PQCNotify", &PQCNotify::get());
    qmlRegisterSingletonInstance("PQCScriptsConfig", 1, 0, "PQCScriptsConfig", &PQCScriptsConfig::get());
    qmlRegisterSingletonInstance("PQCScriptsFilesPaths", 1, 0, "PQCScriptsFilesPaths", &PQCScriptsFilesPaths::get());
    qmlRegisterSingletonInstance("PQCScriptsFileDialog", 1, 0, "PQCScriptsFileDialog", &PQCScriptsFileDialog::get());
    qmlRegisterSingletonInstance("PQCScriptsClipboard", 1, 0, "PQCScriptsClipboard", &PQCScriptsClipboard::get());
    qmlRegisterSingletonInstance("PQCScriptsFileManagement", 1, 0, "PQCScriptsFileManagement", &PQCScriptsFileManagement::get());
    qmlRegisterSingletonInstance("PQCScriptsOther", 1, 0, "PQCScriptsOther", &PQCScriptsOther::get());
    qmlRegisterSingletonInstance("PQCScriptsImages", 1, 0, "PQCScriptsImages", &PQCScriptsImages::get());
    qmlRegisterSingletonInstance("PQCMetaData", 1, 0, "PQCMetaData", &PQCMetaData::get());
    qmlRegisterSingletonInstance("PQCScriptsMetaData", 1, 0, "PQCScriptsMetaData", &PQCScriptsMetaData::get());
    qmlRegisterSingletonInstance("PQCScriptsContextMenu", 1, 0, "PQCScriptsContextMenu", &PQCScriptsContextMenu::get());
    qmlRegisterSingletonInstance("PQCScriptsShortcuts", 1, 0, "PQCScriptsShortcuts", &PQCScriptsShortcuts::get());
    qmlRegisterSingletonInstance("PQCResolutionCache", 1, 0, "PQCResolutionCache", &PQCResolutionCache::get());
    qmlRegisterSingletonInstance("PQCWindowGeometry", 1, 0, "PQCWindowGeometry", &PQCWindowGeometry::get());
    qmlRegisterSingletonInstance("PQCScriptsCrypt", 1, 0, "PQCScriptsCrypt", &PQCScriptsCrypt::get());
    qmlRegisterSingletonInstance("PQCScriptsShareImgur", 1, 0, "PQCScriptsShareImgur", &PQCScriptsShareImgur::get());
    qmlRegisterSingletonInstance("PQCScriptsWallpaper", 1, 0, "PQCScriptsWallpaper", &PQCScriptsWallpaper::get());
    qmlRegisterSingletonInstance("PQCLocation", 1, 0, "PQCLocation", &PQCLocation::get());
    qmlRegisterSingletonInstance("PQCScriptsChromeCast", 1, 0, "PQCScriptsChromeCast", &PQCScriptsChromeCast::get());

    // these are used pretty much everywhere, this avoids having to import it everywhere
    engine.rootContext()->setContextProperty("PQCLook", &PQCLook::get());
    engine.rootContext()->setContextProperty("PQCSettings", &PQCSettings::get());

    engine.addImageProvider("icon", new PQCProviderIcon);
    engine.addImageProvider("theme", new PQCProviderTheme);
    engine.addImageProvider("thumb", new PQCAsyncImageProviderThumb);
    engine.addImageProvider("tooltipthumb", new PQCAsyncImageProviderTooltipThumb);
    engine.addImageProvider("folderthumb",new PQCAsyncImageProviderFolderThumb);
    engine.addImageProvider("dragthumb",new PQCAsyncImageProviderDragThumb);
    engine.addImageProvider("full",new PQCProviderFull);
    engine.addImageProvider("imgurhistory",new PQCAsyncImageProviderImgurHistory);

    qmlRegisterType<PQCPhotoSphere>("PQCPhotoSphere", 1, 0, "PQCPhotoSphere");

#ifdef PQMVIDEOMPV
    qmlRegisterType<PQCMPVObject>("PQCMPVObject", 1, 0, "PQCMPVObject");
#endif

    engine.load(url);


    int ret = app.exec();

#ifdef PQMFREEIMAGE
    FreeImage_DeInitialise();
#endif

#ifdef PQMLIBVIPS
    vips_shutdown();
#endif

    return ret;

}

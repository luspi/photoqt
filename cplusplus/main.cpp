#include <QApplication>
#include "mainhandler.h"
#include "singleinstance/singleinstance.h"
#ifdef GM
#include <GraphicsMagick/Magick++.h>
#endif

int main(int argc, char *argv[]) {

    // We store this as a QString, as this way we don't have to explicitely cast VERSION to a QString below
    QString version = VERSION;

    // Set app name and version
    QApplication::setApplicationName("PhotoQt");
    QApplication::setApplicationVersion(version);

    // Create a new instance (includes handling of argc/argv)
    // This class ensures, that only one instance is running. If one is already running, we pass the commands to the main process and exit.
    // If no process is running yet, we create a LocalServer and continue below
    SingleInstance app(argc, argv);

#ifdef GM
    // Initialise Magick as early as possible
    Magick::InitializeMagick(*argv);
#endif

    // This means, that, e.g., --export or --import was passed along -> we will simply quit (preparation for that is done in the handleExportImport() function)
    if(StartupCheck::ExportImport::handleExportImport(&app) != -1) return 0;

    // Ensure that PhotoQt actually quits when last window is closed
    // Shouldn't be an issue, but set just in case
    qApp->setQuitOnLastWindowClosed(true);

    // Create a handler to manage the qml files and do some preliminary stuff (e.g., startup checks)
    MainHandler handle(app.verbose);

    // A remote action passed on via command line triggers the 'interaction' signal, so we pass it on to the MainWindow
    QObject::connect(&app, SIGNAL(interaction(QString)), &handle, SLOT(remoteAction(QString)));

    // How to proceed when starting PhotoQt in tray or passing on a filename
    handle.manageStartupFilename(app.startintray, app.filename);

    // And execute
    return app.exec();

}

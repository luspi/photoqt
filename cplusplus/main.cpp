/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

#include <QApplication>
#include "mainhandler.h"
#include "singleinstance/singleinstance.h"
#include "startup/startupcheck.h"
#ifdef GM
#include <GraphicsMagick/Magick++.h>
#endif
#ifdef DEVIL
#include <IL/il.h>
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

#ifdef DEVIL
    ilInit();
#endif

#ifdef FREEIMAGE
    FreeImage_Initialise();
#endif

    // This means, that, e.g., --export or --import was passed along -> we will simply quit (handling is done in the handleExportImport() function)
    if(StartupCheck::ExportImport::handleExportImport(&app) != -1) return 0;

    // Ensure that PhotoQt actually quits when last window is closed
    // Shouldn't be an issue, but set just in case
    qApp->setQuitOnLastWindowClosed(true);

    // Create a handler to manage the qml files and do some preliminary stuff (e.g., startup checks)
    MainHandler handle;

    // A remote action passed on via command line triggers the 'interaction' signal, so we pass it on to the MainWindow
    QObject::connect(&app, &SingleInstance::interaction, &handle, &MainHandler::remoteAction);

    // How to proceed when starting PhotoQt in tray or passing on a filename
    handle.manageStartupFilename(app.startintray, app.filename);

    // And execute
    return app.exec();

}

/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <QtDebug>
#include <QFileInfo>
#include <pqc_commandlineparser.h>
#include<QDir>
#include <iostream>

PQCCommandLineParser::PQCCommandLineParser(QApplication &app, QObject *parent) : QObject(parent), QCommandLineParser() {

    // install translator if help message is to be displayed
    // we can't always install the translator as this would overwrite any translator set later (i.e., the settings would be ignored)
    if(app.arguments().contains("--help") || app.arguments().contains("-h")) {
        const QString langCode = QLocale::system().name();
        if(trans.load(QString(":/photoqt_%1.qm").arg(langCode)))
            qDebug() << "Translation loaded:" << trans.language();
    }

    setApplicationDescription(QApplication::translate("commandlineparser", "Image Viewer"));

    addPositionalArgument("[filename]", QApplication::translate("commandlineparser", "Image file to open."));

    addHelpOption();
    addVersionOption();

    addOptions({
                   //: Command line option
        {{"o", "open"}, QApplication::translate("commandlineparser", "Make PhotoQt ask for a new file.")},
                   //: Command line option
        {{"s", "show"}, QApplication::translate("commandlineparser", "Shows PhotoQt from system tray.")},
                   //: Command line option
        {"hide", QApplication::translate("commandlineparser", "Hides PhotoQt to system tray.")},
                   //: Command line option
        {{"q", "quit"}, QApplication::translate("commandlineparser", "Quit PhotoQt.")},
                   //: Command line option
        {{"t", "toggle"}, QApplication::translate("commandlineparser", "Show/Hide PhotoQt.")},
                   //: Command line option
        {"enable-tray", QApplication::translate("commandlineparser", "Enable system tray icon.")},
                   //: Command line option
        {"disable-tray", QApplication::translate("commandlineparser", "Disable system tray icon.")},
                   //: Command line option
        {"start-in-tray", QApplication::translate("commandlineparser", "Start PhotoQt hidden to the system tray.")},
                   //: Command line option
        {"send-shortcut", QApplication::translate("commandlineparser", "Simulate a shortcut sequence"), "shortcut"},
                   //: Command line option
        {"setting", QApplication::translate("commandlineparser", "Change setting to specified value."),
                   //: Command line option
                    QApplication::translate("commandlineparser", "settingname:value")},
                   //: Command line option
        {"debug", QApplication::translate("commandlineparser", "Switch on debug messages.")},
                   //: Command line option
        {"no-debug", QApplication::translate("commandlineparser", "Switch off debug messages.")},
                   //: Command line option
        {"export", QApplication::translate("commandlineparser", "Export configuration to given filename."),
                   //: Command line option
                   QApplication::translate("commandlineparser", "filename")},
                   //: Command line option
        {"import", QApplication::translate("commandlineparser", "Import configuration from given filename."),
                   //: Command line option
                   QApplication::translate("commandlineparser", "filename")},
                   //: Command line option
        {"check-config", QApplication::translate("commandlineparser", "Check the configuration and correct any detected issues.")},
                   //: Command line option
        {"reset-config", QApplication::translate("commandlineparser", "Reset default configuration.")},
                   //: Command line option
        {"show-info", QApplication::translate("commandlineparser", "Show configuration overview.")},
                   //: Command line option
        {"modern", QApplication::translate("commandlineparser", "Launch with modern interface.")},
                   //: Command line option
        {"integrated", QApplication::translate("commandlineparser", "Launch with integrated interface.")},
                   //: Command line option
        {"show-wizard", QApplication::translate("commandlineparser", "Show the startup wizard.")},
                   //: Command line option
        {"skip-wizard", QApplication::translate("commandlineparser", "Don't show the startup wizard.")},
                   //: Command line option
        {"install-extension", QApplication::translate("commandlineparser", "Install specified extension."),
                   "extension.pqe"},
    });

    process(app);

}

PQCCommandLineResult PQCCommandLineParser::getResult() {

    PQCCommandLineResult ret = PQCCommandLineNothing;

#if defined(Q_OS_WIN) && defined(PQMPORTABLETWEAKS)
    // the first entry is the config dir that needs to be ignored
    if(positionalArguments().length() > 1) {
        filenames.clear();
        // the first entry is the config dir and needs to be ignored
        bool first = true;
        for(auto &f : positionalArguments()) {
            if(first) {
                first = false;
                continue;
            }
            // if we have portable tweaks enabled on Windows we need to ignore any executable that might be part of the command line
            if(!f.endsWith(".exe")) {
                // we also need to check if it is a relative path, as we want to use the portable dir and NOT the (temporary) exe dir
                QFileInfo info(f);
                if(info.isRelative())
                    filenames.append(qgetenv("PHOTOQT_PORTABLE_DATA_LOCATION") + "/../" + info.filePath());
                else
                    filenames.append(f);
            }
        }
        if(filenames.length())
            ret = ret|PQCCommandLineFile;

    }
#else
    if(positionalArguments().length() > 0) {
        ret = ret|PQCCommandLineFile;
        filenames = positionalArguments();
    }
#endif

    if(isSet("o") || isSet("open"))
        ret = ret|PQCCommandLineOpen;

    if(isSet("s") || isSet("show"))
        ret = ret|PQCCommandLineShow;

    if(isSet("hide"))
        ret = ret|PQCCommandLineHide;

    if(isSet("quit"))
        ret = ret|PQCCommandLineQuit;

    if(isSet("t") || isSet("toggle"))
        ret = ret|PQCCommandLineToggle;

    if(isSet("start-in-tray"))
        ret = ret|PQCCommandLineStartInTray;

    if(isSet("enable-tray"))
        ret = ret|PQCCommandLineEnableTray;

    if(isSet("disable-tray"))
        ret = ret|PQCCommandLineDisableTray;

    shortcutSequence = value("send-shortcut");
    if(shortcutSequence != "")
        ret = ret|PQShortcutSequence;

    if(isSet("debug"))
        ret = ret|PQCCommandLineDebug;

    if(isSet("no-debug"))
        ret = ret|PQCCommandLineNoDebug;

    exportFileName = value("export");
    if(exportFileName != "")
        ret = ret|PQCCommandLineExport;

    importFileName = value("import");
    if(importFileName != "")
        ret = ret|PQCCommandLineImport;

    if(isSet("check-config"))
        ret = ret|PQCCommandLineCheckConfig;

    if(isSet("reset-config"))
        ret = ret|PQCCommandLineResetConfig;

    if(isSet("show-info"))
        ret = ret|PQCCommandLineShowInfo;

    if(isSet("modern"))
        ret = ret|PQCCommandLineModernInterface;

    if(isSet("integrated"))
        ret = ret|PQCCommandLineIntegratedInterface;

    if(isSet("setting")) {
        const QStringList tmp = value("setting").split(":");
        if(tmp.length() == 2) {
            ret = ret|PQCCommandLineSettingUpdate;
            settingUpdate[0] = tmp[0];
            settingUpdate[1] = tmp[1];
        }
    }

    if(isSet("show-wizard"))
        ret = ret|PQCCommandLineShowStartupWizard;

    if(isSet("skip-wizard"))
        ret = ret|PQCCommandLineDontShowStartupWizard;

    extensionFileName = value("install-extension");
    if(extensionFileName != "")
        ret = ret|PQCCommandLineInstallExtension;

    return ret;

}

PQCCommandLineParser::~PQCCommandLineParser() {
    qApp->removeTranslator(&trans);
}

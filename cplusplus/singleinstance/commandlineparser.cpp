/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include "commandlineparser.h"

PQCommandLineParser::PQCommandLineParser(QApplication &app, QObject *parent) : QObject(parent), QCommandLineParser() {

    // install translator if help message is to be displayed
    // we can't always install the translator as this would overwrite any translator set later (i.e., the settings would be ignored)
    if(app.arguments().contains("--help") || app.arguments().contains("-h")) {
        QTranslator *trans = new QTranslator;
        const QString langCode = QLocale::system().name();
        if(QFile(":/photoqt_" + langCode + ".qm").exists()) {
            trans->load(":/photoqt_" + langCode);
            qApp->installTranslator(trans);
        }
        if(langCode.contains("_")) {
            const QString cc = langCode.split("_").at(0);
            if(QFile(":/photoqt_" + cc + ".qm").exists()) {
                trans->load(":/photoqt_" + cc);
                qApp->installTranslator(trans);
            }
        } else {
            const QString cc = QString("%1_%2").arg(langCode, langCode.toUpper());
            if(QFile(":/photoqt_" + cc + ".qm").exists()) {
                trans->load(":/photoqt_" + cc);
                qApp->installTranslator(trans);
            }
        }
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
        {{"t", "toggle"}, QApplication::translate("commandlineparser", "Show/Hide PhotoQt.")},
                   //: Command line option
        {"thumbs", QApplication::translate("commandlineparser", "Enable thumbnails.")},
                   //: Command line option
        {"no-thumbs", QApplication::translate("commandlineparser", "Disable thumbnails.")},
                   //: Command line option
        {"enable-tray", QApplication::translate("commandlineparser", "Enable system tray icon.")},
                   //: Command line option
        {"disable-tray", QApplication::translate("commandlineparser", "Disable system tray icon.")},
                   //: Command line option
        {"start-in-tray", QApplication::translate("commandlineparser", "Start PhotoQt hidden to the system tray.")},
                   //: Command line option
        {"standalone", QApplication::translate("commandlineparser", "Open standalone PhotoQt, allows for multiple instances but without remote interaction.")},
                   //: Command line option
        {"send-shortcut", QApplication::translate("commandlineparser", "Simulate a shortcut sequence"), "shortcut"},
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
        {"show-info", QApplication::translate("commandlineparser", "Show configuration overview.")}
    });

    process(app);

}

PQCommandLineResult PQCommandLineParser::getResult() {

    PQCommandLineResult ret = PQCOmmandLineNothing;

    if(positionalArguments().length() > 0) {
        ret = ret|PQCommandLineFile;
        filename = positionalArguments().at(0);
    }

    if(isSet("o") || isSet("open"))
        ret = ret|PQCommandLineOpen;

    if(isSet("s") || isSet("show"))
        ret = ret|PQCommandLineShow;

    if(isSet("hide"))
        ret = ret|PQCommandLineHide;

    if(isSet("t") || isSet("toggle"))
        ret = ret|PQCommandLineToggle;

    if(isSet("thumbs"))
        ret = ret|PQCommandLineThumbs;

    if(isSet("no-thumbs"))
        ret = ret|PQCommandLineNoThumbs;

    if(isSet("start-in-tray"))
        ret = ret|PQCommandLineStartInTray;

    if(isSet("enable-tray"))
        ret = ret|PQCommandLineEnableTray;

    if(isSet("disable-tray"))
        ret = ret|PQCommandLineDisableTray;

    if(isSet("standalone"))
        ret = ret|PQCommandLineStandalone;

    shortcutSequence = value("send-shortcut");
    if(shortcutSequence != "")
        ret = ret|PQShortcutSequence;

    if(isSet("debug"))
        ret = ret|PQCommandLineDebug;

    if(isSet("no-debug"))
        ret = ret|PQCommandLineNoDebug;

    exportFileName = value("export");
    if(exportFileName != "")
        ret = ret|PQCommandLineExport;

    importFileName = value("import");
    if(importFileName != "")
        ret = ret|PQCommandLineImport;

    if(isSet("check-config"))
        ret = ret|PQCommandLineCheckConfig;

    if(isSet("reset-config"))
        ret = ret|PQCommandLineResetConfig;

    if(isSet("show-info"))
        ret = ret|PQCommandLineShowInfo;

    return ret;

}

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

#ifndef PQCOMMANDLINEPARSER_H
#define PQCOMMANDLINEPARSER_H

#include <QObject>
#include <QCommandLineParser>
#include <QApplication>
#include <QTranslator>
#include <QFile>
#include <iostream>

enum PQCommandLineResult {
    PQCOmmandLineNothing = 0,
    PQCommandLineFile = 1,
    PQCommandLineOpen = 2,
    PQCommandLineShow = 4,
    PQCommandLineHide = 8,
    PQCommandLineToggle = 16,
    PQCommandLineThumbs = 32,
    PQCommandLineNoThumbs = 64,
    PQCommandLineTray = 128,
    PQCommandLineStandalone = 256,
    PQCommandLineDebug = 512,
    PQCommandLineNoDebug = 1024,
    PQCommandLineExport = 2048,
    PQCommandLineImport = 4096,
    PQShortcutSequence = 8192
};
inline PQCommandLineResult operator|(PQCommandLineResult a, PQCommandLineResult b) {
    return static_cast<PQCommandLineResult>(static_cast<int>(a) | static_cast<int>(b));
}

class PQCommandLineParser : public QObject, public QCommandLineParser {

    Q_OBJECT

public:

    explicit PQCommandLineParser(QApplication &app, QObject *parent = nullptr) : QObject(parent), QCommandLineParser() {

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
            {{"o", "open"}, QApplication::translate("commandlineparser", "Make PhotoQt ask for a new file.")},
            {{"s", "show"}, QApplication::translate("commandlineparser", "Shows PhotoQt from system tray.")},
            {"hide", QApplication::translate("commandlineparser", "Hides PhotoQt to system tray.")},
            {{"t", "toggle"}, QApplication::translate("commandlineparser", "Show/Hide PhotoQt.")},
            {"thumbs", QApplication::translate("commandlineparser", "Enable thumbnails.")},
            {"no-thumbs", QApplication::translate("commandlineparser", "Disable thumbnails.")},
            {"start-in-tray", QApplication::translate("commandlineparser", "Start PhotoQt hidden to the system tray.")},
            {"standalone", QApplication::translate("commandlineparser", "Open standalone PhotoQt, allows for multiple instances but without remote interaction.")},
            {"send-shortcut", QApplication::translate("commandlineparser", "Simulate a shortcut sequence"), "shortcut"},
            {"debug", QApplication::translate("commandlineparser", "Switch on debug messages.")},
            {"no-debug", QApplication::translate("commandlineparser", "Switch off debug messages.")},
            {"export", QApplication::translate("commandlineparser", "Export configuration to given filename."), "filename"},
            {"import", QApplication::translate("commandlineparser", "Import configuration from given filename."), "filename"}
        });

        process(app);

    }

    PQCommandLineResult getResult() {

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
            ret = ret|PQCommandLineTray;

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

        return ret;

    }

    QString exportFileName;
    QString importFileName;
    QString filename;
    QString shortcutSequence;

};


#endif // PQCOMMANDLINEPARSER_H

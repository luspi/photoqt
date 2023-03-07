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
    PQCommandLineStartInTray = 128,
    PQCommandLineStandalone = 256,
    PQCommandLineDebug = 512,
    PQCommandLineNoDebug = 1024,
    PQCommandLineExport = 2048,
    PQCommandLineImport = 4096,
    PQShortcutSequence = 8192,
    PQCommandLineEnableTray = 16384,
    PQCommandLineDisableTray = 32768,
    PQCommandLineCheckConfig = 65536,
    PQCommandLineResetConfig = 131072,
    PQCommandLineShowInfo = 262144
};
inline PQCommandLineResult operator|(PQCommandLineResult a, PQCommandLineResult b) {
    return static_cast<PQCommandLineResult>(static_cast<int>(a) | static_cast<int>(b));
}

class PQCommandLineParser : public QObject, public QCommandLineParser {

    Q_OBJECT

public:

    explicit PQCommandLineParser(QApplication &app, QObject *parent = nullptr);
    PQCommandLineResult getResult();

    QString exportFileName;
    QString importFileName;
    QString filename;
    QString shortcutSequence;

};


#endif // PQCOMMANDLINEPARSER_H

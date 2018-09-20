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

#ifndef COMMANDLINEPARSER_H
#define COMMANDLINEPARSER_H

#include <QCoreApplication>
#include <iomanip>
#include "../logger.h"

// A custom command line parser
// Looks very much like QCommandLineParser, but allows grouping entries
class CommandLineParser : public QObject {

    Q_OBJECT

public:

    explicit CommandLineParser(QCoreApplication *app);

    // Add a command line option
    void addOption(QString cat, QStringList option, QString description, QString valueName = "");

private:

    // Show the help message and quit
    // It is marked as 'noreturn' as it causes PhotoQt to quit
    [[ noreturn ]] void showHelp();

    // Display a detected error
    // It is marked as 'noreturn' as it causes PhotoQt to quit
    [[ noreturn ]] void showError(QString err);

    // Process the command line
    void process(QCoreApplication *app);

public:
    // All options that have been found
    QStringList foundOptions;
    // All option/value pairs that have been found
    QMap<QString,QString> foundValues;
    // The found filename (if any)
    QString foundFilename;

private:
    // Hold max width required for options
    int maxEntriesWidth;
    // All categories that have been set
    QStringList categories;
    // All entries
    QList<QStringList> allEntries;
    // All options that are set as one list
    QStringList validOptions;
    // All options that are set with values as one list
    QStringList optionsWithValue;

};


#endif

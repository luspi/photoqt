/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

#ifndef PQCSCRIPTSCLIPBOARD_H
#define PQCSCRIPTSCLIPBOARD_H

#include <QObject>

class QClipboard;

class PQCScriptsClipboard : public QObject {

    Q_OBJECT

public:
    static PQCScriptsClipboard& get() {
        static PQCScriptsClipboard instance;
        return instance;
    }
    ~PQCScriptsClipboard();

    PQCScriptsClipboard(PQCScriptsClipboard const&)     = delete;
    void operator=(PQCScriptsClipboard const&) = delete;

    Q_INVOKABLE bool areFilesInClipboard();
    Q_INVOKABLE void copyFilesToClipboard(QStringList files);
    Q_INVOKABLE QStringList getListOfFilesInClipboard();
    Q_INVOKABLE void copyTextToClipboard(QString txt, bool removeHTML= false);
    Q_INVOKABLE QString getTextFromClipboard();

private:
    PQCScriptsClipboard();

    QClipboard *clipboard;

Q_SIGNALS:
    void clipboardUpdated();

};

#endif

/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#ifndef PQKEYPRESSCHECKER
#define PQKEYPRESSCHECKER

#include <QObject>
#include <QKeyEvent>
#include <QDateTime>

class PQKeyPressChecker : public QObject {
    Q_OBJECT

    // the actual catching of key events is done in the notify() method of PQSingleInstance
    // this class is used to communicate a key press throughout the application

public:
    static PQKeyPressChecker& get() {
        static PQKeyPressChecker instance;
        return instance;
    }

    PQKeyPressChecker(PQKeyPressChecker const&)    = delete;
    void operator=(PQKeyPressChecker const&) = delete;

private:
    PQKeyPressChecker() { }

signals:
    void receivedKeyPress(int key, int modifiers);

};

#endif // PQKEYPRESSCHECKER

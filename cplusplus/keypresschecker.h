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

#ifndef PQKEYPRESSCHECKER
#define PQKEYPRESSCHECKER

#include <QObject>
#include <QKeyEvent>
#include <QDateTime>

class PQKeyPressMouseChecker : public QObject {
    Q_OBJECT

    // the actual catching of key events is done in the notify() method of PQSingleInstance
    // this class is used to communicate a key press throughout the application

public:
    static PQKeyPressMouseChecker& get() {
        static PQKeyPressMouseChecker instance;
        return instance;
    }

    PQKeyPressMouseChecker(PQKeyPressMouseChecker const&)    = delete;
    void operator=(PQKeyPressMouseChecker const&) = delete;

    Q_INVOKABLE void simulateKeyPress(QString seq) {
        int key = 0;
        int modifiers = 0;
        const QStringList parts = seq.split("+");
        for(const QString &part : parts) {
            if(part.toLower() == "ctrl")
                modifiers |= Qt::CTRL;
            else if(part.toLower() == "shift")
                modifiers |= Qt::SHIFT;
            else if(part.toLower() == "alt")
                modifiers |= Qt::ALT;
            else if(part.toLower() == "meta")
                modifiers |= Qt::META;
            else
                key |= QKeySequence::fromString(part)[0];
        }
        Q_EMIT receivedKeyPress(key, modifiers);
    }

private:
    PQKeyPressMouseChecker() { }

Q_SIGNALS:
    void receivedKeyPress(int key, int modifiers);
    void receivedMouseButtonPress(Qt::MouseButtons but, QPoint pos);
    void receivedMouseLeave();

};

#endif // PQKEYPRESSCHECKER

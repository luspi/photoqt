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

#ifndef PQPASSON_H
#define PQPASSON_H

#include <QObject>

class PQPassOn : public QObject {

    Q_OBJECT

public:
    static PQPassOn& get() {
        static PQPassOn instance;
        return instance;
    }

    PQPassOn(PQPassOn const&)     = delete;
    void operator=(PQPassOn const&) = delete;

private:
    PQPassOn() {}

signals:
    void cmdFilePath(QString path);
    void cmdOpen();
    void cmdShow();
    void cmdHide();
    void cmdToggle();
    void cmdThumbs();
    void cmdNoThumbs();

    void cmdTray();
    void cmdShortcutSequence(QString seq);

    void cmdDebug();
    void cmdNoDebug();

};


#endif // PQPASSON_H

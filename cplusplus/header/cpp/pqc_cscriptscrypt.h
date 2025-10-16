/**************************************************************************
 ** Inspired by SimpleCrypt:                                             **
 ** Copyright (c) 2011, Andre Somers                                     **
 ** All rights reserved.                                                 **
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
#pragma once

#include <QObject>
#include <QRandomGenerator>

/*************************************************************/
/*************************************************************/
//
// this class is ONLY used by C++ at the moment
// if this ever changes then a qml wrapper might have to be created
//
/*************************************************************/
/*************************************************************/

class PQCCScriptsCrypt : public QObject {

    Q_OBJECT

public:
    static PQCCScriptsCrypt& get();
    virtual ~PQCCScriptsCrypt();

    PQCCScriptsCrypt(PQCCScriptsCrypt const&)     = delete;
    void operator=(PQCCScriptsCrypt const&) = delete;

    Q_INVOKABLE QString encryptString(QString plaintext);
    Q_INVOKABLE QString decryptString(QString str);

private:
    PQCCScriptsCrypt();

    quint64 cryptKey;
    QVector<char> cryptKeyParts;

    QRandomGenerator randgen;

};

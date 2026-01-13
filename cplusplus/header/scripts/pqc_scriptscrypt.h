/**************************************************************************
 ** Inspired by SimpleCrypt:                                             **
 ** Copyright (c) 2011, Andre Somers                                     **
 ** All rights reserved.                                                 **
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

#ifndef PQCSCRIPTSCRYPT_H
#define PQCSCRIPTSCRYPT_H

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

class PQCScriptsCrypt : public QObject {

    Q_OBJECT

public:
    static PQCScriptsCrypt& get();
    virtual ~PQCScriptsCrypt();

    PQCScriptsCrypt(PQCScriptsCrypt const&)     = delete;
    void operator=(PQCScriptsCrypt const&) = delete;

    Q_INVOKABLE QString encryptString(QString plaintext);
    Q_INVOKABLE QString decryptString(QString str);

private:
    PQCScriptsCrypt();

    quint64 cryptKey;
    QVector<char> cryptKeyParts;

    QRandomGenerator randgen;

};

#endif

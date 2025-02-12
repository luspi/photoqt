/**************************************************************************
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

#include <scripts/pqc_scriptscrypt.h>

#include <QDateTime>
#include <QIODevice>

PQCScriptsCrypt::PQCScriptsCrypt() {

    // Generate a default encryption key based on the current machine name
    cryptKey = 0;
    QString hostname = QSysInfo::machineHostName();
    if(hostname.length() < 4)
        cryptKey = 63871234;
    else {
        hostname = hostname.remove(5, hostname.length()+1);
        int p = 1;
        for(const auto &character : std::as_const(hostname)) {
            cryptKey += character.unicode()*p;
            p *= 10;
        }
    }

    randgen.seed(uint(QDateTime::currentMSecsSinceEpoch() & 0xFFFF));

    // splitting key
    cryptKeyParts.clear();
    cryptKeyParts.resize(8);
    for (int i=0;i<8;i++) {
        quint64 part = cryptKey;
        for (int j=i; j>0; j--)
            part = part >> 8;
        part = part & 0xff;
        cryptKeyParts[i] = static_cast<char>(part);
    }

}

PQCScriptsCrypt::~PQCScriptsCrypt() {

}

QString PQCScriptsCrypt::encryptString(QString plaintext) {

    QByteArray plaintextArray = plaintext.toUtf8();

    if (cryptKeyParts.isEmpty()) {
        qWarning() << "ERROR: No key set.";
        return QString();
    }

    QByteArray ba = plaintextArray;

    bool flagCompression = false;
    bool flagProtectionChecksum = false;

    QByteArray compressed = qCompress(ba, 9);
    if(compressed.size() < ba.size()) {
        ba = compressed;
        flagCompression = true;
    }

    QByteArray integrityProtection;
    flagProtectionChecksum = true;
    QDataStream s(&integrityProtection, QIODevice::WriteOnly);
    s << qChecksum(ba);

    char randomChar = char(randgen.generate() & 0xFF);
    ba = randomChar + integrityProtection + ba;

    int pos(0);
    char lastChar(0);

    int cnt = ba.size();

    while (pos < cnt) {
        ba[pos] = ba.at(pos) ^ cryptKeyParts.at(pos % 8) ^ lastChar;
        lastChar = ba.at(pos);
        ++pos;
    }

    QByteArray resultArray;
    resultArray.append(flagCompression);
    resultArray.append(flagProtectionChecksum);
    resultArray.append(ba);

    return QString::fromLatin1(resultArray.toBase64());

}

QString PQCScriptsCrypt::decryptString(QString str) {

    if(cryptKeyParts.isEmpty()) {
        qWarning() << "ERROR: No key set.";
        return QString();
    }

    QByteArray ba = QByteArray::fromBase64(str.toLatin1());

    if(ba.size() < 3 )
        return QString();

    bool flagCompression = ba.at(0);
    bool flagProtectionChecksum = ba.at(1);

    ba = ba.mid(2);
    int pos(0);
    int cnt(ba.size());
    char lastChar = 0;

    while (pos < cnt) {
        char currentChar = ba[pos];
        ba[pos] = ba.at(pos) ^ lastChar ^ cryptKeyParts.at(pos % 8);
        lastChar = currentChar;
        ++pos;
    }

    // chop off the random number at the start
    ba = ba.mid(1);

    bool integrityOk(true);
    if(flagProtectionChecksum) {
        if (ba.length() < 2) {
            return QString();
        }
        quint16 storedChecksum;
        {
            QDataStream s(&ba, QIODevice::ReadOnly);
            s >> storedChecksum;
        }
        ba = ba.mid(2);
        quint16 checksum = qChecksum(ba);
        integrityOk = (checksum == storedChecksum);
    }

    if (!integrityOk) {
        return QString();
    }

    if(flagCompression)
        ba = qUncompress(ba);

    return QString::fromUtf8(ba);

}

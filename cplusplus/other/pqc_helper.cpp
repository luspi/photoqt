/**************************************************************************
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
#include <pqc_helper.h>
#include <QSet>

// adapted from:
// https://codebrowser.dev/qt6/qtbase/src/corelib/text/qstringlist.cpp.html#_ZL15accumulatedSizeRK5QListI7QStringEx
qsizetype PQCHelper::setAccumulatedSize(QSet<QString> set, qsizetype seplen) {

    qsizetype result = 0;
    if(!set.isEmpty()) {
        for(const QString &e : set)
            result += e.size() + seplen;
        result -= seplen;
    }
    return result;

}

// adapted from:
// https://codebrowser.dev/qt6/qtbase/src/corelib/text/qstringlist.cpp.html#_ZN9QtPrivate16QStringList_joinERK5QListI7QStringE13QLatin1String
QString PQCHelper::setJoin(QSet<QString> set, QString sep) {

    QString result;
    if(!set.isEmpty()) {
        result.reserve(setAccumulatedSize(set, sep.size()));
        const auto end = set.end();
        auto it = set.begin();
        result += *it;
        while(++it != end) {
            result += sep;
            result += *it;
        }
    }
    return result;

}

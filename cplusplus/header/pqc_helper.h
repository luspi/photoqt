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
#pragma once

#include <QObject>

class PQCHelper {

public:

    static qsizetype setAccumulatedSize(QSet<QString> set, qsizetype seplen);
    static qsizetype setAccumulatedSize(QSet<int> set, qsizetype seplen);
    static QString setJoin(QSet<QString> set, QString sep);
    static QString setJoin(QSet<int> set, QString sep);

    static QString extractInsideFilename(QString path);
    static QString extractInsidePDFFilename(QString path);
    static QString extractInsideARCFilename(QString path);
    static int extractOutsidePDFNumber(QString path);
    static QString extractOutsideARCFilename(QString path);

    static bool zipDirectory(const QString sourceDir, const QString archiveFile);
    static bool unzipDirectory(const QString archiveFile, const QString targetDir);

};

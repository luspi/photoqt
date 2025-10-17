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

#ifndef PQC_RESOLUTIONCACHE
#define PQC_RESOLUTIONCACHE

#include <QObject>
#include <QMap>

class PQCResolutionCache : public QObject {

    Q_OBJECT

public:
    static PQCResolutionCache& get() {
        static PQCResolutionCache instance;
        return instance;
    }
    ~PQCResolutionCache();

    PQCResolutionCache(PQCResolutionCache const&)     = delete;
    void operator=(PQCResolutionCache const&) = delete;

    Q_INVOKABLE void saveResolution(QString filename, QSize res);
    QSize getResolution(QString filename);

private:
    PQCResolutionCache(QObject *parent = nullptr);

    QString getKey(QString filename);
    QMap<QString,QSize> resolution;

};

#endif

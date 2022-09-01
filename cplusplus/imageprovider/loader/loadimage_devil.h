/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#ifndef PQLOADIMAGEDEVIL_H
#define PQLOADIMAGEDEVIL_H

#include <QFile>
#include <QImageReader>
#include <QMutexLocker>

#ifdef DEVIL
#include <IL/il.h>
#endif

#include "../../logger.h"

// class to provide a global mutex
// we need to have one and only one for each thread
// this is needed because DevIL is not threadsafe
class PQLoadImageDevilMutex : public QObject {
    Q_OBJECT
public:
        static PQLoadImageDevilMutex& get() {
            static PQLoadImageDevilMutex instance;
            return instance;
        }
        PQLoadImageDevilMutex(PQLoadImageDevilMutex const&)     = delete;
        void operator=(PQLoadImageDevilMutex const&) = delete;
#ifdef DEVIL
        // DevIL is not threadsafe -> this ensures only one image is loaded at a time
        QMutex devilMutex;
#endif
private:
        PQLoadImageDevilMutex() {}
};

class PQLoadImageDevil {

public:
    PQLoadImageDevil();

    QSize loadSize(QString filename);
    QImage load(QString filename, QSize maxSize, QSize &origSize, bool stopAfterSize = false);

    QString errormsg;

private:

#ifdef DEVIL
    bool checkForError();
#endif

};

#endif // PQLOADIMAGEDEVIL_H

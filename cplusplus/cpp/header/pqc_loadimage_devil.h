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

#ifndef PQCLOADIMAGEDEVIL_H
#define PQCLOADIMAGEDEVIL_H

#include <QMutex>

class QSize;
class QImage;

// class to provide a global mutex
// we need to have one and only one for each thread
// this is needed because DevIL is not threadsafe
class PQCLoadImageDevilMutex {

public:
        static PQCLoadImageDevilMutex& get() {
            static PQCLoadImageDevilMutex instance;
            return instance;
        }
        PQCLoadImageDevilMutex(PQCLoadImageDevilMutex const&)     = delete;
        void operator=(PQCLoadImageDevilMutex const&) = delete;
#ifdef PQMDEVIL
        // DevIL is not threadsafe -> this ensures only one image is loaded at a time
        QMutex devilMutex;
#endif
private:
        PQCLoadImageDevilMutex() {}
};

class PQCLoadImageDevil {

public:
    PQCLoadImageDevil();

    static QSize loadSize(QString filename);
    static QString load(QString filename, QSize maxSize, QSize &origSize, QImage &img);

private:

#ifdef PQMDEVIL
    static QString checkForError();
#endif

};

#endif // PQCLOADIMAGEDEVIL_H

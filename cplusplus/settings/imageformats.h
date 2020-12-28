/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#ifndef PQIMAGEFORMATS_H
#define PQIMAGEFORMATS_H

#include <QObject>
#include <QtSql>
#include <QMessageBox>

#include "../logger.h"
#include "../configfiles.h"

class PQImageFormats : public QObject {

    Q_OBJECT

public:
    static PQImageFormats& get() {
        static PQImageFormats instance;
        return instance;
    }

    PQImageFormats(PQImageFormats const&)     = delete;
    void operator=(PQImageFormats const&) = delete;

    Q_INVOKABLE void readDatabase() {
        readFromDatabase();
    }

    Q_INVOKABLE QVariantList getAllFormats() {
        return formats;
    }
    Q_INVOKABLE void setAllFormats(QVariantList f) {
        writeToDatabase(f);
    }

    Q_INVOKABLE QVector<QString> getEnabledFormats() {
        return formats_enabled;
    }

    Q_INVOKABLE QVector<QString> getDefaultEnabledFormats() {
        return formats_defaultenabled;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsQt() {
        return formats_qt;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsImageMagick() {
        return formats_im;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsGraphicsMagick() {
        return formats_gm;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsLibRaw() {
        return formats_libraw;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsPoppler() {
        return formats_poppler;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsXCFTools() {
        return formats_xcftools;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsDevIL() {
        return formats_devil;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsFreeImage() {
        return formats_freeimage;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsLibArchive() {
        return formats_archive;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsVideo() {
        return formats_video;
    }

    Q_INVOKABLE QVariantMap getMagick() {
        return magick;
    }

private:
    PQImageFormats();

    void readFromDatabase();
    void writeToDatabase(QVariantList f);

    QSqlDatabase db;

    QVariantList formats;

    QVector<QString> formats_enabled;
    QVector<QString> formats_defaultenabled;

    QVector<QString> formats_qt;
    QVector<QString> formats_im;
    QVector<QString> formats_gm;
    QVector<QString> formats_libraw;
    QVector<QString> formats_poppler;
    QVector<QString> formats_xcftools;
    QVector<QString> formats_devil;
    QVector<QString> formats_freeimage;
    QVector<QString> formats_archive;
    QVector<QString> formats_video;

    QVariantMap magick;

    // this is true if reading from the permanent database failed
    // in that case we load the built-in default database but read-only
    bool readonly;

};


#endif // PQIMAGEFORMATS_H

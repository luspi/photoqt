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

#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
#include <Magick++.h>
#endif

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

    Q_INVOKABLE QVector<QString> getEnabledMimeTypes() {
        return mimetypes_enabled;
    }

    Q_INVOKABLE QVector<QString> getDefaultEnabledFormats() {
        return formats_defaultenabled;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsQt() {
        return formats_qt;
    }

    Q_INVOKABLE QVector<QString> getEnabledMimeTypesQt() {
        return mimetypes_qt;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsMagick() {
        return formats_magick;
    }

    Q_INVOKABLE QVector<QString> getEnabledMimeTypesMagick() {
        return mimetypes_magick;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsLibRaw() {
        return formats_libraw;
    }

    Q_INVOKABLE QVector<QString> getEnabledMimeTypesLibRaw() {
        return mimetypes_libraw;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsPoppler() {
        return formats_poppler;
    }

    Q_INVOKABLE QVector<QString> getEnabledMimeTypesPoppler() {
        return mimetypes_poppler;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsXCFTools() {
        return formats_xcftools;
    }

    Q_INVOKABLE QVector<QString> getEnabledMimeTypesXCFTools() {
        return mimetypes_xcftools;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsDevIL() {
        return formats_devil;
    }

    Q_INVOKABLE QVector<QString> getEnabledMimeTypesDevIL() {
        return mimetypes_devil;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsFreeImage() {
        return formats_freeimage;
    }

    Q_INVOKABLE QVector<QString> getEnabledMimeTypesFreeImage() {
        return mimetypes_freeimage;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsLibArchive() {
        return formats_archive;
    }

    Q_INVOKABLE QVector<QString> getEnabledMimeTypesLibArchive() {
        return mimetypes_archive;
    }

    Q_INVOKABLE QVector<QString> getEnabledFormatsVideo() {
        return formats_video;
    }

    Q_INVOKABLE QVector<QString> getEnabledMimeTypesVideo() {
        return mimetypes_video;
    }

    Q_INVOKABLE QVariantMap getMagick() {
        return magick;
    }

    Q_INVOKABLE QVariantMap getMagickMimeType() {
        return magick_mimetype;
    }

private:
    PQImageFormats();

    void readFromDatabase();
    void writeToDatabase(QVariantList f);

    QSqlDatabase db;

    QVariantList formats;

    QVector<QString> formats_enabled;
    QVector<QString> mimetypes_enabled;
    QVector<QString> formats_defaultenabled;

    QVector<QString> formats_qt;
    QVector<QString> mimetypes_qt;
    QVector<QString> formats_magick;
    QVector<QString> mimetypes_magick;
    QVector<QString> formats_libraw;
    QVector<QString> mimetypes_libraw;
    QVector<QString> formats_poppler;
    QVector<QString> mimetypes_poppler;
    QVector<QString> formats_xcftools;
    QVector<QString> mimetypes_xcftools;
    QVector<QString> formats_devil;
    QVector<QString> mimetypes_devil;
    QVector<QString> formats_freeimage;
    QVector<QString> mimetypes_freeimage;
    QVector<QString> formats_archive;
    QVector<QString> mimetypes_archive;
    QVector<QString> formats_video;
    QVector<QString> mimetypes_video;

    QVariantMap magick;
    QVariantMap magick_mimetype;

    // this is true if reading from the permanent database failed
    // in that case we load the built-in default database but read-only
    bool readonly;

};


#endif // PQIMAGEFORMATS_H

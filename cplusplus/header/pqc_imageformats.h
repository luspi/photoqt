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
#include <QVariantMap>
#include <QtSql/QSqlDatabase>

class PQCImageFormats : public QObject {

    Q_OBJECT

public:
    static PQCImageFormats& get() {
        static PQCImageFormats instance;
        return instance;
    }

    PQCImageFormats(PQCImageFormats const&)     = delete;
    void operator=(PQCImageFormats const&) = delete;

    void readDatabase() {
        readFromDatabase();
    }

    const QVariantList getAllFormats() {
        return formats;
    }
    void setAllFormats(QVariantList f) {
        writeToDatabase(f);
    }

    const QStringList getEnabledFormats() {
        return formats_enabled;
    }

    const QStringList getEnabledMimeTypes() {
        return mimetypes_enabled;
    }

    const QStringList getEnabledFormatsQt() {
        return formats_qt;
    }

    const QStringList getEnabledMimeTypesQt() {
        return mimetypes_qt;
    }

    const QStringList getEnabledFormatsResvg() {
        return formats_resvg;
    }

    const QStringList getEnabledMimeTypesResvg() {
        return mimetypes_resvg;
    }

    const QStringList getEnabledFormatsLibVips() {
        return formats_libvips;
    }

    const QStringList getEnabledMimeTypesLibVips() {
        return mimetypes_libvips;
    }

    const QStringList getEnabledFormatsMagick() {
        return formats_magick;
    }

    const QStringList getEnabledMimeTypesMagick() {
        return mimetypes_magick;
    }

    const QStringList getEnabledFormatsLibRaw() {
        return formats_libraw;
    }

    const QStringList getEnabledMimeTypesLibRaw() {
        return mimetypes_libraw;
    }

    const QStringList getEnabledFormatsPoppler() {
        return formats_poppler;
    }

    const QStringList getEnabledMimeTypesPoppler() {
        return mimetypes_poppler;
    }

    const QStringList getEnabledFormatsXCFTools() {
        return formats_xcftools;
    }

    const QStringList getEnabledMimeTypesXCFTools() {
        return mimetypes_xcftools;
    }

    const QStringList getEnabledFormatsDevIL() {
        return formats_devil;
    }

    const QStringList getEnabledMimeTypesDevIL() {
        return mimetypes_devil;
    }

    const QStringList getEnabledFormatsFreeImage() {
        return formats_freeimage;
    }

    const QStringList getEnabledMimeTypesFreeImage() {
        return mimetypes_freeimage;
    }

    const QStringList getEnabledFormatsLibArchive() {
        return formats_archive;
    }

    const QStringList getEnabledMimeTypesLibArchive() {
        return mimetypes_archive;
    }

    const QStringList getEnabledFormatsVideo() {
        return formats_video;
    }

    const QStringList getEnabledMimeTypesVideo() {
        return mimetypes_video;
    }

    const QStringList getEnabledFormatsLibmpv() {
        return formats_libmpv;
    }

    const QStringList getEnabledMimeTypesLibmpv() {
        return mimetypes_libmpv;
    }

    const QStringList getEnabledFormatsLibsai() {
        return formats_libsai;
    }

    const QStringList getEnabledMimeTypesLibsai() {
        return mimetypes_libsai;
    }

    const QVariantHash getMagick() {
        return magick;
    }

    const QVariantHash getMagickMimeType() {
        return magick_mimetype;
    }

    int getEnabledFormatsNum() {
        return formats_enabled.count();
    }

    QVariantList getWriteableFormats();
    QString getFormatName(int uniqueid);
    QStringList getFormatEndings(int uniqueid);
    QVariantMap getFormatsInfo(int uniqueid);
    int detectFormatId(QString filename);
    int getWriteStatus(int uniqueid);

    bool enterNewFormat(QString endings, QString mimetypes, QString description, QString category, int enabled, int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv, int libsai, QString im_gm_magick, QString qt_formatname, bool silentIfExists);
    bool updateFormatByEnding(QString endings, QString mimetypes, QString description, QString category, int enabled, int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv, int libsai, QString im_gm_magick, QString qt_formatname, bool silentIfExists);

    void closeDatabase();
    void reopenDatabase();

public Q_SLOTS:
    void resetToDefault();

Q_SIGNALS:
    void formatsUpdated();

private:
    PQCImageFormats();

    int checkForUpdateOrNew();

    void readFromDatabase();
    void writeToDatabase(QVariantList f);

    QSqlDatabase db;

    QVariantList formats;

    QStringList formats_enabled;
    QStringList mimetypes_enabled;

    QStringList formats_qt;
    QStringList mimetypes_qt;
    QStringList formats_resvg;
    QStringList mimetypes_resvg;
    QStringList formats_libvips;
    QStringList mimetypes_libvips;
    QStringList formats_magick;
    QStringList mimetypes_magick;
    QStringList formats_libraw;
    QStringList mimetypes_libraw;
    QStringList formats_poppler;
    QStringList mimetypes_poppler;
    QStringList formats_xcftools;
    QStringList mimetypes_xcftools;
    QStringList formats_devil;
    QStringList mimetypes_devil;
    QStringList formats_freeimage;
    QStringList mimetypes_freeimage;
    QStringList formats_archive;
    QStringList mimetypes_archive;
    QStringList formats_video;
    QStringList mimetypes_video;
    QStringList formats_libmpv;
    QStringList mimetypes_libmpv;
    QStringList formats_libsai;
    QStringList mimetypes_libsai;

    QVariantHash magick;
    QVariantHash magick_mimetype;

    // this is true if reading from the permanent database failed
    // in that case we load the built-in default database but read-only
    bool readonly;

};

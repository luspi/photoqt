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

    /*****************/

    const QStringList getEnabledFormats() {
        return formats_enabled;
    }
    const QStringList getEnabledMimeTypes() {
        return mimetypes_enabled;
    }

    const QSet<QString> getEnabledFormatsSet() {
        return formats_enabled_set;
    }
    const QSet<QString> getEnabledMimeTypesSet() {
        return mimetypes_enabled_set;
    }

    /***************************************************/

    const QStringList getEnabledFormatsQt() {
        return formats_qt;
    }
    const QStringList getEnabledMimeTypesQt() {
        return mimetypes_qt;
    }
    const QSet<QString> getEnabledFormatsQtSet() {
        return formats_qt_set;
    }
    const QSet<QString> getEnabledMimeTypesQtSet() {
        return mimetypes_qt_set;
    }

    const QStringList getEnabledFormatsResvg() {
        return formats_resvg;
    }
    const QStringList getEnabledMimeTypesResvg() {
        return mimetypes_resvg;
    }
    const QSet<QString> getEnabledFormatsResvgSet() {
        return formats_resvg_set;
    }
    const QSet<QString> getEnabledMimeTypesResvgSet() {
        return mimetypes_resvg_set;
    }

    const QStringList getEnabledFormatsLibVips() {
        return formats_libvips;
    }
    const QStringList getEnabledMimeTypesLibVips() {
        return mimetypes_libvips;
    }
    const QSet<QString> getEnabledFormatsLibVipsSet() {
        return formats_libvips_set;
    }
    const QSet<QString> getEnabledMimeTypesLibVipsSet() {
        return mimetypes_libvips_set;
    }

    const QStringList getEnabledFormatsMagick() {
        return formats_magick;
    }
    const QStringList getEnabledMimeTypesMagick() {
        return mimetypes_magick;
    }
    const QSet<QString> getEnabledFormatsMagickSet() {
        return formats_magick_set;
    }
    const QSet<QString> getEnabledMimeTypesMagickSet() {
        return mimetypes_magick_set;
    }

    const QStringList getEnabledFormatsLibRaw() {
        return formats_libraw;
    }
    const QStringList getEnabledMimeTypesLibRaw() {
        return mimetypes_libraw;
    }
    const QSet<QString> getEnabledFormatsLibRawSet() {
        return formats_libraw_set;
    }
    const QSet<QString> getEnabledMimeTypesLibRawSet() {
        return mimetypes_libraw_set;
    }

    const QStringList getEnabledFormatsPoppler() {
        return formats_poppler;
    }
    const QStringList getEnabledMimeTypesPoppler() {
        return mimetypes_poppler;
    }
    const QSet<QString> getEnabledFormatsPopplerSet() {
        return formats_poppler_set;
    }
    const QSet<QString> getEnabledMimeTypesPopplerSet() {
        return mimetypes_poppler_set;
    }

    const QStringList getEnabledFormatsXCFTools() {
        return formats_xcftools;
    }
    const QStringList getEnabledMimeTypesXCFTools() {
        return mimetypes_xcftools;
    }
    const QSet<QString> getEnabledFormatsXCFToolsSet() {
        return formats_xcftools_set;
    }
    const QSet<QString> getEnabledMimeTypesXCFToolsSet() {
        return mimetypes_xcftools_set;
    }

    const QStringList getEnabledFormatsDevIL() {
        return formats_devil;
    }
    const QStringList getEnabledMimeTypesDevIL() {
        return mimetypes_devil;
    }
    const QSet<QString> getEnabledFormatsDevILSet() {
        return formats_devil_set;
    }
    const QSet<QString> getEnabledMimeTypesDevILSet() {
        return mimetypes_devil_set;
    }

    const QStringList getEnabledFormatsLibArchive() {
        return formats_archive;
    }
    const QStringList getEnabledMimeTypesLibArchive() {
        return mimetypes_archive;
    }
    const QSet<QString> getEnabledFormatsLibArchiveSet() {
        return formats_archive_set;
    }
    const QSet<QString> getEnabledMimeTypesLibArchiveSet() {
        return mimetypes_archive_set;
    }

    const QStringList getEnabledFormatsVideo() {
        return formats_video;
    }
    const QStringList getEnabledMimeTypesVideo() {
        return mimetypes_video;
    }
    const QSet<QString> getEnabledFormatsVideoSet() {
        return formats_video_set;
    }
    const QSet<QString> getEnabledMimeTypesVideoSet() {
        return mimetypes_video_set;
    }

    const QStringList getEnabledFormatsLibmpv() {
        return formats_libmpv;
    }
    const QStringList getEnabledMimeTypesLibmpv() {
        return mimetypes_libmpv;
    }
    const QSet<QString> getEnabledFormatsLibmpvSet() {
        return formats_libmpv_set;
    }
    const QSet<QString> getEnabledMimeTypesLibmpvSet() {
        return mimetypes_libmpv_set;
    }

    const QStringList getEnabledFormatsLibsai() {
        return formats_libsai;
    }
    const QStringList getEnabledMimeTypesLibsai() {
        return mimetypes_libsai;
    }
    const QSet<QString> getEnabledFormatsLibsaiSet() {
        return formats_libsai_set;
    }
    const QSet<QString> getEnabledMimeTypesLibsaiSet() {
        return mimetypes_libsai_set;
    }

    const QVariantHash getMagick() {
        return magick;
    }

    const QVariantHash getMagickMimeType() {
        return magick_mimetype;
    }

    int getEnabledFormatsNum() {
        return formats_enabled_set.count();
    }

    QVariantList getWriteableFormats();
    QString getFormatName(int uniqueid);
    QStringList getFormatEndings(int uniqueid);
    QVariantMap getFormatsInfo(int uniqueid);
    int detectFormatId(QString filename);
    int getWriteStatus(int uniqueid);

    bool enterNewFormat(QString endings, QString mimetypes, QString description, QString category, int enabled, int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int archive, int video, int libmpv, int libsai, QString im_gm_magick, QString qt_formatname, bool silentIfExists);
    bool updateFormatByEnding(QString endings, QString mimetypes, QString description, QString category, int enabled, int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int archive, int video, int libmpv, int libsai, QString im_gm_magick, QString qt_formatname, bool silentIfExists);

    void closeDatabase();
    void reopenDatabase();

public Q_SLOTS:
    void resetToDefault();

Q_SIGNALS:
    void formatsUpdated();

private:
    PQCImageFormats();
    ~PQCImageFormats();

    int checkForUpdateOrNew();

    void readFromDatabase();
    void writeToDatabase(QVariantList f);

    QSqlDatabase db;

    QVariantList formats;

    QStringList formats_enabled;
    QStringList mimetypes_enabled;

    QSet<QString> formats_enabled_set;
    QSet<QString> mimetypes_enabled_set;

    QStringList   formats_qt;
    QSet<QString> formats_qt_set;
    QStringList   mimetypes_qt;
    QSet<QString> mimetypes_qt_set;
    QStringList   formats_resvg;
    QSet<QString> formats_resvg_set;
    QStringList   mimetypes_resvg;
    QSet<QString> mimetypes_resvg_set;
    QStringList   formats_libvips;
    QSet<QString> formats_libvips_set;
    QStringList   mimetypes_libvips;
    QSet<QString> mimetypes_libvips_set;
    QStringList   formats_magick;
    QSet<QString> formats_magick_set;
    QStringList   mimetypes_magick;
    QSet<QString> mimetypes_magick_set;
    QStringList   formats_libraw;
    QSet<QString> formats_libraw_set;
    QStringList   mimetypes_libraw;
    QSet<QString> mimetypes_libraw_set;
    QStringList   formats_poppler;
    QSet<QString> formats_poppler_set;
    QStringList   mimetypes_poppler;
    QSet<QString> mimetypes_poppler_set;
    QStringList   formats_xcftools;
    QSet<QString> formats_xcftools_set;
    QStringList   mimetypes_xcftools;
    QSet<QString> mimetypes_xcftools_set;
    QStringList   formats_devil;
    QSet<QString> formats_devil_set;
    QStringList   mimetypes_devil;
    QSet<QString> mimetypes_devil_set;
    QStringList   formats_archive;
    QSet<QString> formats_archive_set;
    QStringList   mimetypes_archive;
    QSet<QString> mimetypes_archive_set;
    QStringList   formats_video;
    QSet<QString> formats_video_set;
    QStringList   mimetypes_video;
    QSet<QString> mimetypes_video_set;
    QStringList   formats_libmpv;
    QSet<QString> formats_libmpv_set;
    QStringList   mimetypes_libmpv;
    QSet<QString> mimetypes_libmpv_set;
    QStringList   formats_libsai;
    QSet<QString> formats_libsai_set;
    QStringList   mimetypes_libsai;
    QSet<QString> mimetypes_libsai_set;

    QVariantHash magick;
    QVariantHash magick_mimetype;

    // this is true if reading from the permanent database failed
    // in that case we load the built-in default database but read-only
    bool readonly;

};

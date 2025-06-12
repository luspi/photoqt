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

#ifndef PQCIMAGEFORMATS_H
#define PQCIMAGEFORMATS_H

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

    Q_INVOKABLE void readDatabase() {
        readFromDatabase();
    }

    Q_INVOKABLE QVariantList getAllFormats() {
        return formats;
    }
    Q_INVOKABLE void setAllFormats(QVariantList f) {
        writeToDatabase(f);
    }

    Q_INVOKABLE QStringList getEnabledFormats() {
        return formats_enabled;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypes() {
        return mimetypes_enabled;
    }

    Q_INVOKABLE QStringList getEnabledFormatsQt() {
        return formats_qt;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesQt() {
        return mimetypes_qt;
    }

    Q_INVOKABLE QStringList getEnabledFormatsResvg() {
        return formats_resvg;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesResvg() {
        return mimetypes_resvg;
    }

    Q_INVOKABLE QStringList getEnabledFormatsLibVips() {
        return formats_libvips;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesLibVips() {
        return mimetypes_libvips;
    }

    Q_INVOKABLE QStringList getEnabledFormatsMagick() {
        return formats_magick;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesMagick() {
        return mimetypes_magick;
    }

    Q_INVOKABLE QStringList getEnabledFormatsLibRaw() {
        return formats_libraw;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesLibRaw() {
        return mimetypes_libraw;
    }

    Q_INVOKABLE QStringList getEnabledFormatsPoppler() {
        return formats_poppler;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesPoppler() {
        return mimetypes_poppler;
    }

    Q_INVOKABLE QStringList getEnabledFormatsXCFTools() {
        return formats_xcftools;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesXCFTools() {
        return mimetypes_xcftools;
    }

    Q_INVOKABLE QStringList getEnabledFormatsDevIL() {
        return formats_devil;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesDevIL() {
        return mimetypes_devil;
    }

    Q_INVOKABLE QStringList getEnabledFormatsFreeImage() {
        return formats_freeimage;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesFreeImage() {
        return mimetypes_freeimage;
    }

    Q_INVOKABLE QStringList getEnabledFormatsLibArchive() {
        return formats_archive;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesLibArchive() {
        return mimetypes_archive;
    }

    Q_INVOKABLE QStringList getEnabledFormatsVideo() {
        return formats_video;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesVideo() {
        return mimetypes_video;
    }

    Q_INVOKABLE QStringList getEnabledFormatsLibmpv() {
        return formats_libmpv;
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesLibmpv() {
        return mimetypes_libmpv;
    }

    Q_INVOKABLE QVariantHash getMagick() {
        return magick;
    }

    Q_INVOKABLE QVariantHash getMagickMimeType() {
        return magick_mimetype;
    }

    Q_INVOKABLE int getEnabledFormatsNum() {
        return formats_enabled.count();
    }

    Q_INVOKABLE QVariantList getWriteableFormats();
    Q_INVOKABLE QString getFormatName(int uniqueid);
    Q_INVOKABLE QStringList getFormatEndings(int uniqueid);
    QVariantMap getFormatsInfo(int uniqueid);
    Q_INVOKABLE int detectFormatId(QString filename);
    Q_INVOKABLE int getWriteStatus(int uniqueid);

    bool enterNewFormat(QString endings, QString mimetypes, QString description, QString category, int enabled, int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv, QString im_gm_magick, QString qt_formatname, bool silentIfExists);
    bool updateFormatByEnding(QString endings, QString mimetypes, QString description, QString category, int enabled, int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv, QString im_gm_magick, QString qt_formatname, bool silentIfExists);

    Q_INVOKABLE void closeDatabase();
    Q_INVOKABLE void reopenDatabase();

public Q_SLOTS:
    Q_INVOKABLE void restoreDefaults();

Q_SIGNALS:
    void formatsUpdated();

private:
    PQCImageFormats();

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

    QVariantHash magick;
    QVariantHash magick_mimetype;

    // this is true if reading from the permanent database failed
    // in that case we load the built-in default database but read-only
    bool readonly;

};


#endif // PQIMAGEFORMATS_H

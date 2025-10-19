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

    void setup() {}

    void readDatabase() {
        readFromDatabase();
    }

    QVariantList getAllFormats() {
        return formats;
    }
    void setAllFormats(QVariantList f) {
        writeToDatabase(f);
    }

    QStringList getEnabledFormats() {
        return formats_enabled;
    }

    QStringList getEnabledMimeTypes() {
        return mimetypes_enabled;
    }

    QStringList getEnabledFormatsQt() {
        return formats_qt;
    }

    QStringList getEnabledMimeTypesQt() {
        return mimetypes_qt;
    }

    QStringList getEnabledFormatsResvg() {
        return formats_resvg;
    }

    QStringList getEnabledMimeTypesResvg() {
        return mimetypes_resvg;
    }

    QStringList getEnabledFormatsLibVips() {
        return formats_libvips;
    }

    QStringList getEnabledMimeTypesLibVips() {
        return mimetypes_libvips;
    }

    QStringList getEnabledFormatsMagick() {
        return formats_magick;
    }

    QStringList getEnabledMimeTypesMagick() {
        return mimetypes_magick;
    }

    QStringList getEnabledFormatsLibRaw() {
        return formats_libraw;
    }

    QStringList getEnabledMimeTypesLibRaw() {
        return mimetypes_libraw;
    }

    QStringList getEnabledFormatsPoppler() {
        return formats_poppler;
    }

    QStringList getEnabledMimeTypesPoppler() {
        return mimetypes_poppler;
    }

    QStringList getEnabledFormatsXCFTools() {
        return formats_xcftools;
    }

    QStringList getEnabledMimeTypesXCFTools() {
        return mimetypes_xcftools;
    }

    QStringList getEnabledFormatsDevIL() {
        return formats_devil;
    }

    QStringList getEnabledMimeTypesDevIL() {
        return mimetypes_devil;
    }

    QStringList getEnabledFormatsFreeImage() {
        return formats_freeimage;
    }

    QStringList getEnabledMimeTypesFreeImage() {
        return mimetypes_freeimage;
    }

    QStringList getEnabledFormatsLibArchive() {
        return formats_archive;
    }

    QStringList getEnabledMimeTypesLibArchive() {
        return mimetypes_archive;
    }

    QStringList getEnabledFormatsVideo() {
        return formats_video;
    }

    QStringList getEnabledMimeTypesVideo() {
        return mimetypes_video;
    }

    QStringList getEnabledFormatsLibmpv() {
        return formats_libmpv;
    }

    QStringList getEnabledMimeTypesLibmpv() {
        return mimetypes_libmpv;
    }

    QStringList getEnabledFormatsLibsai() {
        return formats_libsai;
    }

    QStringList getEnabledMimeTypesLibsai() {
        return mimetypes_libsai;
    }

    QVariantHash getMagick() {
        return magick;
    }

    QVariantHash getMagickMimeType() {
        return magick_mimetype;
    }

    int getEnabledFormatsNum() {
        return formats_enabled.count();
    }

    QVariantList getWriteableFormats();
    QString getFormatName(int uniqueid);
    QVariantMap getFormatsInfo(int uniqueid);
    int getWriteStatus(int uniqueid);

    bool enterNewFormat(QString endings, QString mimetypes, QString description, QString category, int enabled, int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv, int libsai, QString im_gm_magick, QString qt_formatname, bool silentIfExists);
    bool updateFormatByEnding(QString endings, QString mimetypes, QString description, QString category, int enabled, int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler, int xcftools, int devil, int freeimage, int archive, int video, int libmpv, int libsai, QString im_gm_magick, QString qt_formatname, bool silentIfExists);

    void closeDatabase();
    void reopenDatabase();

public Q_SLOTS:
    void resetToDefault();

Q_SIGNALS:
    void formatsUpdated();

private Q_SLOTS:
    void handleSocketMessage(QString what, QStringList message);

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

    QHash<int, QStringList> m_id2Endings;
    QHash<QString, int> m_endings2Id;
    QHash<int, QString> m_id2Description;
    QHash<QString,QString> m_ending2QtFormatName;
    QHash<QString,QStringList> m_ending2Magick;

    // this is true if reading from the permanent database failed
    // in that case we load the built-in default database but read-only
    bool readonly;

};


#endif // PQIMAGEFORMATS_H

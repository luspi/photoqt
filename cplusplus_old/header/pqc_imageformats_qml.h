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
#pragma once

#include <QObject>
#include <QQmlEngine>
#include <pqc_imageformats.h>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton is a wrapper for the C++ class
//            This class here can ONLY be used from QML!
//
/*************************************************************/
/*************************************************************/

class PQCImageFormatsQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCImageFormats)

public:
    explicit PQCImageFormatsQML() {
        connect(&PQCImageFormats::get(), &PQCImageFormats::formatsUpdated, this, &PQCImageFormatsQML::formatsUpdated);
    }

    Q_INVOKABLE void readDatabase() {
        PQCImageFormats::get().readDatabase();
    }

    Q_INVOKABLE QVariantList getAllFormats() {
        return PQCImageFormats::get().getAllFormats();
    }
    Q_INVOKABLE void setAllFormats(QVariantList f) {
        PQCImageFormats::get().setAllFormats(f);
    }

    Q_INVOKABLE QStringList getEnabledFormats() {
        return PQCImageFormats::get().getEnabledFormats();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypes() {
        return PQCImageFormats::get().getEnabledMimeTypes();
    }

    Q_INVOKABLE QStringList getEnabledFormatsQt() {
        return PQCImageFormats::get().getEnabledFormatsQt();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesQt() {
        return PQCImageFormats::get().getEnabledMimeTypesQt();
    }

    Q_INVOKABLE QStringList getEnabledFormatsResvg() {
        return PQCImageFormats::get().getEnabledFormatsResvg();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesResvg() {
        return PQCImageFormats::get().getEnabledMimeTypesResvg();
    }

    Q_INVOKABLE QStringList getEnabledFormatsLibVips() {
        return PQCImageFormats::get().getEnabledFormatsLibVips();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesLibVips() {
        return PQCImageFormats::get().getEnabledMimeTypesLibVips();
    }

    Q_INVOKABLE QStringList getEnabledFormatsMagick() {
        return PQCImageFormats::get().getEnabledFormatsMagick();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesMagick() {
        return PQCImageFormats::get().getEnabledMimeTypesMagick();
    }

    Q_INVOKABLE QStringList getEnabledFormatsLibRaw() {
        return PQCImageFormats::get().getEnabledFormatsLibRaw();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesLibRaw() {
        return PQCImageFormats::get().getEnabledMimeTypesLibRaw();
    }

    Q_INVOKABLE QStringList getEnabledFormatsPoppler() {
        return PQCImageFormats::get().getEnabledFormatsPoppler();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesPoppler() {
        return PQCImageFormats::get().getEnabledMimeTypesPoppler();
    }

    Q_INVOKABLE QStringList getEnabledFormatsXCFTools() {
        return PQCImageFormats::get().getEnabledFormatsXCFTools();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesXCFTools() {
        return PQCImageFormats::get().getEnabledMimeTypesXCFTools();
    }

    Q_INVOKABLE QStringList getEnabledFormatsDevIL() {
        return PQCImageFormats::get().getEnabledFormatsDevIL();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesDevIL() {
        return PQCImageFormats::get().getEnabledMimeTypesDevIL();
    }

    Q_INVOKABLE QStringList getEnabledFormatsFreeImage() {
        return PQCImageFormats::get().getEnabledFormatsFreeImage();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesFreeImage() {
        return PQCImageFormats::get().getEnabledMimeTypesFreeImage();
    }

    Q_INVOKABLE QStringList getEnabledFormatsLibArchive() {
        return PQCImageFormats::get().getEnabledFormatsLibArchive();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesLibArchive() {
        return PQCImageFormats::get().getEnabledMimeTypesLibArchive();
    }

    Q_INVOKABLE QStringList getEnabledFormatsVideo() {
        return PQCImageFormats::get().getEnabledFormatsVideo();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesVideo() {
        return PQCImageFormats::get().getEnabledMimeTypesVideo();
    }

    Q_INVOKABLE QStringList getEnabledFormatsLibmpv() {
        return PQCImageFormats::get().getEnabledFormatsLibmpv();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesLibmpv() {
        return PQCImageFormats::get().getEnabledMimeTypesLibmpv();
    }

    Q_INVOKABLE QStringList getEnabledFormatsLibsai() {
        return PQCImageFormats::get().getEnabledFormatsLibsai();
    }

    Q_INVOKABLE QStringList getEnabledMimeTypesLibsai() {
        return PQCImageFormats::get().getEnabledMimeTypesLibsai();
    }

    Q_INVOKABLE QVariantHash getMagick() {
        return PQCImageFormats::get().getMagick();
    }

    Q_INVOKABLE QVariantHash getMagickMimeType() {
        return PQCImageFormats::get().getMagickMimeType();
    }

    Q_INVOKABLE int getEnabledFormatsNum() {
        return PQCImageFormats::get().getEnabledFormatsNum();
    }

    Q_INVOKABLE QVariantList getWriteableFormats() {
        return PQCImageFormats::get().getWriteableFormats();
    }

    Q_INVOKABLE QString getFormatName(int uniqueid) {
        return PQCImageFormats::get().getFormatName(uniqueid);
    }

    Q_INVOKABLE QStringList getFormatEndings(int uniqueid) {
        return PQCImageFormats::get().getFormatEndings(uniqueid);
    }

    Q_INVOKABLE QVariantMap getFormatsInfo(int uniqueid) {
        return PQCImageFormats::get().getFormatsInfo(uniqueid);
    }

    Q_INVOKABLE int detectFormatId(QString filename) {
        return PQCImageFormats::get().detectFormatId(filename);
    }

    Q_INVOKABLE int getWriteStatus(int uniqueid) {
        return PQCImageFormats::get().getWriteStatus(uniqueid);
    }

    bool enterNewFormat(QString endings, QString mimetypes, QString description, QString category,
                        int enabled, int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler,
                        int xcftools, int devil, int freeimage, int archive, int video, int libmpv, int libsai,
                        QString im_gm_magick, QString qt_formatname, bool silentIfExists) {
        return PQCImageFormats::get().enterNewFormat(endings, mimetypes, description, category,
                                                     enabled, qt, resvg, libvips, imagemagick, graphicsmagick, libraw, poppler, xcftools, devil,
                                                     freeimage, archive, video, libmpv, libsai, im_gm_magick, qt_formatname, silentIfExists);
    }

    bool updateFormatByEnding(QString endings, QString mimetypes, QString description, QString category,
                              int enabled, int qt, int resvg, int libvips, int imagemagick, int graphicsmagick, int libraw, int poppler,
                              int xcftools, int devil, int freeimage, int archive, int video, int libmpv, int libsai,
                              QString im_gm_magick, QString qt_formatname, bool silentIfExists) {
        return PQCImageFormats::get().updateFormatByEnding(endings, mimetypes, description, category, enabled, qt, resvg, libvips, imagemagick,
                                                           graphicsmagick, libraw, poppler, xcftools, devil, freeimage, archive, video, libmpv,
                                                           libsai, im_gm_magick, qt_formatname, silentIfExists);
    }

    Q_INVOKABLE void closeDatabase() {
        PQCImageFormats::get().closeDatabase();
    }

    Q_INVOKABLE void reopenDatabase() {
        PQCImageFormats::get().reopenDatabase();
    }

public Q_SLOTS:
    Q_INVOKABLE void resetToDefault() { PQCImageFormats::get().resetToDefault(); }

Q_SIGNALS:
    void formatsUpdated();

};

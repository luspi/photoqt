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

// Every image plugin has to inherit this class and implement all its methods

class PQCImagePlugin : public QObject {

    Q_OBJECT

public:
    virtual ~PQCImagePlugin() = default;

    // the printable name of this plugin
    virtual const QString name() = 0;

    // which category this falls under
    virtual const QString category() = 0;
    \
    // is this plugin suitable for preloading?
    virtual const bool canPreload() = 0;

    // either all formats are enabled or disabled by default
    virtual const bool enabledByDefault() = 0;

    // get the formats and mime types that are supported for READING
    virtual const QSet<QString> getAllSuffixes() = 0;
    virtual const QSet<QString> getAllMimetypes() = 0;
    // these are the NOT TOGGLES ones
    virtual const QSet<QString> getSuffixes() = 0;
    virtual const QSet<QString> getMimetypes() = 0;
    // these are the TOGGLED ones
    virtual const QSet<QString> getToggledSuffixes() = 0;
    virtual const QSet<QString> getToggledMimetypes() = 0;

    // the description for a suffix
    virtual const QString getDescription(QString suffix) = 0;
    // the suffixes for a description
    virtual const QSet<QString> getSuffixesForFormatByDescription(QString description) = 0;
    // whether this plugin supports the format based on its description
    virtual const bool supportsFormatByDescription(QString description) = 0;
    // whether this format is supported and enabled based on its description
    virtual const bool isEnabled(QString description) = 0;

    // all formats that can be written
    virtual const QSet<QString> getWritableSuffixes() = 0;
    // write the image to the target path
    virtual const bool writeImage(QImage img, QString targetPath) = 0;

    // LOAD the size (resolution) of the image at the specified path
    virtual const QSize loadSize(QString path) = 0;

    // LOAD the image from the specified path at its requested Size
    // > origSize is set to the original size of the image (before scaling)
    // > error holding any potential error message
    virtual const QImage loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) = 0;

    // toggle the enabled status of the specified formats
    virtual void setEnabled(QString description, bool enabled) = 0;

Q_SIGNALS:
    void formatsUpdated();

};

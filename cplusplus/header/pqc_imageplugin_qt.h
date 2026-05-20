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

#include <pqc_imageplugin.h>
#include <QSet>

class PQCImagePluginQt : public PQCImagePlugin {

public:
    PQCImagePluginQt(QString settingsDir);

    const QString name() override { return "Qt"; }
    const bool canPreload() override { return true; }
    const bool getEnabledByDefault() override { return true; }

    const QSet<QString> getSuffixes()  override { return m_suffixes; }
    const QSet<QString> getMimetypes() override { return m_mimetypes; }
    const QSet<QString> getToggledSuffixes()  override { return m_toggledSuffixes; }
    const QSet<QString> getToggledMimetypes() override { return m_toggledMimetypes; }
    const QSet<QString> getAllSuffixes()  override { return m_allSuffixes; }
    const QSet<QString> getAllMimetypes() override { return m_allMimetypes; }

    const QString getDescription(QString suffix) override;

    // these are the formats that do NOT match the enabledByDefault property
    const QSet<QString> getToggledFormats() override {
        return m_toggledSuffixes;
    }

    // can this format be written by this plugin?
    const bool canWrite(QString path) override;
    // write the image to the target path
    const bool writeImage(QImage img, QString targetPath) override;

    // LOAD the size (resolution) of the image at the specified path
    const QSize getSize(QString path) override;

    // LOAD the image from the specified path at its requested Size
    // > origSize is set to the original size of the image (before scaling)
    // > error holding any potential error message
    const QImage getImage(QString path, QSize requestedSize, QSize &origSize, QString &error) override;

    // toggle the enabled status of the specified formats and/or mimetypes
    void setEnabled(QString suffix, QString mimetype, bool enabled) override;

private:
    QSet<QString> m_suffixes;
    QSet<QString> m_mimetypes;
    QSet<QString> m_toggledSuffixes;
    QSet<QString> m_toggledMimetypes;
    QSet<QString> m_allSuffixes;
    QSet<QString> m_allMimetypes;

    QHash<QString,QString> suffix2description;

    QString m_settingsDir;

    void loadFormats();
    void saveFormats();

// Q_SIGNALS:
//     void formatsUpdated() override;

};

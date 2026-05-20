/**************************************************************************
 * *                                                                      **
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

class PQCImagePluginQt : PQCImagePlugin {

public:
    PQCImagePluginQt(QString settingsFile);

    const QString name() override { return ""; }
    const bool canPreload() override { return true; }
    const bool getEnabledByDefault() override { return true; }

    const QSet<QString> getSupportedSuffixes() override {
        return m_supportedSuffixes;
    }
    const QSet<QString> getSupportedMimetypes() override {
        return m_supportedMimetypes;
    }

    const QSet<QString> getToggledFormats() override {
        return m_toggledFormats;
    }

    const bool canWrite(QString path) override;
    const bool writeImage(QImage img, QString targetPath) override;

    const QSize getSize(QString path) override;
    const QImage getImage(QString path, QSize requestedSize, QSize &origSize, QString &error) override;

    void setEnabled(QString suffix, QString mimetype, bool enabled) override;

private:
    QSet<QString> m_supportedSuffixes;
    QSet<QString> m_supportedMimetypes;
    QSet<QString> m_toggledFormats;
    QSet<QString> m_toggledMimetypes;

    void loadFormats();
    void saveFormats();

};

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
    const QString category() override { return "image"; }
    const bool canPreload() override { return true; }
    const bool enabledByDefault() override { return true; }

    const QSet<QString> getSuffixes()  override { return m_suffixes; }
    const QSet<QString> getMimetypes() override { return m_mimetypes; }
    const QSet<QString> getToggledSuffixes()  override { return m_toggledSuffixes; }
    const QSet<QString> getToggledMimetypes() override { return m_toggledMimetypes; }
    const QSet<QString> getAllSuffixes()  override { return m_allSuffixes; }
    const QSet<QString> getAllMimetypes() override { return m_allMimetypes; }

    const QString getDescription(QString suffix) override;
    const bool supportsFormatByDescription(QString description) override;

    const QSet<QString> getWritableSuffixes() override;
    const bool writeImage(QImage img, QString targetPath) override;

    const QSize loadSize(QString path) override;
    const QImage loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) override;

    void setEnabled(QString description, bool enabled) override;

private:
    QSet<QString> m_suffixes;
    QSet<QString> m_mimetypes;
    QSet<QString> m_toggledSuffixes;
    QSet<QString> m_toggledMimetypes;
    QSet<QString> m_allSuffixes;
    QSet<QString> m_allMimetypes;

    bool m_composedWritableSuffixes;
    QSet<QString> m_writableSuffixes;

    QHash<QString,QString> suffix2description;
    QHash<QString,QString> mimetype2description;

    QString m_settingsDir;

    void loadFormats();
    void saveFormats();

};

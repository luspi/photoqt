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

#ifdef PQMLIBSAI
#if __has_include(<sai.hpp>)
#include <sai.hpp>
#elif __has_include(<sai/sai.hpp>)
#include <sai/sai.hpp>
#endif
#endif

class PQCImagePluginLibsai : public PQCImagePlugin {

public:
    PQCImagePluginLibsai(QString settingsDir);

    const QString name() override { return "libsai"; }
    const bool canPreload() override { return true; }
    const bool getEnabledByDefault() override { return true; }

    const QSet<QString> getSuffixes()  override { return m_suffixes; }
    const QSet<QString> getMimetypes() override { return m_mimetypes; }
    const QSet<QString> getToggledSuffixes()  override { return m_toggledSuffixes; }
    const QSet<QString> getToggledMimetypes() override { return m_toggledMimetypes; }
    const QSet<QString> getAllSuffixes()  override { return m_allSuffixes; }
    const QSet<QString> getAllMimetypes() override { return m_allMimetypes; }

    const QString getDescription(QString suffix) override;

    const bool canWrite(QString path) override;
    const bool writeImage(QImage img, QString targetPath) override;

    const QSize getSize(QString path) override;
    const QImage getImage(QString path, QSize requestedSize, QSize &origSize, QString &error) override;

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

#ifdef PQMLIBSAI
    static std::vector<uint32_t> ReadRasterLayer(const sai::LayerHeader& layerHeader, sai::VirtualFileEntry& layerFile);
    static void RLEDecompressStride(std::byte* destination, const std::byte* source, std::size_t stride, std::size_t strideCount, std::size_t channel);
#endif

};

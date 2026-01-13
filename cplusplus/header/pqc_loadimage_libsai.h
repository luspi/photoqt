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

#include <cstdint>
#include <memory>

#ifdef PQMLIBSAI
#include <sai.hpp>
#endif

class QSize;
class QString;
class QImage;

class PQCLoadImageLibsai {

public:
    PQCLoadImageLibsai();

    static QSize loadSize(QString filename);
    static QString load(QString filename, QSize, QSize &origSize, QImage &img);

private:
#ifdef PQMLIBSAI
    static std::unique_ptr<std::uint32_t[]> ReadRasterLayer(const sai::LayerHeader& layerHeader, sai::VirtualFileEntry& layerFile);
    static void RLEDecompressStride(std::byte* destination, const std::byte* source, std::size_t stride, std::size_t strideCount, std::size_t channel);
#endif

};

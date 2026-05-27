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

#include <pqc_imageplugin_libsai.h>
#include <pqc_settingscpp.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <pqc_imagecache.h>
#include <pqc_notify_cpp.h>

#include <QFile>
#include <QtDebug>
#include <QPainter>

PQCImagePluginLibsai::PQCImagePluginLibsai(QString settingsDir) : m_settingsDir(settingsDir) {

    m_composedWritableSuffixes = false;

    loadFormats();

}

const QString PQCImagePluginLibsai::getDescription(QString suffix) {
    return suffix2description.value(suffix.toLower(), "");
}

const bool PQCImagePluginLibsai::supportsFormatByDescription(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return true;
    }
    return false;
}

const bool PQCImagePluginLibsai::isEnabled(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return m_suffixes.contains(suf);
    }
    return false;
}

const QSet<QString> PQCImagePluginLibsai::getWritableSuffixes() {

    return {};

}

const bool PQCImagePluginLibsai::writeImage(QImage img, QString targetPath) {
    return false;
}

const QSize PQCImagePluginLibsai::loadSize(QString path) {

#ifdef PQMLIBSAI

    sai::Document saidoc(path.toStdString().c_str());

    if(!saidoc.IsOpen()) {
        qWarning() << "Error opening SAI file for reading.";
        return QSize();
    }

    int w = 0, h = 0;
    std::tie(w, h) = saidoc.GetCanvasSize();

    return QSize(w,h);

#endif

    return QSize();

}

const QImage PQCImagePluginLibsai::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path = " << path;
    qDebug() << "args: requestedSize = " << requestedSize;

#ifdef PQMLIBSAI

    sai::Document saidoc(path.toStdString().c_str());

    if(!saidoc.IsOpen()) {
        const QString msg = "Error opening SAI file for reading.";
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    std::uint32_t w = 0, h = 0;
    std::tie(w, h) = saidoc.GetCanvasSize();
    origSize = QSize(w, h);

    // Load thumbnail only
    if(!requestedSize.isEmpty() && qMax(requestedSize.width(), requestedSize.height()) <= 512) {

        // Get the thumbnail data
        uint32_t tw = 0, th = 0;
        std::unique_ptr<std::byte[]> pixels;
        std::tie(pixels, tw, th) = saidoc.GetThumbnail();

        // construct thumbnail image
        // we have to call copy() as QImage does not take ownership of the data and the buffer will be freed while the image is still in use
        QImage img = QImage(reinterpret_cast<uchar*>(pixels.get()), tw, th, 4*tw, QImage::Format_ARGB32_Premultiplied).copy();

        if(!img.isNull()) {

            // make sure thumbnail is not larger than requested
            QSize finalSize = origSize;

            if(finalSize.width() > requestedSize.width() || finalSize.height() > requestedSize.height()) {

                finalSize = finalSize.scaled(requestedSize, Qt::KeepAspectRatio);

                return img.scaled(finalSize,
                                  Qt::IgnoreAspectRatio,
                                  (PQCSettingsCPP::get().getImageviewRescalingSmooth() ? Qt::SmoothTransformation : Qt::FastTransformation));

            }

            return img;

        }

    }

    QList<QImage> allImageLayers;

    saidoc.IterateLayerFiles([&](sai::VirtualFileEntry& LayerFile) {

        if(PQCNotifyCPP::get().isPhotoQtShuttingDown()) return true;

        QImage curImage(w, h, QImage::Format_ARGB32_Premultiplied);
        curImage.fill(Qt::transparent);

        const sai::LayerHeader LayerHeader = LayerFile.Read<sai::LayerHeader>();

        // Read serialization stream
        std::uint32_t CurTag;
        std::uint32_t CurTagSize;
        while(LayerFile.Read<std::uint32_t>(CurTag) && CurTag) {
            LayerFile.Read<std::uint32_t>(CurTagSize);
            LayerFile.Seek(LayerFile.Tell() + CurTagSize);
        }

        bool appendNextImage = true;

        // if this is a layer
        if(static_cast<sai::LayerType>(LayerHeader.Type) == sai::LayerType::Layer ||
            static_cast<sai::LayerType>(LayerHeader.Type) == sai::LayerType::RootLayer) {

            // If the current layer or the full current set is not visible, stop.
            if(LayerHeader.Visible == 0)
                return true;

            std::vector<std::uint32_t> LayerPixels = ReadRasterLayer(LayerHeader, LayerFile);
            if(!LayerPixels.empty()) {

                // Load image from data
                // we have to call copy() as QImage does not take ownership of the data and the buffer will be freed while the image is still in use
                QImage i = QImage(reinterpret_cast<uchar*>(LayerPixels.data()),
                                  LayerHeader.Bounds.Width, LayerHeader.Bounds.Height,
                                  4*LayerHeader.Bounds.Width, QImage::Format_ARGB32).copy();

                // this modifies the last layer and does not create a new one
                if(LayerHeader.PreserveOpacity) {

                    appendNextImage = false;

                    QPainter curPainter(&allImageLayers.last());
                    curPainter.setClipRegion(QRegion(QBitmap::fromImage(allImageLayers.last().createAlphaMask())));
                    curPainter.setOpacity(static_cast<double>(LayerHeader.Opacity)/100.);
                    curPainter.drawImage(QPoint(LayerHeader.Bounds.X, LayerHeader.Bounds.Y), i);
                    curPainter.end();

                    // create new layer image
                } else {

                    QPainter curPainter(&curImage);

                    // the new layer is clipped to the alpha mask of the previous layer
                    if(LayerHeader.Clipping)
                        curPainter.setClipRegion(QRegion(QBitmap::fromImage(allImageLayers.last().createAlphaMask())));

                    curPainter.setOpacity(static_cast<double>(LayerHeader.Opacity)/100.);
                    curPainter.drawImage(QPoint(LayerHeader.Bounds.X, LayerHeader.Bounds.Y), i);
                    curPainter.end();

                }

            }

        } else if(static_cast<sai::LayerType>(LayerHeader.Type) == sai::LayerType::Set) {

            appendNextImage = false;

            if(static_cast<sai::BlendingModes>(LayerHeader.Blending) == sai::BlendingModes::Multiply)
                qWarning() << "Multiply blending not yet implemented";
            else if(static_cast<sai::BlendingModes>(LayerHeader.Blending) == sai::BlendingModes::PassThrough)
                qWarning() << "PassThrough blending not yet implemented";
            else if(static_cast<sai::BlendingModes>(LayerHeader.Blending) == sai::BlendingModes::Screen)
                qWarning() << "Screen blending not yet implemented";
            else if(static_cast<sai::BlendingModes>(LayerHeader.Blending) == sai::BlendingModes::Overlay)
                qWarning() << "Overlay blending not yet implemented";
            else if(static_cast<sai::BlendingModes>(LayerHeader.Blending) == sai::BlendingModes::Luminosity)
                qWarning() << "Luminosity blending not yet implemented";
            else if(static_cast<sai::BlendingModes>(LayerHeader.Blending) == sai::BlendingModes::Shade)
                qWarning() << "Shade blending not yet implemented";
            else if(static_cast<sai::BlendingModes>(LayerHeader.Blending) == sai::BlendingModes::LumiShade)
                qWarning() << "LumiShade blending not yet implemented";
            else if(static_cast<sai::BlendingModes>(LayerHeader.Blending) == sai::BlendingModes::Binary)
                qWarning() << "Binary blending not yet implemented";

        }

        if(appendNextImage)
            allImageLayers.append(curImage);

        return true;
    });

    if(PQCNotifyCPP::get().isPhotoQtShuttingDown()) return QImage();

    // compose final image
    QImage img(w, h, QImage::Format_ARGB32_Premultiplied);
    img.fill(Qt::white);
    QPainter composedPainter(&img);
    for(const QImage &img : std::as_const(allImageLayers)) {
        composedPainter.drawImage(QPoint(0,0), img);
    }
    composedPainter.end();

    // if successful then we cache the image
    if(!img.isNull())
        PQCImageCache::get().saveImageToCache(path, "", &img);

    // make sure we fit the requested size
    if(requestedSize.width() != -1) {
        return img.scaled(origSize.scaled(requestedSize, Qt::KeepAspectRatio),
                          Qt::IgnoreAspectRatio,
                          (PQCSettingsCPP::get().getImageviewRescalingSmooth() ? Qt::SmoothTransformation : Qt::FastTransformation));
    }

    return img;

#endif

    return QImage();

}

void PQCImagePluginLibsai::setEnabled(QString descriptiondescription, bool enabled) {

}

/***********************************************/

void PQCImagePluginLibsai::loadFormats() {

    m_suffixes.clear();
    m_toggledSuffixes.clear();
    m_allSuffixes.clear();

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = m_settingsDir % "/libsai_suffixes";
    QFile suffixFile(suffixFilename);
    if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
        qDebug() << "Failed to open settings file at:" << suffixFilename;
    } else {
        QTextStream suffixIn(&suffixFile);
        const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledSuffixes = QSet<QString>(tmp.begin(), tmp.end());
        suffixFile.close();
    }

    // then we store ALL supported suffixes
    m_allSuffixes = {"sai"};

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_toggledSuffixes;

    suffix2description = {
        {"sai", "PaintTool Sai"}
    };

    /********************************/

    m_mimetypes.clear();
    m_toggledMimetypes.clear();
    m_allMimetypes.clear();
    mimetype2description.clear();

    // no mimetypes here

    Q_EMIT formatsUpdated();

}

void PQCImagePluginLibsai::saveFormats() {

    // TODO

}

#ifdef PQMLIBSAI

/*********************************************************************/
// This function is based on ReadRasterLayer() function found in:
// https://github.com/Wunkolo/libsai/blob/main/samples/Document.cpp
std::vector<std::uint32_t> PQCImagePluginLibsai::ReadRasterLayer(const sai::LayerHeader& layerHeader, sai::VirtualFileEntry& layerFile) {

    const std::size_t tileSize   = 32u;
    const std::size_t tilePixels = tileSize * tileSize;
    const std::size_t pixelSize  = sizeof(std::uint32_t);
    const std::size_t tileBytes  = tilePixels * pixelSize;

    const std::size_t layerTilesX = layerHeader.Bounds.Width / tileSize;
    const std::size_t layerTilesY = layerHeader.Bounds.Height / tileSize;

    // Do not use a std::vector<bool> as this is implemented as a specialized
    // type that does not implement individual bool values as bytes, but rather
    // as packed bits within a word.

    // Read TileMap
    std::vector<std::byte> tileMap(layerTilesX * layerTilesY);
    layerFile.Read({tileMap.data(), layerTilesX * layerTilesY});

    // The resulting raster image data for this layer, RGBA 32bpp interleaved
    // Use a vector to ensure that tiles with no data are still initialized
    // to #00000000
    // Also note that the claim that SystemMax has made involving 16bit color
    // depth may actually only be true at run-time. All raster data found in
    // files are stored at 8bpc while only some run-time color arithmetic
    // converts to 16-bit
    std::vector<std::uint32_t> layerImage(layerHeader.Bounds.Width * layerHeader.Bounds.Height);

    // 32 x 32 Tile of B8G8R8A8 pixels
    std::array<std::byte, tileBytes> compressedTile = {};
    std::array<std::byte, tileBytes> decompressedTile = {};

    // Iterate 32x32 tile chunks row by row
    for(std::size_t y = 0; y < layerTilesY; ++y) {
        for(std::size_t x = 0; x < layerTilesX; ++x) {

            // Process active Tiles
            if(tileMap[x + y*layerTilesX] == std::byte{0})
                continue;

            std::uint8_t  curChannel = 0;
            std::uint16_t RLESize    = 0;

            // Iterate RLE streams for each channel
            while(layerFile.Read<std::uint16_t>(RLESize) == sizeof(std::uint16_t)) {

                assert(RLESize <= compressedTile.size());

                if(layerFile.Read(std::span(compressedTile).first(RLESize)) != RLESize) {
                    // Error reading RLE stream
                    break;
                }

                // Decompress and place into the appropriate interleaved channel
                RLEDecompressStride(decompressedTile.data(), compressedTile.data(),
                                    sizeof(std::uint32_t), tilePixels,
                                    curChannel);
                ++curChannel;

                // Skip all other channels besides the RGBA ones we care about
                if(curChannel >= 4) {

                    for(std::size_t i = 0; i < 4; i++) {
                        RLESize = layerFile.Read<std::uint16_t>();
                        layerFile.Seek(layerFile.Tell() + RLESize);
                    }

                    break;

                }

            }

            // Write 32x32 tile into final image
            const std::uint32_t* imageSource = reinterpret_cast<const std::uint32_t*>(decompressedTile.data());

            // Current 32x32 tile within final image
            std::uint32_t* imageDest = layerImage.data() + (y * tileSize * layerHeader.Bounds.Width) + (x * tileSize);

            const std::uint32_t ts = tileSize*sizeof(std::uint32_t);
            for(std::size_t row = 0; row < tileSize; ++row) {
                std::memcpy(imageDest + row*layerHeader.Bounds.Width, imageSource + row*tileSize, ts);
            }

        }
    }

    return layerImage;

}

/*********************************************************************/
// This function is based on RLEDecompressStride() function found in:
// https://github.com/Wunkolo/libsai/blob/main/samples/Document.cpp
void PQCImagePluginLibsai::RLEDecompressStride(std::byte* destination, const std::byte* source, std::size_t stride, std::size_t strideCount, std::size_t channel) {

    destination += channel;
    std::size_t writeCount = 0;

    while(writeCount < strideCount) {

        std::uint8_t length = std::to_integer<std::uint8_t>(*source++);

        // length == 128 is a no-op

        if(length < 128) { // Copy

            // Copy the next Length+1 bytes
            length++;
            writeCount += length;

            do {
                *destination = *source++;
                destination += stride;
            } while(--length);

        } else if(length > 128) { // Repeating byte

            // Repeat next byte exactly "-Length + 1" times
            length = 257 - length;
            writeCount += length;
            std::byte value = *source++;

            do {
                *destination = value;
                destination += stride;
            } while(--length);

        }
    }
}

#endif

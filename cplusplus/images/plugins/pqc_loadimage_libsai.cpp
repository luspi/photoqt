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

#include <cstddef>
#include <pqc_loadimage_libsai.h>
#include <pqc_configfiles.h>
#include <pqc_settingscpp.h>
#include <scripts/pqc_scriptsimages.h>
#include <QSize>
#include <QImage>
#include <QtDebug>
#include <QPainter>
#include <QCryptographicHash>

// the iterator for the layers below treats all external variables as const
// the only way to actually compose an image is to have it as a global static
static QImage composedImage;

PQCLoadImageLibsai::PQCLoadImageLibsai() {}

QSize PQCLoadImageLibsai::loadSize(QString filename) {

#ifdef PQMLIBSAI

    sai::Document saidoc(filename.toStdString().c_str());

    if(!saidoc.IsOpen()) {
        QString err = "Error opening SAI file for reading.";
        qWarning() << err;
        return QSize();
    }

    int w = 0, h = 0;
    std::tie(w, h) = saidoc.GetCanvasSize();

    return QSize(w,h);

#endif

    return QSize();
}

QString PQCLoadImageLibsai::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename = " << filename;
    qDebug() << "args: maxSize = " << maxSize;

#ifdef PQMLIBSAI

    sai::Document saidoc(filename.toStdString().c_str());

    if(!saidoc.IsOpen()) {
        QString err = "Error opening SAI file for reading.";
        qWarning() << err;
        return err;
    }

    int w = 0, h = 0;
    std::tie(w, h) = saidoc.GetCanvasSize();
    origSize = QSize(w, h);

    // Load thumbnail only
    if(maxSize.width() > 0 && maxSize.height() > 0 && maxSize.width() <= 512 && maxSize.height() <= 512) {

        // Get the thumbnail data
        uint32_t tw = 0, th = 0;
        std::unique_ptr<std::byte[]> pixels;
        std::tie(pixels, tw, th) = saidoc.GetThumbnail();

        // construct thumbnail image
        img = QImage(reinterpret_cast<uchar*>(pixels.get()), tw, th, 4*tw, QImage::Format_ARGB32_Premultiplied);

        if(!img.isNull()) {

            // make sure thumbnail is not larger than requested
            QSize finalSize = origSize;

            if(finalSize.width() > maxSize.width() || finalSize.height() > maxSize.height())
                finalSize = finalSize.scaled(maxSize, Qt::KeepAspectRatio);

            img = img.scaled(finalSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

            return "";

        }

    }

    composedImage = QImage(w, h, QImage::Format_ARGB32_Premultiplied);
    composedImage.fill(Qt::transparent);

    saidoc.IterateLayerFiles([=](sai::VirtualFileEntry& LayerFile) {

        const sai::LayerHeader LayerHeader = LayerFile.Read<sai::LayerHeader>();

        // If the current layer or the full current set is not visible, stop.
        if(LayerHeader.Visible == 0)
            return true;

        // Read serialization stream
        std::uint32_t CurTag;
        std::uint32_t CurTagSize;
        while(LayerFile.Read<std::uint32_t>(CurTag) && CurTag) {
            LayerFile.Read<std::uint32_t>(CurTagSize);
            LayerFile.Seek(LayerFile.Tell() + CurTagSize);
        }

        // if this is a layer
        if(static_cast<sai::LayerType>(LayerHeader.Type) == sai::LayerType::Layer ||
           static_cast<sai::LayerType>(LayerHeader.Type) == sai::LayerType::RootLayer) {

            if(auto LayerPixels = ReadRasterLayer(LayerHeader, LayerFile); LayerPixels) {

                // Load image from data
                QImage i(reinterpret_cast<uchar*>(LayerPixels.get()),
                         LayerHeader.Bounds.Width, LayerHeader.Bounds.Height,
                         4*LayerHeader.Bounds.Width, QImage::Format_ARGB32_Premultiplied);

                /********************/
                // Blending
                //
                // TODO?
                //
                /********************/

                // Both PreserveOpacity and Clipping only apply the color if there is a non-transparent color below already
                // The difference lies in that the former happens in the same layer whereas the latter happens in a seperate layer
                // Since we are only interested in a flat rendered image we can treat them the same way.
                if(LayerHeader.PreserveOpacity || LayerHeader.Clipping) {

                    // value between 0 and 255
                    int alpha = 2.55*LayerHeader.Opacity;

                    for(int x = LayerHeader.Bounds.X; x < LayerHeader.Bounds.Width; ++x) {

                        for(int y = LayerHeader.Bounds.Y; y < LayerHeader.Bounds.Height; ++y) {

                            if(x < 0 || x > w-1 || y < 0 || y > h-1)
                                continue;

                            // not transparent -> set new pixel
                            if(composedImage.pixelColor(x, y).alpha() != 0) {
                                QColor col = i.pixelColor(x, y);
                                col.setAlpha(alpha);
                                composedImage.setPixelColor(x, y, col);
                            }

                        }

                    }

                } else {

                    // simply draw image on top
                    QPainter p(&composedImage);
                    p.setOpacity(100./static_cast<double>(LayerHeader.Opacity));
                    p.drawImage(QRect(LayerHeader.Bounds.X, LayerHeader.Bounds.Y, LayerHeader.Bounds.Width, LayerHeader.Bounds.Height), i);
                    p.end();

                }

            }
        }

        return true;
    });

    // make sure the background is all white
    // we can't do it on the composedImage at the start as it would mess up the PreserveOpacity/Clipping option
    img = QImage(w,h,QImage::Format_ARGB32);
    img.fill(Qt::white);
    QPainter p(&img);
    p.drawImage(0, 0, composedImage);
    p.end();

    if(!img.isNull() && PQCSettingsCPP::get().getMetadataAutoRotation()) {
        // apply transformations if any
        PQCScriptsImages::get().applyExifOrientation(filename, img);
    }

    // make sure we fit the requested size
    if(maxSize.width() != -1) {

        QSize finalSize = origSize;

        if(finalSize.width() > maxSize.width() || finalSize.height() > maxSize.height())
            finalSize = finalSize.scaled(maxSize, Qt::KeepAspectRatio);

        img = img.scaled(finalSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    }

    return "";

#endif

    origSize = QSize(-1,-1);
    QString errormsg = "Failed to load image, libsai not supported by this build of PhotoQt!";
    qDebug() << errormsg;
    return errormsg;

}

#ifdef PQMLIBSAI

/*********************************************************************/
// This function is based on ReadRasterLayer() function found in:
// https://github.com/Wunkolo/libsai/blob/main/samples/Document.cpp
std::unique_ptr<std::uint32_t[]> PQCLoadImageLibsai::ReadRasterLayer(const sai::LayerHeader& layerHeader, sai::VirtualFileEntry& layerFile) {

    const std::size_t tileSize    = 32u;
    const std::size_t layerTilesX = layerHeader.Bounds.Width / tileSize;
    const std::size_t layerTilesY = layerHeader.Bounds.Height / tileSize;
    const auto index2D = [](std::size_t X, std::size_t Y, std::size_t Stride) -> std::size_t {
        return X + (Y * Stride);
    };

    // Do not use a std::vector<bool> as this is implemented as a specialized
    // type that does not implement individual bool values as bytes, but rather
    // as packed bits within a word.

    // Read TileMap
    std::unique_ptr<std::byte[]> tileMap = std::make_unique<std::byte[]>(layerTilesX * layerTilesY);
    layerFile.Read({tileMap.get(), layerTilesX * layerTilesY});

    // The resulting raster image data for this layer, RGBA 32bpp interleaved
    // Use a vector to ensure that tiles with no data are still initialized
    // to #00000000
    // Also note that the claim that SystemMax has made involving 16bit color
    // depth may actually only be true at run-time. All raster data found in
    // files are stored at 8bpc while only some run-time color arithmetic
    // converts to 16-bit
    std::unique_ptr<std::uint32_t[]> layerImage = std::make_unique<std::uint32_t[]>(layerHeader.Bounds.Width * layerHeader.Bounds.Height);

    // 32 x 32 Tile of B8G8R8A8 pixels
    std::array<std::byte, 0x1000> compressedTile   = {};
    std::array<std::byte, 0x1000> decompressedTile = {};

    // Iterate 32x32 tile chunks row by row
    for(std::size_t y = 0; y < layerTilesY; ++y) {

        for(std::size_t x = 0; x < layerTilesX; ++x) {

            // Process active Tiles
            if(!std::to_integer<std::uint8_t>(tileMap[index2D(x, y, layerTilesX)]))
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
                PQCLoadImageLibsai::RLEDecompressStride(decompressedTile.data(), compressedTile.data(),
                                                        sizeof(std::uint32_t), 0x1000 / sizeof(std::uint32_t),
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
            std::uint32_t* imageDest = layerImage.get() + index2D(x * tileSize, y * layerHeader.Bounds.Width, tileSize);

            for(std::size_t i = 0; i < (tileSize * tileSize); i++) {

                std::uint32_t CurPixel = imageSource[i];
                imageDest[index2D(i % tileSize, i / tileSize, layerHeader.Bounds.Width)] = CurPixel;

            }
        }
    }

    return layerImage;

}

/*********************************************************************/
// This function is based on RLEDecompressStride() function found in:
// https://github.com/Wunkolo/libsai/blob/main/samples/Document.cpp
void PQCLoadImageLibsai::RLEDecompressStride(std::byte* destination, const std::byte* source, std::size_t stride, std::size_t strideCount, std::size_t channel) {

    destination += channel;
    std::size_t writeCount = 0;

    while(writeCount < strideCount) {

        std::uint8_t length = std::to_integer<std::uint8_t>(*source++);

        // length == 128 is a no-op

        if(length < 128) { // Copy

            // Copy the next Length+1 bytes
            length++;
            writeCount += length;

            while(length) {
                *destination = *source++;
                destination += stride;
                length--;
            }

        } else if(length > 128) { // Repeating byte

            // Repeat next byte exactly "-Length + 1" times
            length ^= 0xFF;
            length += 2;
            writeCount += length;
            std::byte value = *source++;

            while(length) {
                *destination = value;
                destination += stride;
                length--;
            }

        }
    }
}

#endif

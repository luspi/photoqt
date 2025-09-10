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

#include <cstddef>
#include <pqc_loadimage_libsai.h>
#include <pqc_configfiles.h>
#include <QSize>
#include <QImage>
#include <QtDebug>
#include <QPainter>
#include <QCryptographicHash>

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

    QString hash = QCryptographicHash::hash(filename.toUtf8(), QCryptographicHash::Md5).toHex();

    sai::Document saidoc(filename.toStdString().c_str());

    if(!saidoc.IsOpen()) {
        QString err = "Error opening SAI file for reading.";
        qWarning() << err;
        return err;
    }

    int w = 0, h = 0;
    std::tie(w, h) = saidoc.GetCanvasSize();

    QString baseCache = PQCConfigFiles::get().CACHE_DIR() + "/sai/" + hash;

    QDir d(baseCache);
    if(!d.exists())
        d.mkpath(baseCache);

    saidoc.IterateLayerFiles([=](sai::VirtualFileEntry& LayerFile) {

        const sai::LayerHeader LayerHeader = LayerFile.Read<sai::LayerHeader>();

        char _name[256] = {};
        std::snprintf(_name, 256, "%08x", LayerHeader.Identifier);
        QString name = QString::fromStdString(std::string(_name));

        // Read serialization stream
        std::uint32_t CurTag;
        std::uint32_t CurTagSize;
        while(LayerFile.Read<std::uint32_t>(CurTag) && CurTag) {
            LayerFile.Read<std::uint32_t>(CurTagSize);
            LayerFile.Seek(LayerFile.Tell() + CurTagSize);
        }

        if(static_cast<sai::LayerType>(LayerHeader.Type) == sai::LayerType::Layer) {

            if(auto LayerPixels = ReadRasterLayer(LayerHeader, LayerFile); LayerPixels) {

                // this is the cached file name
                QString fname = QString("%1/%2__%3x%4x%5x%6.ppm")
                                    .arg(baseCache, name)
                                    .arg(LayerHeader.Bounds.X).arg(LayerHeader.Bounds.Y)
                                    .arg(LayerHeader.Bounds.Width).arg(LayerHeader.Bounds.Height);

                // Load raw image file
                QImage i(reinterpret_cast<uchar*>(LayerPixels.get()), LayerHeader.Bounds.Width, LayerHeader.Bounds.Height, 4*LayerHeader.Bounds.Width, QImage::Format_ARGB32_Premultiplied);

                // remove any old files
                if(QFile::exists(fname))
                    QFile::remove(fname);

                // construct proper file with all properties set
                QImage i2(LayerHeader.Bounds.Width, LayerHeader.Bounds.Height, QImage::Format_ARGB32_Premultiplied);
                i2.fill(Qt::transparent);

                QPainter p(&i2);

                // set the opacity level
                p.setOpacity(1./static_cast<double>(LayerHeader.Opacity));

                p.drawImage(0,0,i);
                p.end();

                i2.save(fname);

            }
        }

        return true;
    });

    img = QImage(w, h, QImage::Format_ARGB32_Premultiplied);
    img.fill(Qt::transparent);

    QPainter painter(&img);

    QDir dir(baseCache);
    const QFileInfoList lst = dir.entryInfoList(QDir::Files|QDir::NoDotAndDotDot);
    for(const QFileInfo &entry : lst) {

        qWarning() << " >>> NAME:" << entry.baseName();
        if(!entry.baseName().contains("__"))
            continue;

        QStringList _rect = entry.baseName().split("__")[1].split("x");
        QRect rect(_rect[0].toInt(), _rect[1].toInt(), _rect[2].toInt(), _rect[3].toInt());

        // qWarning() << "reading:" << entry.absoluteFilePath();

        QImage i(entry.absoluteFilePath());
        painter.drawImage(rect, i);

    }

    painter.end();

    return "";

#endif

    origSize = QSize(-1,-1);
    QString errormsg = "Failed to load image, libsai not supported by this build of PhotoQt!";
    qDebug() << errormsg;
    return errormsg;

}

#ifdef PQMLIBSAI

std::unique_ptr<std::uint32_t[]>
PQCLoadImageLibsai::ReadRasterLayer(const sai::LayerHeader& LayerHeader, sai::VirtualFileEntry& LayerFile)
{
    const std::size_t TileSize    = 32u;
    const std::size_t LayerTilesX = LayerHeader.Bounds.Width / TileSize;
    const std::size_t LayerTilesY = LayerHeader.Bounds.Height / TileSize;
    const auto Index2D = [](std::size_t X, std::size_t Y, std::size_t Stride) -> std::size_t {
        return X + (Y * Stride);
    };
    // Do not use a std::vector<bool> as this is implemented as a specialized
    // type that does not implement individual bool values as bytes, but rather
    // as packed bits within a word.

    // Read TileMap
    std::unique_ptr<std::byte[]> TileMap = std::make_unique<std::byte[]>(LayerTilesX * LayerTilesY);
    LayerFile.Read({TileMap.get(), LayerTilesX * LayerTilesY});

    // The resulting raster image data for this layer, RGBA 32bpp interleaved
    // Use a vector to ensure that tiles with no data are still initialized
    // to #00000000
    // Also note that the claim that SystemMax has made involving 16bit color
    // depth may actually only be true at run-time. All raster data found in
    // files are stored at 8bpc while only some run-time color arithmetic
    // converts to 16-bit
    std::unique_ptr<std::uint32_t[]> LayerImage
        = std::make_unique<std::uint32_t[]>(LayerHeader.Bounds.Width * LayerHeader.Bounds.Height);

    // 32 x 32 Tile of B8G8R8A8 pixels
    std::array<std::byte, 0x1000> CompressedTile   = {};
    std::array<std::byte, 0x1000> DecompressedTile = {};

    // Iterate 32x32 tile chunks row by row
    for( std::size_t y = 0; y < LayerTilesY; ++y )
    {
        for( std::size_t x = 0; x < LayerTilesX; ++x )
        {
            // Process active Tiles
            if( !std::to_integer<std::uint8_t>(TileMap[Index2D(x, y, LayerTilesX)]) )
                continue;

            std::uint8_t  CurChannel = 0;
            std::uint16_t RLESize    = 0;
            // Iterate RLE streams for each channel
            while( LayerFile.Read<std::uint16_t>(RLESize) == sizeof(std::uint16_t) )
            {
                assert(RLESize <= CompressedTile.size());
                if( LayerFile.Read(std::span(CompressedTile).first(RLESize)) != RLESize )
                {
                    // Error reading RLE stream
                    break;
                }
                // Decompress and place into the appropriate interleaved channel
                PQCLoadImageLibsai::RLEDecompressStride(
                    DecompressedTile.data(), CompressedTile.data(), sizeof(std::uint32_t),
                    0x1000 / sizeof(std::uint32_t), CurChannel
                    );
                ++CurChannel;
                // Skip all other channels besides the RGBA ones we care about
                if( CurChannel >= 4 )
                {
                    for( std::size_t i = 0; i < 4; i++ )
                    {
                        RLESize = LayerFile.Read<std::uint16_t>();
                        LayerFile.Seek(LayerFile.Tell() + RLESize);
                    }
                    break;
                }
            }

            // Write 32x32 tile into final image
            const std::uint32_t* ImageSource
                = reinterpret_cast<const std::uint32_t*>(DecompressedTile.data());
            // Current 32x32 tile within final image
            std::uint32_t* ImageDest
                = LayerImage.get() + Index2D(x * TileSize, y * LayerHeader.Bounds.Width, TileSize);
            for( std::size_t i = 0; i < (TileSize * TileSize); i++ )
            {
                std::uint32_t CurPixel = ImageSource[i];
                ///
                // Do any Per-Pixel processing you need to do here
                ///
                ImageDest[Index2D(i % TileSize, i / TileSize, LayerHeader.Bounds.Width)] = CurPixel;
            }
        }
    }
    return LayerImage;
}

void PQCLoadImageLibsai::RLEDecompressStride(
    std::byte* Destination, const std::byte* Source, std::size_t Stride, std::size_t StrideCount,
    std::size_t Channel
    )
{
    Destination += Channel;
    std::size_t WriteCount = 0;

    while( WriteCount < StrideCount )
    {
        std::uint8_t Length = std::to_integer<std::uint8_t>(*Source++);
        if( Length == 128 ) // No-op
        {
        }
        else if( Length < 128 ) // Copy
        {
            // Copy the next Length+1 bytes
            Length++;
            WriteCount += Length;
            while( Length )
            {
                *Destination = *Source++;
                Destination += Stride;
                Length--;
            }
        }
        else if( Length > 128 ) // Repeating byte
        {
            // Repeat next byte exactly "-Length + 1" times
            Length ^= 0xFF;
            Length += 2;
            WriteCount += Length;
            std::byte Value = *Source++;
            while( Length )
            {
                *Destination = Value;
                Destination += Stride;
                Length--;
            }
        }
    }
}

#endif

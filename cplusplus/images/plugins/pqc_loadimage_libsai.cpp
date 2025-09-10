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
#include <QSize>
#include <QImage>
#include <QtDebug>

PQCLoadImageLibsai::PQCLoadImageLibsai() {}

QSize PQCLoadImageLibsai::loadSize(QString filename) {

    // TODO

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

    saidoc.IterateLayerFiles([=](sai::VirtualFileEntry& LayerFile) {

        const sai::LayerHeader LayerHeader = LayerFile.Read<sai::LayerHeader>();

        std::printf("\t\033[1m- \033[93m\"%08x\"\033[0m\n", LayerHeader.Identifier);

        char Name[256] = {};
        std::snprintf(Name, 256, "%08x", LayerHeader.Identifier);

        // std::printf(
        //     "\t\tBlending: '%c%c%c%c'(0x%08x)\n", (LayerHeader.Blending >> 24) & 0xFF,
        //     (LayerHeader.Blending >> 16) & 0xFF, (LayerHeader.Blending >> 8) & 0xFF,
        //     (LayerHeader.Blending >> 0) & 0xFF, LayerHeader.Blending
        //     );

        // Read serialization stream
        std::uint32_t CurTag;
        std::uint32_t CurTagSize;
        while( LayerFile.Read<std::uint32_t>(CurTag) && CurTag )
        {
            LayerFile.Read<std::uint32_t>(CurTagSize);
            switch( CurTag )
            {
            case sai::Tag("name"):
            {
                std::array<char, 256> LayerName = {};
                LayerFile.Read(std::as_writable_bytes(std::span(LayerName)));
                std::printf("\t\tName: %.256s\n", LayerName.data());
                break;
            }
            case sai::Tag("lorg"):
            case sai::Tag("pfid"):
            case sai::Tag("plid"):
            case sai::Tag("lmfl"):
            case sai::Tag("fopn"):
            case sai::Tag("texn"):
            case sai::Tag("texp"):
            case sai::Tag("peff"):
            case sai::Tag("vmrk"):
            default:
            {
                std::printf(
                    "\t\tUnhandledTag: '%c%c%c%c'(0x%08x)\n", (CurTag >> 24) & 0xFF,
                    (CurTag >> 16) & 0xFF, (CurTag >> 8) & 0xFF, (CurTag >> 0) & 0xFF, CurTag
                    );
                // for any streams that we do not handle,
                // we just skip forward in the stream
                LayerFile.Seek(LayerFile.Tell() + CurTagSize);
                break;
            }
            }
        }

        switch( static_cast<sai::LayerType>(LayerHeader.Type) )
        {
        case sai::LayerType::Layer:
        {
            if( auto LayerPixels = ReadRasterLayer(LayerHeader, LayerFile); LayerPixels )
            {

                QImage i(reinterpret_cast<uchar*>(LayerPixels.get()), LayerHeader.Bounds.Width, LayerHeader.Bounds.Height, 4*LayerHeader.Bounds.Width, QImage::Format_ARGB32_Premultiplied);
                i.save(QString::fromStdString(std::string(Name)) + ".png");
                qWarning() << ">>>>>> SAVING TO:" << Name;
            }
            break;
        }
        case sai::LayerType::Unknown4:
        case sai::LayerType::Linework:
        case sai::LayerType::Mask:
        case sai::LayerType::Unknown7:
        case sai::LayerType::Set:
        default:
            break;
        }

        return true;
    });

    // QImage qimg(
    //     buffer->data(),
    //     Width,
    //     Height,
    //     Width * 4,
    //     QImage::Format_ARGB32_Premultiplied,
    //     [](void* info) {
    //         // Clean up the shared_ptr when QImage is destroyed
    //         delete static_cast<std::shared_ptr<std::vector<uint8_t>>*>(info);
    //     },
    //     new std::shared_ptr<std::vector<uint8_t>>(buffer)
    //     );


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

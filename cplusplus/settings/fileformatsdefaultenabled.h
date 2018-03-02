/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

#ifndef FILEFORMATSDEFAULT_H
#define FILEFORMATSDEFAULT_H

#include <QStringList>
#include <QImageReader>
#include <QtDebug>

namespace FileFormatsHandler {

    namespace DefaultFormats {

        static inline QStringList getListForQt() {

            QStringList ret;

            QList<QByteArray> formats = QImageReader::supportedImageFormats();

            // Microsoft Windows bitmap
            if(formats.contains("bmp"))
                ret << "*.bmp"
                    << "*.bitmap";

            // CompuServe Graphics Interchange Format
            if(formats.contains("gif"))
                ret << "*.gif";

            // JPEG-2000 Code Stream Syntax
            if(formats.contains("jp2"))
                ret << "*.jpeg2000"
                    << "*.jp2"
                    << "*.jpc"
                    << "*.j2k"
                    << "*.jpx";

            // Multiple-image Network Graphics
            if(formats.contains("mng"))
                ret << "*.mng";

            // Microsoft icon
            if(formats.contains("ico") || formats.contains("cur"))
                ret << "*.ico"
                    << "*.cur";

            // Macintosh OS X icon
            if(formats.contains("icns"))
                ret << "*.icns";

            // Joint Photographic Experts Group JFIF format
            if(formats.contains("jpg") || formats.contains("jpeg"))
                ret << "*.jpeg"
                    << "*.jpg"
                    << "*.jpe";

            // Portable Network Graphics
            if(formats.contains("png"))
                ret << "*.png";

            // Portable bitmap format (black and white)
            if(formats.contains("pbm"))
                ret << "*.pbm";

            // Portable graymap format (gray scale)
            if(formats.contains("pgm"))
                ret << "*.pgm";

            // Portable pixmap format (color)
            if(formats.contains("ppm"))
                ret << "*.ppm";

            // Scalable Vector Graphics
            if(formats.contains("svg") || formats.contains("svgz"))
                ret << "*.svg"
                    << "*.svgz";

            // Truevision Targa Graphic
            if(formats.contains("tga"))
                ret << "*.tga";

            // Tagged Image File Format
            if(formats.contains("tif") || formats.contains("tiff"))
                ret << "*.tif"
                    << "*.tiff";

            // Wireless bitmap
            if(formats.contains("wbmp"))
                ret << "*.wbmp";

            // Google web image format
            if(formats.contains("webp"))
                ret << "*.webp";

            // X Windows system bitmap, black and white only
            if(formats.contains("xbm"))
                ret << "*.xbm";

            // X Windows system pixmap
            if(formats.contains("xpm"))
                ret << "*.xpm";

            return ret;

        }

        static inline QStringList getListForKde() {

            QStringList ret;

            QList<QByteArray> formats = QImageReader::supportedImageFormats();

            // Adobe Encapsulated PostScript
            if(formats.contains("eps") || formats.contains("epsf") || formats.contains("epsi"))
                ret << "*.eps"
                    << "*.epsf"
                    << "*.epsi";

            // OpenEXR
            if(formats.contains("exr"))
                ret << "*.exr";

            // Krita Document
            if(formats.contains("kra"))
                ret << "*.kra";

            // Open Raster Image File
            if(formats.contains("ora"))
                ret << "*.ora";

            // PC Paintbrush
            if(formats.contains("pcx"))
                ret << "*.pcx";

            // Advanced Art Studio?
            if(formats.contains("pic"))
                ret << "*.pic";

            // Adobe PhotoShop
            if(formats.contains("psd") || formats.contains("psb"))
                ret << "*.psd";

            // Sun Graphics
            if(formats.contains("ras"))
                ret << "*.ras";

            // Silicon Graphics
            if(formats.contains("bw") || formats.contains("rgb") || formats.contains("rgba") || formats.contains("sgi"))
                ret << "*.bw"
                    << "*.rgb"
                    << "*.rgba"
                    << "*.sgi";

            // Truevision Targa Graphic
            if(formats.contains("tga"))
                ret << "*.tga";

            // Gimp format
            if(formats.contains("xcf"))
                ret << "*.xcf";

            return ret;

        }

        static inline QStringList getListForGm() {

            QStringList ret;

            ret << "*.avs"                  // AVS X image
                << "*.cal" << "*.cals"      // Continuous Acquisition and Life-cycle Support Type 1 image
                << "*.cin"                  // Kodak Cineon
                << "*.cut"                  // DR Halo
                << "*.acr" << "*.dcm"       // Digital Imaging and Communications in Medicine (DICOM) image
                           << "*.dicom"
                           << "*.dic"
                << "*.dcx"                  // ZSoft IBM PC multi-page Paintbrush image
                << "*.dib"                  // Microsoft Windows Device Independent Bitmap
                << "*.dpx"                  // Digital Moving Picture Exchange
                << "*.fax"                  // Group 3 FAX
                << "*.fits" << "*.fts"      // Flexible Image Transport System
                            << "*.fit"
                << "*.fpx"                  // FlashPix Format
                << "*.jng"                  // JPEG Network Graphics
                << "*.mat"                  // MATLAB image format
                << "*.miff"                 // Magick image file format
                << "*.mtv"                  // MTV Raytracing image format
                << "*.otb"                  // On-the-air Bitmap
                << "*.p7"                   // Xv's Visual Schnauzer thumbnail format
                << "*.palm"                 // Palm pixmap
                << "*.pam"                  // Portable Arbitrary Map format
                << "*.pcd" << "*.pcds"      // Photo CD
                << "*.pcx"                  // ZSoft IBM PC Paintbrush file
                << "*.pdb"                  // Palm Database ImageViewer Format
                << "*.pnm"                  // Portable anymap
                << "*.ptif" << "*.ptiff"    // Pyramid encoded TIFF
                << "*.sfw"                  // Seattle File Works image
                << "*.sgi"                  // Irix RGB image
                << "*.sun"                  // SUN Rasterfile
                << "*.tga"                  // Truevision Targa image
                << "*.vicar"                // VICAR rasterfile format
                << "*.wpg"                  // Word Perfect Graphics File
                << "*.xwd";                 // X Windows system window dump

            return ret;

        }

        static inline QStringList getListForRaw() {

            QStringList ret;

            ret << "*.3fr"                          // Hasselblad
                << "*.ari"                          // ARRIFLEX
                << "*.arw" << "*.srf" << "*.sr2"    // Sony
                << "*.bay"                          // Casio
                << "*.crw" << "*.crr" << "*.cr2"    // Canon
                << "*.cap" << "*.liq" << "*.eip"    // Phase_one
                << "*.dcs" << "*.dcr" << "*.drf"    // Kodak
                           << "*.k25" << "*.kdc"
                << "*.dng"                          // Adobe
                << "*.erf"                          // Epson
                << "*.fff"                          // Imacon/Hasselblad raw
                << "*.mef"                          // Mamiya
                << "*.mdc"                          // Minolta, Agfa
                << "*.mos"                          // Leaf
                << "*.mrw"                          // Minolta, Konica Minolta
                << "*.nef" << "*.nrw"               // Nikon
                << "*.orf"                          // Olympus
                << "*.pef" << "*.ptx"               // Pentax
                << "*.pxn"                          // Logitech
                << "*.r3d"                          // RED Digital Cinema
                << "*.raf"                          // Fuji
                << "*.raw" << "*.rw2"               // Panasonic
                << "*.raw" << "*.rwl" << "*.dng"    // Leica
                << "*.rwz"                          // Rawzor
                << "*.srw"                          // Samsung
                << "*.x3f";                         // Sigma

            return ret;

        }

        static inline QStringList getListForDevIL() {

            QStringList ret;

            ret << "*.cut"              // DR Halo
                << "*.dds"              // DirectDraw Surface
                << "*.lbm"              // Interlaced Bitmap
                << "*.lif"              // Homeworld File
                << "*.lmp"              // Doom Walls / Flats
                << "*.mdl"              // Half-Life Model
                << "*.pcd"              // PhotoCD
                << "*.pcx"              // ZSoft PCX
                << "*.pic"              // PIC
                << "*.psd"              // Adobe PhotoShop
                << "*.bw" << "*.rgb"    // Silicon Graphics
                          << "*.rgba"
                          << "*.sgi"
                << "*.tga"              // Truevision Targa Graphic
                << "*.wal";              // Quake2 Texture

            return ret;

        }

    }

}

#endif // FILEFORMATSDEFAULT_H

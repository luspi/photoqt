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

namespace FileFormatsHandler {

    namespace DefaultFormats {

        static inline QStringList getListForQt() {

            QStringList ret;

            QList<QByteArray> formats = QImageReader::supportedImageFormats();

            ret << "*.bmp"	// Microsoft Windows bitmap
                << "*.bitmap"

                << "*.dds"	// Direct Draw Surface

                << "*.gif"	// CompuServe Graphics Interchange Format

                << "*.tif"	// Tagged Image File Format
                << "*.tiff"

                << "*.jpeg2000"	// JPEG-2000 Code Stream Syntax
                << "*.jp2"
                << "*.jpc"
                << "*.j2k"
                << "*.jpf"
                << "*.jpx"
                << "*.jpm"
                << "*.mj2"

                << "*.mng"	// Multiple-image Network Graphics

                << "*.ico"	// Microsoft icon
                << "*.icns"

                << "*.jpeg"	// Joint Photographic Experts Group JFIF format
                << "*.jpg"

                << "*.png"	// Portable Network Graphics

                << "*.pbm"	// Portable bitmap format (black and white)

                << "*.pgm"	// Portable graymap format (gray scale)

                << "*.ppm"	// Portable pixmap format (color)

                << "*.svg"	// Scalable Vector Graphics
                << "*.svgz"

                << "*.wbmp"	// Wireless bitmap
                << "*.webp"

                << "*.xbm"	// X Windows system bitmap, black and white only

                << "*.xpm";	// X Windows system pixmap

            return ret;

        }

        static inline QStringList getListForKde() {

            QStringList ret;

            QList<QByteArray> formats = QImageReader::supportedImageFormats();

            if(formats.contains("eps") && formats.contains("epsf"))
                ret << "*.eps"   // Adobe Encapsulated PostScript
                    << "*.epsf";

            if(formats.contains("exr"))
                ret << "*.exr";   // OpenEXR

            if(formats.contains("kra"))
                ret << "*.kra";   // Krita Document

            if(formats.contains("ora"))
                ret << "*.ora";   // Open Raster Image File

            if(formats.contains("pcx"))
                ret << "*.pcx";   // PC Paintbrush

            if(formats.contains("pic"))
                ret << "*.pic";

            if(formats.contains("psd") && formats.contains("psb"))
                ret << "*.psd"   // Adobe PhotoShop
                    << "*.psb";

            if(formats.contains("ras"))
                ret << "*.ras";   // Sun Graphics

            if(formats.contains("rgb") && formats.contains("rgba"))
                ret << "*.rgb"
                    << "*.rgba";   // Silicon Graphics

            if(formats.contains("tga"))
                ret << "*.tga";   // Truevision Targa Graphic

            if(formats.contains("xcf"))
                ret << "*.xcf";    // Gimp format

            return ret;

        }

        static inline QStringList getListForGm() {

            QStringList ret;

            ret << "*.avs"	//AVS X image

                << "*.ras"	// Continuous Acquisition and Life-cycle Support Type 1 image

                << "*.cin"	// Kodak Cineon

                << "*.cut"	// DR Halo

                << "*.acr"	// Digital Imaging and Communications in Medicine (DICOM) image
                << "*.dcm"
                << "*.dicom"
                << "*.dic"

                << "*.dcx"	// ZSoft IBM PC multi-page Paintbrush image

                << "*.dib"	// Microsoft Windows Device Independent Bitmap

                << "*.dpx"	// Digital Moving Picture Exchange

                << "*.fax"	// Group 3 FAX

                << "*.fits"	// Flexible Image Transport System
                << "*.fts"
                << "*.fit"

                << "*.fpx"	// FlashPix Format

                << "*.jng"	// JPEG Network Graphics

                << "*.mat"	// MATLAB image format

                << "*.miff"	// Magick image file format

                << "*.mtv"	// MTV Raytracing image format

                << "*.otb"	// On-the-air Bitmap

                << "*.p7"	// Xv's Visual Schnauzer thumbnail format

                << "*.palm"	// Palm pixmap

                << "*.pam"	// Portable Arbitrary Map format

                << "*.pcd"	// Photo CD
                << "*.pcds"

                << "*.pcx"	// ZSoft IBM PC Paintbrush file

                << "*.pdb"	// Palm Database ImageViewer Format

                << "*.pnm"	// Portable anymap

                << "*.ptif"	// Pyramid encoded TIFF
                << "*.ptiff"

                << "*.sfw"	// Seattle File Works image

                << "*.sgi"	// Irix RGB image

                << "*.sun"	// SUN Rasterfile

                << "*.tga"	// Truevision Targa image

                << "*.vicar"	// VICAR rasterfile format

                << "*.wpg"	// Word Perfect Graphics File

                << "*.xwd";	// X Windows system window dump

            return ret;

        }

        static inline QStringList getListForRaw() {

            QStringList ret;

            ret << "*.3fr"							// Hasselblad
                << "*.ari"							// ARRIFLEX
                << "*.arw" << "*.srf" << "*.sr2"	// Sony
                << "*.bay"							// Casio
                << "*.crw" << "*.crr" << "*.cr2"	// Canon
                << "*.cap" << "*.liq" << "*.eip"	// Phase_one
                << "*.dcs" << "*.dcr" << "*.drf"	// Kodak
                           << "*.k25" << "*.kdc"
                << "*.dng"							// Adobe
                << "*.erf"							// Epson
                << "*.fff"							// Imacon/Hasselblad raw
                << "*.mef"							// Mamiya
                << "*.mdc"							// Minolta, Agfa
                << "*.mos"							// Leaf
                << "*.mrw"							// Minolta, Konica Minolta
                << "*.nef" << "*.nrw"				// Nikon
                << "*.orf"							// Olympus
                << "*.pef" << "*.ptx"				// Pentax
                << "*.pxn"							// Logitech
                << "*.r3d"							// RED Digital Cinema
                << "*.raf"							// Fuji
                << "*.raw" << "*.rw2"				// Panasonic
                << "*.raw" << "*.rwl" << "*.dng"	// Leica
                << "*.rwz"							// Rawzor
                << "*.srw"							// Samsung
                << "*.x3f";						// Sigma

            return ret;

        }

    }

}

#endif // FILEFORMATSDEFAULT_H

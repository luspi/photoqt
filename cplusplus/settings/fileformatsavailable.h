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

#ifndef FILEFORMATSAVAILABLE_H
#define FILEFORMATSAVAILABLE_H

#include <QStringList>
#include <QMap>
#include <QVariantList>

namespace FileFormatsHandler {

    namespace AvailableFormats {

        static inline QStringList getListForQt() {

            /*************************************
             ***** SUPPORTED QT FILE FORMATS *****
             *************************************/

            QStringList ret;

            ret << "*.bmp" << "*.bitmap"            // Microsoft Windows bitmap
                << "*.gif"                          // CompuServe Graphics Interchange Format
                << "*.jp2" << "*.jpc" << "*.j2k"    // JPEG-2000 Code Stream Syntax
                           << "*.jpeg2000"
                           << "*.jpx"
                << "*.mng"                          // Multiple-image Network Graphics
                << "*.ico" << "*.cur"               // Microsoft icon
                << "*.icns"                         // Macintosh OS X icon
                << "*.jpeg" << "*.jpg" << "*.jpe"   // Joint Photographic Experts Group JFIF format
                << "*.png"                          // Portable Network Graphics
                << "*.pbm"                          // Portable bitmap format (black and white)
                << "*.pgm"                          // Portable graymap format (gray scale)
                << "*.ppm"                          // Portable pixmap format (color)
                << "*.pnm"                          // Portable anymap (can contain any one of pbm, pgm, ppm)
                << "*.svg" << "*.svgz"              // Scalable Vector Graphics
                << "*.tga"                          // Truevision Targa Graphic
                << "*.tif" << "*.tiff"              // Tagged Image File Format
                << "*.wbmp"                         // Wireless bitmap
                << "*.webp"                         // Google web image format
                << "*.xbm"                          // X Windows system bitmap, black and white only
                << "*.xpm";                         // X Windows system pixmap

            return ret;

        }

        static inline QStringList getListForKde() {

            /**************************************
             ***** SUPPORTED KDE FILE FORMATS *****
             **************************************/

            QStringList ret;

            ret << "*.eps" << "*.epsf" << "*.epsi"  // Adobe Encapsulated PostScript
                << "*.exr"                          // OpenEXR
                << "*.kra"                          // Krita Document
                << "*.ora"                          // Open Raster Image File
                << "*.pcx"                          // ZSoft PCX
                << "*.pic"                          // Apple Macintosh QuickDraw/PICT file
                << "*.psd"                          // Adobe PhotoShop
                << "*.ras"                          // Sun Graphics
                << "*.bw" << "*.rgb" << "*.rgba"    // Silicon Graphics
                          << "*.sgi"
                << "*.tga"                          // Truevision Targa Graphic
                << "*.xcf";                         // Gimp format

            return ret;

        }

        static inline QStringList getListForExtras() {

            /*****************************************
             ***** SUPPORTED EXTRAS FILE FORMATS *****
             *****************************************/

            QStringList ret;

            ret << "*.psb"
                << "*.psd"
                << "*.xcf";

            return ret;
        }

        static inline QStringList getListForGm() {

            /*************************************
             ***** SUPPORTED GM FILE FORMATS *****
             *************************************/

            QStringList ret;

#ifdef GM

            ret << "*.avs" << "*.x"                 // AVS X image
                << "*.cals" << "*.cal" << "*.dcl"   // Continuous Acquisition and Life-cycle Support Type 1 image
                << "*.cin"                          // Kodak Cineon
                << "*.cut"                          // DR Halo
                << "*.acr" << "*.dcm" << "*.dicom"  // Digital Imaging and Communications in Medicine (DICOM) image
                           << "*.dic"
                << "*.dcx"                          // ZSoft IBM PC multi-page Paintbrush image
                << "*.dib"                          // Microsoft Windows Device Independent Bitmap
                << "*.dpx"                          // Digital Moving Picture Exchange
                << "*.epdf"                         // Encapsulated Portable Document Format
                << "*.fax"                          // Group 3 FAX
                << "*.fits" << "*.fts" << "*.fit"   // Flexible Image Transport System
                << "*.fpx"                          // FlashPix Format
                << "*.jng"                          // JPEG Network Graphics
                << "*.jpg" << "*.jpeg" << "*.jpe"
                << "*.mat"                          // MATLAB image format
                << "*.miff"                         // Magick image file format
                << "*.mono"                         // Bi-level bitmap in least-significant-byte first order
                << "*.mtv"                          // MTV Raytracing image format
                << "*.otb"                          // On-the-air Bitmap
                << "*.p7"                           // Xv's Visual Schnauzer thumbnail format
                << "*.palm"                         // Palm pixmap
                << "*.pam"                          // Portable Arbitrary Map format
                << "*.pcd" << "*.pcds"              // Photo CD
                << "*.pcx"                          // ZSoft IBM PC Paintbrush file
                << "*.pdb"                          // Palm Database ImageViewer Format
                << "*.pict" << "*.pct" << "*.pic"   // Apple Macintosh QuickDraw /PICT file
                << "*.pix" << "*.pal"               // Alias/Wavefront RLE image format
                << "*.pnm"                          // Portable anymap
                << "*.psd"                          // Adobe Photoshop bitmap file
                << "*.ptif" << "*.ptiff"            // Pyramid encoded TIFF
                << "*.sfw"                          // Seattle File Works image
                << "*.sgi"                          // Irix RGB image
                << "*.sun"                          // SUN Rasterfile
                << "*.tga"                          // Truevision Targa image
                << "*.vicar"                        // VICAR rasterfile format
                << "*.viff"                         // Khoros Visualization Image File Format
                << "*.wpg"                          // Word Perfect Graphics File
                << "*.xwd";                         // X Windows system window dump

#endif

            return ret;

        }

        static inline QStringList getListForGmGhostscript() {

            /*************************************
             ***** SUPPORTED GM FILE FORMATS *****
             *****    Ghotscript required    *****
             *************************************/

            QStringList ret;

#ifdef GM

            ret << "*.epi" << "*.epsi"      // Adobe Encapsulated PostScript Interchange format
                << "*.eps"<< "*.epsf"       // Adobe Encapsulated PostScript
                << "*.eps2"                 // Adobe Level II Encapsulated PostScript
                << "*.eps3"                 // Adobe Level III Encapsulated PostScript
                << "*.ept"                  // Adobe Encapsulated PostScript Interchange format with TIFF preview
                << "*.pdf"                  // Portable Document Format
                << "*.ps"                   // Adobe PostScript file
                << "*.ps2"                  // Adobe Level II PostScript file
                << "*.ps3";                 // Adobe Level III PostScript file

#endif

            return ret;

        }

        static inline QStringList getListForUntested() {

            /************************************
             ***** UNTESTED GM FILE FORMATS *****
             *****  no test image available *****
             ************************************/

            QStringList ret;

#ifdef GM

            ret << "*.hp" << "*.hpgl"       // HP-GL plotter language
                << "*.jbig" << "*.jbg"      // Joint Bi-level Image experts Group file interchange format
                << "*.pwp"                  // Seattle File Works multi-image file
                << "*.rast"                 // Sun Raster Image
                << "*.rla"                  // Alias/Wavefront image file
                << "*.rle"                  // Utah Run length encoded image file
                << "*.sct"                  // Scitex Continuous Tone Picture
                << "*.tim";                 // PSX TIM file

#endif

            return ret;

        }

        static inline QStringList getListForRaw() {

            /**************************************
             ***** SUPPORTED RAW FILE FORMATS *****
             **************************************/

            QStringList ret;

#ifdef RAW

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

#endif

            return ret;

        }

        static inline QStringList getListForDevIL() {

            /**************************************
             ***** SUPPORTED RAW FILE FORMATS *****
             **************************************/

            QStringList ret;

#ifdef DEVIL

            ret << "*.cut"              // DR Halo
                << "*.dds"              // DirectDraw Surface
                << "*.lbm"              // Interlaced Bitmap
                << "*.lif"              // Homeworld File
                << "*.lmp"              // Doom Walls / Flats
                << "*.mdl"              // Half-Life Model
                << "*.pcd"              // PhotoCD
                << "*.pcx"              // ZSoft PCX
                << "*.pic"              // Apple Macintosh QuickDraw/PICT file
                << "*.psd"              // Adobe PhotoShop
                << "*.bw" << "*.rgb"    // Silicon Graphics
                          << "*.rgba"
                          << "*.sgi"
                << "*.tga"              // Truevision Targa Graphic
                << "*.wal";              // Quake2 Texture

#endif

            return ret;

        }

    }

}

#endif // FILEFORMATSAVAILABLE_H

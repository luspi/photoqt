#ifndef FILEFORMATSDEFAULT_H
#define FILEFORMATSDEFAULT_H

#include <QStringList>

namespace FileFormatsHandler {

	namespace DefaultFormats {

		static inline QStringList getList() {

			QStringList ret;

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

					 << "*.xpm"	// X Windows system pixmap



					 << "*.avs"	//AVS X image

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

	}

}

#endif // FILEFORMATSDEFAULT_H

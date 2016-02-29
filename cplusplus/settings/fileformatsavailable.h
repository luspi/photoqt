#ifndef FILEFORMATSAVAILABLE_H
#define FILEFORMATSAVAILABLE_H

#include <QStringList>

namespace FileFormatsHandler {

	namespace AvailableFormats {

//		static inline void getList(QStringList *formats_qt, QStringList *formats_gm, QStringList *formats_gm_ghostscript, QStringList *formats_extras, QStringList *formats_untested, QStringList *formats_raw) {

		static inline QStringList getListForQt() {

			QStringList ret;

			/*************************************
			 ***** SUPPORTED QT FILE FORMATS *****
			 *************************************/

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

		static inline QStringList getListForExtras() {

			QStringList ret;

			ret << "**.psb"
				<< "**.psd"
				<< "**.xcf";

			return ret;
		}

		static inline QStringList getListForGm() {

			QStringList ret;

#ifdef GM


			/*************************************
			 ***** SUPPORTED GM FILE FORMATS *****
			 *************************************/

	// WORKING
			ret << "*.avs"	//AVS X image
				<< "*.x"

	// WORKING
				<< "*.cals"	// Continuous Acquisition and Life-cycle Support Type 1 image
				<< "*.cal"
				<< "*.dcl"
				<< "*.ras"

	// WORKING
				<< "*.cin"	// Kodak Cineon

	// WORKING
				<< "*.cut"	// DR Halo

	// WORKING
				<< "*.acr"	// Digital Imaging and Communications in Medicine (DICOM) image
				<< "*.dcm"
				<< "*.dicom"
				<< "*.dic"

	// WORKING
				<< "*.dcx"	// ZSoft IBM PC multi-page Paintbrush image

	// WORKING
				<< "*.dib"	// Microsoft Windows Device Independent Bitmap

	// WORKING
				<< "*.dpx"	// Digital Moving Picture Exchange

	// WORKING
				<< "*.epdf"	// Encapsulated Portable Document Format

	// WORKING
				<< "*.fax"	// Group 3 FAX

	// WORKING
				<< "*.fits"	// Flexible Image Transport System
				<< "*.fts"
				<< "*.fit"

	// WORKING
				<< "*.fpx"	// FlashPix Format

	// WORKING
				<< "*.jng"	// JPEG Network Graphics

	// WORKING
				<< "*.mat"	// MATLAB image format

	// WORKING
				<< "*.miff"	// Magick image file format

	// WORKING
				<< "*.mono"	// Bi-level bitmap in least-significant-byte first order

	// WORKING
				<< "*.mtv"	// MTV Raytracing image format

	// WORKING
				<< "*.otb"	// On-the-air Bitmap

	// WORKING
				<< "*.p7"	// Xv's Visual Schnauzer thumbnail format

	// WORKING
				<< "*.palm"	// Palm pixmap

	// WORKING
				<< "*.pam"	// Portable Arbitrary Map format

	// WORKING
				<< "*.pcd"	// Photo CD
				<< "*.pcds"

	// WORKING
				<< "*.pcx"	// ZSoft IBM PC Paintbrush file

	// WORKING
				<< "*.pdb"	// Palm Database ImageViewer Format

	// WORKING
				<< "*.pict"	// Apple Macintosh QuickDraw /PICT file
				<< "*.pct"
				<< "*.pic"

	// WORKING
				<< "*.pix"	// Alias/Wavefront RLE image format
				<< "*.pal"

	// WORKING
				<< "*.pnm"	// Portable anymap

	// WORKING
				<< "*.psd"	// Adobe Photoshop bitmap file

	// WORKING
				<< "*.ptif"	// Pyramid encoded TIFF
				<< "*.ptiff"

	// WORKING
				<< "*.sfw"	// Seattle File Works image

	// WORKING
				<< "*.sgi"	// Irix RGB image

	// WORKING
				<< "*.sun"	// SUN Rasterfile

	// WORKING
				<< "*.tga"	// Truevision Targa image

	// WORKING
				<< "*.txt"	// Text files

	// WORKING
				<< "*.vicar"	// VICAR rasterfile format

	// WORKING
				<< "*.viff"	// Khoros Visualization Image File Format

	// WORKING
				<< "*.wpg"	// Word Perfect Graphics File

	// WORKING
				<< "*.xwd";	// X Windows system window dump

#endif

			return ret;

		}

		static inline QStringList getListForGmGhostscript() {

			QStringList ret;

#ifdef GM

	// WORKING (Ghostscript required)
			ret << "*.epi"	// Adobe Encapsulated PostScript Interchange format
				<< "*.epsi"

	// WORKING (Ghostscript required)
				<< "*.eps"	// Adobe Encapsulated PostScript
				<< "*.epsf"

	// WORKING (Ghostscript required)
				<< "*.eps2"	// Adobe Level II Encapsulated PostScript

	// WORKING (Ghostscript required)
				<< "*.eps3"	// Adobe Level III Encapsulated PostScript

	// WORKING (Ghostscript required)
				<< "*.ept"	// Adobe Encapsulated PostScript Interchange format with TIFF preview

	// WORKING (Ghostscript required)
				<< "*.pdf"	// Portable Document Format

	// WORKING (Ghostscript required)
				<< "*.ps"	// Adobe PostScript file

	// WORKING (Ghostscript required)
				<< "*.ps2"	// Adobe Level II PostScript file

	// WORKING (Ghostscript required)
				<< "*.ps3";	// Adobe Level III PostScript file

#endif

			return ret;

		}

		static inline QStringList getListForUntested() {

			QStringList ret;

#ifdef GM

	// UNTESTED (no test image available)
			ret << "*.hp"	// HP-GL plotter language
				<< "*.hpgl"
				<< "*.jbig"	// Joint Bi-level Image experts Group file interchange format
				<< "*.jbg"
				<< "*.pwp"	// Seattle File Works multi-image file
				<< "*.rast"	// Sun Raster Image
				<< "*.rla"	// Alias/Wavefront image file
				<< "*.rle"	// Utah Run length encoded image file
				<< "*.sct"	// Scitex Continuous Tone Picture
				<< "*.tim";	// PSX TIM file

#endif

			return ret;

		}

		static inline QStringList getListForRaw() {

			QStringList ret;

#ifdef RAW

			ret << "*.3fr"							// Hasselblad
				<< "*.ari"							// ARRIFLEX
				<< "*.arw" << "*.srf" << "*.sr2"	// Sony
				<< "*.bay"							// Casio
				<< "*.crw" << "*.crr"				// Canon
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
				<< "*.x3f";							// Sigma

#endif

			return ret;

		}

	}

}

#endif // FILEFORMATSAVAILABLE_H

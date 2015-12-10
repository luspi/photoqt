#ifndef FILEFORMATS_H
#define FILEFORMATS_H

#include <QObject>
#include <QTextStream>
#include <iostream>
#include <QDir>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QtDebug>

class FileFormats : public QObject {

	Q_OBJECT

private:
	QFileSystemWatcher *watcher;
	QTimer *saveFileformatsTimer;

	QStringList TMP_formatsQtEnabled;
	QStringList TMP_formatsGmEnabled;
	QStringList TMP_formatsGmGhostscriptEnabled;
	QStringList TMP_formatsExtrasEnabled;
	QStringList TMP_formatsUntestedEnabled;

public:

	FileFormats(QObject *parent = 0) : QObject(parent) {

		setDefaultFormats();
		getFormats("");

		watcher = new QFileSystemWatcher;
		watcher->addPaths(QStringList() << QDir::homePath() + "/.photoqt/settings" << QDir::homePath() + "/.photoqt/fileformats.disabled");
		connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(getFormats(QString)));

		// When saving the settings, we don't want to write the settings file hundreds of time within a few milliseconds, but use a timer to save it once after all settings are set
		saveFileformatsTimer = new QTimer;
		saveFileformatsTimer->setInterval(400);
		saveFileformatsTimer->setSingleShot(true);
		connect(saveFileformatsTimer, SIGNAL(timeout()), this, SLOT(initiateSaving()));

	}

	~FileFormats() { delete watcher; }

	// Per default enabled image formats
	QStringList formatsQtEnabled;
	QStringList formatsGmEnabled;
	QStringList formatsGmGhostscriptEnabled;
	QStringList formatsExtrasEnabled;
	QStringList formatsUntestedEnabled;

	QStringList getFormatsQtEnabled() { return formatsQtEnabled; }
	QStringList getFormatsGmEnabled() { return formatsGmEnabled; }
	QStringList getFormatsGmGhostscriptEnabled() { return formatsGmGhostscriptEnabled; }
	QStringList getFormatsExtrasEnabled() { return formatsExtrasEnabled; }
	QStringList getFormatsUntestedEnabled() { return formatsUntestedEnabled; }
	void setFormatsQtEnabled(const QStringList val) { TMP_formatsQtEnabled = val; saveFileformatsTimer->start(); }
	void setFormatsGmEnabled(const QStringList val) { TMP_formatsGmEnabled = val; saveFileformatsTimer->start(); }
	void setFormatsGmGhostscriptEnabled(const QStringList val) { TMP_formatsGmGhostscriptEnabled = val; saveFileformatsTimer->start(); }
	void setFormatsExtrasEnabled(const QStringList val) { TMP_formatsExtrasEnabled = val; saveFileformatsTimer->start(); }
	void setFormatsUntestedEnabled(const QStringList val) { TMP_formatsUntestedEnabled = val; saveFileformatsTimer->start(); }
	Q_PROPERTY(QStringList formatsQtEnabled READ getFormatsQtEnabled WRITE setFormatsQtEnabled NOTIFY formatsQtEnabledChanged)
	Q_PROPERTY(QStringList formatsGmEnabled READ getFormatsGmEnabled WRITE setFormatsGmEnabled NOTIFY formatsGmEnabledChanged)
	Q_PROPERTY(QStringList formatsGmGhostscriptEnabled READ getFormatsGmGhostscriptEnabled WRITE setFormatsGmGhostscriptEnabled NOTIFY formatsGmGhostscriptEnabledChanged)
	Q_PROPERTY(QStringList formatsExtrasEnabled READ getFormatsExtrasEnabled WRITE setFormatsExtrasEnabled NOTIFY formatsExtrasEnabledChanged)
	Q_PROPERTY(QStringList formatsUntestedEnabled READ getFormatsUntestedEnabled WRITE setFormatsUntestedEnabled NOTIFY formatsUntestedEnabledChanged)

	void setDefaultFormats() {

		formatsQtEnabled.clear();
		formatsGmEnabled.clear();
		formatsGmGhostscriptEnabled.clear();
		formatsExtrasEnabled.clear();
		formatsUntestedEnabled.clear();

		/******************************
		 ***** 14 FORMATS WORKING *****
		 ******************************/

		formatsQtEnabled << "*.bmp"	// Microsoft Windows bitmap
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



		formatsExtrasEnabled << "**.psb"
							 << "**.psd"
							 << "**.xcf";

#ifdef GM


		/**************************************
		 ***** 49 FORMATS PASSED THE TEST *****
		 **************************************/

// WORKING
		formatsGmEnabled << "*.avs"	//AVS X image
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


// WORKING (Ghostscript required)
		formatsGmGhostscriptEnabled << "*.epi"	// Adobe Encapsulated PostScript Interchange format
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


// UNTESTED (no test image available)
		formatsUntestedEnabled << "*.hp"	// HP-GL plotter language
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

	}


public slots:

	// Read formats from file (if available)
	void getFormats(QString path) {

		QFile file2(QDir::homePath() + "/.photoqt/fileformats.disabled");

		if(file2.exists()) {

			if(!file2.open(QIODevice::ReadOnly))
				std::cerr << "ERROR: Can't open disabled image formats file" << std::endl;
			else {

				QTextStream in(&file2);

				QString line = in.readLine();
				while (!line.isNull()) {
					line = line.trimmed();

					if(line.length() != 0 && formatsQtEnabled.contains(line))
						formatsQtEnabled.removeAll(line);
					if(line.length() != 0 && formatsExtrasEnabled.contains(line))
						formatsExtrasEnabled.removeAll(line);
					if(line.length() != 0 && formatsGmEnabled.contains(line))
						formatsGmEnabled.removeAll(line);
					if(line.length() != 0 && formatsGmGhostscriptEnabled.contains(line))
						formatsGmGhostscriptEnabled.removeAll(line);
					if(line.length() != 0 && formatsUntestedEnabled.contains(line))
						formatsUntestedEnabled.removeAll(line);

					line = in.readLine();
				}

			}

		}

		emit formatsQtEnabledChanged(formatsQtEnabled);
		emit formatsGmEnabledChanged(formatsGmEnabled);
		emit formatsGmGhostscriptEnabledChanged(formatsGmGhostscriptEnabled);
		emit formatsExtrasEnabledChanged(formatsExtrasEnabled);
		emit formatsUntestedEnabledChanged(formatsUntestedEnabled);

	}

private slots:

	void initiateSaving() {
		saveFormats(TMP_formatsQtEnabled, TMP_formatsGmEnabled, TMP_formatsGmGhostscriptEnabled, TMP_formatsExtrasEnabled, TMP_formatsUntestedEnabled);
	}

	// Save all enabled formats to file
	void saveFormats(QStringList new_qtFormats, QStringList new_gmFormats, QStringList new_gmghostscriptFormats,
					 QStringList new_extrasFormats, QStringList new_untestedFormats) {

		setDefaultFormats();

		QStringList disabled;

		for(int i = 0; i < formatsQtEnabled.length(); ++i) {

			if(!new_qtFormats.contains(formatsQtEnabled.at(i)))
				disabled.append(formatsQtEnabled.at(i));

		}

		for(int i = 0; i < formatsGmEnabled.length(); ++i) {

			if(!new_gmFormats.contains(formatsGmEnabled.at(i)))
				disabled.append(formatsGmEnabled.at(i));

		}

		for(int i = 0; i < formatsGmGhostscriptEnabled.length(); ++i) {

			if(!new_gmghostscriptFormats.contains(formatsGmGhostscriptEnabled.at(i)))
				disabled.append(formatsGmGhostscriptEnabled.at(i));

		}

		for(int i = 0; i < formatsExtrasEnabled.length(); ++i) {

			if(!new_extrasFormats.contains(QString(formatsExtrasEnabled.at(i)).remove(0,1)))
				disabled.append(formatsExtrasEnabled.at(i));

		}

		for(int i = 0; i < formatsUntestedEnabled.length(); ++i) {

			if(!new_untestedFormats.contains(formatsUntestedEnabled.at(i)))
				disabled.append(formatsUntestedEnabled.at(i));

		}

		formatsQtEnabled = new_qtFormats;
		formatsGmEnabled = new_gmFormats;
		formatsGmGhostscriptEnabled = new_gmghostscriptFormats;
		formatsExtrasEnabled = new_extrasFormats;
		formatsUntestedEnabled = new_untestedFormats;

		QFile file(QDir::homePath() + "/.photoqt/fileformats.disabled");
		if(file.exists()) {
			if(!file.remove())
				std::cerr << "ERROR: Cannot replace disabled image formats file" << std::endl;
		}
		if(!file.open(QIODevice::WriteOnly))
			std::cerr << "ERROR: Cannot write to disabled image formats file" << std::endl;
		else {
			QTextStream out(&file);
			out << disabled.join("\n");
			file.close();
		}

	}

signals:
	void formatsQtEnabledChanged(QStringList val);
	void formatsGmEnabledChanged(QStringList val);
	void formatsGmGhostscriptEnabledChanged(QStringList val);
	void formatsExtrasEnabledChanged(QStringList val);
	void formatsUntestedEnabledChanged(QStringList val);

};

#endif // FILEFORMATS_H

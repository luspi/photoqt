#ifndef LOADER_H
#define LOADER_H

#include <QImage>
#include <QtSvg>

#include "errorimage.h"

#include <archive.h>
#include <archive_entry.h>

#ifdef RAW
// Both the libraw and the freeimage library have typedefs for INT64 and UINT64.
// As we never use them directly, we can redefine one of them (here for libraw) to use a different name and thus avoid the clash.
#define INT64 INT64_SOMETHINGELSE
#define UINT64 UINT64_SOMETHINGELSE
#include <libraw/libraw.h>
#endif

#ifdef FREEIMAGE
#undef INT64
#undef UINT64
#include <FreeImagePlus.h>
#endif

#ifdef DEVIL
#include <IL/il.h>
#endif

#ifdef EXIV2
#include <exiv2/exiv2.hpp>
#include <QLockFile>
#include <thread>
#endif

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#endif

#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif

class PLoadImage {

public:
    static QImage FreeImage(QString filename, QSize maxSize);
    static QImage Qt(QString filename, QSize maxSize, bool metaRotate);
    static QImage Archive(QString filename, QSize maxSize);
    static QImage DevIL(QString filename, QSize maxSize);
    static QImage Raw(QString filename, QSize maxSize, bool loadEmbeddedThumbnail, bool neededForThumbnails);
    static QImage GraphicsMagick(QString filename, QSize maxSize);
    static QImage Poppler(QString filename, QSize maxSize, int pdfQuality);
    static QImage Unrar(QString filename, QSize maxSize);
    static QImage Xcftools(QString filename, QSize maxSize);

private:
    static void safelyReadMetadata(Exiv2::Image::AutoPtr *image);
#ifdef GM
    static std::string getImageMagickString(QString suf);
#endif

};


#endif // LOADER_H

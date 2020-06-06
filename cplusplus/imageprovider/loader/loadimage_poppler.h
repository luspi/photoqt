#ifndef PQLOADIMAGESPOPPLER_H
#define PQLOADIMAGESPOPPLER_H

#include <QImage>
#include "../../settings/settings.h"
#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif

#include "../../logger.h"

class PQLoadImagePoppler {

public:
    PQLoadImagePoppler() {
        errormsg = "";
    }

    QImage load(QString filename, QSize maxSize, QSize *origSize) {

#ifdef POPPLER

        errormsg = "";

        // extract page and totalpage value from filename (prepended to filename (after filepath))
        int page = 0;
        if(filename.contains("::PQT::")) {
            page = filename.split("::PQT::").at(0).toInt();
            filename = filename.split("::PQT::").at(1);
        }

        // Load poppler document and render to QImage
        Poppler::Document* document = Poppler::Document::load(filename);
        if(!document || document->isLocked()) {
            std::stringstream ss;
            ss << "PQLoadImage::PDF::load(): ERROR: Invalid PDF document, unable to load!";
            LOG << CURDATE << ss.str() << NL;
            errormsg = "Invalid PDF document, unable to load!";
            return QImage();
        }
        document->setRenderHint(Poppler::Document::TextAntialiasing);
        document->setRenderHint(Poppler::Document::Antialiasing);
        Poppler::Page *p = document->page(page);
        if(p == nullptr) {
            errormsg = QString("Error: unable to read page %1").arg(page);
            LOG << CURDATE << "PQLoadImage::PDF::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }
        QImage ret = p->renderToImage(PQSettings::get().getPdfQuality(), PQSettings::get().getPdfQuality());
        *origSize = ret.size();
        delete document;

        // ensure it fits inside maxSize
        if(maxSize.width() > 5 && maxSize.height() > 5) {
            if(ret.width() > maxSize.width() || ret.height() > maxSize.height())
                return ret.scaled(maxSize, ::Qt::KeepAspectRatio);
        }

        // return render image
        return ret;

#endif

    errormsg = "Failed to load image with Poppler!";
    return QImage();


    }

    QString errormsg;

};

#endif // PQLOADIMAGESPOPPLER_H

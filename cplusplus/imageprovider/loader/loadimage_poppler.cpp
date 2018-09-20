#include "loader.h"

QImage PLoadImage::Poppler(QString filename, QSize maxSize, int pdfQuality) {

#ifdef POPPLER

    // extract page and totalpage value from filename (prepended to filename (after filepath))
    int page = 0;
    if(filename.contains("::PQT1::") && filename.contains("::PQT2::")) {

        QString pageinfo = filename.split("::PQT1::").at(1).split("::PQT2::").at(0);
        page = pageinfo.split("::").at(0).toInt();

        filename = filename.remove(QString("::PQT1::%1::PQT2::").arg(pageinfo));
    }

    // Load poppler document and render to QImage
    Poppler::Document* document = Poppler::Document::load(filename);
    if(!document || document->isLocked()) {
        std::stringstream ss;
        ss << "LoadImage::PDF::load(): ERROR: Invalid PDF document, unable to load!";
        LOG << CURDATE << ss.str() << NL;
        return PErrorImage::load(QString::fromStdString(ss.str()));
    }
    document->setRenderHint(Poppler::Document::TextAntialiasing);
    document->setRenderHint(Poppler::Document::Antialiasing);
    QImage ret = document->page(page)->renderToImage(pdfQuality, pdfQuality);
    delete document;

    // ensure it fits inside maxSize
    if(maxSize.width() > 5 && maxSize.height() > 5) {
        if(ret.width() > maxSize.width() || ret.height() > maxSize.height())
            return ret.scaled(maxSize, ::Qt::KeepAspectRatio);
    }

    // return render image
    return ret;

#else

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "LoadImagePDF: PhotoQt was compiled without Poppler support, returning error image" << NL;

    return PErrorImage::load("Failed to load image with Poppler!");

#endif

}

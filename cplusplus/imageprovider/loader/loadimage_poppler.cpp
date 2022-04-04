#include "loadimage_poppler.h"

PQLoadImagePoppler::PQLoadImagePoppler() {
    errormsg = "";
}

QImage PQLoadImagePoppler::load(QString filename, QSize maxSize, QSize *origSize) {

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
        errormsg = "Invalid PDF document, unable to load!";
        LOG << CURDATE << "PQLoadImagePoppler::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }
    document->setRenderHint(Poppler::Document::TextAntialiasing);
    document->setRenderHint(Poppler::Document::Antialiasing);
    Poppler::Page *p = document->page(page);
    if(p == nullptr) {
        errormsg = QString("Unable to read page %1").arg(page);
        LOG << CURDATE << "PQLoadImagePoppler::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    double useQuality = PQSettings::get()["filetypesPDFQuality"].toDouble();
    if(maxSize.width() != -1 && maxSize.height() != -1) {
        double factor1 = maxSize.width()/p->pageSizeF().width();
        double factor2 = maxSize.height()/p->pageSizeF().height();
        double factor = qMin(factor1, factor2);
        useQuality = 72.0*factor;
    }

    QImage ret = p->renderToImage(useQuality, useQuality);

    *origSize = p->pageSize()*(PQSettings::get()["filetypesPDFQuality"].toDouble()/72.0);
    delete document;

    // return render image
    return ret;

#endif

    errormsg = "Failed to load image, Poppler not supported by this build of PhotoQt!";
    LOG << CURDATE << "PQLoadImagePoppler::load(): " << errormsg.toStdString() << NL;
    return QImage();

}

#include <pqc_loadimage_resvg.h>
#include <pqc_imagecache.h>
#include <pqc_settings.h>
#include <QSize>
#include <QImage>
#ifdef PQMRESVG
#include <ResvgQt.h>
#endif

PQCLoadImageResvg::PQCLoadImageResvg() {}

QSize PQCLoadImageResvg::loadSize(QString filename) {

    qDebug() << "args: filename =" << filename;

#ifdef PQMRESVG

    ResvgOptions opt;
    ResvgRenderer renderer(filename, opt);
    return renderer.defaultSize();

#endif

    return QSize();

}

QString PQCLoadImageResvg::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize =" << maxSize;

#ifdef PQMRESVG

    ResvgOptions opt;
    ResvgRenderer renderer(filename, opt);

    if(!renderer.isValid()) {
        QString errmsg = "Invalid SVG encountered";
        qWarning() << errmsg;
        return errmsg;
    }

    origSize = renderer.defaultSize();

    if(maxSize.isValid())
        img = renderer.renderToImage(maxSize);
    else
        img = renderer.renderToImage();

    return "";

#endif

    return "";

}

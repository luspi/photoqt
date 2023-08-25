#include <pqc_loadimage_resvg.h>
#include <pqc_imagecache.h>
#include <pqc_settings.h>
#include <QSize>
#include <QImage>
#ifdef RESVG
#include <ResvgQt.h>
#endif

PQCLoadImageResvg::PQCLoadImageResvg() {}

QSize PQCLoadImageResvg::loadSize(QString filename) {

    qDebug() << "args: filename =" << filename;

#ifdef RESVG

    ResvgOptions opt;
    ResvgRenderer renderer(filename, opt);
    return renderer.defaultSize();

#endif

    return QSize();

}

QString PQCLoadImageResvg::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize =" << maxSize;

#ifdef RESVG

    ResvgOptions opt;
    ResvgRenderer renderer(filename, opt);

    if(maxSize.isValid())
        img = renderer.renderToImage();
    else
        img = renderer.renderToImage(maxSize);

    return "";

#endif

    return "";

}

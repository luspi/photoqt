#include "loader.h"

QImage PLoadImage::Qt(QString filename, QSize maxSize, bool metaRotate) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "LoadImageQt: Load image using Qt: " << QFileInfo(filename).fileName().toStdString() << NL;

    // For reading SVG files
    QSvgRenderer svg;
    QPixmap svg_pixmap;

    // For all other supported file types
    QImageReader reader;

    // Return image
    QImage img;

    QSize origSize;

    // Suffix, for easier access later-on
    QString suffix = QFileInfo(filename).suffix().toLower();

    if(suffix == "svg") {

        // Loading SVG file
        svg.load(filename);

        // Invalid vector graphic
        if(!svg.isValid()) {
            LOG << CURDATE << "LoadImageQt: reader svg - Error: invalid svg file" << NL;
            return PErrorImage::load("The file doesn't contain a valid vector graphic");
        }

        // Render SVG into pixmap
        svg_pixmap = QPixmap(svg.defaultSize());
        svg_pixmap.fill(::Qt::transparent);
        QPainter painter(&svg_pixmap);
        svg.render(&painter);

        // Store the width/height for later use
        origSize = svg.defaultSize();

    } else {

        // Setting QImageReader
        reader.setFileName(filename);

        // Store the width/height for later use
        origSize = reader.size();

        // Sometimes the size returned by reader.size() is <= 0 (observed for, e.g., .jp2 files)
        // -> then we need to load the actual image to get dimensions
        if(origSize.width() <= 0 || origSize.height() <= 0) {
            LOG << CURDATE << "LoadImageQt: imagereader qt - Error: failed to read origsize" << NL;
            QImageReader r;
            r.setFileName(filename);
            origSize = r.read().size();
        }

    }

    int dispWidth = origSize.width();
    int dispHeight = origSize.height();

    double q;

    if(dispWidth > maxSize.width()) {
        q = maxSize.width()/(dispWidth*1.0);
        dispWidth *= q;
        dispHeight *= q;
    }

    // If thumbnails are kept visible, then we need to subtract their height from the absolute height otherwise they overlap with main image
    if(dispHeight > maxSize.height()) {
        q = maxSize.height()/(dispHeight*1.0);
        dispWidth *= q;
        dispHeight *= q;
    }

    // Finalise SVG files
    if(suffix == "svg") {

        // Convert pixmap to image
        img = svg_pixmap.toImage();

    } else {

        // Scale imagereader (if not zoomed)
        if(maxSize.width() != -1)
            reader.setScaledSize(QSize(dispWidth,dispHeight));

        reader.setAutoTransform(metaRotate);

        // Eventually load the image
        reader.read(&img);

        // If an error occured
        if(img.isNull()) {
            QString err = reader.errorString();
            LOG << CURDATE << "LoadImageQt: reader qt - Error: file failed to load: " << err.toStdString() << NL;
            LOG << CURDATE << "LoadImageQt: Filename: " << filename.toStdString() << NL;
            return PErrorImage::load(err);
        }

    }

    return img;

}

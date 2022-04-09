#include "loadimage_libvips.h"
#include <QtDebug>
#include <vips/image.h>

PQLoadImageLibVips::PQLoadImageLibVips() {
    errormsg = "";
}

QImage PQLoadImageLibVips::load(QString filename, QSize, QSize *origSize) {

    // we use the C API as the equivalent C++ API calls led to crash on subsequent call

    // The vips image object
    VipsImage *in;

    // attempt to the load the image
    if(!(in = vips_image_new_from_file(filename.toStdString().c_str(), NULL))) {
        g_object_unref(in);
        errormsg = "vips_image_new_from_file: failed to load image from file";
        LOG << CURDATE << "PQLoadImageLibVips::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // store original size
    *origSize = QSize(vips_image_get_width(in), vips_image_get_height(in));

    // convert VipsImage to QImage
    QImage img((uchar*)vips_image_get_data(in), vips_image_get_width(in), vips_image_get_height(in), VIPS_IMAGE_SIZEOF_LINE(in), QImage::Format_RGB888);
    if(img.isNull()) {
        errormsg = "converting VipsImage to QImage failed";
        LOG << CURDATE << "PQLoadImageLibVips::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    g_object_unref(in);

    return img;

}

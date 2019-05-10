#include "imageproperties.h"

PQImageProperties::PQImageProperties(QObject *parent) : QObject(parent) { }


bool PQImageProperties::isAnimated(QString path) {

    QImageReader reader(path);

    return (reader.supportsAnimation()&&reader.imageCount()>1);


}

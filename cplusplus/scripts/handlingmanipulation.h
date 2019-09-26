#ifndef PQHANDLINGMANIPULATION_H
#define PQHANDLINGMANIPULATION_H

#include <QObject>
#include <QImageReader>
#include "../logger.h"
#ifdef EXIV2
#include <exiv2/exiv2.hpp>
#endif

class PQHandlingManipulation : public QObject {

    Q_OBJECT

public:
    PQHandlingManipulation(QObject *parent = nullptr);

    Q_INVOKABLE QSize getCurrentImageResolution(QString filename);
    Q_INVOKABLE bool canThisBeScaled(QString filename);
    Q_INVOKABLE bool scaleImage(QString sourceFilename, bool scaleInPlace, QSize targetSize, int targetQuality);

};


#endif // PQHANDLINGMANIPULATION_H

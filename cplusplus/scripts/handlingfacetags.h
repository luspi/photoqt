#ifndef PQHANDLINGFACETAGS_H
#define PQHANDLINGFACETAGS_H

#include <QObject>
#include "../logger.h"

#ifdef EXIV2
#include <exiv2/exiv2.hpp>
#endif

class PQHandlingFaceTags : public QObject {

    Q_OBJECT

public:
    explicit PQHandlingFaceTags(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList getFaceTags(QString filename);

};

#endif // PQHANDLINGFACETAGS_H

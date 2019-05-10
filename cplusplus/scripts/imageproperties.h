#ifndef PQIMAGEPROPERTIES_H
#define PQIMAGEPROPERTIES_H

#include <QObject>
#include <QImageReader>
#include <QUrl>

class PQImageProperties : public QObject {

    Q_OBJECT

public:
    explicit PQImageProperties(QObject *parent = nullptr);

    Q_INVOKABLE bool isAnimated(QString path);

};

#endif // PQIMAGEPROPERTIES_H

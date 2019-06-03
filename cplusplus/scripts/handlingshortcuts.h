#ifndef PQHANDLINGSHORTCUTS_H
#define PQHANDLINGSHORTCUTS_H

#include <QObject>
#include <QFile>
#include <QKeySequence>
#include "../logger.h"

class PQHandlingShortcuts : public QObject {

    Q_OBJECT

public:
    PQHandlingShortcuts(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList loadFromFile();
    Q_INVOKABLE QString convertKeyCodeToText(int id);

};


#endif // PQHANDLINGSHORTCUTS_H

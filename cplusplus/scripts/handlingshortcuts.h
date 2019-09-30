#ifndef PQHANDLINGSHORTCUTS_H
#define PQHANDLINGSHORTCUTS_H

#include <QObject>
#include <QFile>
#include <QKeySequence>
#include <QProcess>
#include "../logger.h"

class PQHandlingShortcuts : public QObject {

    Q_OBJECT

public:
    PQHandlingShortcuts(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList loadFromFile();
    Q_INVOKABLE QString convertKeyCodeToText(int id);
    Q_INVOKABLE void executeExternalApp(QString cmd, QString filename);

};


#endif // PQHANDLINGSHORTCUTS_H

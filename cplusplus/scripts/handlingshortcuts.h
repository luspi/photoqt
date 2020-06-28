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
    Q_INVOKABLE QString composeString(Qt::KeyboardModifiers mods, Qt::Key keys);
    Q_INVOKABLE QString composeDisplayString(QString combo);

};


#endif // PQHANDLINGSHORTCUTS_H

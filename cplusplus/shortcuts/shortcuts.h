#ifndef SHORTCUTS_H
#define SHORTCUTS_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QKeySequence>

#include "../configfiles.h"
#include "../logger.h"

class Shortcuts : public QObject {

    Q_OBJECT

public:
    Shortcuts(QObject *parent = 0);
    Q_INVOKABLE QStringList load();
    Q_INVOKABLE QString convertKeycodeToString(int code);

};

#endif

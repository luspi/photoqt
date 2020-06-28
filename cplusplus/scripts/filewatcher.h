#ifndef PQFILEWATCHER_H
#define PQFILEWATCHER_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QFileInfo>
#include <thread>
#include "../configfiles.h"

class PQFileWatcher : public QObject {

    Q_OBJECT

public:
    explicit PQFileWatcher(QObject *parent = nullptr);

private:
    QFileSystemWatcher *userPlacesWatcher;
    QFileSystemWatcher *shortcutsWatcher;

private slots:
    void userPlacesChangedSLOT();
    void shortcutsChangedSLOT();

signals:
    void userPlacesChanged();
    void shortcutsChanged();

};


#endif // PQFILEWATCHER_H

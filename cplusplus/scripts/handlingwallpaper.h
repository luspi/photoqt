#ifndef PQHANDLINGWALLPAPER_H
#define PQHANDLINGWALLPAPER_H

#include <QObject>
#include <QProcess>
#include <QtDBus>
#include <QGuiApplication>
#include "../logger.h"

class PQHandlingWallpaper : public QObject {

    Q_OBJECT

public:
    PQHandlingWallpaper(QObject *parent = nullptr);

    Q_INVOKABLE void setWallpaper(QString category, QString filename, QVariantMap options);
    Q_INVOKABLE int getScreenCount();
    Q_INVOKABLE int getEnlightenmentWorkspaceCount();
    Q_INVOKABLE bool checkXfce();
    Q_INVOKABLE bool checkFeh();
    Q_INVOKABLE bool checkNitrogen();
    Q_INVOKABLE bool checkGSettings();
    Q_INVOKABLE bool checkEnlightenmentRemote();
    Q_INVOKABLE bool checkEnlightenmentMsgbus();

    Q_INVOKABLE QString detectWM();

private:
    bool checkCommand(QString cmd, QString &out);

};


#endif // PQHANDLINGWALLPAPER_H

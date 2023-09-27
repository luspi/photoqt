#ifndef PQCSCRIPTSWALLPAPER_H
#define PQCSCRIPTSWALLPAPER_H

#include <QObject>

class PQCScriptsWallpaper : public QObject {

    Q_OBJECT

public:
    static PQCScriptsWallpaper& get() {
        static PQCScriptsWallpaper instance;
        return instance;
    }
    ~PQCScriptsWallpaper();

    PQCScriptsWallpaper(PQCScriptsWallpaper const&)     = delete;
    void operator=(PQCScriptsWallpaper const&) = delete;

    Q_INVOKABLE int getScreenCount();

    Q_INVOKABLE bool checkGSettings();

    Q_INVOKABLE bool checkFeh();
    Q_INVOKABLE bool checkNitrogen();

    Q_INVOKABLE bool checkXfce();

    Q_INVOKABLE bool checkEnlightenmentMsgbus();
    Q_INVOKABLE bool checkEnlightenmentRemote();
    Q_INVOKABLE QList<int> getEnlightenmentWorkspaceCount();

    Q_INVOKABLE void setWallpaper(QString category, QString filename, QVariantMap options);

private:
    PQCScriptsWallpaper();
    bool checkIfCommandExists(QString cmd, QStringList args, QString &out);

};

#endif

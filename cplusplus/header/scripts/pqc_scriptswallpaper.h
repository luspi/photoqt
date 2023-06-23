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

private:
    PQCScriptsWallpaper();

};

#endif

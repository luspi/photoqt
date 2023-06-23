#ifndef PQCSCRIPTSSHAREIMGUR_H
#define PQCSCRIPTSSHAREIMGUR_H

#include <QObject>

class PQCScriptsShareImgur : public QObject {

    Q_OBJECT

public:
    static PQCScriptsShareImgur& get() {
        static PQCScriptsShareImgur instance;
        return instance;
    }
    ~PQCScriptsShareImgur();

    PQCScriptsShareImgur(PQCScriptsShareImgur const&)     = delete;
    void operator=(PQCScriptsShareImgur const&) = delete;

private:
    PQCScriptsShareImgur();

};

#endif

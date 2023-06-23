#ifndef PQCSCRIPTSCHROMECAST_H
#define PQCSCRIPTSCHROMECAST_H

#include <QObject>

class PQCScriptsChromeCast : public QObject {

    Q_OBJECT

public:
    static PQCScriptsChromeCast& get() {
        static PQCScriptsChromeCast instance;
        return instance;
    }
    ~PQCScriptsChromeCast();

    PQCScriptsChromeCast(PQCScriptsChromeCast const&)     = delete;
    void operator=(PQCScriptsChromeCast const&) = delete;

private:
    PQCScriptsChromeCast();

};

#endif

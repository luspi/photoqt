#ifndef PQCSCRIPTSFILESPATHS_H
#define PQCSCRIPTSFILESPATHS_H

#include <QObject>

class PQCScriptsFilesPaths : public QObject {

    Q_OBJECT

public:
    static PQCScriptsFilesPaths& get() {
        static PQCScriptsFilesPaths instance;
        return instance;
    }
    ~PQCScriptsFilesPaths();

    PQCScriptsFilesPaths(PQCScriptsFilesPaths const&)     = delete;
    void operator=(PQCScriptsFilesPaths const&) = delete;

    Q_INVOKABLE QString cleanPath(QString path);

private:
    PQCScriptsFilesPaths();

};

#endif

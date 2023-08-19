#ifndef PQCSCRIPTSMETADATA_H
#define PQCSCRIPTSMETADATA_H

#include <QObject>

class PQCScriptsMetaData : public QObject {

    Q_OBJECT

public:
    static PQCScriptsMetaData& get() {
        static PQCScriptsMetaData instance;
        return instance;
    }
    ~PQCScriptsMetaData();

    PQCScriptsMetaData(PQCScriptsMetaData const&)     = delete;
    void operator=(PQCScriptsMetaData const&) = delete;

    Q_INVOKABLE QString convertGPSToDecimal(QString gps);

private:
    PQCScriptsMetaData();

};

#endif

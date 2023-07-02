#ifndef PQCSCRIPTSFILEMANAGEMENT_H
#define PQCSCRIPTSFILEMANAGEMENT_H

#include <QObject>

class PQCScriptsFileManagement : public QObject {

    Q_OBJECT

public:
    static PQCScriptsFileManagement& get() {
        static PQCScriptsFileManagement instance;
        return instance;
    }
    ~PQCScriptsFileManagement();

    PQCScriptsFileManagement(PQCScriptsFileManagement const&)     = delete;
    void operator=(PQCScriptsFileManagement const&) = delete;

    Q_INVOKABLE bool copyFileToHere(QString filename, QString targetdir);
    Q_INVOKABLE bool deletePermanent(QString filename);
    Q_INVOKABLE bool moveFileToTrash(QString filename);

private:
    PQCScriptsFileManagement();

};

#endif

#ifndef PQCSCRIPTSOTHER_H
#define PQCSCRIPTSOTHER_H

#include <QObject>

class PQCScriptsOther : public QObject {

    Q_OBJECT

public:
    static PQCScriptsOther& get() {
        static PQCScriptsOther instance;
        return instance;
    }
    ~PQCScriptsOther();

    PQCScriptsOther(PQCScriptsOther const&)     = delete;
    void operator=(PQCScriptsOther const&) = delete;

    Q_INVOKABLE qint64 getTimestamp();
    Q_INVOKABLE bool takeScreenshots();
    Q_INVOKABLE void deleteScreenshots();
    Q_INVOKABLE QString getUniqueId();
    Q_INVOKABLE void printFile(QString filename);
    Q_INVOKABLE int getCurrentScreen(QPoint pos);

private:
    PQCScriptsOther();

};

#endif

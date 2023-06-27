#ifndef PQCSCRIPTSFILEDIALOG_H
#define PQCSCRIPTSFILEDIALOG_H

#include <QObject>

class PQCScriptsFileDialog : public QObject {

    Q_OBJECT

public:
    static PQCScriptsFileDialog& get() {
        static PQCScriptsFileDialog instance;
        return instance;
    }
    ~PQCScriptsFileDialog();

    PQCScriptsFileDialog(PQCScriptsFileDialog const&)     = delete;
    void operator=(PQCScriptsFileDialog const&) = delete;

    Q_INVOKABLE QVariantList getDevices();
    Q_INVOKABLE QVariantList getPlaces();
    QString getUniquePlacesId();
    Q_INVOKABLE void setLastLocation(QString path);

private:
    PQCScriptsFileDialog();

};

#endif

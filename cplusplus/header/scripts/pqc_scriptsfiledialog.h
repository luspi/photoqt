#ifndef PQCSCRIPTSFILEDIALOG_H
#define PQCSCRIPTSFILEDIALOG_H

#include <QObject>
#include <QHash>

class QJSValue;

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
    Q_INVOKABLE QString getLastLocation();
    unsigned int _getNumberOfFilesInFolder(QString path);
    Q_INVOKABLE void getNumberOfFilesInFolder(QString path, const QJSValue &callback);
    Q_INVOKABLE void movePlacesEntry(QString id, bool moveDown, int howmany);
    Q_INVOKABLE void addPlacesEntry(QString path, int pos);
    Q_INVOKABLE void hidePlacesEntry(QString id, bool hidden);
    Q_INVOKABLE void deletePlacesEntry(QString id);

private:
    PQCScriptsFileDialog();
    QHash<QString,int> cacheNumberOfFilesInFolder;

};

#endif

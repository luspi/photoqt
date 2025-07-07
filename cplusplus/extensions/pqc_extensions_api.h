#pragma once

#include <QObject>

class PQExtensionsAPI {

public:
    virtual ~PQExtensionsAPI() = default;

    virtual QString description() = 0;
    virtual QString author() = 0;
    virtual QString contact() = 0;
    virtual int targetAPIVersion() = 0;
    virtual QSize minimumRequiredWindowSize() = 0;
    virtual bool isModal() = 0;

    // initial setup stuff
    virtual QList<QStringList> shortcuts() = 0;
    virtual QList<QStringList> settings() = 0;
    virtual QMap<QString, QList<QStringList> > migrateSettings() = 0;
    virtual QMap<QString, QList<QStringList> > migrateShortcuts() = 0;

    /////////////////////////////////////////

    // reaction methods to do stuff
    virtual QVariant doOnFileLoad(QString filepath, QImage &img) = 0;
    virtual QVariant doOnFileUnLoad(QString filepath) = 0;


};

#define PhotoQt_IID "org.photoqt.PhotoQt"
Q_DECLARE_INTERFACE(PQExtensionsAPI, PhotoQt_IID)

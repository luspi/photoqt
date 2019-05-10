#ifndef PQHANDLINGFILEDIALOG_H
#define PQHANDLINGFILEDIALOG_H

#include <QObject>
#include <QXmlStreamWriter>
#include <QStorageInfo>
#include <QUrl>
#include <QFutureWatcher>
#include <QJSValue>
#include <QJSEngine>
#include <QtConcurrent/QtConcurrent>
#include <QDomDocument>
#include <pugixml.hpp>

#include "../logger.h"
#include "imageformats.h"

class PQHandlingFileDialog : public QObject {

    Q_OBJECT

public:
    explicit PQHandlingFileDialog(QObject *parent = nullptr);
    ~PQHandlingFileDialog();

    Q_INVOKABLE QVariantList getUserPlaces();
    Q_INVOKABLE void moveUserPlacesEntry(QString id, bool moveDown, int howmany);
    Q_INVOKABLE void addNewUserPlacesEntry(QVariantList entry, int pos);
    Q_INVOKABLE QVariantList getStorageInfo();

    unsigned int getNumberOfFilesInFolder(QString path);
    Q_INVOKABLE void getNumberOfFilesInFolder(QString path, const QJSValue &callback);

    QJSValue getFileSize(QString path);
    Q_INVOKABLE void getFileSize(QString path, const QJSValue &callback);

    Q_INVOKABLE QString cleanPath(QString path);

    Q_INVOKABLE QStringList getFoldersIn(QString path);

    Q_INVOKABLE QString getHomeDir();

private:
    PQImageFormats *imageformats;


};

#endif // PQHANDLINGFILEDIALOG_H

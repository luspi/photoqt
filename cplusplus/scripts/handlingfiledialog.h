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
#ifdef PUGIXML
#include <pugixml.hpp>
#endif
#include <QMimeDatabase>
#include <QKeySequence>

#include "../logger.h"
#include "../settings/imageformats.h"
#include "../settings/settings.h"
#include "../variables.h"

#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif

#ifdef LIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

class PQHandlingFileDialog : public QObject {

    Q_OBJECT

public:
    explicit PQHandlingFileDialog(QObject *parent = nullptr);
    ~PQHandlingFileDialog();

    Q_INVOKABLE QVariantList getUserPlaces();
    Q_INVOKABLE void moveUserPlacesEntry(QString id, bool moveDown, int howmany);
    Q_INVOKABLE void hideUserPlacesEntry(QString id, bool hidden);
    Q_INVOKABLE void addNewUserPlacesEntry(QString path, int pos);
    Q_INVOKABLE void removeUserPlacesEntry(QString id);
    QString getNewUniqueId();
    Q_INVOKABLE QVariantList getStorageInfo();

    unsigned int getNumberOfFilesInFolder(QString path);
    Q_INVOKABLE void getNumberOfFilesInFolder(QString path, const QJSValue &callback);

    Q_INVOKABLE QString cleanPath(QString path);
    Q_INVOKABLE QString getSuffix(QString path, bool lowerCase = true);
    Q_INVOKABLE QString getBaseName(QString path, bool lowerCase = true);

    Q_INVOKABLE QStringList getFoldersIn(QString path);

    Q_INVOKABLE QString getHomeDir();
    Q_INVOKABLE QString getLastLocation();
    Q_INVOKABLE void setLastLocation(QString path);

    Q_INVOKABLE QString convertBytesToHumanReadable(qint64 bytes);
    Q_INVOKABLE QString getFileType(QString path);

    Q_INVOKABLE int convertCharacterToKeyCode(QString key);

    Q_INVOKABLE QStringList listPDFPages(QString path);
    Q_INVOKABLE QStringList listArchiveContent(QString path);

};

#endif // PQHANDLINGFILEDIALOG_H

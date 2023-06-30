#include <scripts/pqc_scriptsfilespaths.h>
#include <QtLogging>
#include <QtDebug>
#include <QDir>
#include <QMimeDatabase>
#include <QUrl>
#include <QStorageInfo>
#include <QCollator>

PQCScriptsFilesPaths::PQCScriptsFilesPaths() {

}

PQCScriptsFilesPaths::~PQCScriptsFilesPaths() {

}

QString PQCScriptsFilesPaths::cleanPath(QString path) {

    qDebug() << "args: path =" << path;

// older versions of PhotoQt used the incorrect form of only two slashes after file:
// this was corrected everywhere starting with v3.0, but we still need to check for both

#ifdef Q_OS_WIN
    if(path.startsWith("file:///"))
        path = path.remove(0, 8);
    else if(path.startsWith("file://"))
        path = path.remove(0, 7);
#else
    if(path.startsWith("file:////"))
        path = path.remove(0, 8);
    else if(path.startsWith("file:///"))
        path = path.remove(0, 7);
#endif
    else if(path.startsWith("image://full/"))
        path = path.remove(0, 13);
    else if(path.startsWith("image://thumb/"))
        path = path.remove(0, 14);

#ifdef Q_OS_WIN
    path = QDir::cleanPath(path.replace("//", "|::::::::|"));
    return path.replace("|::::::::|", "//");
#else
    return QDir::cleanPath(path);
#endif

}

QString PQCScriptsFilesPaths::pathWithNativeSeparators(QString path) {

#ifdef Q_OS_WIN
    while(path.startsWith("/"))
        path = path.mid(1);
#endif

    return QDir::toNativeSeparators(path);

}

QString PQCScriptsFilesPaths::getSuffix(QString path, bool lowerCase) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: lowerCase =" << lowerCase;

    if(lowerCase)
        return QFileInfo(path).suffix().toLower();
    return QFileInfo(path).suffix();

}

QString PQCScriptsFilesPaths::getFilename(QString fullpath) {

    qDebug() << "args: path =" << fullpath;

    return QFileInfo(fullpath).fileName();

}

QDateTime PQCScriptsFilesPaths::getFileModified(QString path) {

    qDebug() << "args: path =" << path;

    return QFileInfo(path).lastModified();

}

QString PQCScriptsFilesPaths::getFileType(QString path) {

    qDebug() << "args: path =" << path;

    QMimeDatabase db;
    return db.mimeTypeForFile(path).name();

}

QString PQCScriptsFilesPaths::getFileSizeHumanReadable(QString path) {

    const qint64 bytes = QFileInfo(path).size();

    if(bytes <= 1024)
        return QString("%1 B").arg(bytes);
    else if(bytes <= 1024*1024)
        return QString("%1 KB").arg(qRound(10.0*(bytes/1024.0))/10.0);

    return QString("%1 MB").arg(qRound(100.0*(bytes/(1024.0*1024.0)))/100.0);

}

QString PQCScriptsFilesPaths::toPercentEncoding(QString str) {
    return QUrl::toPercentEncoding(str);
}

QString PQCScriptsFilesPaths::goUpOneLevel(QString path) {
    QDir dir(path);
    dir.cdUp();
    return dir.absolutePath();
}

QString PQCScriptsFilesPaths::getWindowsDriveLetter(QString path) {

    QStorageInfo info(path);
    return info.rootPath();

}

QStringList PQCScriptsFilesPaths::getFoldersIn(QString path) {

    QDir dir(path);

    dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    QStringList ret = dir.entryList();

    QCollator collator;
    collator.setNumericMode(true);
    std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });

    return ret;

}

QString PQCScriptsFilesPaths::getHomeDir() {
    return QDir::homePath();
}

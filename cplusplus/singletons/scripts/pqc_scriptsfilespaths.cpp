#include <QtLogging>
#include <QtDebug>
#include <QDir>
#include <scripts/pqc_scriptsfilespaths.h>

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

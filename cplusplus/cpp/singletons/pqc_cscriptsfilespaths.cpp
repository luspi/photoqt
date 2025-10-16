#include <cpp/pqc_cscriptsfilespaths.h>
#include <cpp/pqc_csettings.h>
#include <QStorageInfo>

PQCCScriptsFilesPaths::PQCCScriptsFilesPaths() {

    m_networkSharesTimer.setInterval(1000*60*5);
    connect(&m_networkSharesTimer, &QTimer::timeout, this, &PQCCScriptsFilesPaths::detectNetworkShares);
    detectNetworkShares();

}

QString PQCCScriptsFilesPaths::cleanPath(QString path) {

#ifdef Q_OS_WIN
    return cleanPath_windows(path);
#else
    if(path.startsWith("file:////"))
        path = path.remove(0, 8);
    else if(path.startsWith("file:///"))
        path = path.remove(0, 7);
    else if(path.startsWith("file://"))
        path = path.remove(0, 6);
    else if(path.startsWith("file:/"))
        path = path.remove(0, 5);
    else if(path.startsWith("image://full/"))
        path = path.remove(0, 13);
    else if(path.startsWith("image://thumb/"))
        path = path.remove(0, 14);

    QFileInfo info(path);
    if(info.isSymLink() && info.exists())
        path = info.symLinkTarget();

    return QDir::cleanPath(path);
#endif

}

QString PQCCScriptsFilesPaths::cleanPath_windows(QString path) {

    if(path.startsWith("file:///"))
        path = path.remove(0, 8);
    else if(path.startsWith("file://"))
        path = path.remove(0, 7);
    else if(path.startsWith("file:/"))
        path = path.remove(0, 6);
    else if(path.startsWith("file:"))
        path = path.remove(0, 5);
    else if(path.startsWith("image://full/"))
        path = path.remove(0, 13);
    else if(path.startsWith("image://thumb/"))
        path = path.remove(0, 14);

    QFileInfo info(path);
    if(info.isSymLink() && info.exists())
        path = info.symLinkTarget();

    bool addslash = false;
    if(path.startsWith("//"))
        addslash = true;

    path = QDir::cleanPath(path);
    if(addslash)
        path = "/"+path;

    return path;

}

void PQCCScriptsFilesPaths::detectNetworkShares() {
    m_networkshares.clear();
    const QList<QStorageInfo> info = QStorageInfo::mountedVolumes();
    for(const QStorageInfo &s : info) {
        if(s.isValid() && (s.fileSystemType() == "cifs" || s.fileSystemType() == "samba" || s.fileSystemType() == "fuse"))
            m_networkshares.push_back(s.rootPath());
#ifdef Q_OS_WIN
        // on windows network shares often have a fileSystemType of FAT or NTFS or therelike
        // This check excludes known physical devices assuming everything else to be remote
        if (!QString::fromLatin1(s.device()).startsWith(QLatin1String("\\\\?\\Volume")))
            m_networkshares.push_back(s.rootPath());
#endif
    }
#ifdef Q_OS_UNIX
    // sshfs mounts are not listed as part of mountedVolumes but we might be able to find them in mtab
    QFile f("/etc/mtab");
    if(f.exists() && f.open(QIODevice::ReadOnly)) {
        QTextStream in(&f);
        QString line;
        while(in.readLineInto(&line)) {
            QStringList parts = line.split(" ");
            if(parts[2] == "fuse.sshfs")
                m_networkshares.push_back(parts[1]);
        }
    }
#endif
    m_networkSharesTimer.start();
}

bool PQCCScriptsFilesPaths::isExcludeDirFromCaching(QString filename) {

    qDebug() << "args: filename =" << filename;

    if(PQCCSettings::get().getThumbnailsExcludeDropBox() != "") {
        if(filename.indexOf(PQCCSettings::get().getThumbnailsExcludeDropBox())== 0)
            return true;
    }

    if(PQCCSettings::get().getThumbnailsExcludeNextcloud() != "") {
        if(filename.indexOf(PQCCSettings::get().getThumbnailsExcludeNextcloud())== 0)
            return true;
    }

    if(PQCCSettings::get().getThumbnailsExcludeOwnCloud() != "") {
        if(filename.indexOf(PQCCSettings::get().getThumbnailsExcludeOwnCloud())== 0)
            return true;
    }

    const QStringList str = PQCCSettings::get().getThumbnailsExcludeFolders();
    for(const QString &dir: str) {
        if(dir != "" && filename.indexOf(dir) == 0)
            return true;
    }

    if(PQCCSettings::get().getThumbnailsExcludeNetworkShares()) {
        return isOnNetwork(filename);
    }

    return false;

}

bool PQCCScriptsFilesPaths::isOnNetwork(QString filename) {

    qDebug() << "args: filename =" << filename;

    for(const QString &dir: std::as_const(m_networkshares)) {
        if(dir != "" && filename.indexOf(dir) == 0)
            return true;
    }
    return false;
}

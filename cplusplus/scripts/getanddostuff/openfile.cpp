#include "openfile.h"

GetAndDoStuffOpenFile::GetAndDoStuffOpenFile(QObject *parent) : QObject(parent) {

    formats = new FileFormats;

    watcher = new QFileSystemWatcher;
    userPlacesFileDoesntExist = !QFile(QString(ConfigFiles::DATA_DIR()) + "/../user-places.xbel").exists();
    recheckFile();
    connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(updateUserPlaces()));
}
GetAndDoStuffOpenFile::~GetAndDoStuffOpenFile() {
    delete watcher;
}

int GetAndDoStuffOpenFile::getNumberFilesInFolder(QString path, int selectionFileTypes) {

    QDir dir(path);
    if(selectionFileTypes == 0)
        dir.setNameFilters(formats->formats_qt + formats->formats_gm + formats->formats_gm_ghostscript + formats->formats_extras + formats->formats_untested + formats->formats_raw);
    else if(selectionFileTypes == 1)
        dir.setNameFilters(formats->formats_qt);
    else if(selectionFileTypes == 2)
        dir.setNameFilters(formats->formats_gm + formats->formats_gm_ghostscript + formats->formats_untested);
    else if(selectionFileTypes == 3)
        dir.setNameFilters(formats->formats_raw);
    else if(selectionFileTypes == 4)
        dir.setNameFilters(QStringList() << "*.*");
    dir.setFilter(QDir::Files);

    return dir.entryList().length();

}

QVariantList GetAndDoStuffOpenFile::getUserPlaces() {

    QVariantList sub_places;
    QVariantList sub_devices;

    QFile file(QString(ConfigFiles::DATA_DIR()) + "/../user-places.xbel");
    if(file.exists() && !file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "GetAndDoStuffOpenFile: Can't open ~/.local/share/user-places.xbel file" << NL;
        return QVariantList();
    } else if(file.exists()) {

        QDomDocument doc;
        doc.setContent(&file);

        QDomNodeList bookmarks = doc.elementsByTagName("bookmark");
        for(int i = 0; i < bookmarks.size(); i++) {
            QDomNode n = bookmarks.item(i);

            QString icon = "";
            QString location = n.attributes().namedItem("href").nodeValue();
            QString title = n.firstChildElement("title").text();

            QDomNodeList info = n.firstChildElement("info").childNodes();
            for(int j = 0; j < info.size(); ++j) {
                QDomNode ele_icon = info.item(j).firstChildElement("bookmark:icon");
                if(ele_icon.isNull())
                    continue;
                icon = ele_icon.attributes().namedItem("name").nodeValue();
            }

            if(location.startsWith("file:///"))
                location = location.remove(0,7);
            else if(location.startsWith("file://"))
                location = location.remove(0,6);

            QVariantList ele = QVariantList() << "user" << title << location << icon;

            if(QDir(location).exists())
                sub_places.append(ele);

        }

        file.close();

    }

#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))

    for(auto storage : QStorageInfo::mountedVolumes()) {
        if(storage.isValid()) {

            qint64 size = storage.bytesTotal()/1024/1024/102.4;

            if(size > 0) {

                QVariantList ele = QVariantList() << "volumes"
                                                  << QString("%1 GB " + tr("Volume") + " (%2)")
                                                     .arg(size/10.0)
                                                     .arg(QString(storage.fileSystemType()))
                                                  << storage.rootPath()
                                                  << "drive-harddisk";
                sub_devices.append(ele);

            }
        }
    }

#endif


    return sub_places+sub_devices;

}

QVariantList GetAndDoStuffOpenFile::getFilesAndFoldersIn(QString path) {

    if(path.startsWith("file:/"))
        path = path.remove(0,6);

    QDir dir(path);
    dir.setNameFilters(formats->formats_qt + formats->formats_gm + formats->formats_gm_ghostscript + formats->formats_extras + formats->formats_untested + formats->formats_raw);
    dir.setFilter(QDir::AllDirs|QDir::Files|QDir::NoDotAndDotDot);
    dir.setSorting(QDir::DirsFirst|QDir::IgnoreCase);

    QStringList list = dir.entryList();
    QVariantList ret;
    foreach(QString l, list)
        ret.append(l);

    return ret;

}

QVariantList GetAndDoStuffOpenFile::getFoldersIn(QString path, bool getDotDot) {

    if(path.startsWith("file:/"))
        path = path.remove(0,6);

    QDir dir(path);
    if(getDotDot)
        dir.setFilter(QDir::AllDirs|QDir::NoDot);
    else
        dir.setFilter(QDir::AllDirs|QDir::NoDotAndDotDot);
    dir.setSorting(QDir::IgnoreCase);

    QStringList list = dir.entryList();
    QVariantList ret;
    foreach(QString l, list)
        ret.append(l);

    return ret;

}

QVariantList GetAndDoStuffOpenFile::getFilesIn(QString path) {

    if(path.startsWith("file:/"))
        path = path.remove(0,6);

    QDir dir(path);
    dir.setNameFilters(formats->formats_qt + formats->formats_gm + formats->formats_gm_ghostscript + formats->formats_extras + formats->formats_untested + formats->formats_raw);
    dir.setFilter(QDir::Files);
    dir.setSorting(QDir::IgnoreCase);

    QStringList list = dir.entryList();
    QVariantList ret;
    foreach(QString l, list)
        ret.append(l);

    return ret;

}

QVariantList GetAndDoStuffOpenFile::getFilesWithSizeIn(QString path, int selectionFileTypes) {

    if(path.startsWith("file:/"))
        path = path.remove(0,6);

    QDir dir(path);
    if(selectionFileTypes == 0)
        dir.setNameFilters(formats->formats_qt + formats->formats_gm + formats->formats_gm_ghostscript + formats->formats_extras + formats->formats_untested + formats->formats_raw);
    else if(selectionFileTypes == 1)
        dir.setNameFilters(formats->formats_qt);
    else if(selectionFileTypes == 2)
        dir.setNameFilters(formats->formats_gm + formats->formats_gm_ghostscript + formats->formats_untested);
    else if(selectionFileTypes == 3)
        dir.setNameFilters(formats->formats_raw);
    else if(selectionFileTypes == 4)
        dir.setNameFilters(QStringList() << "*.*");

    dir.setFilter(QDir::Files);
    dir.setSorting(QDir::IgnoreCase);

    QFileInfoList list = dir.entryInfoList();
    QVariantList ret;
    foreach(QFileInfo l, list) {
        int s = l.size();
        QString size = "";
        if(s <= 1024)
            size = QString::number(s) + " B";
        else if(s <= 1024*1024)
            size = QString::number(qRound(double(s)/1024.0)) + " KB";
        else
            size = QString::number(qRound(100*double(s)/(1024*1024))/100.0) + " MB";
        ret.append(QVariantList() << l.fileName() << size);
    }

    return ret;

}

bool GetAndDoStuffOpenFile::isFolder(QString path) {
    if(path.startsWith("file:/"))
        path = path.remove(0,6);
    QFileInfo info(path);
    return !info.isFile();
}

QString GetAndDoStuffOpenFile::removePrefixFromDirectoryOrFile(QString path) {

    if(path.startsWith("file:/"))
        return path.remove(0,6);

    return path;

}

void GetAndDoStuffOpenFile::addToUserPlaces(QString path) {

    QFile file(QString(ConfigFiles::DATA_DIR()) + "/../user-places.xbel");
    if(file.exists() && !file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        LOG << CURDATE << "GetAndDoStuffOpenFile: Can't open ~/.local/share/user-places.xbel file" << NL;
        return;
    }

    QDomDocument doc;
    if(file.exists())
        doc.setContent(&file);
    else
        doc.setContent(QString("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<xbel xmlns:mime=\"http://www.freedesktop.org/standards/shared-mime-info\" xmlns:kdepriv=\"http://www.kde.org/kdepriv\" xmlns:bookmark=\"http://www.freedesktop.org/standards/desktop-bookmarks\">\n</xbel>\n"));

    QDomElement root = doc.documentElement();

    QDomElement bookmark = doc.createElement("bookmark");
    bookmark.setAttribute("href","file://" + path);

    QDomElement title = doc.createElement("title");
    QDomText titleText = doc.createTextNode(QFileInfo(path).fileName());
    title.appendChild(titleText);
    bookmark.appendChild(title);

    QDomElement info = doc.createElement("info");

    QDomElement metadata = doc.createElement("metadata");
    metadata.setAttribute("owner","http://freedesktop.org");

    QDomElement icon = doc.createElement("bookmark:icon");
    icon.setAttribute("name","inode-directory");

    metadata.appendChild(icon);
    info.appendChild(metadata);
    bookmark.appendChild(info);

    root.appendChild(bookmark);

    file.close();

    if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        LOG << CURDATE << "GetAndDoStuffOpenFile: Can't open ~/.local/share/user-places.xbel file" << NL;
        return;
    }

    QTextStream out(&file);
    root.save(out,2);

    file.close();

}

void GetAndDoStuffOpenFile::saveUserPlaces(QVariantList enabled) {

    QDomDocument doc;
    doc.setContent(QString("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<xbel xmlns:mime=\"http://www.freedesktop.org/standards/shared-mime-info\" xmlns:kdepriv=\"http://www.kde.org/kdepriv\" xmlns:bookmark=\"http://www.freedesktop.org/standards/desktop-bookmarks\">\n</xbel>\n"));

    QDomElement root = doc.documentElement();

    foreach(QVariant l, enabled) {
        QVariantList cur = l.toList();
        if(cur.length() == 4) {

            QDomElement bookmark = doc.createElement("bookmark");
            bookmark.setAttribute("href","file://" + cur.at(2).toString());

            QDomElement title = doc.createElement("title");
            QDomText titleText = doc.createTextNode(QFileInfo(cur.at(1).toString()).fileName());
            title.appendChild(titleText);
            bookmark.appendChild(title);

            QDomElement info = doc.createElement("info");

            QDomElement metadata = doc.createElement("metadata");
            metadata.setAttribute("owner","http://freedesktop.org");

            QDomElement icon = doc.createElement("bookmark:icon");
            icon.setAttribute("name",cur.at(3).toString());

            metadata.appendChild(icon);
            info.appendChild(metadata);
            bookmark.appendChild(info);

            root.appendChild(bookmark);

        }
    }

    QFile file(QString(ConfigFiles::DATA_DIR()) + "/../user-places.xbel");
    if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        LOG << CURDATE << "GetAndDoStuffOpenFile: Can't open ~/.local/share/user-places.xbel file" << NL;
        return;
    }

    QTextStream out(&file);
    root.save(out,2);

    file.close();

}

void GetAndDoStuffOpenFile::setOpenFileLastLocation(QString path) {

    QFile file(ConfigFiles::OPENFILE_LAST_LOCATION());
    if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream out(&file);
        out << path;
        file.close();
    } else
        LOG << CURDATE << " GetAndDoStuffOpenFile::setLastLocation(): Unable to open file for writing: " << file.errorString().toStdString() << NL;

}

QString GetAndDoStuffOpenFile::getOpenFileLastLocation() {

    QString ret = QDir::homePath();
    QFile file(ConfigFiles::OPENFILE_LAST_LOCATION());
    if(file.exists() && file.open(QIODevice::ReadOnly)) {
        QTextStream in(&file);
        ret = in.readAll().trimmed();
        file.close();
    }
    return ret;

}

void GetAndDoStuffOpenFile::saveLastOpenedImage(QString path) {

    QFile file(ConfigFiles::LASTOPENEDIMAGE_FILE());
    if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream out(&file);
        out << path;
        file.close();
    } else
        LOG << CURDATE << "ERROR: Unable to store path of last opened image. Error: " << file.errorString().trimmed().toStdString() << NL;

}

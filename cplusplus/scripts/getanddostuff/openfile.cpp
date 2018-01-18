#include "openfile.h"

GetAndDoStuffOpenFile::GetAndDoStuffOpenFile(QObject *parent) : QObject(parent) {
    formats = new FileFormats;
    load = new LoadDir(false);
}
GetAndDoStuffOpenFile::~GetAndDoStuffOpenFile() {
    delete formats;
    delete load;
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

    QFile file(QString(ConfigFiles::GENERIC_DATA_DIR()) + "/user-places.xbel");

    if(!file.exists()) {
        LOG << CURDATE << "GetAndDoStuffOpenFile: File " << ConfigFiles::GENERIC_DATA_DIR().toStdString() << "/user-places.xbel does not exist" << NL;
        return QVariantList();
    } else if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "GetAndDoStuffOpenFile: Can't open " + ConfigFiles::GENERIC_DATA_DIR().toStdString() + "/user-places.xbel file" << NL;
        return QVariantList();
    }

    QVariantList ret;

    QTextStream in(&file);
    QString all = in.readAll();
    QStringList entries = all.split("<bookmark href=\"");
    for(int i = 1; i < entries.length(); ++i) {

        QString entry = entries.at(i);

        QString path = "", name = "", icon = "", id = "", isSystemItem = "", isHidden = "false";

        path = entry.split("\">").at(0);
        if(path.contains("file://"))
            path.remove(0,7);

        if(path == "trash:/")
            path = ConfigFiles::GENERIC_DATA_DIR() + "/Trash/files";

        if(entry.contains("<title>") && entry.contains("</title>"))
            name = entry.split("<title>").at(1).split("</title>").at(0);
        else
            name = path;

        if(entry.contains("<bookmark:icon name=\""))
            icon = entry.split("<bookmark:icon name=\"").at(1).split("\"/>").at(0);
        else
            icon = "inode-directory";

        if(entry.contains("<ID>"))
            id = entry.split("<ID>").at(1).split("</ID>").at(0);

        if(entry.contains("<IsHidden>"))
            isHidden = entry.split("<IsHidden>").at(1).split("</IsHidden>").at(0);

        if(entry.contains("<isSystemItem>"))
            isSystemItem = entry.split("<isSystemItem>").at(1).split("</isSystemItem>").at(0);

        QVariantList entrylist;
        entrylist << name << path << icon << id << isHidden << isSystemItem;
        ret.append(entrylist);

    }

    return ret;

}

QVariantList GetAndDoStuffOpenFile::getStorageInfo() {

    QVariantList ret;

    for(QStorageInfo s : QStorageInfo::mountedVolumes()) {
        if(s.isValid()) {

            QVariantList vol;
            vol << s.name()
                << s.bytesTotal()
                << s.fileSystemType()
                << s.rootPath();

            ret.append(vol);

        }
    }

    return ret;

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
    for(QString l : list)
        ret.append(l);

    return ret;

}

QVariantList GetAndDoStuffOpenFile::getFoldersIn(QString path, bool getDotDot, bool showHidden) {

    if(path.startsWith("file:/"))
        path = path.remove(0,6);

    QDir dir(path);
    if(showHidden)
        dir.setFilter(QDir::AllDirs|(getDotDot ? QDir::NoDot : QDir::NoDotAndDotDot)|QDir::Hidden);
    else
        dir.setFilter(QDir::AllDirs|(getDotDot ? QDir::NoDot : QDir::NoDotAndDotDot));
    dir.setSorting(QDir::IgnoreCase);

    QStringList list = dir.entryList();
    QVariantList ret;
    for(QString l : list)
        ret.append(l);

    return ret;

}

QVariantList GetAndDoStuffOpenFile::getFilesIn(QString file, QString filter, QString sortby, bool sortbyAscending) {

    if(file.startsWith("file:/"))
        file = file.remove(0,6);

    QDir dir(QFileInfo(file).absoluteDir());
    dir.setNameFilters(formats->formats_qt + formats->formats_gm + formats->formats_gm_ghostscript + formats->formats_extras + formats->formats_untested + formats->formats_raw);
    dir.setFilter(QDir::Files);
    dir.setSorting(QDir::IgnoreCase);

    QFileInfoList list = dir.entryInfoList();
    if(!list.contains(QFileInfo(file)))
        list.append(QFileInfo(file));

    load->sortList(&list, sortby, sortbyAscending);

    QVariantList ret;
    if(filter.startsWith(".")) {
        for(QFileInfo l : list) {
            if(l.fileName().endsWith(filter))
                ret.append(l.fileName());
        }
    } else if(filter != "") {
        for(QFileInfo l : list) {
            if(l.fileName().contains(filter))
                ret.append(l.fileName());
        }
    } else {
        for(QFileInfo l : list)
            ret.append(l.fileName());
    }


    return ret;

}

QVariantList GetAndDoStuffOpenFile::getFilesWithSizeIn(QString path, int selectionFileTypes, bool showHidden, QString sortby, bool sortbyAscending) {

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

    if(showHidden)
        dir.setFilter(QDir::Files|QDir::Hidden);
    else
        dir.setFilter(QDir::Files);
    dir.setSorting(QDir::IgnoreCase);

    QFileInfoList list = dir.entryInfoList();

    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);

    load->sortList(&list, sortby, sortbyAscending);

    QVariantList ret;
    for(QFileInfo l : list) {
        ret.append(l.fileName());
        qint64 s = l.size();
        if(s <= 1024)
            ret.append(QString::number(s) + " B");
        else if(s <= 1024*1024)
            ret.append(QString::number(qRound(10.0*(s/1024.0))/10.0) + " KB");
        else
            ret.append(QString::number(qRound(100.0*(s/(1024.0*1024.0)))/100.0) + " MB");
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

void GetAndDoStuffOpenFile::saveUserPlaces(QVariantList enabled) {

    QFile file(QString(ConfigFiles::GENERIC_DATA_DIR()) + "/user-places.xbel");
    if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        LOG << CURDATE << "GetAndDoStuffOpenFile: Can't open " << ConfigFiles::GENERIC_DATA_DIR().toStdString() << "/user-places.xbel file" << NL;
        return;
    }

    QXmlStreamWriter s(&file);
    s.setAutoFormatting(true);
    s.setAutoFormattingIndent(1);
    s.writeStartDocument();

    s.writeStartElement("xbel");

    s.writeAttribute("xmlns:kdepriv", "http://www.kde.org/kdepriv");
    s.writeAttribute("xmlns:bookmark", "https://freedesktop.org/wiki/Specifications/desktop-bookmark-spec");
    s.writeAttribute("xmlns:mime", "http://www.freedesktop.org/standards/shared-mime-info");

    for(QVariant l : enabled) {

        QVariantList cur = l.toList();

        if(cur.length() != 6) continue;

        // START bookmark
        s.writeStartElement("bookmark");

        s.writeAttribute("href", cur.at(1).toString());

        // title
        s.writeTextElement("title", cur.at(0).toString());

        // START info
        s.writeStartElement("info");


        // START metadata
        s.writeStartElement("metadata");

        s.writeAttribute("owner", "http://freedesktop.org");

        // START bookmark:icon
        s.writeStartElement("bookmark:icon");

        s.writeAttribute("name", cur.at(2).toString());

        // END bookmark:icon
        s.writeEndElement();

        // END metadata
        s.writeEndElement();


        // START metadata
        s.writeStartElement("metadata");

        s.writeAttribute("owner", "http://www.kde.org");

        if(cur.at(3).toString() != "")
            s.writeTextElement("ID", cur.at(3).toString());
        s.writeTextElement("IsHidden", cur.at(4).toString());
        if(cur.at(5).toString() != "")
            s.writeTextElement("isSystemItem", cur.at(5).toString());

        // END metadata
        s.writeEndElement();


        // END info
        s.writeEndElement();

        // END bookmark
        s.writeEndElement();

    }

    // xbel
    s.writeEndElement();

    s.writeEndDocument();

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

QString GetAndDoStuffOpenFile::getDirectoryDirName(QString path) {

    return QDir(path).dirName();

}

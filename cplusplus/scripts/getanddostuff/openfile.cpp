#include "openfile.h"
#include "../sortlist.h"

GetAndDoStuffOpenFile::GetAndDoStuffOpenFile(QObject *parent) : QObject(parent) {
    formats = new FileFormats;
}
GetAndDoStuffOpenFile::~GetAndDoStuffOpenFile() {
    delete formats;
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

    // This list will contain all return values
    QVariantList ret;

    // We use the stream reader to parse the file
    QXmlStreamReader xmlReader(&file);

    // set up some variables for the data. They are filled progressively in the loop below
    QString path = "";
    QString name = "";
    QString icon = "";
    QString id = "";
    QString isSystemItem = "";
    QString isHidden = "false";

    // these keep track of which tag we have entered
    bool enteredTitle = false;
    bool enteredID = false;
    bool enteredIsHidden = false;
    bool enteredIsSystemItem = false;

    // loop through xml file
    while (!xmlReader.atEnd()) {

        // next item
        xmlReader.readNext();

        // A bookmark end tag finishes a full entry
        if(xmlReader.tokenType() == QXmlStreamReader::EndElement && xmlReader.name() == "bookmark") {

            // Compose all items into a list
            QVariantList entrylist;
            entrylist << name << path << icon << id << isHidden << isSystemItem;
            ret.append(entrylist);

            // and reset the variables
            path = "";
            name = "";
            icon = "";
            id = "";
            isHidden = "false";
            isSystemItem = "";

            // and make sure that these are all reset (should be already done)
            enteredTitle = false;
            enteredID = false;
            enteredIsHidden = false;
            enteredIsSystemItem = false;

        }

        // BOOKMARK

        if(xmlReader.tokenType() == QXmlStreamReader::StartElement && xmlReader.name() == "bookmark") {

            path = xmlReader.attributes().value("href").toString();

            if(path.contains("file://"))
                path.remove(0,7);

            if(path == "trash:/")
                path = ConfigFiles::GENERIC_DATA_DIR() + "/Trash/files";

        }

        // TITLE

        if(xmlReader.tokenType() == QXmlStreamReader::StartElement && xmlReader.name() == "title")
            enteredTitle = true;

        if(xmlReader.tokenType() == QXmlStreamReader::Characters && enteredTitle) {
            name = xmlReader.text().toString();
            enteredTitle = false;
        }

        // ICON

        if(xmlReader.tokenType() == QXmlStreamReader::StartElement && xmlReader.name() == "icon")
            icon = xmlReader.attributes().value("name").toString();

        // ID

        if(xmlReader.tokenType() == QXmlStreamReader::StartElement && xmlReader.name() == "ID")
            enteredID = true;

        if(xmlReader.tokenType() == QXmlStreamReader::Characters && enteredID) {
            id = xmlReader.text().toString();
            enteredID = false;
        }

        // ISHIDDEN

        if(xmlReader.tokenType() == QXmlStreamReader::StartElement && xmlReader.name() == "IsHidden")
            enteredIsHidden = true;

        if(xmlReader.tokenType() == QXmlStreamReader::Characters && enteredIsHidden) {
            isHidden = xmlReader.text().toString();
            enteredIsHidden = false;
        }

        // ISSYSTEMITEM

        if(xmlReader.tokenType() == QXmlStreamReader::StartElement && xmlReader.name() == "isSystemItem")
            enteredIsSystemItem = true;

        if(xmlReader.tokenType() == QXmlStreamReader::Characters && enteredIsSystemItem) {
            isSystemItem = xmlReader.text().toString();
            enteredIsSystemItem = false;
        }

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

    Sort::sortList(&list, sortby, sortbyAscending);

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

    Sort::sortList(&list, sortby, sortbyAscending);

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

    QString ret = QDir::currentPath();
    QFile file(ConfigFiles::OPENFILE_LAST_LOCATION());
    if(file.exists() && file.open(QIODevice::ReadOnly)) {
        QTextStream in(&file);
        ret = in.readAll().trimmed();
        file.close();
    }
    return ret;

}

QString GetAndDoStuffOpenFile::getCurrentWorkingDirectory() {
    return QDir::currentPath();
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

/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include "handlingfiledialog.h"

PQHandlingFileDialog::PQHandlingFileDialog(QObject *parent) : QObject(parent) {}

PQHandlingFileDialog::~PQHandlingFileDialog() {}

QString PQHandlingFileDialog::getNewUniqueId() {

    DBG << CURDATE << "PQHandlingFileDialog::getNewUniqueId()" << NL;

#ifdef PUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        LOG << CURDATE << "ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
        return "";
    }

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    QStringList allIds;
    for(pugi::xpath_node node : bookmarks) {
        pugi::xml_node cur = node.node();
        QString curId = cur.select_node("info/metadata/ID").node().child_value();
        QString curPath = cur.attribute("href").value();
        if(curPath.startsWith("file:/") || curPath == "trash:/")
            allIds.append(curId);
    }

    QString newid_base = QString::number(QDateTime::currentSecsSinceEpoch());

    int counter = 0;
    while(allIds.contains(QString("%1/%2").arg(newid_base).arg(counter)))
        ++counter;

    return QString("%1/%2").arg(newid_base).arg(counter);

#endif

    return "";

}

QVariantList PQHandlingFileDialog::getUserPlaces() {

    DBG << CURDATE << "PQHandlingFileDialog::getUserPlaces()" << NL;

    QVariantList ret;

#ifdef PUGIXML

    // if file does not exist yet then we create a sceleton file
    if(!QFile(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel")).exists()) {
        QString cont = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        cont += "<xbel xmlns:kdepriv=\"http://www.kde.org/kdepriv\" xmlns:mime=\"http://www.freedesktop.org/standards/shared-mime-info\" xmlns:bookmark=\"http://www.freedesktop.org/standards/desktop-bookmarks\">\n";
        cont += "</xbel>";
        QFile file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel"));
        if(file.open(QIODevice::WriteOnly)) {
            QTextStream out(&file);
            out << cont;
            file.close();
        }
    }

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        LOG << CURDATE << "PQHandlingFileDialog::getUserPlaces(): ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
        return ret;
    }

    bool docUpdated = false;

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    for(pugi::xpath_node node: bookmarks) {

        QVariantList entry;

        pugi::xml_node bm = node.node();

        QString path = bm.attribute("href").value();

        if(path.startsWith("file:///"))
            path = path.remove(0,7);
        else if(path.startsWith("file://"))
            path = path.remove(0,6);
        else if(path == "trash:/")
            path = ConfigFiles::GENERIC_DATA_DIR() + "/Trash/files";
        else
            continue;

        // name
        entry << bm.select_node("title").node().child_value();

        // path
        entry << path;

        // icon
        entry << bm.select_node("info/metadata/bookmark:icon").node().attribute("name").value();

        // id
        QString id = bm.select_node("info/metadata/ID").node().child_value();
        // id doesn't exist (i.e., kde metadata part missing)
        if(id.isEmpty()) {

            id = getNewUniqueId();

            pugi::xml_node info = bm.select_node("info").node();

            // <metadata> kde.org
            pugi::xml_node metadata = info.append_child("metadata");
            metadata.append_attribute("owner");
            metadata.attribute("owner").set_value("http://www.kde.org");

            // <ID>
            pugi::xml_node ID = metadata.append_child("ID");
            ID.text().set(id.toStdString().c_str());

            // <IsHidden>
            pugi::xml_node IsHidden = metadata.append_child("IsHidden");
            IsHidden.text().set("false");

            // <isSystemItem>
            pugi::xml_node isSystemItem = metadata.append_child("isSystemItem");
            isSystemItem.text().set("false");

            docUpdated = true;

        }
        entry << id;

        // hidden
        QString hidden = bm.select_node("info/metadata/IsHidden").node().child_value();
        if(hidden.isEmpty())
            hidden = "false";
        entry << hidden;

        ret.append(entry);

    }

    if(docUpdated)
        doc.save_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8(), " ");

#endif

    return ret;

}

void PQHandlingFileDialog::moveUserPlacesEntry(QString id, bool moveDown, int howmany) {

    DBG << CURDATE << "PQHandlingFileDialog::moveUserPlacesEntry()" << NL
        << CURDATE << "** id = " << id.toStdString() << NL
        << CURDATE << "** moveDown = " << moveDown << NL
        << CURDATE << "** howmany = " << howmany << NL;

#ifdef PUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        LOG << CURDATE << "PQHandlingFileDialog::moveUserPlacesEntry(): ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
        return;
    }

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    // first get a handle for this node
    QStringList allIds;
    for(pugi::xpath_node node : bookmarks) {
        pugi::xml_node cur = node.node();
        QString curId = cur.select_node("info/metadata/ID").node().child_value();
        QString curPath = cur.attribute("href").value();
        if(curPath.startsWith("file:/") || curPath == "trash:/")
            allIds.append(curId);
    }

    for(pugi::xpath_node nodeToBeMoved : bookmarks) {

        pugi::xml_node cur = nodeToBeMoved.node();
        QString curId = cur.select_node("info/metadata/ID").node().child_value();

        if(id == curId) {

            QString targetId = "";
            bool addAtBeginning = false;
            if(moveDown)
                targetId = allIds[qMin(allIds.length()-1, allIds.indexOf(id)+howmany)];
            else {
                int newid =allIds.indexOf(id)-howmany-1;
                if(newid < 0)
                    addAtBeginning = true;
                targetId = allIds[qMax(0, newid)];
            }

            for(pugi::xpath_node targetNode : bookmarks) {

                QString curId = targetNode.node().select_node("info/metadata/ID").node().child_value();

                if(curId == targetId) {
                    pugi::xml_node ret;
                    if(addAtBeginning)
                        ret = targetNode.node().parent().insert_move_before(nodeToBeMoved.node(), targetNode.node());
                    else
                        ret = targetNode.node().parent().insert_move_after(nodeToBeMoved.node(), targetNode.node());
                    if(ret == nullptr)
                        LOG << CURDATE << "ERROR: Reordering items in user-places.xbel failed..." << NL;
                    break;
                }

            }

            break;

        }

    }

    doc.save_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8(), " ");

#endif

}

void PQHandlingFileDialog::hideUserPlacesEntry(QString id, bool hidden) {

    DBG << CURDATE << "PQHandlingFileDialog::hideUserPlacesEntry()" << NL
        << CURDATE << "** id = " << id.toStdString() << NL
        << CURDATE << "** hidden = " << hidden << NL;

#ifdef PUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        LOG << CURDATE << "PQHandlingFileDialog::hideUserPlacesEntry(): ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
        return;
    }

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    for(pugi::xpath_node node : bookmarks) {

        pugi::xml_node cur = node.node();
        QString curId = cur.select_node("info/metadata/ID").node().child_value();

        if(curId == id) {
            if(QString(cur.select_node("info/metadata/IsHidden").node().child_value()) == "") {
                pugi::xml_node metadata = cur.select_node("info/metadata").node();
                pugi::xml_node isHidden = metadata.append_child("IsHidden");
                isHidden.text().set(hidden ? "true" : "false");
            } else
                if(!cur.select_node("info/metadata/IsHidden").node().text().set(hidden ? "true" : "false"))
                    LOG << CURDATE << "ERROR: Unable to hide/show item with id " << id.toStdString() << NL;
            break;
        }
    }

    doc.save_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8(), " ");

#endif

}

void PQHandlingFileDialog::addNewUserPlacesEntry(QString path, int pos) {

    DBG << CURDATE << "PQHandlingFileDialog::addNewUserPlacesEntry()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** pos = " << pos << NL;

#ifdef PUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        LOG << CURDATE << "PQHandlingFileDialog::addNewUserPlacesEntry(): ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
        return;
    }

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    QStringList allIds;
    for(pugi::xpath_node node : bookmarks) {

        pugi::xml_node cur = node.node();

        QString path = cur.attribute("href").value();

        if(path == "trash:/" || path.startsWith("file:/"))
            allIds.push_back(cur.select_node("info/metadata/ID").node().child_value());

    }

    QString newid_base = QString::number(QDateTime::currentDateTime().toMSecsSinceEpoch());

    int counter = 0;
    while(allIds.contains(QString("%1/%2").arg(newid_base).arg(counter)))
        ++counter;

    // no items currenty set
    if(allIds.length() == 0) {

        pugi::xpath_node_set toplevel = doc.select_nodes("/xbel");

        pugi::xml_node newnode = toplevel.first().node().append_child("bookmark");
        if(newnode == nullptr)
            LOG << CURDATE << "PQHandlingFileDialog::addNewUserPlacesEntry(): ERROR: Unable to add first node..." << NL;

        // <bookmark>
        newnode.set_name("bookmark");
        newnode.append_attribute("href");
        newnode.attribute("href").set_value(QString("file://%1").arg(path).toStdString().c_str());

        // <title>
        pugi::xml_node title = newnode.append_child("title");
        title.text().set(QFileInfo(path).fileName().toStdString().c_str());

        // <info>
        pugi::xml_node info = newnode.append_child("info");

        // <metadata> freedesktop.org
        pugi::xml_node metadata1 = info.append_child("metadata");
        metadata1.append_attribute("owner");
        metadata1.attribute("owner").set_value("http://freedesktop.org");

        // <bookmark:icon>
        pugi::xml_node icon = metadata1.append_child("bookmark:icon");
        icon.append_attribute("name");
        icon.attribute("name").set_value("folder");

        // <metadata> kde.org
        pugi::xml_node metadata2 = info.append_child("metadata");
        metadata2.append_attribute("owner");
        metadata2.attribute("owner").set_value("http://www.kde.org");

        // <ID>
        pugi::xml_node ID = metadata2.append_child("ID");
        ID.text().set(QString("%1/%2").arg(newid_base).arg(counter).toStdString().c_str());

        // <IsHidden>
        pugi::xml_node IsHidden = metadata2.append_child("IsHidden");
        IsHidden.text().set("false");

        // <isSystemItem>
        pugi::xml_node isSystemItem = metadata2.append_child("isSystemItem");
        isSystemItem.text().set("false");

    } else {

        QString insertAfterId = allIds.length() == 0 ? "" : allIds[qMax(0, pos-2)];

        for(pugi::xpath_node node : bookmarks) {

            pugi::xml_node cur = node.node();

            if(insertAfterId == "" || cur.select_node("info/metadata/ID").node().child_value() == insertAfterId) {

                pugi::xml_node newnode = cur.parent().insert_child_after(pugi::node_element, cur);
                if(newnode == nullptr)
                    LOG << CURDATE << "PQHandlingFileDialog::addNewUserPlacesEntry(): ERROR: Unable to add new node..." << NL;

                // <bookmark>
                newnode.set_name("bookmark");
                newnode.append_attribute("href");
                newnode.attribute("href").set_value(QString("file://%1").arg(path).toStdString().c_str());

                // <title>
                pugi::xml_node title = newnode.append_child("title");
                title.text().set(QFileInfo(path).fileName().toStdString().c_str());

                // <info>
                pugi::xml_node info = newnode.append_child("info");

                // <metadata> freedesktop.org
                pugi::xml_node metadata1 = info.append_child("metadata");
                metadata1.append_attribute("owner");
                metadata1.attribute("owner").set_value("http://freedesktop.org");

                // <bookmark:icon>
                pugi::xml_node icon = metadata1.append_child("bookmark:icon");
                icon.append_attribute("name");
                icon.attribute("name").set_value("folder");

                // <metadata> kde.org
                pugi::xml_node metadata2 = info.append_child("metadata");
                metadata2.append_attribute("owner");
                metadata2.attribute("owner").set_value("http://www.kde.org");

                // <ID>
                pugi::xml_node ID = metadata2.append_child("ID");
                ID.text().set(QString("%1/%2").arg(newid_base).arg(counter).toStdString().c_str());

                // <IsHidden>
                pugi::xml_node IsHidden = metadata2.append_child("IsHidden");
                IsHidden.text().set("false");

                // <isSystemItem>
                pugi::xml_node isSystemItem = metadata2.append_child("isSystemItem");
                isSystemItem.text().set("false");

                break;

            }

        }

    }

    doc.save_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8(), " ");

#endif

}

void PQHandlingFileDialog::removeUserPlacesEntry(QString id) {

    DBG << CURDATE << "PQHandlingFileDialog::removeUserPlacesEntry()" << NL
        << CURDATE << "** id = " << id.toStdString() << NL;

#ifdef PUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        LOG << CURDATE << "PQHandlingFileDialog::removeUserPlacesEntry(): ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
        return;
    }

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    for(pugi::xpath_node node : bookmarks) {

        pugi::xml_node cur = node.node();
        QString curId = cur.select_node("info/metadata/ID").node().child_value();

        if(curId == id) {
            if(!cur.parent().remove_child(cur))
                LOG << CURDATE << "ERROR: Unable to remove item with id " << id.toStdString() << NL;
            break;
        }
    }

    doc.save_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8(), " ");

#endif

}

QVariantList PQHandlingFileDialog::getStorageInfo() {

    DBG << CURDATE << "PQHandlingFileDialog::getStorageInfo()" << NL;

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffOpenFile::getStorageInfo()" << NL;

    QVariantList ret;

    for(QStorageInfo s : QStorageInfo::mountedVolumes()) {
        if(s.isValid()) {

            QString name = s.name();
            if(name == "")
                name = s.rootPath();

            QVariantList vol;
            vol << name
                << s.bytesTotal()
                << QString(s.fileSystemType())
                << s.rootPath();

            ret.append(vol);

        }
    }

    return ret;

}

unsigned int PQHandlingFileDialog::getNumberOfFilesInFolder(QString path) {

    // no debug statement here, this function is only and always called by the next function with the same name

    QDir dir(path);

    QStringList checkForTheseFormats = PQImageFormats2::get().getAllEnabledFileFormats();
    dir.setNameFilters(checkForTheseFormats);
    dir.setFilter(QDir::Files);

    return dir.count();

}

void PQHandlingFileDialog::getNumberOfFilesInFolder(QString path, const QJSValue &callback) {

    DBG << CURDATE << "PQHandlingFileDialog::getNumberOfFilesInFolder()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    auto *watcher = new QFutureWatcher<unsigned int>(this);
    QObject::connect(watcher, &QFutureWatcher<unsigned int>::finished,
                     this, [this,watcher,callback]() {
        unsigned int count = watcher->result();
        QJSValue cbCopy(callback); // needed as callback is captured as const
        QJSEngine *engine = qjsEngine(this);
        cbCopy.call(QJSValueList { engine->toScriptValue(count) });
        watcher->deleteLater();
    });
    watcher->setFuture(QtConcurrent::run(this, &PQHandlingFileDialog::getNumberOfFilesInFolder, path));
}

QString PQHandlingFileDialog::cleanPath(QString path) {

    DBG << CURDATE << "PQHandlingFileDialog::cleanPath()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    if(path.startsWith("file:///"))
        path = path.remove(0, 7);
    if(path.startsWith("file://"))
        path = path.remove(0, 6);

    return QDir::cleanPath(path);

}

QString PQHandlingFileDialog::getSuffix(QString path, bool lowerCase) {

    DBG << CURDATE << "PQHandlingFileDialog::getSuffix()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** lowerCase = " << lowerCase << NL;

    if(lowerCase)
        return QFileInfo(path).suffix().toLower();
    return QFileInfo(path).suffix();

}

QString PQHandlingFileDialog::getBaseName(QString path, bool lowerCase) {

    DBG << CURDATE << "PQHandlingFileDialog::getBaseName()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** lowerCase = " << lowerCase << NL;

    if(lowerCase)
        return QFileInfo(path).baseName().toLower();
    return QFileInfo(path).baseName();

}

QString PQHandlingFileDialog::getDirectory(QString path, bool lowerCase) {

    DBG << CURDATE << "PQHandlingFileDialog::getDirectory()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** lowerCase = " << lowerCase << NL;

    if(lowerCase)
        return QFileInfo(path).absolutePath().toLower();
    return QFileInfo(path).absolutePath();

}

bool PQHandlingFileDialog::doesItExist(QString path) {

    DBG << CURDATE << "PQHandlingFileDialog::doesItExist()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QFile file(path);
    return file.exists();

}

QStringList PQHandlingFileDialog::getFoldersIn(QString path) {

    DBG << CURDATE << "PQHandlingFileDialog::getFoldersIn()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QDir dir(path);

    dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    return dir.entryList();

}

QString PQHandlingFileDialog::getHomeDir() {

    DBG << CURDATE << "PQHandlingFileDialog::getHomeDir()" << NL;

    return QDir::homePath();

}

QString PQHandlingFileDialog::getLastLocation() {

    DBG << CURDATE << "PQHandlingFileDialog::getLastLocation()" << NL;

    QString ret = QDir::currentPath();
    QFile file(ConfigFiles::OPENFILE_LAST_LOCATION());
    if(file.exists() && file.open(QIODevice::ReadOnly)) {
        QTextStream in(&file);
        ret = in.readAll().trimmed();
        file.close();
    }
    QDir folder(ret);
    if(folder.exists())
        return ret;
    return QDir::homePath();

}

void PQHandlingFileDialog::setLastLocation(QString path) {

    DBG << CURDATE << "PQHandlingFileDialog::setLastLocation()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QFile file(ConfigFiles::OPENFILE_LAST_LOCATION());
    if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream out(&file);
        out << path;
        file.close();
    }

}

QString PQHandlingFileDialog::convertBytesToHumanReadable(qint64 bytes) {

    DBG << CURDATE << "PQHandlingFileDialog::convertBytesToHumanReadable()" << NL
        << CURDATE << "** bytes = " << bytes << NL;

    if(bytes <= 1024)
        return (QString::number(bytes) + " B");
    else if(bytes <= 1024*1024)
        return (QString::number(qRound(10.0*(bytes/1024.0))/10.0) + " KB");

    return (QString::number(qRound(100.0*(bytes/(1024.0*1024.0)))/100.0) + " MB");

}

QString PQHandlingFileDialog::getFileType(QString path) {

    DBG << CURDATE << "PQHandlingFileDialog::getFileType()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QMimeDatabase db;
    QMimeType mime = db.mimeTypeForFile(path);
    return mime.name();
}

int PQHandlingFileDialog::convertCharacterToKeyCode(QString key) {

    DBG << CURDATE << "PQHandlingFileDialog::convertCharacterToKeyCode()" << NL
        << CURDATE << "** key = " << key.toStdString() << NL;

    return QKeySequence(key)[0];

}

QStringList PQHandlingFileDialog::listPDFPages(QString path) {

    DBG << CURDATE << "PQHandlingFileDialog::listPDFPages()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QStringList ret;

#ifdef POPPLER

    Poppler::Document* document = Poppler::Document::load(path);
    if(document && !document->isLocked()) {
        int numPages = document->numPages();
        for(int i = 0; i < numPages; ++i)
            ret.append(QString("%1::PQT::%2").arg(i).arg(path));
    }
    delete document;

#endif

    return ret;

}

QStringList PQHandlingFileDialog::listArchiveContent(QString path) {

    DBG << CURDATE << "PQHandlingFileDialog::listArchiveContent()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QStringList ret;

    QFileInfo info(path);

#ifndef Q_OS_WIN
    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which", QStringList() << "unrar");
    which.waitForFinished();

    if(!which.exitCode() && PQSettings::get().getArchiveUseExternalUnrar() && (info.suffix() == "cbr" || info.suffix() == "rar")) {

        QProcess p;
        p.start("unrar", QStringList() << "lb" << info.absoluteFilePath());

        if(p.waitForStarted()) {

            QByteArray outdata = "";

            while(p.waitForReadyRead())
                outdata.append(p.readAll());

#if (QT_VERSION >= QT_VERSION_CHECK(5, 15, 0))
            QStringList allfiles = QString::fromLatin1(outdata).split('\n', Qt::SkipEmptyParts);
#else
            QStringList allfiles = QString::fromLatin1(outdata).split('\n', QString::SkipEmptyParts);
#endif
            allfiles.sort();
            foreach(QString f, allfiles) {
                if(PQImageFormats2::get().getEnabledFileformatsQt().contains("*." + QFileInfo(f).suffix()))
                    ret.append(QString("%1::ARC::%2").arg(f).arg(path));
            }

        }

    } else {

#endif

#ifdef LIBARCHIVE

        // Create new archive handler
        struct archive *a = archive_read_new();

        // We allow any type of compression and format
        archive_read_support_filter_all(a);
        archive_read_support_format_all(a);

        // Read file
        int r = archive_read_open_filename(a, info.absoluteFilePath().toLocal8Bit().data(), 10240);

        // If something went wrong, output error message and stop here
        if(r != ARCHIVE_OK) {
            LOG << CURDATE << "GetAndDoStuffListFiles::loadAllArchiveFiles(): ERROR: archive_read_open_filename() returned code of " << r << NL;
            return ret;
        }

        // Loop over entries in archive
        struct archive_entry *entry;
        QStringList allfiles;
        while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

            // Read the current file entry
            QString filenameinside = QString::fromStdString(archive_entry_pathname(entry));

            // If supported file format, append to temporary list
            if((PQImageFormats2::get().getEnabledFileformatsQt().contains("*." + QFileInfo(filenameinside).suffix())))
                allfiles.append(filenameinside);

        }

        // Sort the temporary list and add to global list
        allfiles.sort();
        foreach(QString f, allfiles)
            ret.append(QString("%1::ARC::%2").arg(f).arg(path));

        // Close archive
        r = archive_read_free(a);
        if(r != ARCHIVE_OK)
            LOG << CURDATE << "GetAndDoStuffListFiles::loadAllArchiveFiles(): ERROR: archive_read_free() returned code of " << r << NL;

#endif

#ifndef Q_OS_WIN
    }
#endif

    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);
    collator.setNumericMode(true);

    if(PQSettings::get().getSortbyAscending())
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
    else
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });

    return ret;

}


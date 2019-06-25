#include "handlingfiledialog.h"
#include <QtDebug>

PQHandlingFileDialog::PQHandlingFileDialog(QObject *parent) : QObject(parent) {}

PQHandlingFileDialog::~PQHandlingFileDialog() {}

QString PQHandlingFileDialog::getNewUniqueId() {

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

}

QVariantList PQHandlingFileDialog::getUserPlaces() {

    QVariantList ret;

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

    return ret;

}

void PQHandlingFileDialog::moveUserPlacesEntry(QString id, bool moveDown, int howmany) {

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

}

void PQHandlingFileDialog::hideUserPlacesEntry(QString id, bool hidden) {

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

}

void PQHandlingFileDialog::addNewUserPlacesEntry(QString path, int pos) {

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

    QString insertAfterId = allIds[qMax(0, pos-2)];

    for(pugi::xpath_node node : bookmarks) {

        pugi::xml_node cur = node.node();

        if(cur.select_node("info/metadata/ID").node().child_value() == insertAfterId) {

            pugi::xml_node newnode = cur.parent().insert_child_after(pugi::node_element, cur);
            if(newnode == nullptr)
                LOG << CURDATE << "ERROR: Unable to add new node..." << NL;

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

    doc.save_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8(), " ");

}

void PQHandlingFileDialog::removeUserPlacesEntry(QString id) {

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

}

QVariantList PQHandlingFileDialog::getStorageInfo() {

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

    QDir dir(path);

    QStringList checkForTheseFormats = PQImageFormats::get().getAllEnabledFileFormats();
    dir.setNameFilters(checkForTheseFormats);
    dir.setFilter(QDir::Files);

    return dir.count();

}

void PQHandlingFileDialog::getNumberOfFilesInFolder(QString path, const QJSValue &callback) {
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

    if(path.startsWith("file:/"))
        path = path.remove(0, 6);

    return QDir::cleanPath(path);

}

QString PQHandlingFileDialog::getSuffix(QString path) {
    return QFileInfo(path).suffix().toLower();
}

QStringList PQHandlingFileDialog::getFoldersIn(QString path) {

    QDir dir(path);

    dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    return dir.entryList();

}

QString PQHandlingFileDialog::getHomeDir() {
    return QDir::homePath();
}

QString PQHandlingFileDialog::getLastLocation() {

    QString ret = QDir::currentPath();
    QFile file(ConfigFiles::OPENFILE_LAST_LOCATION());
    if(file.exists() && file.open(QIODevice::ReadOnly)) {
        QTextStream in(&file);
        ret = in.readAll().trimmed();
        file.close();
    }
    return ret;

}

void PQHandlingFileDialog::setLastLocation(QString path) {

    QFile file(ConfigFiles::OPENFILE_LAST_LOCATION());
    if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream out(&file);
        out << path;
        file.close();
    }

}

QString PQHandlingFileDialog::convertBytesToHumanReadable(qint64 bytes) {
    if(bytes <= 1024)
        return (QString::number(bytes) + " B");
    else if(bytes <= 1024*1024)
        return (QString::number(qRound(10.0*(bytes/1024.0))/10.0) + " KB");

    return (QString::number(qRound(100.0*(bytes/(1024.0*1024.0)))/100.0) + " MB");
}

QString PQHandlingFileDialog::getFileType(QString path) {
    QMimeDatabase db;
    QMimeType mime = db.mimeTypeForFile(path);
    return mime.name();
}

int PQHandlingFileDialog::convertCharacterToKeyCode(QString key) {
    return QKeySequence(key)[0];
}

QStringList PQHandlingFileDialog::listPDFPages(QString path) {

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

    QStringList ret;

    QFileInfo info(path);

#ifndef Q_OS_WIN
    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which unrar");
    which.waitForFinished();

    if(!which.exitCode() && PQSettings::get().getArchiveUseExternalUnrar() && (info.suffix() == "cbr" || info.suffix() == "rar")) {

        QProcess p;
        p.start(QString("unrar lb \"%1\"").arg(info.absoluteFilePath()));

        if(p.waitForStarted()) {

            QByteArray outdata = "";

            while(p.waitForReadyRead())
                outdata.append(p.readAll());

            QStringList allfiles = QString::fromLatin1(outdata).split('\n', QString::SkipEmptyParts);
            allfiles.sort();
            foreach(QString f, allfiles) {
                if(PQImageFormats::get().getEnabledFileformatsQt().contains("*." + QFileInfo(f).suffix()))
                    ret.append(QString("%1::ARC::%2").arg(f).arg(path));
            }

        }

    } else {

#endif

        // Create new archive handler
        struct archive *a = archive_read_new();

        // We allow any type of compression and format
        archive_read_support_filter_all(a);
        archive_read_support_format_all(a);

        // Read file
        int r = archive_read_open_filename(a, info.absoluteFilePath().toLatin1(), 10240);

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
            if((PQImageFormats::get().getEnabledFileformatsQt().contains("*." + QFileInfo(filenameinside).suffix())))
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


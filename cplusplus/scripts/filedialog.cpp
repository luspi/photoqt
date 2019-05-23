#include "filedialog.h"
#include <QtDebug>

PQHandlingFileDialog::PQHandlingFileDialog(QObject *parent) : QObject(parent) {
    imageformats = new PQImageFormats;
}

PQHandlingFileDialog::~PQHandlingFileDialog() {
    delete imageformats;
}

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

    QStringList checkForTheseFormats = imageformats->getAllEnabledFileformats();
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


QJSValue PQHandlingFileDialog::getFileSize(QString path) {

    QFileInfo info(path);

    qint64 s = info.size();

    if(s <= 1024)
        return (QString::number(s) + " B");
    else if(s <= 1024*1024)
        return (QString::number(qRound(10.0*(s/1024.0))/10.0) + " KB");

    return (QString::number(qRound(100.0*(s/(1024.0*1024.0)))/100.0) + " MB");

}

void PQHandlingFileDialog::getFileSize(QString path, const QJSValue &callback) {
    auto *watcher = new QFutureWatcher<QJSValue>(this);
    QObject::connect(watcher, &QFutureWatcher<QJSValue>::finished,
                     this, [this,watcher,callback]() {
        QJSValue count = watcher->result();
        QJSValue cbCopy(callback); // needed as callback is captured as const
        QJSEngine *engine = qjsEngine(this);
        cbCopy.call(QJSValueList { engine->toScriptValue(count) });
        watcher->deleteLater();
    });
    watcher->setFuture(QtConcurrent::run(this, &PQHandlingFileDialog::getFileSize, path));
}

QString PQHandlingFileDialog::cleanPath(QString path) {

    if(path.startsWith("file:/"))
        path = path.remove(0, 6);

    return QDir::cleanPath(path);

}

QStringList PQHandlingFileDialog::getFoldersIn(QString path) {

    QDir dir(path);

    dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    return dir.entryList();

}

QString PQHandlingFileDialog::getHomeDir() {
    return QDir::homePath();
}


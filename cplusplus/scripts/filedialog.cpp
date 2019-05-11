#include "filedialog.h"
#include <QtDebug>

PQHandlingFileDialog::PQHandlingFileDialog(QObject *parent) : QObject(parent) {
    imageformats = new PQImageFormats;
}

PQHandlingFileDialog::~PQHandlingFileDialog() {
    delete imageformats;
}

QVariantList PQHandlingFileDialog::getUserPlaces() {

    QVariantList ret;

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        LOG << CURDATE << "ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
        return ret;
    }

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
        entry << bm.select_node("info/metadata/ID").node().child_value();
        // hidden
        entry << bm.select_node("info/metadata/IsHidden").node().child_value();

        ret.append(entry);

    }

    return ret;

}

void PQHandlingFileDialog::moveUserPlacesEntry(QString id, bool moveDown, int howmany) {

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        LOG << CURDATE << "ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
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
        LOG << CURDATE << "ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
        return;
    }

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    for(pugi::xpath_node node : bookmarks) {

        pugi::xml_node cur = node.node();
        QString curId = cur.select_node("info/metadata/ID").node().child_value();

        if(curId == id) {
            if(!cur.select_node("info/metadata/IsHidden").node().text().set(hidden ? "true" : "false"))
                LOG << CURDATE << "ERROR: Unable to hide/show item with id " << id.toStdString() << NL;
            break;
        }
    }

    doc.save_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8(), " ");

}

void PQHandlingFileDialog::addNewUserPlacesEntry(QVariantList, int) {
//void PQHandlingFileDialog::addNewUserPlacesEntry(QVariantList entry, int pos) {

}

void PQHandlingFileDialog::removeUserPlacesEntry(QString id) {

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        LOG << CURDATE << "ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
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


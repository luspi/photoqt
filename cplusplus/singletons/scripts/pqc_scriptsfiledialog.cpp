#include <pqc_configfiles.h>
#include <scripts/pqc_scriptsfiledialog.h>
#include <pqc_imageformats.h>
#include <QtDebug>
#include <QStorageInfo>
#include <QUrl>
#include <QFutureWatcher>
#include <QJSValue>
#include <QJSEngine>
#include <QtConcurrent>

#ifdef PUGIXML
#include <pugixml.hpp>
#endif

PQCScriptsFileDialog::PQCScriptsFileDialog() {

}

PQCScriptsFileDialog::~PQCScriptsFileDialog() {

}

QVariantList PQCScriptsFileDialog::getDevices() {

    qDebug() << "";

    QVariantList ret;

    const QList<QStorageInfo> info = QStorageInfo::mountedVolumes();
    for(const QStorageInfo &s : info) {
        if(s.isValid()) {

            QString name = s.name();
            if(name == "")
                name = QDir::toNativeSeparators(s.rootPath());

            QString p = s.rootPath();

            QVariantList vol;
            vol << name
                << s.bytesTotal()
                << QString(s.fileSystemType())
                << p;

            ret.append(vol);

        }
    }

    return ret;

}

QVariantList PQCScriptsFileDialog::getPlaces() {

    qDebug() << "";

    QVariantList ret;

#ifdef PUGIXML

    // if file does not exist yet then we create a sceleton file
    if(!QFile(QString(PQCConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel")).exists()) {
        QString cont = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        cont += "<xbel xmlns:kdepriv=\"http://www.kde.org/kdepriv\" xmlns:mime=\"http://www.freedesktop.org/standards/shared-mime-info\" xmlns:bookmark=\"http://www.freedesktop.org/standards/desktop-bookmarks\">\n";
        cont += "</xbel>";
        QFile file(QString(PQCConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel"));
        if(file.open(QIODevice::WriteOnly)) {
            QTextStream out(&file);
            out << cont;
            file.close();
        }
    }

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(PQCConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        qWarning() << "Unable to read user places. Either file doesn't exist (yet) or cannot be read...";
        return ret;
    }

    bool docUpdated = false;

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    for(pugi::xpath_node node: bookmarks) {

        QVariantList entry;

        pugi::xml_node bm = node.node();

        QString path = QUrl::fromPercentEncoding(bm.attribute("href").value());

// we need to check for the old (wrong) syntax of two slashes
// and for the new right synbtax of three slashes after file:
#ifdef Q_OS_WIN
        if(path.startsWith("file:///"))
            path = path.remove(0,8);
        else if(path.startsWith("file://"))
            path = path.remove(0,7);
#else
        if(path.startsWith("file:////"))
            path = path.remove(0,8);
        else if(path.startsWith("file:///"))
            path = path.remove(0,7);
        else if(path == "trash:/")
            path = PQCConfigFiles::GENERIC_DATA_DIR() + "/Trash/files";
#endif
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

            id = getUniquePlacesId();

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
        doc.save_file(QString(PQCConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8(), " ");

#endif

    return ret;

}

QString PQCScriptsFileDialog::getUniquePlacesId() {

    qDebug() << "";

#ifdef PUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(PQCConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        qWarning() << "Unable to read user places. Either file doesn't exist (yet) or cannot be read...";
        return "";
    }

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    QStringList allIds;
    for(pugi::xpath_node node : bookmarks) {
        pugi::xml_node cur = node.node();
        QString curId = cur.select_node("info/metadata/ID").node().child_value();
        QString curPath = QUrl::fromPercentEncoding(cur.attribute("href").value());
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

void PQCScriptsFileDialog::setLastLocation(QString path) {

    qDebug() << "args: path =" << path;

    QFile file(PQCConfigFiles::FILEDIALOG_LAST_LOCATION());
    if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream out(&file);
        out << path;
        file.close();
    }

}

unsigned int PQCScriptsFileDialog::_getNumberOfFilesInFolder(QString path) {

    // no debug statement here, this function is only and always called by the next function with the same name

    // cache key
    const QString key = QString("%1%2").arg(path,QFileInfo(path).lastModified().toString());

    // if already loaded before, read from cache
    if(cacheNumberOfFilesInFolder.contains(key))
        return cacheNumberOfFilesInFolder[key];

    // fresh count of files in folder

    QDir dir(path);
    QStringList checkForTheseFormats;
    const QStringList lst = PQCImageFormats::get().getEnabledFormats();
    for(const QString &c : lst)
        checkForTheseFormats << QString("*.%1").arg(c);

    dir.setNameFilters(checkForTheseFormats);
    dir.setFilter(QDir::Files);

    const int count = dir.count();
    cacheNumberOfFilesInFolder.insert(key, count);

    return count;

}

void PQCScriptsFileDialog::getNumberOfFilesInFolder(QString path, const QJSValue &callback) {

    qDebug() << "args: path =" << path;

    auto *watcher = new QFutureWatcher<unsigned int>(this);
    QObject::connect(watcher, &QFutureWatcher<unsigned int>::finished,
                     this, [this,watcher,callback]() {
                         unsigned int count = watcher->result();
                         QJSValue cbCopy(callback); // needed as callback is captured as const
                         QJSEngine *engine = qjsEngine(this);
                         cbCopy.call(QJSValueList { engine->toScriptValue(count) });
                         watcher->deleteLater();
                     });
    watcher->setFuture(QtConcurrent::run(&PQCScriptsFileDialog::_getNumberOfFilesInFolder, this, path));
}

QString PQCScriptsFileDialog::getLastLocation() {

    qDebug() << "";

    QString ret = QDir::currentPath();
    QFile file(PQCConfigFiles::FILEDIALOG_LAST_LOCATION());
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

void PQCScriptsFileDialog::moveUserPlacesEntry(QString id, bool moveDown, int howmany) {

    qDebug() << "args: id = " << id;
    qDebug() << "args: moveDown = " << moveDown;
    qDebug() << "args: howmany = " << howmany;

#ifdef PUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(PQCConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        qWarning() << "ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read...";
        return;
    }

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    // first get a handle for this node
    QStringList allIds;
    for(pugi::xpath_node node : bookmarks) {
        pugi::xml_node cur = node.node();
        QString curId = cur.select_node("info/metadata/ID").node().child_value();
        QString curPath = QUrl::fromPercentEncoding(cur.attribute("href").value());
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
                        qWarning() << "ERROR: Reordering items in user-places.xbel failed...";
                    break;
                }

            }

            break;

        }

    }

    doc.save_file(QString(PQCConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8(), " ");

#endif

}

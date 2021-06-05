/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

QStringList PQHandlingFileDialog::getFoldersIn(QString path) {

    DBG << CURDATE << "PQHandlingFileDialog::getFoldersIn()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QDir dir(path);

    dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    return dir.entryList();

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

unsigned int PQHandlingFileDialog::getNumberOfFilesInFolder(QString path) {

    // no debug statement here, this function is only and always called by the next function with the same name

    QDir dir(path);

    QStringList checkForTheseFormats;
    for(QString c : PQImageFormats::get().getEnabledFormats())
        checkForTheseFormats << QString("*.%1").arg(c);

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

QVariantList PQHandlingFileDialog::getStorageInfo() {

    DBG << CURDATE << "PQHandlingFileDialog::getStorageInfo()" << NL;

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

QString PQHandlingFileDialog::getNewUniqueId() {

    DBG << CURDATE << "PQHandlingFileDialog::getNewUniqueId()" << NL;

#ifdef PUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8());
    if(!result) {
        LOG << CURDATE << "PQHandlingFileDialog::getNewUniqueId(): ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read..." << NL;
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
                LOG << CURDATE << "PQHandlingFileDialog::removeUserPlacesEntry(): ERROR: Unable to remove item with id " << id.toStdString() << NL;
            break;
        }
    }

    doc.save_file(QString(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").toUtf8(), " ");

#endif

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

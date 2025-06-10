/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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
#include <pqc_settingscpp.h>

#ifdef PQMPUGIXML
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

            const QString tpe = QString(s.fileSystemType());

            if((tpe.toLower() == "tmpfs" || tpe.toLower() == "squashfs") && !PQCSettingsCPP::get().getFiledialogDevicesShowTmpfs())
                continue;

            QString name = s.name();
            if(name == "")
                name = QDir::toNativeSeparators(s.rootPath());

            QString p = s.rootPath();

            QVariantList vol;
            vol << name
                << s.bytesTotal()
                << tpe
                << p;

            ret.append(vol);

        }
    }

    return ret;

}

QVariantList PQCScriptsFileDialog::getPlaces(bool performEmptyCheck) {

    qDebug() << "";

    QVariantList ret;

#ifdef PQMPUGIXML

    // if file does not exist yet then we create a sceleton file
    if(!QFile(PQCConfigFiles::get().USER_PLACES_XBEL()).exists()) {

        qDebug() << "Loading default user_places.xbel file";

        QString cont = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        cont += "<xbel xmlns:mime=\"http://www.freedesktop.org/standards/shared-mime-info\" xmlns:bookmark=\"http://www.freedesktop.org/standards/desktop-bookmarks\">\n";
        cont += "</xbel>";

        QFile file(PQCConfigFiles::get().USER_PLACES_XBEL());
        if(file.open(QIODevice::WriteOnly)) {
            QTextStream out(&file);
            out << cont;
            file.close();
        }
    }

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8());
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

// we need to check for the old syntax of two/three slashes
#ifdef Q_OS_WIN
        if(path.startsWith("file:///"))
            path = path.remove(0,8);
        else if(path.startsWith("file://"))
            path = path.remove(0,7);
        else if(path.startsWith("file:/"))
            path = path.remove(0,6);
        else if(path.startsWith("file:"))
            path = path.remove(0,5);
#else
        if(path.startsWith("file:////"))
            path = path.remove(0,8);
        else if(path.startsWith("file:///"))
            path = path.remove(0,7);
        else if(path.startsWith("file://"))
            path = path.remove(0,6);
        else if(path.startsWith("file:/"))
            path = path.remove(0,5);
        else if(path.startsWith("file:"))
            path = path.remove(0,4);
        else if(path == "trash:/" || path == "trash:")
            path = PQCConfigFiles::get().USER_TRASH_FILES();
#endif
        else
            continue;

        // name
        const QString nme = bm.select_node("title").node().child_value();
        entry << nme;

        // path
        entry << path;

        // icon
        const QString icn = bm.select_node("info/metadata/bookmark:icon").node().attribute("name").value();
        if((nme == "Home" || nme == QStandardPaths::displayName(QStandardPaths::HomeLocation)) && icn == "true")
            entry << "user-home";
        else
            entry << icn;

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
        doc.save_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8(), " ");

#endif

    // When no entries are found, we fill in the four default entries
    // the `performEmptyCheck` boolean prevents a potential infinite loop if things go horribly wrong
    if(ret.length() == 0 && performEmptyCheck) {

        addPlacesEntry(QStandardPaths::writableLocation(QStandardPaths::HomeLocation),
                       0,
                       (QStandardPaths::displayName(QStandardPaths::HomeLocation)=="" ? "Home" : QStandardPaths::displayName(QStandardPaths::HomeLocation)),
                       "user-home",
                       true);
        addPlacesEntry(QStandardPaths::writableLocation(QStandardPaths::DesktopLocation),
                       0,
                       (QStandardPaths::displayName(QStandardPaths::DesktopLocation)=="" ? "Desktop" : QStandardPaths::displayName(QStandardPaths::DesktopLocation)),
                       "user-desktop",
                       true);
        addPlacesEntry(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation),
                       0,
                       (QStandardPaths::displayName(QStandardPaths::PicturesLocation)=="" ? "Pictures" : QStandardPaths::displayName(QStandardPaths::PicturesLocation)),
                       "folder-documents",
                       true);
        addPlacesEntry(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation),
                       0,
                       (QStandardPaths::displayName(QStandardPaths::DownloadLocation)=="" ? "Downloads" : QStandardPaths::displayName(QStandardPaths::DownloadLocation)),
                       "folder-downloads",
                       true);

        return getPlaces(false);

    }

    return ret;

}

QString PQCScriptsFileDialog::getUniquePlacesId() {

    qDebug() << "";

#ifdef PQMPUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8());
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
        if(curPath.startsWith("file:") || curPath == "trash:" || curPath == "trash:/")
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
    QFile file(PQCConfigFiles::get().FILEDIALOG_LAST_LOCATION());
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

void PQCScriptsFileDialog::movePlacesEntry(QString id, bool moveDown, int howmany) {

    qDebug() << "args: id = " << id;
    qDebug() << "args: moveDown = " << moveDown;
    qDebug() << "args: howmany = " << howmany;

#ifdef PQMPUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8());
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
        if(curPath.startsWith("file:") || curPath == "trash:" || curPath == "trash:/")
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

    doc.save_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8(), " ");

#endif

}

void PQCScriptsFileDialog::addPlacesEntry(QString path, int pos, QString titlestring, QString icon, bool isSystemItem) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: pos =" << pos;
    qDebug() << "args: titlestring =" << titlestring;
    qDebug() << "args: icon =" << icon;
    qDebug() << "args: isSystemItem =" << isSystemItem;

#ifdef PQMPUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8());
    if(!result) {
        qWarning() << "ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read...";
        return;
    }

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    QStringList allIds;
    for(pugi::xpath_node node : bookmarks) {

        pugi::xml_node cur = node.node();

        QString path = cur.attribute("href").value();

        if(path == "trash:" || path == "trash:/" || path.startsWith("file:"))
            allIds.push_back(cur.select_node("info/metadata/ID").node().child_value());

    }

    QString newid_base = QString::number(QDateTime::currentDateTime().toMSecsSinceEpoch());

    int counter = 0;
    while(allIds.contains(QString("%1/%2").arg(newid_base).arg(counter)))
        ++counter;

    // no items currently set
    if(allIds.length() == 0) {

        pugi::xpath_node_set toplevel = doc.select_nodes("/xbel");

        pugi::xml_node newnode = toplevel.first().node().append_child("bookmark");
        if(newnode == nullptr)
            qWarning() << "ERROR: Unable to add first node...";

        // <bookmark>
        newnode.set_name("bookmark");
        newnode.append_attribute("href");
        newnode.attribute("href").set_value(QString("file:%1").arg(QString::fromLatin1(QUrl::toPercentEncoding(path))).toStdString().c_str());

        // <title>
        pugi::xml_node title = newnode.append_child("title");
        title.text().set(titlestring=="" ? QFileInfo(path).fileName().toStdString().c_str() : titlestring.toStdString().c_str());

        // <info>
        pugi::xml_node info = newnode.append_child("info");

        // <metadata> freedesktop.org
        pugi::xml_node metadata1 = info.append_child("metadata");
        metadata1.append_attribute("owner");
        metadata1.attribute("owner").set_value("http://freedesktop.org");

        // <bookmark:icon>
        pugi::xml_node node_icon = metadata1.append_child("bookmark:icon");
        node_icon.append_attribute("name");
        node_icon.attribute("name").set_value(icon.toStdString().c_str());

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
        pugi::xml_node node_isSystemItem = metadata2.append_child("isSystemItem");
        node_isSystemItem.text().set(isSystemItem ? "true" : "false");

    } else {

        QString insertAfterId = allIds.length() == 0 ? "" : allIds[qMax(0, pos-2)];

        for(pugi::xpath_node node : bookmarks) {

            pugi::xml_node cur = node.node();

            if(insertAfterId == "" || cur.select_node("info/metadata/ID").node().child_value() == insertAfterId) {

                pugi::xml_node newnode = cur.parent().insert_child_after(pugi::node_element, cur);
                if(newnode == nullptr)
                    qWarning() << "ERROR: Unable to add new node...";

                // <bookmark>
                newnode.set_name("bookmark");
                newnode.append_attribute("href");
                newnode.attribute("href").set_value(QString("file:%1").arg(QString::fromLatin1(QUrl::toPercentEncoding(path))).toStdString().c_str());

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
                pugi::xml_node node_icon = metadata1.append_child("bookmark:icon");
                node_icon.append_attribute("name");
                node_icon.attribute("name").set_value(icon.toStdString().c_str());

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
                pugi::xml_node node_isSystemItem = metadata2.append_child("isSystemItem");
                node_isSystemItem.text().set("false");

                break;

            }

        }

    }

    doc.save_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8(), " ");

#endif

}

void PQCScriptsFileDialog::hidePlacesEntry(QString id, bool hidden) {

    qDebug() << "args: id = " << id;
    qDebug() << "args: hidden = " << hidden;

#ifdef PQMPUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8());
    if(!result) {
        qWarning() << "ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read...";
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
                qWarning() << "ERROR: Unable to hide/show item with id" << id;
            break;
        }
    }

    doc.save_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8(), " ");

#endif

}

void PQCScriptsFileDialog::deletePlacesEntry(QString id) {

    qDebug() << "args: id =" << id;

#ifdef PQMPUGIXML

    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8());
    if(!result) {
        qWarning() << "ERROR: Unable to read user places. Either file doesn't exist (yet) or cannot be read...";
        return;
    }

    pugi::xpath_node_set bookmarks = doc.select_nodes("/xbel/bookmark");

    for(pugi::xpath_node node : bookmarks) {

        pugi::xml_node cur = node.node();
        QString curId = cur.select_node("info/metadata/ID").node().child_value();

        if(curId == id) {
            if(!cur.parent().remove_child(cur))
                qWarning() << "ERROR: Unable to remove item with id" << id;
            break;
        }
    }

    doc.save_file(PQCConfigFiles::get().USER_PLACES_XBEL().toUtf8(), " ");

#endif

}

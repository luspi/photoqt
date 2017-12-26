#include "context.h"

GetAndDoStuffContext::GetAndDoStuffContext(QObject *parent) : QObject(parent) { }
GetAndDoStuffContext::~GetAndDoStuffContext() { }

QStringList GetAndDoStuffContext::setDefaultContextMenuEntries() {

#ifdef Q_OS_WIN
    return QStringList();
#endif

    // These are the possible entries
    QStringList m;
    m << tr("Edit with") + " Gimp" << "gimp %f"
      << tr("Edit with") + " Krita" << "krita %f"
      << tr("Edit with") + " KolourPaint" << "kolourpaint %f"
      << tr("Open in") + " GwenView" << "gwenview %f"
      << tr("Open in") + " showFoto" << "showfoto %f"
      << tr("Open in") + " Shotwell" << "shotwell %f"
      << tr("Open in") + " GThumb" << "gthumb %f"
      << tr("Open in") + " Eye of Gnome" << "eog %f";

    QStringList ret;
    QVariantList forsaving;
    int counter = 0;
    // Check for all entries
    for(int i = 0; i < m.size()/2; ++i) {
        if(checkIfBinaryExists(m[2*i+1])) {
            ret << m[2*i+1] << "0" << m[2*i];
            QVariantMap map;
            map.insert("posInView",counter);
            map.insert("binary",m[2*i+1]);
            map.insert("description",m[2*i]);
            map.insert("quit","0");
            forsaving.append(map);
            ++counter;
        }
    }

    saveContextMenu(forsaving);

    return ret;

}

QStringList GetAndDoStuffContext::getContextMenu() {

#ifdef Q_OS_WIN
    return QStringList();
#endif

    QFile file(ConfigFiles::CONTEXTMENU_FILE());

    if(!file.exists()) return setDefaultContextMenuEntries();

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "GetAndDoStuffContext: ERROR: Can't open contextmenu file" << NL;
        return QStringList();
    }

    QTextStream in(&file);

    QStringList all = in.readAll().split("\n");
    int numRow = 0;
    QStringList ret;
    foreach(QString line, all) {
        QString tmp = line;
        if(numRow == 0) {
            ret.append(tmp.remove(0,1));
            ret.append(line.remove(1,line.length()));
            ++numRow;
        } else if(numRow == 1) {
            ret.append(line);
            ++numRow;
        } else
            numRow = 0;
    }

    return ret;

}

bool GetAndDoStuffContext::checkIfBinaryExists(QString exec) {

#ifdef Q_OS_WIN
    return false;
#endif

    QProcess p;
#if QT_VERSION >= 0x050200
    p.setStandardOutputFile(QProcess::nullDevice());
#endif
    p.start("which " + exec);
    p.waitForFinished();
    return p.exitCode() != 2;
}


qint64 GetAndDoStuffContext::getContextMenuFileModifiedTime() {
    QFileInfo info(ConfigFiles::CONTEXTMENU_FILE());
    return info.lastModified().toMSecsSinceEpoch();
}

void GetAndDoStuffContext::saveContextMenu(QVariantList l) {

#ifdef Q_OS_WIN
    return;
#endif

    QMap<int,QVariantList> adj;

    // We re-order the data (use actual position in list as keys), if not deleted
    foreach(QVariant map, l) {
        QVariantMap data = map.toMap();
        // Invalid data can be caused by deletion
        if(data.value("description").isValid())
            adj.insert(data.value("posInView").toInt(),QList<QVariant>() << data.value("binary") << data.value("description") << data.value("quit"));
    }

    // Open file
    QFile file(ConfigFiles::CONTEXTMENU_FILE());

    if(file.exists() && !file.remove()) {
        LOG << CURDATE << "GetAndDoStuffContext: ERROR: Failed to remove old contextmenu file" << NL;
        return;
    }

    if(!file.open(QIODevice::WriteOnly)) {
        LOG << CURDATE << "GetAndDoStuffContext: ERROR: Failed to write to contextmenu file" << NL;
        return;
    }

    QTextStream out(&file);

    QList<int> keys = adj.keys();
    std::sort(keys.begin(),keys.end());

    // And save data
    for(int i = 0; i < keys.length(); ++i) {
        int key = keys[i];	// We need to check for the actual keys, as some integers might be skipped (due to deletion)
        QString bin = adj[key][0].toString();
        QString desc = adj[key][1].toString();
        // We need to check for that, as deleting an item otherwise could lead to an empty entry
        if(bin != "" && desc != "") {
            if(i != 0) out << "\n\n";
            out << adj[key][2].toInt() << bin << "\n";
            out << desc;
        }
    }

    file.close();

}

#include "shortcuts.h"

Shortcuts::Shortcuts(QObject *parent) : QObject(parent) {

}

QStringList Shortcuts::load() {

    QFile file(ConfigFiles::KEY_SHORTCUTS_FILE());

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << " Shortcuts::load() 1 - ERROR: Unable to open key shortcuts file for reading" << NL;
        return QStringList();
    }

    QStringList ret;

    QTextStream in(&file);
    QStringList cont = in.readAll().split("\n");

    foreach(QString line, cont) {

        if(line.startsWith("Version=") || line.trimmed() == "")
            continue;

        QStringList parts = line.split("::");
        if(parts.length() != 3) {
            LOG << CURDATE << " Shortcuts::load() 2 - ERROR: Invalid shortcuts format: " << line.toStdString() << NL;
            continue;
        }

        QStringList val;
        val << parts.at(1) << parts.at(0) << parts.at(2);

        ret.append(val);

    }

    return ret;

}

QString Shortcuts::convertKeycodeToString(int code) {

    return QKeySequence(code).toString();

}

#include "shortcuts.h"

Shortcuts::Shortcuts(QObject *parent) : QObject(parent) {

}

QStringList Shortcuts::load() {

    QStringList ret;


    QFile fileKeys(ConfigFiles::KEY_SHORTCUTS_FILE());

    if(!fileKeys.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << " Shortcuts::load() 1 - ERROR: Unable to open key shortcuts file for reading" << NL;
        return QStringList();
    }

    QTextStream inKeys(&fileKeys);
    QStringList contKeys = inKeys.readAll().split("\n");

    foreach(QString line, contKeys) {

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

    fileKeys.close();



    QFile fileMouse(ConfigFiles::MOUSE_SHORTCUTS_FILE());

    if(!fileMouse.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << " Shortcuts::load() 1 - ERROR: Unable to open key shortcuts file for reading" << NL;
        return QStringList();
    }

    QTextStream inMouse(&fileMouse);
    QStringList contMouse = inMouse.readAll().split("\n");

    foreach(QString line, contMouse) {

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

    fileMouse.close();



    return ret;

}

QString Shortcuts::convertKeycodeToString(int code) {

    return QKeySequence(code).toString();

}

#include "shortcuts.h"

Shortcuts::Shortcuts(QObject *parent) : QObject(parent) {

}

QStringList Shortcuts::load() {

    QStringList ret;

    QFile file(ConfigFiles::SHORTCUTS_FILE());

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << " Shortcuts::load() 1 - ERROR: Unable to open key shortcuts file for reading" << NL;
        return QStringList();
    }

    QTextStream in(&file);
    QStringList cont = in.readAll().split("\n");

    for(QString line : cont) {

        if(line.startsWith("Version=") || line.trimmed() == "")
            continue;

        QStringList parts = line.split("::");
        if(parts.length() != 3) {
            LOG << CURDATE << " Shortcuts::load() 2 - ERROR: Invalid shortcuts format: " << line.toStdString() << NL;
            continue;
        }

        QStringList val;
        // sh, close, cmd
        val << parts.at(1) << parts.at(0) << parts.at(2);

        ret.append(val);

    }

    file.close();

    return ret;

}

QStringList Shortcuts::loadDefaults() {

    QStringList ret;

    ret.append(QStringList() << "O" << "0" << "__open");

    ret.append(QStringList() << "Ctrl+O" << "0" << "__open");
    ret.append(QStringList() << "Right" << "0" << "__next");
    ret.append(QStringList() << "Space" << "0" << "__next");
    ret.append(QStringList() << "Left" << "0" << "__prev");
    ret.append(QStringList() << "Backspace" << "0" << "__prev");
    ret.append(QStringList() << "Ctrl+F" << "0" << "__filterImages");

    ret.append(QStringList() << "+" << "0" << "__zoomIn");
    ret.append(QStringList() << "=" << "0" << "__zoomIn");
    ret.append(QStringList() << "Ctrl++" << "0" << "__zoomIn");
    ret.append(QStringList() << "Ctrl+=" << "0" << "__zoomIn");
    ret.append(QStringList() << "-" << "0" << "__zoomOut");
    ret.append(QStringList() << "Ctrl+-" << "0" << "__zoomOut");
    ret.append(QStringList() << "0" << "0" << "__zoomReset");
    ret.append(QStringList() << "1" << "0" << "__zoomActual");
    ret.append(QStringList() << "Ctrl+1" << "0" << "__zoomActual");

    ret.append(QStringList() << "R" << "0" << "__rotateR");
    ret.append(QStringList() << "L" << "0" << "__rotateL");
    ret.append(QStringList() << "Ctrl+0" << "0" << "__rotate0");
    ret.append(QStringList() << "Ctrl+H" << "0" << "__flipH");
    ret.append(QStringList() << "Ctrl+V" << "0" << "__flipV");

    ret.append(QStringList() << "Ctrl+X" << "0" << "__scale");
    ret.append(QStringList() << "Ctrl+E" << "0" << "__hideMeta");
    ret.append(QStringList() << "E" << "0" << "__settings");
    ret.append(QStringList() << "I" << "0" << "__about");
    ret.append(QStringList() << "M" << "0" << "__slideshow");
    ret.append(QStringList() << "Shift+M" << "0" << "__slideshowQuick");
    ret.append(QStringList() << "W" << "0" << "__wallpaper");
    ret.append(QStringList() << "S" << "0" << "__stopThb");
    ret.append(QStringList() << "Ctrl+R" << "0" << "__reloadThb");

    ret.append(QStringList() << "F2" << "0" << "__rename");
    ret.append(QStringList() << "Ctrl+C" << "0" << "__copy");
    ret.append(QStringList() << "Ctrl+M" << "0" << "__move");
    ret.append(QStringList() << "Delete" << "0" << "__delete");

    ret.append(QStringList() << "Escape" << "0" << "__hide");
    ret.append(QStringList() << "Q" << "0" << "__close");
    ret.append(QStringList() << "Ctrl+Q" << "0" << "__close");

    ret.append(QStringList() << "Home" << "0" << "__gotoFirstThb");
    ret.append(QStringList() << "End" << "0" << "__gotoLastThb");

    return ret;

}

void Shortcuts::saveShortcuts(QVariantList data) {

    QFile file(ConfigFiles::SHORTCUTS_FILE());
    if(!file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
        LOG << CURDATE << "saveShortcuts(): ERROR: unable to open shortcuts file for saving" << NL;
        return;
    }

    QTextStream out(&file);

    out << QString("Version=%1\n").arg(VERSION);

    for(QVariant entry : data) {

        QVariantList l = entry.toList();

        if(l.length() != 3)
            continue;

        QString key = entry.toList().at(0).toString();
        QString close = entry.toList().at(1).toString();
        QString cmd = entry.toList().at(2).toString();

        if(key != "" || close != "" || cmd != "")
            out << QString("%1::%2::%3\n").arg(close).arg(key).arg(cmd);

    }

    file.close();

}

QString Shortcuts::convertKeycodeToString(int code) {

    return QKeySequence(code).toString();

}

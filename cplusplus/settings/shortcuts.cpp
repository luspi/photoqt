#include "shortcuts.h"
#include <QtDebug>

PQShortcuts::PQShortcuts(QObject *parent) : QObject(parent) {

    saveShortcutsTimer = new QTimer;
    saveShortcutsTimer->setInterval(400);
    saveShortcutsTimer->setSingleShot(true);

    setDefault();
    readShortcuts();

    saveShortcutsTimer->stop();

    connect(saveShortcutsTimer, &QTimer::timeout, this, &PQShortcuts::saveShortcuts);

}

void PQShortcuts::setDefault() {

    shortcuts["__about"] = QStringList() << "I";
    shortcuts["__close"] = QStringList() << "Escape" << "Right Button+SES";
    shortcuts["__copy"] = QStringList() << "Ctrl+C";
    shortcuts["__delete"] = QStringList() << "Delete";
    shortcuts["__filterImages"] = QStringList() << "Ctrl+F";
    shortcuts["__flipH"] = QStringList() << "Ctrl+H";
    shortcuts["__flipV"] = QStringList() << "Ctrl+V";
    shortcuts["__goToFirst"] = QStringList() << "Home" << "Ctrl+Left";
    shortcuts["__goToLast"] = QStringList() << "End";
    shortcuts["__histogram"] = QStringList() << "H";
    shortcuts["__imgurAnonym"] = QStringList() << "Ctrl+Shift+I";
    shortcuts["__keepMetaData"] = QStringList() << "Ctrl+Shift+E";
    shortcuts["__move"] = QStringList() << "Ctrl+M";
    shortcuts["__next"] = QStringList() << "Right" << "Space" << "Right Button+E";
    shortcuts["__open"] = QStringList() << "O" << "Ctrl+O" << "Right Button+WE";
    shortcuts["__playPauseAni"] = QStringList() << "Shift+P";
    shortcuts["__prev"] = QStringList() << "Left" << "Backspace" << "Right Button+W";
    shortcuts["__quickNavigation"] = QStringList() << "Ctrl+N";
    shortcuts["__quit"] = QStringList() << "Q" << "Ctrl+Q";
    shortcuts["__rename"] = QStringList() << "F2";
    shortcuts["__rotate0"] = QStringList() << "Ctrl+0";
    shortcuts["__rotateL"] = QStringList() << "L";
    shortcuts["__rotateR"] = QStringList() << "R";
    shortcuts["__saveAs"] = QStringList() << "Ctrl+Shift+S" << "Ctrl+S";
    shortcuts["__scale"] = QStringList() << "Ctrl+X";
    shortcuts["__settings"] = QStringList() << "P";
    shortcuts["__showFaceTags"] = QStringList() << "Ctrl+Shift+F";
    shortcuts["__showMainMenu"] = QStringList() << "Ctrl+Shift+M";
    shortcuts["__showMetaData"] = QStringList() << "Ctrl+E";
    shortcuts["__showThumbnails"] = QStringList() << "Ctrl+T";
    shortcuts["__slideshow"] = QStringList() << "M";
    shortcuts["__slideshowQuick"] = QStringList() << "Shift+M";
    shortcuts["__tagFaces"] = QStringList() << "F";
    shortcuts["__viewerMode"] = QStringList() << "V";
    shortcuts["__wallpaper"] = QStringList() << "W";
    shortcuts["__zoomActual"] = QStringList() << "1" << "Ctrl+1";
    shortcuts["__zoomIn"] = QStringList() << "+" << "=" << "Keypad++" << "Ctrl++" << "Ctrl+=" << "Ctrl+Wheel Up" << "Wheel Up";
    shortcuts["__zoomOut"] = QStringList() << "-" << "Keypad+-" << "Ctrl+-" << "Ctrl+Wheel Down" << "Wheel Down";
    shortcuts["__zoomReset"] = QStringList() << "0";

}

QStringList PQShortcuts::getCommandForShortcut(QString sh) {

    QMapIterator<QString, QStringList> iter(shortcuts);
    while(iter.hasNext()) {
        iter.next();
        if(iter.value().contains(sh))
            return QStringList() << "0" << iter.key();
    }

    QMapIterator<QString, QStringList> iter2(externalShortcuts);
    while(iter2.hasNext()) {
        iter2.next();
        if(iter2.value().mid(1).contains(sh))
            return QStringList() << iter2.value().at(0) << iter2.key();
    }

    return QStringList() << "" << "";

}

QStringList PQShortcuts::getShortcutsForCommand(QString cmd) {

    if(shortcuts.contains(cmd))
        return QStringList() << "0" << shortcuts[cmd];
    else if(externalShortcuts.contains(cmd))
        return externalShortcuts[cmd];

    return QStringList();

}

QVariantList PQShortcuts::getAllExternalShortcuts() {

    QVariantList ret;

    QMapIterator<QString, QStringList> iter(externalShortcuts);
    while(iter.hasNext()) {
        iter.next();
        ret.append(QStringList() << iter.key() << iter.value());
    }

    return ret;

}

void PQShortcuts::setShortcut(QString cmd, QStringList sh) {

    if(cmd.startsWith("__"))
        shortcuts[cmd] = sh;
    else
        externalShortcuts[cmd] = sh;

    saveShortcutsTimer->start();

}

void PQShortcuts::readShortcuts() {

    QFile file(ConfigFiles::SHORTCUTS_FILE());

    if(file.open(QIODevice::ReadOnly)) {

        QTextStream in(&file);
        QString txt = in.readAll();

        const QStringList parts = txt.split("\n");

        for(const QString &p : parts) {

            if(p.startsWith("Version") || p == "")
                continue;

            QStringList vals = p.split("::");

            if(vals.length() < 3)
                continue;

            const bool close = vals.at(0).toInt();
            const QString cmd = vals.at(1);
            const QStringList sh = vals.mid(2);


            // any valid command will be in the map (from setDefault()).
            // if the key is not there, then this is either a typo or external command that starts with two underscores
            if(cmd.startsWith("__"))
                shortcuts[cmd] = ((sh.length() == 1 && sh[0] == "") ? QStringList() : sh);
            else
                externalShortcuts[cmd] = QStringList() << (close?"1":"0") << sh;

        }

    }

    file.close();

}

void PQShortcuts::saveShortcuts() {

    QString cont = QString("Version=%1\n").arg(VERSION);

    QMapIterator<QString, QStringList> iter(shortcuts);
    while(iter.hasNext()) {
        iter.next();
        cont += QString("0::%1::%2\n").arg(iter.key(), iter.value().join("::"));
    }

    QMapIterator<QString, QStringList> iter2(externalShortcuts);
    while(iter2.hasNext()) {
        iter2.next();
        cont += QString("%1::%2::%3\n").arg(iter2.value().at(0)).arg(iter2.key(), iter2.value().mid(1).join("::"));
    }

    QFile file(ConfigFiles::SHORTCUTS_FILE());
    if(file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {

        QTextStream out(&file);
        out << cont;
        file.close();
    }

}

void PQShortcuts::deleteAllExternalShortcuts() {
    externalShortcuts.clear();
}

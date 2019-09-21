#include "handlingshortcuts.h"
#include <QtDebug>

PQHandlingShortcuts::PQHandlingShortcuts(QObject *parent) : QObject(parent) {}

QVariantList PQHandlingShortcuts::loadFromFile() {

    QVariantList ret;

    QFile file(ConfigFiles::SHORTCUTS_FILE());

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "PQHandlingShortcuts::load() - ERROR: Unable to open key shortcuts file for reading" << NL;
        return QVariantList();
    }

    QTextStream in(&file);
    QStringList cont = in.readAll().split("\n");

    for(QString line : cont) {

        if(line.startsWith("Version=") || line.trimmed() == "")
            continue;

        QStringList parts = line.split("::");
        if(parts.length() != 3) {
            LOG << CURDATE << "PQHandlingShortcuts::load() - ERROR: Invalid shortcuts format: " << line.toStdString() << NL;
            continue;
        }

        // close, sh, cmd
        ret << parts;

    }

    file.close();

    return ret;

}

QString PQHandlingShortcuts::convertKeyCodeToText(int id) {
    QString ret = QKeySequence(id).toString();
    if(ret == "Esc") ret = "Escape";    // Up to v1.7.1 'Escape' was used so we should stick to that
    return ret;
}

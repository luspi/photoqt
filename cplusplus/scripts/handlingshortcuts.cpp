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

void PQHandlingShortcuts::saveToFile(QVariantList lst) {

    QString cont = QString("Version=%1\n").arg(VERSION);
    for(auto l : lst)
        cont += QString("%1::%2::%3\n").arg(l.toList()[0].toString()).arg(l.toList()[1].toString()).arg(l.toList()[2].toString());

    QFile file(ConfigFiles::SHORTCUTS_FILE());

    if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        LOG << CURDATE << "PQHandlingShortcuts::saveToFile() - ERROR: Unable to open key shortcuts file for writing" << NL;
        return;
    }
    QTextStream out(&file);
    out << cont;
    file.close();
}

QString PQHandlingShortcuts::convertKeyCodeToText(int id) {
    QString ret = QKeySequence(id).toString();
    if(ret == "Esc") ret = "Escape";    // Up to v1.7.1 'Escape' was used so we should stick to that
    if(ret == "Del") ret = "Delete";
    return ret;
}

void PQHandlingShortcuts::executeExternalApp(QString cmd, QString filename) {

    QByteArray fn = QByteArray::fromPercentEncoding(filename.toUtf8());

    QProcess *p = new QProcess;
    cmd = cmd.replace("%f", "\"" + fn + "\"");
    cmd = cmd.replace("%u", "\"" + QFileInfo(fn).fileName() + "\"");
    cmd = cmd.replace("%d", "\"" + QFileInfo(fn).absolutePath() + "\"");

    p->startDetached(cmd, QStringList());
    if(p->error() == QProcess::UnknownError)
        p->waitForStarted(2000);

    delete p;

}

QString PQHandlingShortcuts::composeString(Qt::KeyboardModifiers mods, Qt::Key keys) {

    QString combostring = "";

    if(mods & Qt::ControlModifier)
        combostring += "Ctrl+";
    if(mods & Qt::AltModifier)
        combostring += "Alt+";
    if(mods & Qt::ShiftModifier)
        combostring += "Shift+";
    if(mods & Qt::MetaModifier)
        combostring += "Meta+";
    if(mods & Qt::KeypadModifier)
        combostring += "Keypad+";

    switch(keys) {
        case Qt::Key_Control:
        case Qt::Key_Alt:
        case Qt::Key_Shift:
        case Qt::Key_Meta:
            break;
        case Qt::Key_Escape:
            combostring += "Escape";
            break;
        case Qt::Key_Right:
            combostring += "Right";
            break;
        case Qt::Key_Left:
            combostring += "Left";
            break;
        case Qt::Key_Up:
            combostring += "Up";
            break;
        case Qt::Key_Down:
            combostring += "Down";
            break;
        case Qt::Key_Space:
            combostring += "Space";
            break;
        case Qt::Key_Delete:
            combostring += "Delete";
            break;
        case Qt::Key_Home:
            combostring += "Home";
            break;
        case Qt::Key_End:
            combostring += "End";
            break;
        case Qt::Key_PageUp:
            combostring += "Page Up";
            break;
        case Qt::Key_PageDown:
            combostring += "Page Down";
            break;
        case Qt::Key_Insert:
            combostring += "Insert";
            break;
        case Qt::Key_Tab:
            combostring += "Tab";
            break;
        case Qt::Key_Backtab:
            combostring += "Tab";
            break;
        case Qt::Key_Return:
            combostring += "Return";
            break;
        case Qt::Key_Enter:
            combostring += "Enter";
            break;
        case Qt::Key_Pause:
            combostring += "Pause";
            break;
        case Qt::Key_Print:
            combostring += "Print";
            break;
        case Qt::Key_SysReq:
            combostring += "SysReq";
            break;
        case Qt::Key_Clear:
            combostring += "Clear";
            break;
        case Qt::Key_CapsLock:
            combostring += "CapsLock";
            break;
        case Qt::Key_NumLock:
            combostring += "NumLock";
            break;
        case Qt::Key_ScrollLock:
            combostring += "ScrollLock";
            break;
        case Qt::Key_Super_L:
            combostring += "Super L";
            break;
        case Qt::Key_Super_R:
            combostring += "Super R";
            break;
        case Qt::Key_Menu:
            combostring += "Menu";
            break;
        case Qt::Key_Hyper_L:
            combostring += "Hyper L";
            break;
        case Qt::Key_Hyper_R:
            combostring += "Hyper R";
            break;
        case Qt::Key_Help:
            combostring += "Help";
            break;
        case Qt::Key_Direction_L:
            combostring += "Direction L";
            break;
        case Qt::Key_Direction_R:
            combostring += "Direction R";
            break;
        case Qt::Key_F1:
            combostring += "F1";
            break;
        case Qt::Key_F2:
            combostring += "F2";
            break;
        case Qt::Key_F3:
            combostring += "F3";
            break;
        case Qt::Key_F4:
            combostring += "F4";
            break;
        case Qt::Key_F5:
            combostring += "F5";
            break;
        case Qt::Key_F6:
            combostring += "F6";
            break;
        case Qt::Key_F7:
            combostring += "F7";
            break;
        case Qt::Key_F8:
            combostring += "F8";
            break;
        case Qt::Key_F9:
            combostring += "F9";
            break;
        case Qt::Key_F10:
            combostring += "F10";
            break;
        case Qt::Key_F11:
            combostring += "F11";
            break;
        case Qt::Key_F12:
            combostring += "F12";
            break;
        case Qt::Key_F13:
            combostring += "F13";
            break;
        case Qt::Key_F14:
            combostring += "F14";
            break;
        case Qt::Key_F15:
            combostring += "F15";
            break;
        case Qt::Key_F16:
            combostring += "F16";
            break;
        case Qt::Key_F17:
            combostring += "F17";
            break;
        case Qt::Key_F18:
            combostring += "F18";
            break;
        case Qt::Key_F19:
            combostring += "F19";
            break;
        case Qt::Key_F20:
            combostring += "F20";
            break;
        case Qt::Key_F21:
            combostring += "F21";
            break;
        case Qt::Key_F22:
            combostring += "F22";
            break;
        case Qt::Key_F23:
            combostring += "F23";
            break;
        case Qt::Key_F24:
            combostring += "F24";
            break;
        case Qt::Key_F25:
            combostring += "F25";
            break;
        case Qt::Key_F26:
            combostring += "F26";
            break;
        case Qt::Key_F27:
            combostring += "F27";
            break;
        case Qt::Key_F28:
            combostring += "F28";
            break;
        case Qt::Key_F29:
            combostring += "F29";
            break;
        case Qt::Key_F30:
            combostring += "F30";
            break;
        case Qt::Key_F31:
            combostring += "F31";
            break;
        case Qt::Key_F32:
            combostring += "F32";
            break;
        case Qt::Key_F33:
            combostring += "F33";
            break;
        case Qt::Key_F34:
            combostring += "F34";
            break;
        case Qt::Key_F35:
            combostring += "F35";
            break;
        default: {
            if(QKeySequence(keys).toString() != "")
                combostring += QKeySequence(keys).toString();
        }

    }

    return combostring;

}

QString PQHandlingShortcuts::composeDisplayString(QString combo) {

    QString ret;

    if(combo.startsWith("Left Button+") || combo.startsWith("Middle Button+") || combo.startsWith("Right Button+")) {

        QStringList p = combo.split("+");
        ret = p[0] + " + ";

        QStringList dir = p[1].split("", Qt::SkipEmptyParts);
        ret += dir.join("-");

    } else if(combo.contains("+"))
        ret = combo.split("+").join(" + ");
    else
        ret = combo;

    if(ret == "")
        return "...";
    return ret;

}

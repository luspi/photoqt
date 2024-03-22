/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

#include <scripts/pqc_scriptsshortcuts.h>
#include <QtDebug>
#include <QFileInfo>
#include <QProcess>
#include <QDir>
#include <QPoint>
#include <QKeySequence>

PQCScriptsShortcuts::PQCScriptsShortcuts() {}

PQCScriptsShortcuts::~PQCScriptsShortcuts() {}

void PQCScriptsShortcuts::executeExternal(QString exe, QString args, QString currentfile) {

    qDebug() << "args: exe = " << exe;
    qDebug() << "args: args = " << args;
    qDebug() << "args: currentfile = " << currentfile;

    if(exe == "")
        return;

    QFileInfo info(currentfile);
    QStringList argslist;

    args = args.replace("\\space\\", "\\spa|ce\\");
    args = args.replace("\\ ", "\\space\\");

    QStringList argslist_tmp = args.split(" ");

#ifdef Q_OS_WIN
    for(auto &a : argslist_tmp) {
        if(a.contains("%f"))
            a = a.replace("%f", currentfile.replace("/","\\"));
        if(args.contains("%u"))
            a = a.replace("%u", info.fileName().replace("/","\\"));
        if(a.contains("%d"))
            a = a.replace("%d", info.absolutePath().replace("/","\\"));
        a = a.replace("\\space\\", "\\ ");
        a = a.replace("\\spa|ce\\", "\\space\\");
        argslist << a;
    }
#else
    for(auto &a : argslist_tmp) {
        if(a.contains("%f"))
            a = a.replace("%f", currentfile);
        if(args.contains("%u"))
            a = a.replace("%u", info.fileName());
        if(a.contains("%d"))
            a = a.replace("%d", info.absolutePath());
        a = a.replace("\\space\\", " ");
        a = a.replace("\\spa|ce\\", "\\space\\");
        argslist << a;
    }
#endif

    QProcess proc;
    proc.setProgram(QDir::toNativeSeparators(exe));
    proc.setArguments(argslist);

    proc.startDetached();

}

QStringList PQCScriptsShortcuts::analyzeModifier(Qt::KeyboardModifiers mods) {

    QStringList ret;

    if(mods & Qt::ControlModifier)
        ret.append("Ctrl");
    if(mods & Qt::AltModifier)
        ret.append("Alt");
    if(mods & Qt::ShiftModifier)
        ret.append("Shift");
    if(mods & Qt::MetaModifier)
        ret.append("Meta");
    if(mods & Qt::KeypadModifier)
        ret.append("Keypad");

    return ret;

}

QString PQCScriptsShortcuts::analyzeMouseWheel(QPoint angleDelta) {

    QString ret = "";

    if(std::abs(angleDelta.x()) < 2) {
        if(angleDelta.y() < 0)
            ret += "Wheel Down";
        else if(angleDelta.y() > 0)
            ret += "Wheel Up";
    } else {
        if(angleDelta.x() < 0)
            ret += "Wheel Left";
        else if(angleDelta.x() > 0)
            ret += "Wheel Right";
    }

    return ret;

}

QString PQCScriptsShortcuts::analyzeMouseButton(Qt::MouseButton button) {

    QString ret = "";

    switch(button) {

        case Qt::LeftButton:
            ret += "Left Button";
            break;
        case Qt::MiddleButton:
            ret += "Middle Button";
            break;
        case Qt::RightButton:
            ret += "Right Button";
            break;
        case Qt::ForwardButton:
            ret += "Forward Button";
            break;
        case Qt::BackButton:
            ret += "Back Button";
            break;
        case Qt::TaskButton:
            ret += "Task Button";
            break;
        case Qt::ExtraButton4:
            ret += "Button #7";
            break;
        case Qt::ExtraButton5:
            ret += "Button #8";
            break;
        case Qt::ExtraButton6:
            ret += "Button #9";
            break;
        case Qt::ExtraButton7:
            ret += "Button #10";
            break;
        default:
            ret += "Unknown Button";
            break;

    }

    return ret;

}

QString PQCScriptsShortcuts::analyzeMouseDirection(QPoint prevPoint, QPoint curPoint) {

    int threshold = 50;

    int dx = curPoint.x()-prevPoint.x();
    int dy = curPoint.y()-prevPoint.y();
    int distance = std::sqrt(std::pow(dx,2)+std::pow(dy,2));

    int angle = (std::atan2(dy, dx)/M_PI)*180;
        angle = (angle+360)%360;

    if(distance > threshold) {
        if(angle <= 45 || angle > 315)
            return "W";
        else if(angle > 45 && angle <= 135)
            return "N";
        else if(angle > 135 && angle <= 225)
            return "E";
        else if(angle > 225 && angle <= 315)
            return "S";
    }

    return "";

}

QString PQCScriptsShortcuts::analyzeKeyPress(Qt::Key key) {

    switch(key) {
        case Qt::Key_Control:
        case Qt::Key_Alt:
        case Qt::Key_Shift:
        case Qt::Key_Meta:
            break;
        case Qt::Key_Escape:
            return "Esc";
            break;
        case Qt::Key_Right:
            return "Right";
            break;
        case Qt::Key_Left:
            return "Left";
            break;
        case Qt::Key_Up:
            return "Up";
            break;
        case Qt::Key_Down:
            return "Down";
            break;
        case Qt::Key_Space:
            return "Space";
            break;
        case Qt::Key_Delete:
            return "Delete";
            break;
        case Qt::Key_Home:
            return "Home";
            break;
        case Qt::Key_End:
            return "End";
            break;
        case Qt::Key_PageUp:
            return "Page Up";
            break;
        case Qt::Key_PageDown:
            return "Page Down";
            break;
        case Qt::Key_Insert:
            return "Insert";
            break;
        case Qt::Key_Tab:
            return "Tab";
            break;
        case Qt::Key_Backtab:
            return "Tab";
            break;
        case Qt::Key_Return:
            return "Return";
            break;
        case Qt::Key_Enter:
            return "Enter";
            break;
        case Qt::Key_Pause:
            return "Pause";
            break;
        case Qt::Key_Print:
            return "Print";
            break;
        case Qt::Key_SysReq:
            return "SysReq";
            break;
        case Qt::Key_Clear:
            return "Clear";
            break;
        case Qt::Key_CapsLock:
            return "CapsLock";
            break;
        case Qt::Key_NumLock:
            return "NumLock";
            break;
        case Qt::Key_ScrollLock:
            return "ScrollLock";
            break;
        case Qt::Key_Super_L:
            return "Super L";
            break;
        case Qt::Key_Super_R:
            return "Super R";
            break;
        case Qt::Key_Menu:
            return "Menu";
            break;
        case Qt::Key_Hyper_L:
            return "Hyper L";
            break;
        case Qt::Key_Hyper_R:
            return "Hyper R";
            break;
        case Qt::Key_Help:
            return "Help";
            break;
        case Qt::Key_Direction_L:
            return "Direction L";
            break;
        case Qt::Key_Direction_R:
            return "Direction R";
            break;
        case Qt::Key_F1:
            return "F1";
            break;
        case Qt::Key_F2:
            return "F2";
            break;
        case Qt::Key_F3:
            return "F3";
            break;
        case Qt::Key_F4:
            return "F4";
            break;
        case Qt::Key_F5:
            return "F5";
            break;
        case Qt::Key_F6:
            return "F6";
            break;
        case Qt::Key_F7:
            return "F7";
            break;
        case Qt::Key_F8:
            return "F8";
            break;
        case Qt::Key_F9:
            return "F9";
            break;
        case Qt::Key_F10:
            return "F10";
            break;
        case Qt::Key_F11:
            return "F11";
            break;
        case Qt::Key_F12:
            return "F12";
            break;
        case Qt::Key_F13:
            return "F13";
            break;
        case Qt::Key_F14:
            return "F14";
            break;
        case Qt::Key_F15:
            return "F15";
            break;
        case Qt::Key_F16:
            return "F16";
            break;
        case Qt::Key_F17:
            return "F17";
            break;
        case Qt::Key_F18:
            return "F18";
            break;
        case Qt::Key_F19:
            return "F19";
            break;
        case Qt::Key_F20:
            return "F20";
            break;
        case Qt::Key_F21:
            return "F21";
            break;
        case Qt::Key_F22:
            return "F22";
            break;
        case Qt::Key_F23:
            return "F23";
            break;
        case Qt::Key_F24:
            return "F24";
            break;
        case Qt::Key_F25:
            return "F25";
            break;
        case Qt::Key_F26:
            return "F26";
            break;
        case Qt::Key_F27:
            return "F27";
            break;
        case Qt::Key_F28:
            return "F28";
            break;
        case Qt::Key_F29:
            return "F29";
            break;
        case Qt::Key_F30:
            return "F30";
            break;
        case Qt::Key_F31:
            return "F31";
            break;
        case Qt::Key_F32:
            return "F32";
            break;
        case Qt::Key_F33:
            return "F33";
            break;
        case Qt::Key_F34:
            return "F34";
            break;
        case Qt::Key_F35:
            return "F35";
            break;
        default: {
            const QString k = QKeySequence(key).toString();
            if(k != "")
                return k;
        }

    }

    return "";

}

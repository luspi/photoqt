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

    QString ret = "";

    switch(key) {
        case Qt::Key_Control:
        case Qt::Key_Alt:
        case Qt::Key_Shift:
        case Qt::Key_Meta:
            break;
        case Qt::Key_Escape:
            ret += "Esc";
            break;
        case Qt::Key_Right:
            ret += "Right";
            break;
        case Qt::Key_Left:
            ret += "Left";
            break;
        case Qt::Key_Up:
            ret += "Up";
            break;
        case Qt::Key_Down:
            ret += "Down";
            break;
        case Qt::Key_Space:
            ret += "Space";
            break;
        case Qt::Key_Delete:
            ret += "Delete";
            break;
        case Qt::Key_Home:
            ret += "Home";
            break;
        case Qt::Key_End:
            ret += "End";
            break;
        case Qt::Key_PageUp:
            ret += "Page Up";
            break;
        case Qt::Key_PageDown:
            ret += "Page Down";
            break;
        case Qt::Key_Insert:
            ret += "Insert";
            break;
        case Qt::Key_Tab:
            ret += "Tab";
            break;
        case Qt::Key_Backtab:
            ret += "Tab";
            break;
        case Qt::Key_Return:
            ret += "Return";
            break;
        case Qt::Key_Enter:
            ret += "Enter";
            break;
        case Qt::Key_Pause:
            ret += "Pause";
            break;
        case Qt::Key_Print:
            ret += "Print";
            break;
        case Qt::Key_SysReq:
            ret += "SysReq";
            break;
        case Qt::Key_Clear:
            ret += "Clear";
            break;
        case Qt::Key_CapsLock:
            ret += "CapsLock";
            break;
        case Qt::Key_NumLock:
            ret += "NumLock";
            break;
        case Qt::Key_ScrollLock:
            ret += "ScrollLock";
            break;
        case Qt::Key_Super_L:
            ret += "Super L";
            break;
        case Qt::Key_Super_R:
            ret += "Super R";
            break;
        case Qt::Key_Menu:
            ret += "Menu";
            break;
        case Qt::Key_Hyper_L:
            ret += "Hyper L";
            break;
        case Qt::Key_Hyper_R:
            ret += "Hyper R";
            break;
        case Qt::Key_Help:
            ret += "Help";
            break;
        case Qt::Key_Direction_L:
            ret += "Direction L";
            break;
        case Qt::Key_Direction_R:
            ret += "Direction R";
            break;
        case Qt::Key_F1:
            ret += "F1";
            break;
        case Qt::Key_F2:
            ret += "F2";
            break;
        case Qt::Key_F3:
            ret += "F3";
            break;
        case Qt::Key_F4:
            ret += "F4";
            break;
        case Qt::Key_F5:
            ret += "F5";
            break;
        case Qt::Key_F6:
            ret += "F6";
            break;
        case Qt::Key_F7:
            ret += "F7";
            break;
        case Qt::Key_F8:
            ret += "F8";
            break;
        case Qt::Key_F9:
            ret += "F9";
            break;
        case Qt::Key_F10:
            ret += "F10";
            break;
        case Qt::Key_F11:
            ret += "F11";
            break;
        case Qt::Key_F12:
            ret += "F12";
            break;
        case Qt::Key_F13:
            ret += "F13";
            break;
        case Qt::Key_F14:
            ret += "F14";
            break;
        case Qt::Key_F15:
            ret += "F15";
            break;
        case Qt::Key_F16:
            ret += "F16";
            break;
        case Qt::Key_F17:
            ret += "F17";
            break;
        case Qt::Key_F18:
            ret += "F18";
            break;
        case Qt::Key_F19:
            ret += "F19";
            break;
        case Qt::Key_F20:
            ret += "F20";
            break;
        case Qt::Key_F21:
            ret += "F21";
            break;
        case Qt::Key_F22:
            ret += "F22";
            break;
        case Qt::Key_F23:
            ret += "F23";
            break;
        case Qt::Key_F24:
            ret += "F24";
            break;
        case Qt::Key_F25:
            ret += "F25";
            break;
        case Qt::Key_F26:
            ret += "F26";
            break;
        case Qt::Key_F27:
            ret += "F27";
            break;
        case Qt::Key_F28:
            ret += "F28";
            break;
        case Qt::Key_F29:
            ret += "F29";
            break;
        case Qt::Key_F30:
            ret += "F30";
            break;
        case Qt::Key_F31:
            ret += "F31";
            break;
        case Qt::Key_F32:
            ret += "F32";
            break;
        case Qt::Key_F33:
            ret += "F33";
            break;
        case Qt::Key_F34:
            ret += "F34";
            break;
        case Qt::Key_F35:
            ret += "F35";
            break;
        default: {
            const QString k = QKeySequence(key).toString();
            if(k != "")
                ret += k;
        }

    }

    return ret;

}

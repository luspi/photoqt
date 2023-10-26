#include <scripts/pqc_scriptsshortcuts.h>
#include <QtDebug>
#include <QFileInfo>
#include <QProcess>
#include <QDir>

PQCScriptsShortcuts::PQCScriptsShortcuts() {

    //: Refers to a keyboard modifier
    keyStrings.insert("alt", tr("Alt"));
    //: Refers to a keyboard modifier
    keyStrings.insert("ctrl", tr("Ctrl"));
    //: Refers to a keyboard modifier
    keyStrings.insert("shift", tr("Shift"));
    //: Refers to one of the keys on the keyboard
    keyStrings.insert("page up", tr("Page Up"));
    //: Refers to one of the keys on the keyboard
    keyStrings.insert("page down", tr("Page Down"));
    //: Refers to the key that usually has the Windows symbol on it
    keyStrings.insert("meta", tr("Meta"));
    //: Refers to the key that triggers the number block on keyboards
    keyStrings.insert("keypad", tr("Keypad"));
    //: Refers to one of the keys on the keyboard
    keyStrings.insert("escape", tr("Escape"));
    //: Refers to one of the arrow keys on the keyboard
    keyStrings.insert("right", tr("Right"));
    //: Refers to one of the arrow keys on the keyboard
    keyStrings.insert("left", tr("Left"));
    //: Refers to one of the arrow keys on the keyboard
    keyStrings.insert("up", tr("Up"));
    //: Refers to one of the arrow keys on the keyboard
    keyStrings.insert("down", tr("Down"));
    //: Refers to one of the keys on the keyboard
    keyStrings.insert("space", tr("Space"));
    //: Refers to one of the keys on the keyboard
    keyStrings.insert("delete", tr("Delete"));
    //: Refers to one of the keys on the keyboard
    keyStrings.insert("backspace", tr("Backspace"));
    //: Refers to one of the keys on the keyboard
    keyStrings.insert("home", tr("Home"));
    //: Refers to one of the keys on the keyboard
    keyStrings.insert("end", tr("End"));
    //: Refers to one of the keys on the keyboard
    keyStrings.insert("insert", tr("Insert"));
    //: Refers to one of the keys on the keyboard
    keyStrings.insert("tab", tr("Tab"));
    //: Return refers to the enter key of the number block - please try to make the translations of Return and Enter (the main button) different if possible!
    keyStrings.insert("return", tr("Return"));
    //: Enter refers to the main enter key - please try to make the translations of Return (in the number block) and Enter different if possible!
    keyStrings.insert("enter", tr("Enter"));

    //: Refers to a mouse button
    mouseStrings.insert("left button", tr("Left Button"));
    //: Refers to a mouse button
    mouseStrings.insert("right button", tr("Right Button"));
    //: Refers to a mouse button
    mouseStrings.insert("middle button", tr("Middle Button"));
    //: Refers to a mouse button
    mouseStrings.insert("back button", tr("Back Button"));
    //: Refers to a mouse button
    mouseStrings.insert("forward button", tr("Forward Button"));
    //: Refers to a mouse button
    mouseStrings.insert("task button", tr("Task Button"));
    //: Refers to a mouse button
    mouseStrings.insert("button #7", tr("Button #7"));
    //: Refers to a mouse button
    mouseStrings.insert("button #8", tr("Button #8"));
    //: Refers to a mouse button
    mouseStrings.insert("button #9", tr("Button #9"));
    //: Refers to a mouse button
    mouseStrings.insert("button #10", tr("Button #10"));
    //: Refers to a mouse event
    mouseStrings.insert("double click", tr("Double Click"));
    //: Refers to the mouse wheel
    mouseStrings.insert("wheel up", tr("Wheel Up"));
    //: Refers to the mouse wheel
    mouseStrings.insert("wheel down", tr("Wheel Down"));
    //: Refers to the mouse wheel
    mouseStrings.insert("wheel left", tr("Wheel Left"));
    //: Refers to the mouse wheel
    mouseStrings.insert("wheel right", tr("Wheel Right"));
    //: Refers to a direction of the mouse when performing a mouse gesture
    mouseStrings.insert("east", tr("East"));
    //: Refers to a direction of the mouse when performing a mouse gesture
    mouseStrings.insert("south", tr("South"));
    //: Refers to a direction of the mouse when performing a mouse gesture
    mouseStrings.insert("west", tr("West"));
    //: Refers to a direction of the mouse when performing a mouse gesture
    mouseStrings.insert("north", tr("North"));

}

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

QString PQCScriptsShortcuts::getTranslation(QString key) {
    key = key.toLower().trimmed();
    if(keyStrings.contains(key))
        return keyStrings[key];
    if(mouseStrings.contains(key))
        return mouseStrings[key];
    return key;
}

QString PQCScriptsShortcuts::translateShortcut(QString combo) {

    qDebug() << "args: combo =" << combo;

    combo = combo.replace("++","+PLUS");
    if(combo == "+") combo = "PLUS";

    QStringList parts = combo.split("+");

    QString ret = "";
    for(const auto &i : std::as_const(parts)) {
        if(ret != "")
            ret += " + ";
        if(i == "")
            continue;
        if(i == "PLUS")
            ret += "+";
        else
            ret += getTranslation(i);
    }

    combo = combo.toLower();
    if(combo.contains("left button") || combo.contains("right button")) {

        QStringList p = ret.split("+");
        QString lastItem = p[p.length()-1];
        ret = "";
        for(const auto &j : std::as_const(p)) {
            if(ret != "") ret += " + ";
            ret += j;
        }

        for(int k = 0; k < lastItem.length(); ++k) {
            if(lastItem[k] == 'E')
                ret += "→";
            else if(lastItem[k] == 'S')
                ret += "↓";
            else if(lastItem[k] == 'W')
                ret += "←";
            else if(lastItem[k] == 'N')
                ret += "↑";
        }
        if(ret.endsWith("-"))
            ret = ret.sliced(0, ret.length()-1);

    }

    return ret;

}

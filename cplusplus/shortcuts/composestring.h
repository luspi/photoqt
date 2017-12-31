#ifndef COMPOSESTRING_H
#define COMPOSESTRING_H

#include <QKeyEvent>

class ComposeString {

public:
    static QString compose(QKeyEvent *e) {

        QString combostring = getModifiers(e);

        if(e->key() == Qt::Key_Escape)
            combostring += "Escape";
        else if(e->key() == Qt::Key_Right)
            combostring += "Right";
        else if(e->key() == Qt::Key_Left)
            combostring += "Left";
        else if(e->key() == Qt::Key_Up)
            combostring += "Up";
        else if(e->key() == Qt::Key_Down)
            combostring += "Down";
        else if(e->key() == Qt::Key_Space)
            combostring += "Space";
        else if(e->key() == Qt::Key_Delete)
            combostring += "Delete";
        else if(e->key() == Qt::Key_Home)
            combostring += "Home";
        else if(e->key() == Qt::Key_End)
            combostring += "End";
        else if(e->key() == Qt::Key_PageUp)
            combostring += "Page Up";
        else if(e->key() == Qt::Key_PageDown)
            combostring += "Page Down";
        else if(e->key() == Qt::Key_Insert)
            combostring += "Insert";
        else if(e->key() == Qt::Key_Tab || e->key() == Qt::Key_Backtab)
            combostring += "Tab";
        else if(e->key() == Qt::Key_Return)
            combostring += "Return";
        else if(e->key() == Qt::Key_Enter)
            combostring += "Enter";
        else if(e->key() == Qt::Key_F1)
            combostring += "F1";
        else if(e->key() == Qt::Key_F2)
            combostring += "F2";
        else if(e->key() == Qt::Key_F3)
            combostring += "F3";
        else if(e->key() == Qt::Key_F4)
            combostring += "F4";
        else if(e->key() == Qt::Key_F5)
            combostring += "F5";
        else if(e->key() == Qt::Key_F6)
            combostring += "F6";
        else if(e->key() == Qt::Key_F7)
            combostring += "F7";
        else if(e->key() == Qt::Key_F8)
            combostring += "F8";
        else if(e->key() == Qt::Key_F9)
            combostring += "F9";
        else if(e->key() == Qt::Key_F10)
            combostring += "F10";
        else if(e->key() == Qt::Key_F11)
            combostring += "F11";
        else if(e->key() == Qt::Key_F12)
            combostring += "F12";
        else if(e->text().length() > 0)
            combostring += QKeySequence(e->key()).toString();

        return combostring;

    }

    static QString getModifiers(QKeyEvent *e) {

        QString modstring = "";

        if(e->modifiers() & Qt::ControlModifier)
            modstring += "Ctrl+";
        if(e->modifiers() & Qt::AltModifier)
            modstring += "Alt+";
        if(e->modifiers() & Qt::ShiftModifier)
            modstring += "Shift+";
        if(e->modifiers() & Qt::MetaModifier)
            modstring += "Meta+";
        if(e->modifiers() & Qt::KeypadModifier)
            modstring += "Keypad+";

        return modstring;

    }

};


#endif // COMPOSESTRING_H

#ifndef SHORTCUTS_H
#define SHORTCUTS_H

#include "../logger.h"
#include <QKeyEvent>
#include <QtDebug>

class Shortcuts {

public:
	QString handleKeyPress(QKeyEvent *e) {

		QString txt = "";
		bool isvalid = false;

		if(e->modifiers() & Qt::CTRL) {
			isvalid = true;
			txt += "Ctrl+";
		}
		if(e->modifiers() & Qt::ALT) {
			isvalid = true;
			txt += "Alt+";
		}
		if(e->modifiers() & Qt::SHIFT) {
			isvalid = true;
			txt += "Shift+";
		}
		if(e->modifiers() & Qt::META) {
			isvalid = true;
			txt += "Meta+";
		}
		if(e->modifiers() & Qt::KeypadModifier) {
			isvalid = true;
			txt += "Keypad+";
		}
		if(e->key() == Qt::Key_Escape) {
			isvalid = true;
			txt += "Escape";
		} else if(e->key() == Qt::Key_Right) {
			isvalid = true;
			txt += "Right";
		} else if(e->key() == Qt::Key_Left) {
			isvalid = true;
			txt += "Left";
		} else if(e->key() == Qt::Key_Up) {
			isvalid = true;
			txt += "Up";
		} else if(e->key() == Qt::Key_Down) {
			isvalid = true;
			txt += "Down";
		} else if(e->key() == Qt::Key_Space) {
			isvalid = true;
			txt += "Space";
		} else if(e->key() == Qt::Key_Delete) {
			isvalid = true;
			txt += "Delete";
		} else if(e->key() == Qt::Key_Home) {
			isvalid = true;
			txt += "Home";
		} else if(e->key() == Qt::Key_End) {
			isvalid = true;
			txt += "End";
		} else if(e->key() == Qt::Key_PageUp) {
			isvalid = true;
			txt += "Page Up";
		} else if(e->key() == Qt::Key_PageDown) {
			txt += "Page Down";
			isvalid = true;
		} else if(e->key() == Qt::Key_Insert) {
			isvalid = true;
			txt += "Insert";
		} else if(e->key() == Qt::Key_Tab || e->key() == Qt::Key_Backtab) {
			isvalid = true;
			txt += "Tab";
		} else if(e->key() == Qt::Key_Return) {
			isvalid = true;
			txt += "Return";
		} else if(e->key() == Qt::Key_Enter) {
			isvalid = true;
			txt += "Enter";
        // Fis key detection
        } else if(e->key() != Qt::Key_Control && e->key() != Qt::Key_Alt && e->key() != Qt::Key_Shift
                  && e->key() != Qt::Key_AltGr && e->key() != Qt::Key_Meta && e->key() != Qt::KeypadModifier) {
			isvalid = true;
			txt += QKeySequence(e->key()).toString();
		}

		return (isvalid ? txt : "");

	}

};


#endif // SHORTCUTS_H

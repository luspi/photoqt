#ifndef KEYMODIFIER_H
#define KEYMODIFIER_H

#include <QKeyEvent>

namespace KeyModifier {

	static QString extract_(Qt::KeyboardModifiers keymods) {

		QStringList mods;
		bool isvalid = false;

		if(keymods & Qt::CTRL) {
			isvalid = true;
			mods.append("Ctrl");
		}
		if(keymods & Qt::ALT) {
			isvalid = true;
			mods.append("Alt");
		}
		if(keymods & Qt::SHIFT) {
			isvalid = true;
			mods.append("Shift");
		}
		if(keymods & Qt::META) {
			isvalid = true;
			mods.append("Meta");
		}
		if(keymods & Qt::KeypadModifier) {
			isvalid = true;
			mods.append("Keypad");
		}

		return (isvalid ? mods.join("+") : "");

	}

	static QString extract(QKeyEvent *e) {
		return extract_(e->modifiers());
	}
	static QString extract(QTouchEvent *e) {
		return extract_(e->modifiers());
	}
	static QString extract(QMouseEvent *e) {
		return extract_(e->modifiers());
	}
	static QString extract(QEvent *e) {
		return extract_(((QKeyEvent*)e)->modifiers());
	}

}


#endif // KEYMODIFIER_H

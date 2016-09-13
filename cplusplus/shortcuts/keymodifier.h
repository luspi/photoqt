#ifndef KEYMODIFIER_H
#define KEYMODIFIER_H

#include "../logger.h"
#include <QKeyEvent>

namespace KeyModifier {

	static QString extract(QKeyEvent *e) {

		QStringList mods;
		bool isvalid = false;

		if(e->modifiers() & Qt::CTRL) {
			isvalid = true;
			mods.append("Ctrl");
		}
		if(e->modifiers() & Qt::ALT) {
			isvalid = true;
			mods.append("Alt");
		}
		if(e->modifiers() & Qt::SHIFT) {
			isvalid = true;
			mods.append("Shift");
		}
		if(e->modifiers() & Qt::META) {
			isvalid = true;
			mods.append("Meta");
		}
		if(e->modifiers() & Qt::KeypadModifier) {
			isvalid = true;
			mods.append("Keypad");
		}

		return (isvalid ? mods.join("+") : "");

	}

}


#endif // KEYMODIFIER_H

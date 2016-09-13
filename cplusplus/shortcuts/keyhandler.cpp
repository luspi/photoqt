#include "keyhandler.h"

KeyHandler::KeyHandler(QObject *parent) : QObject(parent) {
	combo = "";
}

bool KeyHandler::handle(QEvent *e) {

	if(e->type() == QEvent::KeyPress) {
		updateCombo((QKeyEvent*)e);
		return true;
	} else if(e->type() == QEvent::KeyRelease) {
		finishedCombo();
		return true;
	}

	return false;

}

void KeyHandler::updateCombo(QKeyEvent *e) {

	combo = KeyModifier::extract(e);

	bool isvalid = false;
	if(combo != "") {
		isvalid = true;
		combo += "+";
	}

	if(e->key() == Qt::Key_Escape) {
		isvalid = true;
		combo += "Escape";
	} else if(e->key() == Qt::Key_Right) {
		isvalid = true;
		combo += "Right";
	} else if(e->key() == Qt::Key_Left) {
		isvalid = true;
		combo += "Left";
	} else if(e->key() == Qt::Key_Up) {
		isvalid = true;
		combo += "Up";
	} else if(e->key() == Qt::Key_Down) {
		isvalid = true;
		combo += "Down";
	} else if(e->key() == Qt::Key_Space) {
		isvalid = true;
		combo += "Space";
	} else if(e->key() == Qt::Key_Delete) {
		isvalid = true;
		combo += "Delete";
	} else if(e->key() == Qt::Key_Home) {
		isvalid = true;
		combo += "Home";
	} else if(e->key() == Qt::Key_End) {
		isvalid = true;
		combo += "End";
	} else if(e->key() == Qt::Key_PageUp) {
		isvalid = true;
		combo += "Page Up";
	} else if(e->key() == Qt::Key_PageDown) {
		isvalid = true;
		combo += "Page Down";
	} else if(e->key() == Qt::Key_Insert) {
		isvalid = true;
		combo += "Insert";
	} else if(e->key() == Qt::Key_Tab || e->key() == Qt::Key_Backtab) {
		isvalid = true;
		combo += "Tab";
	} else if(e->key() == Qt::Key_Return) {
		isvalid = true;
		combo += "Return";
	} else if(e->key() == Qt::Key_Enter) {
		isvalid = true;
		combo += "Enter";
	// Fis key detection
	} else if(e->key() != Qt::Key_Control && e->key() != Qt::Key_Alt && e->key() != Qt::Key_Shift
				&& e->key() != Qt::Key_AltGr && e->key() != Qt::Key_Meta && e->key() != Qt::KeypadModifier) {
		isvalid = true;
		combo += QKeySequence(e->key()).toString();
	}

	emit receivedKeyEvent(isvalid ? combo : "");

}

void KeyHandler::finishedCombo() {
	emit receivedFinishedCombo(combo);
}

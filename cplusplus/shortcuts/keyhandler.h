#ifndef KEYHANDLER_H
#define KEYHANDLER_H

#include "../logger.h"
#include "keymodifier.h"
#include <QKeyEvent>

class KeyHandler : public QObject {

	Q_OBJECT

public:

	explicit KeyHandler(QObject *parent = 0);

	bool handle(QEvent *e);
	void updateCombo(QKeyEvent *e);

private:
	QString combo;

signals:
	void receivedKeyEvent(QString combo);

};


#endif // KEYHANDLER_H

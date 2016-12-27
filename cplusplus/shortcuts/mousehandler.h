/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef MOUSEHANDLER_H
#define MOUSEHANDLER_H

#include <QtDebug>
#include <QMouseEvent>
#include <QTime>
#include <cmath>
#include "keymodifier.h"
#include "mousebutton.h"
#include "../settings/settings.h"

class MouseHandler : public QObject {

	Q_OBJECT

public:
	explicit MouseHandler(QObject *parent = 0);
	~MouseHandler();

	// Handle touch event -> call respective handler function
	bool handle(QEvent *e);

	bool isDetecting() { return detecting; }
	void abort() { gestureCancelled(); }

private:

	// Some variables handling the movement
	QStringList gesturePath;
	QList<QPoint> gesturePathPts;
	int threshold;
	qint64 startTime;

	QString button;
	int angleDelta;

	bool detecting;

	int numButtonClicked;

	void gestureStarted(QMouseEvent *e);
	void gestureUpdated(QMouseEvent *e);
	void gestureEnded(QEvent *e);
	void gestureCancelled();

	Settings *settings;

signals:
	void updatedMouseEvent(QString button, QStringList gesture, QString modifiers);
	void finishedMouseEvent(QPoint start, QPoint end, qint64 duration, QString button, QStringList gesture, int wheelAngleDelta, QString modifiers);
	void setImageInteractiveMode(bool enabled);

};

#endif

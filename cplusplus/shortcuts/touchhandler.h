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

#ifndef TOUCHHANDLER_H
#define TOUCHHANDLER_H

#include <QtDebug>
#include <QTouchEvent>
#include <QTime>
#include <cmath>
#include <QTimer>
#include "../settings/settings.h"

class TouchHandler : public QObject {

    Q_OBJECT

public:
    explicit TouchHandler(QObject *parent = 0);
    ~TouchHandler();

    // Handle touch event -> call respective handler function
    bool handle(QEvent *e);
    bool isTouchGestureDetecting() { return amDetecting; }

private:

    // Some variables handling the movement
    QList<QStringList> touchPath;
    QList<QList<QTouchEvent::TouchPoint> > touchPathPts;
    int threshold;
    qint64 startTime;
    bool amDetecting;
    int numFingers;

    bool touchFinished;

    int gestureTimeoutMs;

    QPointF gestureCenterPointStart;
    QPointF gestureCenterPointEnd;

    // A touch has been started -> reset variables
    void touchStarted(QTouchEvent *e);

    // Update to touch
    void touchUpdated(QTouchEvent *e);

    // A gesture has been finished
    void touchEnded(QTouchEvent *);

    // A gesture has been cancelled
    void touchCancelled();

    QVariantList analyseGestureUpToNow();

    Settings *settings;

private slots:
    void resetAmDetectingVariable();

signals:
    void updatedTouchEvent(QPointF start, QPointF end, QString type, unsigned int numFingers, qint64 duration, QStringList path);
    void receivedTouchEvent(QPointF start, QPointF end, QString type, unsigned int numFingers, qint64 duration, QStringList path);
    void setImageInteractiveMode(bool enabled);

};

#endif // TOUCHHANDLER_H

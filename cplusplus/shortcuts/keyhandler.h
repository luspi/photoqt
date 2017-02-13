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

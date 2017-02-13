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

/**********************************************************/
/* CODE INSPIRED BY QT SYSTEM FILE qquicktooltip_p.h FILE */
/**********************************************************/

#ifndef TOOLTIP_H
#define TOOLTIP_H

#include <QObject>
#include <QPointF>
#include <QQuickItem>
#include <QToolTip>

class ToolTip : public QObject {

    Q_OBJECT

public:
    ToolTip(QObject *parent = 0);

    Q_INVOKABLE void showText(QQuickItem *item, const QPointF &pos, const QString &text);
    Q_INVOKABLE void hideText();
    Q_INVOKABLE void setBackgroundColor(int r, int g, int b, int a = 255);
    Q_INVOKABLE void setBackgroundColor(QString col);
    Q_INVOKABLE void setTextColor(int r, int g, int b, int a = 255);
    Q_INVOKABLE void setTextColor(QString col);

private:
    void _setTextColor(QColor col);
    void _setBackgroundColor(QColor col);

};

#endif // TOOLTIP_H

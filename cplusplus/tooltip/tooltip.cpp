/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include "tooltip.h"
#include <QQuickWindow>
#include <QQuickRenderControl>

ToolTip::ToolTip(QObject *parent) : QObject(parent) { }

void ToolTip::showText(QQuickItem *item, const QPointF &pos, const QString &str) {
    QPoint quickWidgetOffsetInTlw;
    QWindow *renderWindow = QQuickRenderControl::renderWindowFor(item->window(), &quickWidgetOffsetInTlw);
    QWindow *window = renderWindow ? renderWindow : item->window();
    const QPoint offsetInQuickWidget = item->mapToScene(pos).toPoint();
    const QPoint mappedPos = window->mapToGlobal(offsetInQuickWidget + quickWidgetOffsetInTlw);
    QToolTip::showText(mappedPos, str);
}

void ToolTip::hideText() {
    QToolTip::hideText();
}

void ToolTip::setBackgroundColor(int r, int g, int b, int a) {
    _setBackgroundColor(QColor(r,g,b,a));
}

void ToolTip::setBackgroundColor(QString col) {
    _setBackgroundColor(QColor(col));
}

void ToolTip::setTextColor(int r, int g, int b, int a) {
    _setTextColor(QColor(r,g,b,a));
}

void ToolTip::setTextColor(QString col) {
    _setTextColor(QColor(col));
}

void ToolTip::_setTextColor(QColor col) {
    QPalette pal = QToolTip::palette();
    pal.setColor(QPalette::ToolTipText, col);
    QToolTip::setPalette(pal);
}

void ToolTip::_setBackgroundColor(QColor col) {
    QPalette pal = QToolTip::palette();
    pal.setColor(QPalette::ToolTipBase, col);
    QToolTip::setPalette(pal);
}

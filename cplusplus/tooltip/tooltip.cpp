/**********************************************************/
/* CODE INSPIRED BY QT SYSTEM FILE qquicktooltip.cpp FILE */
/**********************************************************/

#include "tooltip.h"
#include <QQuickWindow>
#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
    #include <QQuickRenderControl>
#endif

ToolTip::ToolTip(QObject *parent) : QObject(parent) { }

void ToolTip::showText(QQuickItem *item, const QPointF &pos, const QString &str) {
    QPoint quickWidgetOffsetInTlw;
#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
    QWindow *renderWindow = QQuickRenderControl::renderWindowFor(item->window(), &quickWidgetOffsetInTlw);
    QWindow *window = renderWindow ? renderWindow : item->window();
#else
    QWindow *window = item->window();
#endif
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

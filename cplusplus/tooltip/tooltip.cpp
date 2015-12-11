/**********************************************************/
/* CODE INSPIRED BY QT SYSTEM FILE qquicktooltip.cpp FILE */
/**********************************************************/

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

//void ToolTip::setBackgroundColor(int r, int g, int b, int a) {
void ToolTip::setBackgroundColor(QString col) {
	QPalette pal = QToolTip::palette();
//	pal.setColor(QPalette::ToolTipBase, QColor(r,g,b,a));
	pal.setColor(QPalette::ToolTipBase, QColor(col));
	QToolTip::setPalette(pal);
}

//void ToolTip::setTextColor(int r, int g, int b, int a) {
void ToolTip::setTextColor(QString col) {
	QPalette pal = QToolTip::palette();
//	pal.setColor(QPalette::ToolTipText, QColor(r,g,b,a));
	pal.setColor(QPalette::ToolTipText, QColor(col));
	QToolTip::setPalette(pal);
}

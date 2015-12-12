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

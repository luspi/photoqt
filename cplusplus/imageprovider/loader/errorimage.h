#ifndef LOADIMAGE_ERROR_H
#define LOADIMAGE_ERROR_H

#include <QImage>
#include <QTextDocument>
#include "../../logger.h"

class ErrorImage {

public:

	static QImage load(QString errormessage) {
		QPixmap pix(":/img/plainerrorimg.png");
		QPainter paint(&pix);
		QTextDocument txt;
		txt.setHtml(QString("<center><div style=\"text-align: center; font-size: 12pt; font-wight: bold; color: white; background: none;\"><b>ERROR LOADING IMAGE</b><br><br><bR>%1</div></center>").arg(errormessage));
		paint.translate(100,150);
		txt.setTextWidth(440);
		txt.drawContents(&paint);
		paint.end();
		return pix.toImage();
	}

};

#endif // LOADIMAGE_ERROR_H

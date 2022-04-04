#include "errorimage.h"

PQLoadImageErrorImage::PQLoadImageErrorImage() {}

QImage PQLoadImageErrorImage::load(QString errormessage) {
    QPixmap pix(":/image/plainerrorimg.png");
    QPainter paint(&pix);
    QTextDocument txt;
    txt.setHtml("<div align='center' style='color: white; font-size: 20pt'><b>Image failed to load</b></div><br><div align='center' style='color: white; font-size: 15pt'>" + errormessage + "</div>");
    txt.setTextWidth(800);
    paint.translate(0,(600-txt.size().height())/2.0);
    QPen pen;
    pen.setColor(Qt::white);
    pen.setWidth(30);
    paint.setPen(pen);
    txt.drawContents(&paint);
    paint.end();
    QImage pix2img = pix.toImage();
    pix2img.setText("error", "error");
    pix2img.setText("", "error");
    return pix2img;
}

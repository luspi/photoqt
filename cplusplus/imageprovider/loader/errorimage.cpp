#include "errorimage.h"

//QImage PErrorImage::load(QString errormessage) {
//    QPixmap pix(":/img/plainerrorimg.png");
//    QPainter paint(&pix);
//    QTextDocument txt;
//    txt.setHtml("<center><div style=\"text-align: center; font-size: 12pt; font-wight: bold; color: white; background: none;\">" +
//                QString("<b>ERROR LOADING IMAGE</b><br><br><bR>%1</div></center>").arg(errormessage));
//    paint.translate(100,150);
//    txt.setTextWidth(440);
//    txt.drawContents(&paint);
//    paint.end();
//    QImage pix2img = pix.toImage();
//    pix2img.setText("error", "error");
//    return pix2img;
//}

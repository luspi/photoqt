#ifndef PQLOADIMAGEVIDEO_H
#define PQLOADIMAGEVIDEO_H

#include <QImage>
#include <QProcess>
#include <QPixmap>
#include <QPainter>

#include "../../logger.h"
#include "../../settings/settings.h"

class PQLoadImageVideo {

public:
    PQLoadImageVideo() {
        errormsg = "";
    }

    QImage load(QString filename, QSize maxSize, QSize *origSize) {

        errormsg = "";

        QImage img;

        if(PQSettings::get().getVideoThumbnailer() == "ffmpegthumbnailer") {

            // the temp image thumbnail path (incl random int)
            QString tmp_path = QString("%1/photoqt_videothumb_%2.jpg").arg(QDir::tempPath()).arg(rand());

            // create thumbnail using ffmpegthumbnailer
            QProcess proc;
            proc.execute("ffmpegthumbnailer", QStringList() << "-i" << filename << "-s" << QString::number(maxSize.width()) << "-o" << tmp_path);

            // thumbnail and film border pixmap
            QPixmap thumb(tmp_path);
            QPixmap border(":/image/filmborder.png");

            // create painter (part opaque)
            QPainter paint(&thumb);
            paint.setOpacity(0.5);

            // add border left and right of thumbnail
            paint.drawPixmap(QRectF(0, 0, 20, thumb.height()), border, QRectF(0, 0, 20, thumb.height()));
            paint.drawPixmap(QRectF(thumb.width()-20, 0, 20, thumb.height()), border, QRectF(0, 0, 20, thumb.height()));

            // done
            paint.end();

            // remove temporary thumbnail file
            QFile file(tmp_path);
            file.remove();

            // store in return variable
            img = thumb.toImage();

        } else {
            qDebug() << "unknown video thumbnailer used:" << PQSettings::get().getVideoThumbnailer();
        }

        return img;

    }

    QString errormsg;

};

#endif // PQLOADIMAGEVIDEO_H

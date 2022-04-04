#include "loadimage_video.h"

PQLoadImageVideo::PQLoadImageVideo() {
    errormsg = "";
}

QImage PQLoadImageVideo::load(QString filename, QSize maxSize, QSize *) {

    errormsg = "";

#ifdef Q_OS_LINUX

    if(PQSettings::get()["filetypesVideoThumbnailer"].toString() == "ffmpegthumbnailer") {

        // the temp image thumbnail path (incl random int)
        QString tmp_path = QString("%1/photoqt_videothumb_%2.jpg").arg(QDir::tempPath()).arg(rand());

        // create thumbnail using ffmpegthumbnailer
        QProcess proc;
        int ret = proc.execute("ffmpegthumbnailer", QStringList() << "-i" << filename << "-s" << QString::number(maxSize.width()) << "-o" << tmp_path);

        if(ret != 0) {
            LOG << CURDATE << "PQLoadImageVideo: ffmpegthumbnailer ended with error code " << ret << " - is it installed?" << NL;
            QImage img(":/image/genericvideothumb.png");
            return img.scaledToWidth(maxSize.width());
        }

        QImage thumb(tmp_path);

        // remove temporary thumbnail file
        QFile::remove(tmp_path);

        // store in return variable
        return thumb;

    } else if(PQSettings::get()["filetypesVideoThumbnailer"].toString() == "") {

#endif

        QImage img(":/image/genericvideothumb.png");
        return img.scaledToWidth(maxSize.width());

#ifdef Q_OS_LINUX

    }

    errormsg = "Unknown video thumbnailer used: " + PQSettings::get()["filetypesVideoThumbnailer"].toString();
    LOG << CURDATE << "PQLoadImageVideo::load(): " << errormsg.toStdString() << NL;
    return QImage();

#endif

}

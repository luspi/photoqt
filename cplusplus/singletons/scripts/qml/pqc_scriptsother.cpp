/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

#include <scripts/qml/pqc_scriptsother.h>
#include <pqc_notify_cpp.h>
#include <pqc_printtabimageoptions.h>
#include <pqc_printtabimagepositiontile.h>
#include <pqc_loadimage.h>
#include <pqc_settings.h>

#include <QMessageBox>
#include <QDateTime>
#include <QApplication>
#include <QScreen>
#include <QDir>
#include <QPrinter>
#include <QPrintDialog>
#include <QPainter>
#include <QColorDialog>
#include <QProcess>

PQCScriptsOther::PQCScriptsOther() {}

PQCScriptsOther::~PQCScriptsOther() {}

qint64 PQCScriptsOther::getTimestamp() {
    return QDateTime::currentMSecsSinceEpoch();
}

void PQCScriptsOther::deleteScreenshots() {
    qDebug() << "";
    int count = 0;
    while(true) {
        QFile file(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(count));
        if(file.exists())
            file.remove();
        else
            break;
    }
}

QString PQCScriptsOther::getUniqueId() {

    qDebug() << "";

    return QString::number(QDateTime::currentMSecsSinceEpoch());

}

void PQCScriptsOther::printFile(QString filename) {

    QSettings settings;

    // Get the image
    QImage img;
    QSize orig;
    PQCLoadImage::get().load(filename, QSize(), orig, img);

    // show the printer dialog with additional options tab
    QPrinter printer(QPrinter::HighResolution);

    // get the starting output filename (directory stored, filename based on image filename)
    QFileInfo info(filename);
    printer.setOutputFileName(QString("%1/%2.pdf").arg(info.absolutePath(), info.baseName()));

    // the additional image options tab
    PQCPrintTabImageOptions *imageoptions = new PQCPrintTabImageOptions(printer.pageLayout().pageSize().rect(QPageSize::Millimeter).size());

    // The print dialog
    QPrintDialog printDialog(&printer, nullptr);
    printDialog.setWindowTitle(tr("Print"));
    printDialog.setOptionTabs({imageoptions});
    if(printDialog.exec() != QDialog::Accepted) {
        delete imageoptions;
        return;
    }

    // store all the settings
    imageoptions->storeNewSettings();

    // create a painter and create handles for some much used properties
    QPainter painter(&printer);
    QRect viewport = painter.viewport();
    QSize imgsize = img.size();

    // scale the image to fit into the page
    if(imageoptions->getScalingFitToPage()) {

        bool imageBiggerThanPaper = imgsize.width() > viewport.width() || imgsize.height() > viewport.height();

        if (imageBiggerThanPaper || imageoptions->getScalingEnlargeSmaller())
            imgsize.scale(viewport.size(), Qt::KeepAspectRatio);

        // scale the image to a certain width/height
    } else if(imageoptions->getScalingScaleTo()) {

        double wImg = imageoptions->getScalingScaleToSize().width();
        double hImg = imageoptions->getScalingScaleToSize().height();
        imgsize.setWidth(int(wImg * printer.resolution()));
        imgsize.setHeight(int(hImg * printer.resolution()));

        // do not scale the image
    } else {

        const double INCHES_PER_METER = 100. / 2.54;
        const int dpmX = img.dotsPerMeterX();
        const int dpmY = img.dotsPerMeterY();

        if (dpmX > 0 && dpmY > 0) {
            double wImg = double(imgsize.width()) / double(dpmX) * INCHES_PER_METER;
            double hImg = double(imgsize.height()) / double(dpmY) * INCHES_PER_METER;
            imgsize.setWidth(int(wImg * printer.resolution()));
            imgsize.setHeight(int(hImg * printer.resolution()));
        }

    }


    // get the image position the user selected in the options tab
    int imgPos = imageoptions->getImagePosition();

    // we are done with this, so delete
    delete imageoptions;

    // the final position of the image on the page is stored in these
    // these default values are horizontal left and vertical top
    int x = 0;
    int y = 0;

    // horizontal center
    if((imgPos-1)%3 == 0)
        x = (viewport.width()-imgsize.width())/2;
    // horizontal right
    else if((imgPos+1)%3 == 0)
        x = viewport.width()-imgsize.width();

    // vertical center
    if(imgPos > 2 && imgPos < 6)
        y = (viewport.height()-imgsize.height())/2;
    // vertical bottom
    else if(imgPos > 5)
        y = viewport.height()-imgsize.height();

    // set properties to painter
    painter.setViewport(x, y, imgsize.width(), imgsize.height());
    painter.setWindow(img.rect());

    // and draw final image
    painter.drawImage(0, 0, img);

    // done!
    painter.end();

}

int PQCScriptsOther::getCurrentScreen(QPoint pos) {
    for(int i = 0; i < QApplication::screens().count(); ++i) {
        QScreen *screen = QApplication::screens().at(i);
        QRect r = screen->geometry();
        if(r.x() < pos.x() && r.x()+r.width() > pos.x() &&
            r.y() < pos.y() && r.y()+r.height() > pos.y())
            return i;
    }
    return 0;
}

QString PQCScriptsOther::addAlphaToColor(QString rgb, int alpha) {

    qDebug() << "args: rgb =" << rgb;
    qDebug() << "args: alpha =" << alpha;

    QColor col(rgb);
    col.setAlpha(alpha);
    return col.name(QColor::HexArgb);

}

QVariantList PQCScriptsOther::convertHexToRgba(QString hex) {

    qDebug() << "args: hex =" << hex;

    int r,g,b,a;

    // no transparency
    if(hex.length() == 7) {

        a = 255;
        r = hex.sliced(1, 2).toUInt(nullptr, 16);
        g = hex.sliced(3, 2).toUInt(nullptr, 16);
        b = hex.sliced(5, 2).toUInt(nullptr, 16);

    } else {

        a = hex.sliced(1, 2).toUInt(nullptr, 16);
        r = hex.sliced(3, 2).toUInt(nullptr, 16);
        g = hex.sliced(5, 2).toUInt(nullptr, 16);
        b = hex.sliced(7, 2).toUInt(nullptr, 16);

    }

    return QVariantList() << r << g << b << a;

}

QString PQCScriptsOther::convertRgbaToHex(QVariantList rgba) {

    qDebug() << "args: rgba =" << rgba;

    QColor col(qRgba(rgba[0].toInt(), rgba[1].toInt(), rgba[2].toInt(), rgba[3].toInt()));
    return col.name(QColor::HexArgb);

}

QString PQCScriptsOther::convertRgbToHex(QVariantList rgb) {

    qDebug() << "args: rgb =" << rgb;

    QColor col(qRgb(rgb[0].toInt(), rgb[1].toInt(), rgb[2].toInt()));
    return col.name(QColor::HexRgb);

}

QVariantList PQCScriptsOther::selectColor(QVariantList def) {

    QVariantList ret;

    QColor cur = qRgb(def[0].toInt(), def[1].toInt(), def[2].toInt());
    cur.setAlpha(def[3].toInt());

    QColorDialog coldiag;
    coldiag.setOption(QColorDialog::ShowAlphaChannel);
    coldiag.setCurrentColor(cur);
    coldiag.setWindowTitle("Select color");
    if(!coldiag.exec())
        return ret;

    QColor col = coldiag.selectedColor();

    if(col == QColor::Invalid)
        return ret;

    ret.push_back(col.red());
    ret.push_back(col.green());
    ret.push_back(col.blue());
    ret.push_back(col.alpha());

    return ret;

}

void PQCScriptsOther::setPointingHandCursor() {

    if(qApp->overrideCursor() != nullptr)
        qApp->restoreOverrideCursor();
    qApp->setOverrideCursor(Qt::PointingHandCursor);

}

void PQCScriptsOther::restoreOverrideCursor() {

    qApp->restoreOverrideCursor();

}

bool PQCScriptsOther::showDesktopNotification(QString summary, QString txt) {

    qDebug() << "args: summary =" << summary;
    qDebug() << "args: txt =" << txt;

#ifndef Q_OS_WIN

    QProcess proc_notifysend;
    proc_notifysend.start("notify-send", {"-t", "5000",
                               "-a", "PhotoQt",
                               "-i", "org.photoqt.PhotoQt",
                               summary,
                               txt});

    proc_notifysend.waitForFinished(2500);
    // success!
    if(proc_notifysend.exitCode() == 0)
        return true;

    /*********************************************************/
    // if notify-send didn't work, try gdbus

    QProcess proc_gdbus;
    proc_gdbus.start("gdbus", {"call",
                               "--session",
                               "--dest=org.freedesktop.Notifications",
                               "--object-path=/org/freedesktop/Notifications",
                               "--method=org.freedesktop.Notifications.Notify",
                               "PhotoQt",
                               "0",
                               "org.photoqt.PhotoQt",
                               summary,
                               txt,
                               "[]",
                               "{'urgency': <1>}",
                               "5000"});

    proc_gdbus.waitForFinished(2500);
    // success!
    if(proc_gdbus.exitCode() == 0)
        return true;

    /*********************************************************/
    // if neither worked (or if we're on windows) return false

#endif

    return false;

}

QStringList PQCScriptsOther::convertJSArrayToStringList(QVariant val) {

    QStringList ret;

    QJSValue v = val.value<QJSValue>();
    const int length = v.property("length").toInt();
    for(int i = 0; i < length; ++i)
        ret << v.property(i).toString();

    return ret;

}

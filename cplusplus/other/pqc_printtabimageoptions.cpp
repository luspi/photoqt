/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <pqc_printtabimageoptions.h>

#include <QLabel>
#include <QHBoxLayout>
#include <QLabel>
#include <QFrame>
#include <QRadioButton>
#include <QCheckBox>
#include <QDoubleSpinBox>
#include <QComboBox>
#include <vector>

/**********************************************************/
/* the setup and layout of this page inspired by GwenView */
/**********************************************************/

PQCPrintTabImageOptions::PQCPrintTabImageOptions(QSizeF pixmapsize, QWidget *parent) : QWidget(parent) {

    this->setWindowTitle("Image Settings");

    mainhorlay = new QHBoxLayout;

    /**********************************************/
    // Image position

    posFrame = new QFrame;
    posFrame->setFrameStyle(QFrame::Box);
    posFrame->setStyleSheet("border: 1px solid rgb(200,200,200)");

    posLayout = new QVBoxLayout;
    posLayout->setSpacing(10);

    posTitle = new QLabel("Image Position");
    posTitle->setAlignment(Qt::AlignHCenter);
    posTitle->setStyleSheet("border: none");

    posGrid = new QGridLayout;
    posGrid->setSpacing(0);
    posGrid->setHorizontalSpacing(0);

    posSelected = set.value("printImagePos", 4).toInt();

    for(int y = 0; y < 3; ++y) {
        for(int x = 0; x < 3; ++x) {
            PQCPrintTabImagePositionTile *pos = new PQCPrintTabImagePositionTile(y*3+x, ((y*3+x)==posSelected));
            posGridTiles.push_back(pos);
            posGrid->addWidget(pos, y, x);
            connect(pos, &PQCPrintTabImagePositionTile::newPosSelected, this, &PQCPrintTabImageOptions::newPosSelected);
            connect(this, &PQCPrintTabImageOptions::notifyNewPosSelected, pos, &PQCPrintTabImagePositionTile::checkIfIAmStillSelected);
        }
    }

    posLayout->addWidget(posTitle);
    posLayout->addLayout(posGrid);
    posLayout->addStretch();

    posFrame->setLayout(posLayout);


    /**********************************************/
    // scaling

    const bool setNoScaling = set.value("printNoScaling", false).toBool();
    const bool setFitImagePage = set.value("printFitImagePage", true).toBool();
    const bool setEnlargeSmall = set.value("printEnlargeSmall", false).toBool();
    const bool setScaleTo = set.value("printScaleTo", false).toBool();
    const QSize setScaleToSize = set.value("printScaleToSize", QSize(pixmapsize.width(), pixmapsize.height())).toSize();
    const int setScaleToUnit = set.value("printScaleToUnit", 0).toInt();
    const bool setKeepRatio = set.value("printKeepRatio", false).toBool();

    scaFrame = new QFrame;
    scaFrame->setFrameStyle(QFrame::Box);
    scaFrame->setStyleSheet("QFrame { border: 1px solid rgb(200,200,200); }");

    scaLayout = new QVBoxLayout;

    scaTitle = new QLabel("Scaling");
    scaTitle->setAlignment(Qt::AlignHCenter);
    scaTitle->setStyleSheet("border: none");

    scaNone = new QRadioButton("No scaling");
    scaNone->setChecked(setNoScaling);
    scaPage = new QRadioButton("Fit image to page");
    scaPage->setChecked(setFitImagePage);

    scaInc = new QCheckBox("Enlarge smaller images");
    scaInc->setEnabled(scaPage->isChecked());
    scaInc->setChecked(setEnlargeSmall);
    scaIncLayout = new QHBoxLayout;
    scaIncLayout->addSpacing(25);
    scaIncLayout->addWidget(scaInc);
    connect(scaPage, &QRadioButton::toggled, scaInc, &QCheckBox::setEnabled);

    scaSize = new QRadioButton("Scale to:");
    scaSize->setChecked(setScaleTo);

    scaWid = new QDoubleSpinBox;
    scaWid->setEnabled(scaSize->isChecked());
    scaWid->setMaximum(9999);
    scaWid->setValue(setScaleToSize.width());
    scaX = new QLabel("x");
    scaX->setStyleSheet("border: none");
    scaHei = new QDoubleSpinBox;
    scaHei->setEnabled(scaSize->isChecked());
    scaHei->setMaximum(9999);
    scaHei->setValue(setScaleToSize.height());
    scaUni = new QComboBox;
    scaUni->setEnabled(scaSize->isChecked());
    scaUni->addItem("Millimeters");
    scaUni->addItem("Centimeters");
    scaUni->addItem("Inches");
    scaUni->setCurrentIndex(setScaleToUnit);
    scaSizeLayout = new QHBoxLayout;
    scaSizeLayout->addSpacing(25);
    scaSizeLayout->addWidget(scaWid);
    scaSizeLayout->addWidget(scaX);
    scaSizeLayout->addWidget(scaHei);
    scaSizeLayout->addWidget(scaUni);
    scaSizeLayout->addStretch();
    connect(scaSize, &QRadioButton::toggled, scaWid, &QDoubleSpinBox::setEnabled);
    connect(scaSize, &QRadioButton::toggled, scaHei, &QDoubleSpinBox::setEnabled);
    connect(scaSize, &QRadioButton::toggled, scaUni, &QComboBox::setEnabled);

    scaRat = new QCheckBox("Keep ratio");
    scaRat->setEnabled(scaSize->isChecked());
    scaRat->setChecked(setKeepRatio);
    scaRatLayout = new QHBoxLayout;
    scaRatLayout->addSpacing(25);
    scaRatLayout->addWidget(scaRat);
    connect(scaSize, &QRadioButton::toggled, scaRat, &QCheckBox::setEnabled);

    scaLayout->addWidget(scaTitle);
    scaLayout->addWidget(scaNone);
    scaLayout->addWidget(scaPage);
    scaLayout->addLayout(scaIncLayout);
    scaLayout->addWidget(scaSize);
    scaLayout->addLayout(scaSizeLayout);
    scaLayout->addLayout(scaRatLayout);
    scaLayout->addStretch();

    scaFrame->setLayout(scaLayout);


    /**********************************************/

    mainhorlay->addWidget(posFrame);
    mainhorlay->addWidget(scaFrame);

    this->setLayout(mainhorlay);

}

int PQCPrintTabImageOptions::getImagePosition() {
    return posSelected;
}

bool PQCPrintTabImageOptions::getScalingNone() {
    return scaNone->isChecked();
}

bool PQCPrintTabImageOptions::getScalingFitToPage() {
    return scaPage->isChecked();
}

bool PQCPrintTabImageOptions::getScalingEnlargeSmaller() {
    return scaInc->isChecked();
}

bool PQCPrintTabImageOptions::getScalingScaleTo() {
    return scaSize->isChecked();
}

QSizeF PQCPrintTabImageOptions::getScalingScaleToSize() {

    // Inches
    if(scaUni->currentIndex() == 2)
        return QSizeF(scaWid->value(), scaHei->value());

    // Centimeter
    else if(scaUni->currentIndex() == 1)
        return QSizeF(scaWid->value(), scaHei->value()) / 2.54;

    // Millimeters
    else
        return QSizeF(scaWid->value(), scaHei->value()) / 25.4;

}

bool PQCPrintTabImageOptions::getScalingKeepRatio() {
    return scaRat->isChecked();
}

void PQCPrintTabImageOptions::storeNewSettings() {

    set.setValue("printImagePos", posSelected);
    set.setValue("printNoScaling", scaNone->isChecked());
    set.setValue("printFitImagePage", scaPage->isChecked());
    set.setValue("printEnlargeSmall", scaInc->isChecked());
    set.setValue("printScaleTo", scaSize->isChecked());
    set.setValue("printScaleToSize", QSize(scaWid->value(), scaHei->value()));
    set.setValue("printScaleToUnit", scaUni->currentIndex());
    set.setValue("printKeepRatio", scaRat->isChecked());

}

PQCPrintTabImageOptions::~PQCPrintTabImageOptions() {

    delete posTitle;
    for(size_t i = 0; i < posGridTiles.size(); ++i)
        delete posGridTiles[i];
    delete posGrid;
    delete posFrame;

    delete scaTitle;
    delete scaNone;
    delete scaPage;
    delete scaInc;
    delete scaIncLayout;
    delete scaSize;
    delete scaWid;
    delete scaX;
    delete scaHei;
    delete scaUni;
    delete scaSizeLayout;
    delete scaRat;
    delete scaRatLayout;
    delete scaFrame;

    delete mainhorlay;

}

void PQCPrintTabImageOptions::newPosSelected(int id) {
    posSelected = id;
    Q_EMIT notifyNewPosSelected(id);
}

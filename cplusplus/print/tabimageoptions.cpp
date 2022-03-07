/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#include "tabimageoptions.h"
#include <QHBoxLayout>
#include <QLabel>
#include <QFrame>
#include <QRadioButton>
#include <QCheckBox>
#include <QDoubleSpinBox>
#include <QComboBox>

// the setup and layout of this page is inspired by GwenView.

PQTabImageOptions::PQTabImageOptions(QWidget *parent) : QWidget(parent) {

    this->setWindowTitle("Image Settings");

    QHBoxLayout *mainhorlay = new QHBoxLayout;

    /**********************************************/
    // Image position

    QFrame *posFrame = new QFrame;
    posFrame->setFrameStyle(QFrame::Box);
    posFrame->setStyleSheet("border: 1px solid rgb(200,200,200)");

    QVBoxLayout *posLayout = new QVBoxLayout;
    posLayout->setSpacing(10);

    QLabel *posTitle = new QLabel("Image Position");
    posTitle->setAlignment(Qt::AlignHCenter);
    posTitle->setStyleSheet("border: none");

    QGridLayout *posGrid = new QGridLayout;
    posGrid->setSpacing(0);
    posGrid->setHorizontalSpacing(0);

    for(int y = 0; y < 3; ++y) {
        for(int x = 0; x < 3; ++x) {
            PQTabImagePositionTile *pos = new PQTabImagePositionTile(y*3 + x + 1, (x==1&&y==1));
            posGrid->addWidget(pos, y, x);
            connect(pos, &PQTabImagePositionTile::newPosSelected, this, &PQTabImageOptions::newPosSelected);
            connect(this, &PQTabImageOptions::notifyNewPosSelected, pos, &PQTabImagePositionTile::checkIfIAmStillSelected);
        }
    }

    posLayout->addWidget(posTitle);
    posLayout->addLayout(posGrid);
    posLayout->addStretch();

    posFrame->setLayout(posLayout);


    /**********************************************/
    // scaling

    QFrame *scaFrame = new QFrame;
    scaFrame->setFrameStyle(QFrame::Box);
    scaFrame->setStyleSheet("QFrame { border: 1px solid rgb(200,200,200); }");

    QVBoxLayout *scaLayout = new QVBoxLayout;

    QLabel *scaTitle = new QLabel("Scaling");
    scaTitle->setAlignment(Qt::AlignHCenter);
    scaTitle->setStyleSheet("border: none");

    QRadioButton *scaNone = new QRadioButton("No scaling");
    scaNone->setChecked(true);
    QRadioButton *scaPage = new QRadioButton("Fit image to page");

    QCheckBox *scaInc = new QCheckBox("Enlarge smaller images");
    scaInc->setEnabled(false);
    QHBoxLayout *scaIncLayout = new QHBoxLayout;
    scaIncLayout->addSpacing(25);
    scaIncLayout->addWidget(scaInc);
    connect(scaPage, &QRadioButton::toggled, scaInc, &QCheckBox::setEnabled);

    QRadioButton *scaSize = new QRadioButton("Scale to:");

    QDoubleSpinBox *scaWid = new QDoubleSpinBox;
    scaWid->setEnabled(false);
    QLabel *scaX = new QLabel("x");
    scaX->setStyleSheet("border: none");
    QDoubleSpinBox *scaHei = new QDoubleSpinBox;
    scaHei->setEnabled(false);
    QComboBox *scaUni = new QComboBox;
    scaUni->setEnabled(false);
    scaUni->addItem("Millimeters");
    scaUni->addItem("Centimeters");
    scaUni->addItem("Inches");
    QHBoxLayout *scaSizeLayout = new QHBoxLayout;
    scaSizeLayout->addSpacing(25);
    scaSizeLayout->addWidget(scaWid);
    scaSizeLayout->addWidget(scaX);
    scaSizeLayout->addWidget(scaHei);
    scaSizeLayout->addWidget(scaUni);
    scaSizeLayout->addStretch();
    connect(scaSize, &QRadioButton::toggled, scaWid, &QDoubleSpinBox::setEnabled);
    connect(scaSize, &QRadioButton::toggled, scaHei, &QDoubleSpinBox::setEnabled);
    connect(scaSize, &QRadioButton::toggled, scaUni, &QComboBox::setEnabled);

    QCheckBox *scaRat = new QCheckBox("Keep ratio");
    scaRat->setEnabled(false);
    QHBoxLayout *scaRatLayout = new QHBoxLayout;
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

void PQTabImageOptions::newPosSelected(int id) {
    Q_EMIT notifyNewPosSelected(id);
}

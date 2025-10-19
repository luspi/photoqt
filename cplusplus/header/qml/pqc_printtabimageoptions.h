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
#pragma once

#include <qml/pqc_printtabimagepositiontile.h>
#include <QWidget>
#include <QSettings>

class QHBoxLayout;
class QVBoxLayout;
class QGridLayout;
class QRadioButton;
class QCheckBox;
class QDoubleSpinBox;
class QComboBox;

class PQCPrintTabImageOptions : public QWidget {

    Q_OBJECT

public:
    PQCPrintTabImageOptions(QSizeF pixmapsize, QWidget *parent = nullptr);
    ~PQCPrintTabImageOptions();

    int getImagePosition();
    bool getScalingNone();
    bool getScalingFitToPage();
    bool getScalingEnlargeSmaller();
    bool getScalingScaleTo();
    QSizeF getScalingScaleToSize();
    bool getScalingKeepRatio();
    void storeNewSettings();

private:
    int posSelected;

    QHBoxLayout *mainhorlay;
    QFrame *posFrame;
    QVBoxLayout *posLayout;
    QLabel *posTitle;
    std::vector<PQCPrintTabImagePositionTile*> posGridTiles;
    QGridLayout *posGrid;

    QFrame *scaFrame;
    QVBoxLayout *scaLayout;
    QLabel *scaTitle;
    QRadioButton *scaNone;
    QRadioButton *scaPage;
    QCheckBox *scaInc;
    QHBoxLayout *scaIncLayout;
    QRadioButton *scaSize;
    QDoubleSpinBox *scaWid;
    QLabel *scaX;
    QDoubleSpinBox *scaHei;
    QComboBox *scaUni;
    QHBoxLayout *scaSizeLayout;
    QCheckBox *scaRat;
    QHBoxLayout *scaRatLayout;

    QSettings set;

private Q_SLOTS:
    void newPosSelected(int id);

Q_SIGNALS:
    void notifyNewPosSelected(int id);

};

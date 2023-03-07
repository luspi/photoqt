/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#ifndef TABIMAGEOPTIONS_H
#define TABIMAGEOPTIONS_H

#include "tabimagepositiontile.h"
#include <QWidget>
#include <QLabel>
#include <QHBoxLayout>
#include <QLabel>
#include <QFrame>
#include <QRadioButton>
#include <QCheckBox>
#include <QDoubleSpinBox>
#include <QComboBox>
#include <QSettings>
#include <vector>

class PQTabImageOptions : public QWidget {

    Q_OBJECT

public:
    PQTabImageOptions(QSizeF pixmapsize, QWidget *parent = nullptr);
    ~PQTabImageOptions();

    int getImagePosition() {
        return posSelected;
    }

    bool getScalingNone() {
        return scaNone->isChecked();
    }

    bool getScalingFitToPage() {
        return scaPage->isChecked();
    }

    bool getScalingEnlargeSmaller() {
        return scaInc->isChecked();
    }

    bool getScalingScaleTo() {
        return scaSize->isChecked();
    }

    QSizeF getScalingScaleToSize() {

        // Inches
        if (scaUni->currentIndex() == 2)
            return QSizeF(scaWid->value(), scaHei->value());

        // Centimeter
        else if (scaUni->currentIndex() == 1)
            return QSizeF(scaWid->value(), scaHei->value()) / 2.54;

        // Millimeters
        else
            return QSizeF(scaWid->value(), scaHei->value()) / 25.4;

    }

    bool getScalingKeepRatio() {
        return scaRat->isChecked();
    }

    void storeNewSettings();

private:
    int posSelected;

    QHBoxLayout *mainhorlay;
    QFrame *posFrame;
    QVBoxLayout *posLayout;
    QLabel *posTitle;
    std::vector<PQTabImagePositionTile*> posGridTiles;
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




#endif // TABIMAGEOPTIONS_H

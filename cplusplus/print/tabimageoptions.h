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
    PQTabImageOptions(QWidget *parent = nullptr);
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
        return QSizeF(scaWid->value(), scaHei->value());
    }

    int getScalingScaleToUnit() {
        return scaUni->currentIndex();
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

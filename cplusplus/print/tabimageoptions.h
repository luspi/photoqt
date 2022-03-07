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
#include <vector>

class PQTabImageOptions : public QWidget {

    Q_OBJECT

public:
    PQTabImageOptions(QWidget *parent = nullptr);
    ~PQTabImageOptions();

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

private Q_SLOTS:
    void newPosSelected(int id);

Q_SIGNALS:
    void notifyNewPosSelected(int id);

};




#endif // TABIMAGEOPTIONS_H

/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

#include <pqc_look.h>
#include <pqc_settings.h>
#include <QColor>
#include <QFont>
#include <QtDebug>

PQCLook::PQCLook() {

    colorNameToHex.insert("gray",   "#111111");
    colorNameToHex.insert("red",    "#110505");
    colorNameToHex.insert("green" , "#051105");
    colorNameToHex.insert("blue",   "#050b11");
    colorNameToHex.insert("purple", "#0b0211");
    colorNameToHex.insert("orange", "#110b02");
    colorNameToHex.insert("pink",   "#11020b");

    // we use this to preserve the given order
    colorNames = {"gray",
                  "red", "green", "blue",
                  "purple", "orange", "pink"};


    calculateColors(colorNameToHex.value(PQCSettings::get()["interfaceAccentColor"].toString(), "#111111"));

    calculateFontSizes(11);

    m_fontWeightBold = QFont::Bold;
    m_fontWeightNormal = QFont::Normal;

    connect(&PQCSettings::get(), &PQCSettings::valueChanged, this, [=](const QString &key, const QVariant &value) {
        if(key == "interfaceAccentColor") {
            calculateColors(colorNameToHex[value.toString()]);
            Q_EMIT baseColorChanged();
            Q_EMIT baseColorAccentChanged();
            Q_EMIT baseColorHighlightChanged();
            Q_EMIT baseColorActiveChanged();

            Q_EMIT inverseColorChanged();
            Q_EMIT inverseColorHighlightChanged();
            Q_EMIT inverseColorActiveChanged();

            Q_EMIT faintColorChanged();
            Q_EMIT transColorChanged();
            Q_EMIT transColorAccentChanged();
            Q_EMIT transColorHighlightChanged();
            Q_EMIT transColorActiveChanged();

            Q_EMIT textColorChanged();
            Q_EMIT textColorDisabledChanged();

            Q_EMIT textInverseColorChanged();
            Q_EMIT textInverseColorHighlightChanged();
            Q_EMIT textInverseColorActiveChanged();
        }
    });

}

PQCLook &PQCLook::get() {
    static PQCLook instance;
    return instance;
}

PQCLook::~PQCLook() { }

void PQCLook::calculateColors(QString base) {

#if QT_VERSION >= QT_VERSION_CHECK(6, 4, 0)
    QColor col = QColor::fromString(base);
#else
    QColor col(base);
#endif

    QColor colTrans = col;
    colTrans.setAlpha(222);

    m_baseColor = base;
    m_transColor = colTrans.name(QColor::HexArgb);

    colTrans.setAlpha(20);
    m_faintColor = colTrans.name(QColor::HexArgb);

    QColor invcol((255-col.red()), (255-col.green()), (255-col.blue()));
    m_inverseColor = invcol.name(QColor::HexArgb);

    const int accent = 150;
    const int highlight = 300;
    const int active = 600;

    m_baseColorAccent = col.lighter(accent).name(QColor::HexArgb);
    m_baseColorHighlight = col.lighter(highlight).name(QColor::HexArgb);
    m_baseColorActive = col.lighter(active).name(QColor::HexArgb);

    m_inverseColorHighlight = invcol.darker(highlight).name(QColor::HexArgb);
    m_inverseColorActive = invcol.darker(active).name(QColor::HexArgb);

    m_transColorAccent = colTrans.lighter(accent).name(QColor::HexArgb);
    m_transColorHighlight = colTrans.lighter(highlight).name(QColor::HexArgb);
    m_transColorActive = colTrans.lighter(active).name(QColor::HexArgb);

    QColor colText = QColor(255,255,255);
    m_textColor = colText.name(QColor::HexArgb);
    m_textColorDisabled = colText.darker(highlight).name(QColor::HexArgb);

    QColor colInverseText = QColor(75,75,75);
    m_textInverseColor = colInverseText.name(QColor::HexArgb);
    m_textInverseColorHighlight = colInverseText.lighter(highlight).name(QColor::HexArgb);
    m_textInverseColorActive = colInverseText.lighter(active).name(QColor::HexArgb);

}

/******************************************************/

QString PQCLook::getBaseColor() {
    return m_baseColor;
}
QString PQCLook::getBaseColorAccent() {
    return m_baseColorAccent;
}
QString PQCLook::getBaseColorActive() {
    return m_baseColorActive;
}
QString PQCLook::getBaseColorHighlight() {
    return m_baseColorHighlight;
}

void PQCLook::setBaseColor(QString val) {

    if(val != m_baseColor) {

        calculateColors(val);

        Q_EMIT baseColorChanged();
        Q_EMIT baseColorAccentChanged();
        Q_EMIT baseColorActiveChanged();
        Q_EMIT baseColorHighlightChanged();

        Q_EMIT inverseColorChanged();
        Q_EMIT inverseColorActiveChanged();
        Q_EMIT inverseColorHighlightChanged();

        Q_EMIT transColorChanged();
        Q_EMIT transColorAccentChanged();
        Q_EMIT transColorActiveChanged();
        Q_EMIT transColorHighlightChanged();

        Q_EMIT textColorChanged();
        Q_EMIT textColorDisabledChanged();

        Q_EMIT textInverseColorChanged();
        Q_EMIT textInverseColorActiveChanged();
        Q_EMIT textInverseColorHighlightChanged();

    }

}

/******************************************************/

QString PQCLook::getInverseColor() {
    return m_inverseColor;
}

QString PQCLook::getInverseColorActive() {
    return m_inverseColorActive;
}

QString PQCLook::getInverseColorHighlight() {
    return m_inverseColorHighlight;
}

/******************************************************/

QString PQCLook::getTransColor() {
    return m_transColor;
}
QString PQCLook::getFaintColor() {
    return m_faintColor;
}
QString PQCLook::getTransColorAccent() {
    return m_transColorAccent;
}
QString PQCLook::getTransColorActive() {
    return m_transColorActive;
}
QString PQCLook::getTransColorHighlight() {
    return m_transColorHighlight;
}

/******************************************************/

QString PQCLook::getTextColor() { return m_textColor; }
QString PQCLook::getTextColorDisabled() { return m_textColorDisabled; }

/******************************************************/

QString PQCLook::getTextInverseColor() { return m_textInverseColor; }
QString PQCLook::getTextInverseColorActive() { return m_textInverseColorActive; }
QString PQCLook::getTextInverseColorHighlight() { return m_textInverseColorHighlight; }

/******************************************************/

void PQCLook::setFontSize(int val) {
    if(val != m_fontSize) {
        calculateFontSizes(val);
        Q_EMIT fontSizeChanged();
        Q_EMIT fontSizeSChanged();
        Q_EMIT fontSizeLChanged();
        Q_EMIT fontSizeXLChanged();
        Q_EMIT fontSizeXXLChanged();
    }
}

int PQCLook::getFontSize() {
    return m_fontSize;
}
int PQCLook::getFontSizeS() {
    return m_fontSizeS;
}
int PQCLook::getFontSizeL() {
    return m_fontSizeL;
}
int PQCLook::getFontSizeXL() {
    return m_fontSizeXL;
}
int PQCLook::getFontSizeXXL() {
    return m_fontSizeXXL;
}

void PQCLook::calculateFontSizes(int sze) {
    m_fontSize = sze;
    m_fontSizeS = sze-3;
    m_fontSizeL = sze+4;
    m_fontSizeXL = sze+9;
    m_fontSizeXXL = sze+14;
}

/******************************************************/

int PQCLook::getFontWeightBold() {
    return m_fontWeightBold;
}
void PQCLook::setFontWeightBold(int val) {
    if(val != m_fontWeightBold) {
        m_fontWeightBold = val;
        Q_EMIT fontWeightBoldChanged();
    }
}
int PQCLook::getFontWeightNormal() {
    return m_fontWeightNormal;
}
void PQCLook::setFontWeightNormal(int val) {
    if(val != m_fontWeightNormal) {
        m_fontWeightNormal = val;
        Q_EMIT fontWeightNormalChanged();
    }
}

/******************************************************/

QStringList PQCLook::getColorNames() {
    return colorNames;
}



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

#include <pqc_look.h>
#include <pqc_settingscpp.h>
#include <QCoreApplication>
#include <QColor>
#include <QFont>
#include <QtDebug>

PQCLook::PQCLook() : QObject() {

    lightness_threshold = 96;

    // we use this to preserve the given order
    colorHexes = {"#222222",
                  "#110505", "#051105", "#050b11", "#110b02",
                  "#dddddd",
                  "#ff8080", "#a4c4a4", "#a4a4ff", "#ffd7c0"};
    colorNames = {QCoreApplication::translate("settingsmanager", "dark gray"),
                  QCoreApplication::translate("settingsmanager", "dark red"),
                  QCoreApplication::translate("settingsmanager", "dark green"),
                  QCoreApplication::translate("settingsmanager", "dark blue"),
                  QCoreApplication::translate("settingsmanager", "dark orange"),
                  QCoreApplication::translate("settingsmanager", "light gray"),
                  QCoreApplication::translate("settingsmanager", "light red"),
                  QCoreApplication::translate("settingsmanager", "light green"),
                  QCoreApplication::translate("settingsmanager", "light blue"),
                  QCoreApplication::translate("settingsmanager", "light orange")};

    calculateColors(PQCSettingsCPP::get().getInterfaceAccentColor());

    calculateFontSizes(11);

    m_fontWeightNormal = std::min(900, std::max(100, PQCSettingsCPP::get().getInterfaceFontNormalWeight()));
    m_fontWeightBold = std::min(900, std::max(100, PQCSettingsCPP::get().getInterfaceFontBoldWeight()));

    connect(&PQCSettingsCPP::get(), &PQCSettingsCPP::interfaceAccentColorChanged, this, [=]() {

        const QString val = PQCSettingsCPP::get().getInterfaceAccentColor();
        calculateColors(val.startsWith("#") ? val : QColor(val).name(QColor::HexArgb));

        Q_EMIT iconShadeChanged();

        Q_EMIT baseColorChanged();
        Q_EMIT baseColorAccentChanged();
        Q_EMIT baseColorHighlightChanged();
        Q_EMIT baseColorActiveChanged();

        Q_EMIT inverseColorChanged();
        Q_EMIT inverseColorAccentChanged();
        Q_EMIT inverseColorHighlightChanged();
        Q_EMIT inverseColorActiveChanged();

        Q_EMIT faintColorChanged();
        Q_EMIT transColorChanged();
        Q_EMIT transColorAccentChanged();
        Q_EMIT transColorHighlightChanged();
        Q_EMIT transColorActiveChanged();

        Q_EMIT transInverseColorChanged();

        Q_EMIT textColorChanged();
        Q_EMIT textColorDisabledChanged();

        Q_EMIT textInverseColorChanged();
        Q_EMIT textInverseColorHighlightChanged();
        Q_EMIT textInverseColorActiveChanged();

    });

    connect(&PQCSettingsCPP::get(), &PQCSettingsCPP::interfaceFontBoldWeightChanged, this, [=]() {

        m_fontWeightBold = PQCSettingsCPP::get().getInterfaceFontBoldWeight();
        Q_EMIT fontWeightBoldChanged();

    });
    connect(&PQCSettingsCPP::get(), &PQCSettingsCPP::interfaceFontNormalWeightChanged, this, [=]() {

        m_fontWeightNormal = PQCSettingsCPP::get().getInterfaceFontNormalWeight();
        Q_EMIT fontWeightNormalChanged();

    });

}

PQCLook::~PQCLook() { }

void PQCLook::calculateColors(QString name) {

    QString base = name;
    if(!name.startsWith("#"))
        base = QColor(name).name(QColor::HexArgb);

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

    int val = qMax(col.red(), qMax(col.green(), col.blue()));

    QColor invcol((255-val), (255-val), (255-val));
    m_inverseColor = invcol.name(QColor::HexArgb);
    QColor transinvcol = invcol;
    transinvcol.setAlpha(222);
    m_transInverseColor = transinvcol.name(QColor::HexArgb);

    const int accent = 75;
    const int highlight = 150;
    const int active = 225;

    if(col.lightness() < lightness_threshold) {

        m_iconShade = "light";

        m_baseColorAccent = col.lighter(accent).name(QColor::HexArgb);
        m_baseColorHighlight = col.lighter(highlight).name(QColor::HexArgb);
        m_baseColorActive = col.lighter(active).name(QColor::HexArgb);

        m_transColorAccent = colTrans.lighter(accent).name(QColor::HexArgb);
        m_transColorHighlight = colTrans.lighter(highlight).name(QColor::HexArgb);
        m_transColorActive = colTrans.lighter(active).name(QColor::HexArgb);

        QColor coltxt(255,255,255);
        m_textColor = coltxt.name(QColor::HexArgb);
        m_textColorDisabled = coltxt.darker(highlight).name(QColor::HexArgb);

        m_inverseColorAccent = invcol.darker(accent).name(QColor::HexArgb);
        m_inverseColorHighlight = invcol.darker(highlight).name(QColor::HexArgb);
        m_inverseColorActive = invcol.darker(active).name(QColor::HexArgb);

        QColor invcoltxt(75,75,75);
        m_textInverseColor = invcoltxt.name(QColor::HexArgb);
        m_textInverseColorHighlight = invcoltxt.lighter(highlight).name(QColor::HexArgb);
        m_textInverseColorActive = invcoltxt.lighter(active).name(QColor::HexArgb);

    } else {

        m_iconShade = "dark";

        m_baseColorAccent = col.darker(accent).name(QColor::HexArgb);
        m_baseColorHighlight = col.darker(highlight).name(QColor::HexArgb);
        m_baseColorActive = col.darker(active).name(QColor::HexArgb);

        m_transColorAccent = colTrans.darker(accent).name(QColor::HexArgb);
        m_transColorHighlight = colTrans.darker(highlight).name(QColor::HexArgb);
        m_transColorActive = colTrans.darker(active).name(QColor::HexArgb);

        QColor coltxt(0,0,0);
        m_textColor = coltxt.name(QColor::HexArgb);
        m_textColorDisabled = coltxt.lighter(highlight).name(QColor::HexArgb);

        m_inverseColorAccent = invcol.lighter(accent).name(QColor::HexArgb);
        m_inverseColorHighlight = invcol.lighter(highlight).name(QColor::HexArgb);
        m_inverseColorActive = invcol.lighter(active).name(QColor::HexArgb);

        QColor invcoltxt(180,180,180);
        m_textInverseColor = invcoltxt.name(QColor::HexArgb);
        m_textInverseColorHighlight = invcoltxt.darker(highlight).name(QColor::HexArgb);
        m_textInverseColorActive = invcoltxt.darker(active).name(QColor::HexArgb);

    }

}

QString PQCLook::getIconShade() {
    return m_iconShade;
}

/******************************************************/

QString PQCLook::getBaseColor() {
    return m_baseColor;
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

void PQCLook::calculateFontSizes(int sze) {
    m_fontSize = sze;
    m_fontSizeS = sze-3;
    m_fontSizeL = sze+4;
    m_fontSizeXL = sze+9;
    m_fontSizeXXL = sze+14;
}

/******************************************************/

QStringList PQCLook::getColorNames() {
    return colorNames;
}

QStringList PQCLook::getColorHexes() {
    return colorHexes;
}

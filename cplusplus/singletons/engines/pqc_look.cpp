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

#include <pqc_look.h>
#include <pqc_settingscpp.h>
#include <pqc_configfiles.h>

#include <QColor>
#include <QFont>
#include <QtDebug>
#include <QSqlQuery>
#include <QFile>
#include <QSqlError>
#include <QStyle>
#include <QStyleHints>
#include <QApplication>

PQCLook::PQCLook() : QObject() {

    m_interfaceModernVariant = (PQCSettingsCPP::get().getGeneralInterfaceVariant() == "modern");

    calculateFontSizes(11);

    m_fontWeightNormal = std::min(900, std::max(100, PQCSettingsCPP::get().getInterfaceFontNormalWeight()));
    m_fontWeightBold = std::min(900, std::max(100, PQCSettingsCPP::get().getInterfaceFontBoldWeight()));

    lightness_threshold = 96;

    m_pal = QPalette();

    if(!m_interfaceModernVariant) {

        calculateColors("");

    } else {

        // we use this to preserve the given order
        colorHexes = {"#222222",
                      "#110505", "#051105", "#050b11", "#110b02",
                      "#dddddd",
                      "#ff8080", "#a4c4a4", "#a4a4ff", "#ffd7c0"};
        colorNames = {QApplication::translate("settingsmanager", "dark gray"),
                      QApplication::translate("settingsmanager", "dark red"),
                      QApplication::translate("settingsmanager", "dark green"),
                      QApplication::translate("settingsmanager", "dark blue"),
                      QApplication::translate("settingsmanager", "dark orange"),
                      QApplication::translate("settingsmanager", "light gray"),
                      QApplication::translate("settingsmanager", "light red"),
                      QApplication::translate("settingsmanager", "light green"),
                      QApplication::translate("settingsmanager", "light blue"),
                      QApplication::translate("settingsmanager", "light orange")};

        calculateColors(PQCSettingsCPP::get().getInterfaceAccentColor());

        connect(&PQCSettingsCPP::get(), &PQCSettingsCPP::interfaceAccentColorChanged, this, [=]() {

            const QString val = PQCSettingsCPP::get().getInterfaceAccentColor();
            calculateColors(val.startsWith("#") ? val : QColor(val).name(QColor::HexArgb));

            Q_EMIT iconShadeChanged();
            Q_EMIT baseBorderChanged();

        });

    }

    connect(&PQCSettingsCPP::get(), &PQCSettingsCPP::interfaceFontBoldWeightChanged, this, [=]() {

        m_fontWeightBold = PQCSettingsCPP::get().getInterfaceFontBoldWeight();
        Q_EMIT fontWeightBoldChanged();

    });
    connect(&PQCSettingsCPP::get(), &PQCSettingsCPP::interfaceFontNormalWeightChanged, this, [=]() {

        m_fontWeightNormal = PQCSettingsCPP::get().getInterfaceFontNormalWeight();
        Q_EMIT fontWeightNormalChanged();

    });

}

void PQCLook::testColor(QString color) {

    if(color == "") {

        Q_EMIT PQCSettingsCPP::get().interfaceAccentColorChanged();

    } else {

        calculateColors(color.startsWith("#") ? color : QColor(color).name(QColor::HexArgb));

        Q_EMIT iconShadeChanged();
        Q_EMIT baseBorderChanged();

    }

}

PQCLook::~PQCLook() { }

void PQCLook::calculateColors(QString name) {

    qDebug() << "args: name =" << name;
    qDebug() << "m_interfaceModernVariant =" << m_interfaceModernVariant;

    QPalette curPalette = m_pal;

    if(!m_interfaceModernVariant) {

        m_iconShade = "dark";
#if QT_VERSION >= QT_VERSION_CHECK(6, 5, 0)
        if(qApp->styleHints()->colorScheme() == Qt::ColorScheme::Dark)
            m_iconShade = "light";
        else if(qApp->styleHints()->colorScheme() == Qt::ColorScheme::Unknown) {
            const QPalette defaultPalette;
            const auto text = defaultPalette.color(QPalette::WindowText);
            const auto window = defaultPalette.color(QPalette::Window);
            if(text.lightness() > window.lightness())
                m_iconShade = "light";
        }

#else
        const QPalette defaultPalette;
        const auto text = defaultPalette.color(QPalette::WindowText);
        const auto window = defaultPalette.color(QPalette::Window);
        if(text.lightness() > window.lightness())
            m_iconShade = "light";
#endif

    } else {

        QColor baseCol(name);

        curPalette = QPalette(QColor(name));

        if(baseCol.lightness() < lightness_threshold) {

            m_iconShade = "light";

            curPalette.setColor(QPalette::Base, baseCol);
            curPalette.setColor(QPalette::AlternateBase, baseCol.lighter(115));

            QColor coltxt(255,255,255);
            QColor hightxt = coltxt;
            hightxt.setAlpha(125);
            curPalette.setColor(QPalette::HighlightedText, coltxt);
            curPalette.setColor(QPalette::Highlight, hightxt);

            curPalette.setColor(QPalette::Disabled, QPalette::Text, curPalette.color(QPalette::Text).darker(200));

        } else {

            m_iconShade = "dark";

            curPalette.setColor(QPalette::Base, baseCol);
            curPalette.setColor(QPalette::AlternateBase, baseCol.darker(105));

            QColor coltxt(0,0,0);
            QColor hightxt = coltxt;
            hightxt.setAlpha(125);
            curPalette.setColor(QPalette::HighlightedText, coltxt);
            curPalette.setColor(QPalette::Highlight, hightxt);

            curPalette.setColor(QPalette::Disabled, QPalette::Text, curPalette.color(QPalette::Text).lighter(200));

        }

    }

    QColor bb = curPalette.text().color();
    bb.setAlpha(50);
    m_baseBorder = bb.name(QColor::HexArgb);

    m_highlightedText = curPalette.highlightedText().color().name(QColor::HexArgb);
    m_highlight = curPalette.highlight().color().name(QColor::HexArgb);

    m_brightText = curPalette.brightText().color().name(QColor::HexArgb);

    qApp->setPalette(curPalette);

}

QString PQCLook::getIconShade() {
    return m_iconShade;
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

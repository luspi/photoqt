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

#include <qml/pqc_look.h>
#include <shared/pqc_csettings.h>
#include <shared/pqc_configfiles.h>

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

    m_interfaceModernVariant = (PQCCSettings::get().getGeneralInterfaceVariant() == "modern");

    calculateFontSizes(11);

    m_fontWeightNormal = std::min(900, std::max(100, PQCCSettings::get().getInterfaceFontNormalWeight()));
    m_fontWeightBold = std::min(900, std::max(100, PQCCSettings::get().getInterfaceFontBoldWeight()));

    lightness_threshold = 96;

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

        calculateColors(PQCCSettings::get().getInterfaceAccentColor());

        connect(&PQCCSettings::get(), &PQCCSettings::interfaceAccentColorChanged, this, [=]() {

            const QString val = PQCCSettings::get().getInterfaceAccentColor();
            calculateColors(val.startsWith("#") ? val : QColor(val).name(QColor::HexArgb));

            Q_EMIT iconShadeChanged();
            Q_EMIT baseBorderChanged();
            Q_EMIT tooltipTextChanged();
            Q_EMIT tooltipBaseChanged();
            Q_EMIT tooltipBorderChanged();

        });

    }

    connect(&PQCCSettings::get(), &PQCCSettings::interfaceFontBoldWeightChanged, this, [=]() {

        m_fontWeightBold = PQCCSettings::get().getInterfaceFontBoldWeight();
        Q_EMIT fontWeightBoldChanged();

    });
    connect(&PQCCSettings::get(), &PQCCSettings::interfaceFontNormalWeightChanged, this, [=]() {

        m_fontWeightNormal = PQCCSettings::get().getInterfaceFontNormalWeight();
        Q_EMIT fontWeightNormalChanged();

    });

}

void PQCLook::testColor(QString color) {

    if(color == "") {

        Q_EMIT PQCCSettings::get().interfaceAccentColorChanged();

    } else {

        calculateColors(color.startsWith("#") ? color : QColor(color).name(QColor::HexArgb));

        Q_EMIT iconShadeChanged();
        Q_EMIT baseBorderChanged();
        Q_EMIT tooltipTextChanged();
        Q_EMIT tooltipBaseChanged();
        Q_EMIT tooltipBorderChanged();

    }

}

PQCLook::~PQCLook() { }

void PQCLook::calculateColors(QString name) {

    qDebug() << "args: name =" << name;
    qDebug() << "m_interfaceModernVariant =" << m_interfaceModernVariant;

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

        m_pal.setColor(QPalette::Base, baseCol);
        m_pal.setColor(QPalette::Window, baseCol);

        if(baseCol.lightness() < lightness_threshold) {

            m_iconShade = "light";

            m_pal.setColor(QPalette::AlternateBase, baseCol.darker(125));
            m_pal.setColor(QPalette::ToolTipBase, baseCol.darker(30));

            QColor coltxt(255,255,255);
            m_pal.setColor(QPalette::Normal, QPalette::Text, coltxt);
            m_pal.setColor(QPalette::Normal, QPalette::WindowText, coltxt);
            m_pal.setColor(QPalette::Disabled, QPalette::Text, coltxt.darker(150));
            m_pal.setColor(QPalette::Disabled, QPalette::WindowText, coltxt.darker(150));

            QColor hightxt = coltxt;
            hightxt.setAlpha(125);
            m_pal.setColor(QPalette::HighlightedText, coltxt);
            m_pal.setColor(QPalette::Highlight, hightxt);

            m_pal.setColor(QPalette::PlaceholderText, coltxt.darker(100));
            m_pal.setColor(QPalette::ToolTipText, coltxt.darker(30));

            m_pal.setColor(QPalette::Button, baseCol.lighter(50));
            m_pal.setColor(QPalette::ButtonText, coltxt);

            m_pal.setColor(QPalette::BrightText, QColor(75,75,75));

        } else {

            m_iconShade = "dark";

            m_pal.setColor(QPalette::AlternateBase, baseCol.lighter(125));
            m_pal.setColor(QPalette::ToolTipBase, baseCol.lighter(30));

            QColor coltxt(0,0,0);
            m_pal.setColor(QPalette::Normal, QPalette::Text, coltxt);
            m_pal.setColor(QPalette::Normal, QPalette::WindowText, coltxt);
            m_pal.setColor(QPalette::Disabled, QPalette::Text, coltxt.lighter(150));
            m_pal.setColor(QPalette::Disabled, QPalette::WindowText, coltxt.lighter(150));

            QColor hightxt = coltxt;
            hightxt.setAlpha(125);
            m_pal.setColor(QPalette::HighlightedText, coltxt);
            m_pal.setColor(QPalette::Highlight, hightxt);

            m_pal.setColor(QPalette::PlaceholderText, coltxt.lighter(100));
            m_pal.setColor(QPalette::ToolTipText, coltxt.lighter(30));

            m_pal.setColor(QPalette::Button, baseCol.darker(50));
            m_pal.setColor(QPalette::ButtonText, coltxt);

            m_pal.setColor(QPalette::BrightText, QColor(180, 180, 180));

        }

        qApp->setPalette(m_pal);

    }

    QColor bb = m_pal.text().color();
    bb.setAlpha(50);
    m_baseBorder = bb.name(QColor::HexArgb);

    m_highlightedText = m_pal.highlightedText().color().name(QColor::HexArgb);
    m_highlight = m_pal.highlight().color().name(QColor::HexArgb);

    m_tooltipBase = m_pal.toolTipBase().color().name(QColor::HexArgb);
    QColor col = m_pal.toolTipText().color();
    m_tooltipText = col.name(QColor::HexArgb);
    col.setAlpha(175);
    m_tooltipBorder = col.name(QColor::HexArgb);

    m_brightText = m_pal.brightText().color().name(QColor::HexArgb);

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

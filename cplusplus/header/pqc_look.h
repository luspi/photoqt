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

#ifndef PQCLOOK_H
#define PQCLOOK_H

#include <QObject>
#include <QHash>
#include <QQmlEngine>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCLook : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit PQCLook();
    ~PQCLook();

    void calculateColors(QString name);

    Q_PROPERTY(QString iconShade READ getIconShade NOTIFY iconShadeChanged)
    QString getIconShade();
    /******************************************************/
    /******************************************************/

    Q_PROPERTY(QString tooltipText MEMBER m_tooltipText NOTIFY tooltipTextChanged)
    Q_PROPERTY(QString tooltipBase MEMBER m_tooltipBase NOTIFY tooltipBaseChanged)
    Q_PROPERTY(QString tooltipBorder MEMBER m_tooltipBorder NOTIFY tooltipBorderChanged)

    /******************************************************/
    /******************************************************/

    Q_PROPERTY(QString baseColor READ getBaseColor WRITE setBaseColor NOTIFY baseColorChanged)
    Q_PROPERTY(QString baseColorAccent MEMBER m_baseColorAccent NOTIFY baseColorAccentChanged)
    Q_PROPERTY(QString baseColorHighlight MEMBER m_baseColorHighlight NOTIFY baseColorHighlightChanged)
    Q_PROPERTY(QString baseColorActive MEMBER m_baseColorActive NOTIFY baseColorActiveChanged)
    void setBaseColor(QString val);
    QString getBaseColor();

    /******************************************************/

    Q_PROPERTY(QString inverseColor MEMBER m_inverseColor NOTIFY inverseColorChanged)
    Q_PROPERTY(QString inverseColorAccent MEMBER m_inverseColorAccent NOTIFY inverseColorAccentChanged)
    Q_PROPERTY(QString inverseColorHighlight MEMBER m_inverseColorHighlight NOTIFY inverseColorHighlightChanged)
    Q_PROPERTY(QString inverseColorActive MEMBER m_inverseColorActive NOTIFY inverseColorActiveChanged)

    /******************************************************/

    Q_PROPERTY(QString transColor MEMBER m_transColor NOTIFY transColorChanged)
    Q_PROPERTY(QString transColorAccent MEMBER m_transColorAccent NOTIFY transColorAccentChanged)
    Q_PROPERTY(QString transColorHighlight MEMBER m_transColorHighlight NOTIFY transColorHighlightChanged)
    Q_PROPERTY(QString transColorActive MEMBER m_transColorActive NOTIFY transColorActiveChanged)

    /******************************************************/

    Q_PROPERTY(QString transInverseColor MEMBER m_transInverseColor NOTIFY transInverseColorChanged)

    /******************************************************/

    Q_PROPERTY(QString textColor MEMBER m_textColor NOTIFY textColorChanged)
    Q_PROPERTY(QString textColorDisabled MEMBER m_textColorDisabled NOTIFY textColorDisabledChanged)

    /******************************************************/

    Q_PROPERTY(QString textInverseColor MEMBER m_textInverseColor NOTIFY textInverseColorChanged)
    Q_PROPERTY(QString textInverseColorHighlight MEMBER m_textInverseColorHighlight NOTIFY textInverseColorHighlightChanged)
    Q_PROPERTY(QString textInverseColorActive MEMBER m_textInverseColorActive NOTIFY textInverseColorActiveChanged)

    /******************************************************/

    Q_PROPERTY(int fontSize READ getFontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(int fontSizeS MEMBER m_fontSizeS NOTIFY fontSizeSChanged)
    Q_PROPERTY(int fontSizeL MEMBER m_fontSizeL NOTIFY fontSizeLChanged)
    Q_PROPERTY(int fontSizeXL MEMBER m_fontSizeXL NOTIFY fontSizeXLChanged)
    Q_PROPERTY(int fontSizeXXL MEMBER m_fontSizeXXL NOTIFY fontSizeXXLChanged)
    void setFontSize(int val);
    int getFontSize();
    void calculateFontSizes(int sze);

    /******************************************************/

    Q_PROPERTY(int fontWeightBold MEMBER m_fontWeightBold NOTIFY fontWeightBoldChanged)
    Q_PROPERTY(int fontWeightNormal MEMBER m_fontWeightNormal NOTIFY fontWeightNormalChanged)

    /******************************************************/

    Q_INVOKABLE QStringList getColorNames();
    Q_INVOKABLE QStringList getColorHexes();

private:
    int lightness_threshold;

    QString m_iconShade;
    QString m_tooltipText;
    QString m_tooltipBase;
    QString m_tooltipBorder;

    QString m_baseColor;
    QString m_baseColorAccent;
    QString m_baseColorHighlight;
    QString m_baseColorActive;

    QString m_inverseColor;
    QString m_inverseColorAccent;
    QString m_inverseColorHighlight;
    QString m_inverseColorActive;

    QString m_transColor;
    QString m_transColorAccent;
    QString m_transColorHighlight;
    QString m_transColorActive;

    QString m_transInverseColor;

    QString m_textColor;
    QString m_textColorDisabled;

    QString m_textInverseColor;
    QString m_textInverseColorHighlight;
    QString m_textInverseColorActive;

    int m_fontSize;
    int m_fontSizeS;
    int m_fontSizeL;
    int m_fontSizeXL;
    int m_fontSizeXXL;

    int m_fontWeightBold;
    int m_fontWeightNormal;

    QStringList colorNames;
    QStringList colorHexes;

    bool m_interfaceModernVariant;

Q_SIGNALS:
    void baseColorChanged();
    void baseColorAccentChanged();
    void baseColorHighlightChanged();
    void baseColorActiveChanged();

    void inverseColorChanged();
    void inverseColorAccentChanged();
    void inverseColorHighlightChanged();
    void inverseColorActiveChanged();

    void transColorChanged();
    void transColorAccentChanged();
    void transColorHighlightChanged();
    void transColorActiveChanged();

    void transInverseColorChanged();

    void textColorChanged();
    void textColorDisabledChanged();

    void textInverseColorChanged();
    void textInverseColorHighlightChanged();
    void textInverseColorActiveChanged();

    void fontSizeChanged();
    void fontSizeSChanged();
    void fontSizeLChanged();
    void fontSizeXLChanged();
    void fontSizeXXLChanged();

    void fontWeightBoldChanged();
    void fontWeightNormalChanged();

    void iconShadeChanged();
    void tooltipTextChanged();
    void tooltipBaseChanged();
    void tooltipBorderChanged();

};

#endif

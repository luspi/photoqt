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
#include <QPalette>

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

    Q_PROPERTY(QString baseBorder MEMBER m_baseBorder NOTIFY baseBorderChanged)
    Q_PROPERTY(QString highlightedText MEMBER m_highlightedText NOTIFY highlightedTextChanged)
    Q_PROPERTY(QString highlight MEMBER m_highlight NOTIFY highlightChanged)
    Q_PROPERTY(QString brightText MEMBER m_brightText NOTIFY brightTextChanged)

    /******************************************************/
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
    Q_INVOKABLE void testColor(QString color);

private:
    int lightness_threshold;

    QString m_iconShade;
    QString m_highlightedText;
    QString m_highlight;
    QString m_baseBorder;
    QString m_brightText;

    QPalette m_pal;

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
    void fontSizeChanged();
    void fontSizeSChanged();
    void fontSizeLChanged();
    void fontSizeXLChanged();
    void fontSizeXXLChanged();

    void fontWeightBoldChanged();
    void fontWeightNormalChanged();

    void iconShadeChanged();
    void highlightedTextChanged();
    void highlightChanged();
    void baseBorderChanged();
    void brightTextChanged();

};

#endif

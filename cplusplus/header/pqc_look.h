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

#ifndef PQCLOOK_H
#define PQCLOOK_H

#include <QObject>
#include <QHash>

class PQCLook : public QObject {

    Q_OBJECT

public:
    static PQCLook& get();
    ~PQCLook();

    PQCLook(PQCLook const&)        = delete;
    void operator=(PQCLook const&) = delete;

    void calculateColors(QString base);

    /******************************************************/

    Q_PROPERTY(QString baseColor READ getBaseColor WRITE setBaseColor NOTIFY baseColorChanged)
    Q_PROPERTY(QString baseColorAccent READ getBaseColorAccent NOTIFY baseColorAccentChanged)
    Q_PROPERTY(QString baseColorHighlight READ getBaseColorHighlight NOTIFY baseColorHighlightChanged)
    Q_PROPERTY(QString baseColorActive READ getBaseColorActive NOTIFY baseColorActiveChanged)
    void setBaseColor(QString val);
    QString getBaseColor();
    QString getBaseColorAccent();
    QString getBaseColorHighlight();
    QString getBaseColorActive();

    /******************************************************/

    Q_PROPERTY(QString inverseColor READ getInverseColor NOTIFY inverseColorChanged)
    Q_PROPERTY(QString inverseColorHighlight READ getInverseColorHighlight NOTIFY inverseColorHighlightChanged)
    Q_PROPERTY(QString inverseColorActive READ getInverseColorActive NOTIFY inverseColorActiveChanged)
    QString getInverseColor();
    QString getInverseColorHighlight();
    QString getInverseColorActive();

    /******************************************************/

    Q_PROPERTY(QString faintColor READ getFaintColor NOTIFY faintColorChanged)
    Q_PROPERTY(QString transColor READ getTransColor NOTIFY transColorChanged)
    Q_PROPERTY(QString transColorAccent READ getTransColorAccent NOTIFY transColorAccentChanged)
    Q_PROPERTY(QString transColorHighlight READ getTransColorHighlight NOTIFY transColorHighlightChanged)
    Q_PROPERTY(QString transColorActive READ getTransColorActive NOTIFY transColorActiveChanged)
    QString getFaintColor();
    QString getTransColor();
    QString getTransColorAccent();
    QString getTransColorHighlight();
    QString getTransColorActive();

    /******************************************************/

    Q_PROPERTY(QString textColor READ getTextColor NOTIFY textColorChanged)
    Q_PROPERTY(QString textColorDisabled READ getTextColorDisabled NOTIFY textColorDisabledChanged)
    QString getTextColor();
    QString getTextColorDisabled();

    /******************************************************/

    Q_PROPERTY(QString textInverseColor READ getTextInverseColor NOTIFY textInverseColorChanged)
    Q_PROPERTY(QString textInverseColorHighlight READ getTextInverseColorHighlight NOTIFY textInverseColorHighlightChanged)
    Q_PROPERTY(QString textInverseColorActive READ getTextInverseColorActive NOTIFY textInverseColorActiveChanged)
    QString getTextInverseColor();
    QString getTextInverseColorHighlight();
    QString getTextInverseColorActive();

    /******************************************************/

    Q_PROPERTY(int fontSize READ getFontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(int fontSizeS READ getFontSizeS NOTIFY fontSizeSChanged)
    Q_PROPERTY(int fontSizeL READ getFontSizeL NOTIFY fontSizeLChanged)
    Q_PROPERTY(int fontSizeXL READ getFontSizeXL NOTIFY fontSizeXLChanged)
    Q_PROPERTY(int fontSizeXXL READ getFontSizeXXL NOTIFY fontSizeXXLChanged)
    void setFontSize(int val);
    int getFontSize();
    int getFontSizeS();
    int getFontSizeL();
    int getFontSizeXL();
    int getFontSizeXXL();

    void calculateFontSizes(int sze);

    /******************************************************/

    Q_PROPERTY(int fontWeightBold READ getFontWeightBold WRITE setFontWeightBold NOTIFY fontWeightBoldChanged)
    Q_PROPERTY(int fontWeightNormal READ getFontWeightNormal WRITE setFontWeightNormal NOTIFY fontWeightNormalChanged)
    int getFontWeightBold();
    int getFontWeightNormal();
    void setFontWeightBold(int val);
    void setFontWeightNormal(int val);

    /******************************************************/

    Q_INVOKABLE QStringList getColorNames();

private:
    PQCLook();

    QString m_baseColor;
    QString m_baseColorAccent;
    QString m_baseColorHighlight;
    QString m_baseColorActive;

    QString m_inverseColor;
    QString m_inverseColorHighlight;
    QString m_inverseColorActive;

    QString m_faintColor;
    QString m_transColor;
    QString m_transColorAccent;
    QString m_transColorHighlight;
    QString m_transColorActive;

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

    QHash<QString,QString> colorNameToHex;
    QStringList colorNames;

Q_SIGNALS:
    void baseColorChanged();
    void baseColorAccentChanged();
    void baseColorHighlightChanged();
    void baseColorActiveChanged();

    void inverseColorChanged();
    void inverseColorHighlightChanged();
    void inverseColorActiveChanged();

    void faintColorChanged();
    void transColorChanged();
    void transColorAccentChanged();
    void transColorHighlightChanged();
    void transColorActiveChanged();

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

};

#endif

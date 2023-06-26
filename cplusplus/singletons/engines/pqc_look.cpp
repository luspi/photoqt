#include <pqc_look.h>
#include <QColor>
#include <QFont>
#include <QtDebug>

PQCLook::PQCLook() {

    calculateColors("#ff0a0a0a");

    calculateFontSizes(11);

    m_fontWeightBold = QFont::Bold;
    m_fontWeightNormal = QFont::Normal;

}

PQCLook &PQCLook::get() {
    static PQCLook instance;
    return instance;
}

PQCLook::~PQCLook() { }

void PQCLook::calculateColors(QString base) {

    QColor col = QColor::fromString(base);

    QColor colTrans = col;
    colTrans.setAlpha(222);

    m_baseColor = base;
    m_transColor = colTrans.name(QColor::HexArgb);

    bool darkcolor = false;
    if(col.toHsv().value() < 128)
        darkcolor = true;

    QColor invcol((255-col.red()), (255-col.green()), (255-col.blue()));
    m_highlightColor = invcol.name(QColor::HexArgb);

    if(darkcolor) {

        m_baseColorDisabled = col.lighter(300).name(QColor::HexArgb);
        m_baseColorContrast = col.lighter(900).name(QColor::HexArgb);

        m_highlightColorDisabled = invcol.darker(300).name(QColor::HexArgb);
        m_highlightColorContrast = invcol.darker(900).name(QColor::HexArgb);

        m_transColorDisabled = colTrans.lighter(300).name(QColor::HexArgb);
        m_transColorContrast = colTrans.lighter(900).name(QColor::HexArgb);

        QColor colText = QColor(255,255,255);
        m_textColor = colText.name(QColor::HexArgb);
        m_textColorDisabled = colText.darker(300).name(QColor::HexArgb);
        m_textColorContrast = colText.darker(900).name(QColor::HexArgb);

        QColor colHighlightText = QColor(75,75,75);
        m_textHighlightColor = colHighlightText.name(QColor::HexArgb);
        m_textHighlightColorDisabled = colHighlightText.lighter(300).name(QColor::HexArgb);
        m_textHighlightColorContrast = colHighlightText.lighter(900).name(QColor::HexArgb);

    } else {

        m_baseColorDisabled = col.darker(300).name(QColor::HexArgb);
        m_baseColorContrast = col.darker(900).name(QColor::HexArgb);

        m_highlightColorDisabled = invcol.lighter(300).name(QColor::HexArgb);
        m_highlightColorContrast = invcol.lighter(900).name(QColor::HexArgb);

        m_transColorDisabled = colTrans.darker(300).name(QColor::HexArgb);
        m_transColorContrast = colTrans.darker(900).name(QColor::HexArgb);

        QColor colText = QColor(0,0,0);
        m_textColor = colText.name(QColor::HexArgb);
        m_textColorDisabled = colText.lighter(300).name(QColor::HexArgb);
        m_textColorContrast = colText.lighter(900).name(QColor::HexArgb);

        QColor colHighlightText = QColor(180,180,180);
        m_textHighlightColor = colHighlightText.name(QColor::HexArgb);
        m_textHighlightColorDisabled = colHighlightText.darker(300).name(QColor::HexArgb);
        m_textHighlightColorContrast = colHighlightText.darker(900).name(QColor::HexArgb);

    }

}

/******************************************************/

QString PQCLook::getBaseColor() {
    return m_baseColor;
}
QString PQCLook::getBaseColorContrast() {
    return m_baseColorContrast;
}
QString PQCLook::getBaseColorDisabled() {
    return m_baseColorDisabled;
}

void PQCLook::setBaseColor(QString val) {

    if(val != m_baseColor) {

        calculateColors(val);

        Q_EMIT baseColorChanged();
        Q_EMIT baseColorContrastChanged();
        Q_EMIT baseColorDisabledChanged();

        Q_EMIT highlightColorChanged();
        Q_EMIT highlightColorContrastChanged();
        Q_EMIT highlightColorDisabledChanged();

        Q_EMIT transColorChanged();
        Q_EMIT transColorContrastChanged();
        Q_EMIT transColorDisabledChanged();

        Q_EMIT textColorChanged();
        Q_EMIT textColorContrastChanged();
        Q_EMIT textColorDisabledChanged();

        Q_EMIT textHighlightColorChanged();
        Q_EMIT textHighlightColorContrastChanged();
        Q_EMIT textHighlightColorDisabledChanged();

    }

}

/******************************************************/

QString PQCLook::getHighlightColor() {
    return m_highlightColor;
}

QString PQCLook::getHighlightColorContrast() {
    return m_highlightColorContrast;
}

QString PQCLook::getHighlightColorDisabled() {
    return m_highlightColorDisabled;
}

/******************************************************/

QString PQCLook::getTransColor() {
    return m_transColor;
}
QString PQCLook::getTransColorContrast() {
    return m_transColorContrast;
}
QString PQCLook::getTransColorDisabled() {
    return m_transColorDisabled;
}

/******************************************************/

QString PQCLook::getTextColor() { return m_textColor; }
QString PQCLook::getTextColorContrast() { return m_textColorContrast; }
QString PQCLook::getTextColorDisabled() { return m_textColorDisabled; }

/******************************************************/

QString PQCLook::getTextHighlightColor() { return m_textHighlightColor; }
QString PQCLook::getTextHighlightColorContrast() { return m_textHighlightColorContrast; }
QString PQCLook::getTextHighlightColorDisabled() { return m_textHighlightColorDisabled; }

/******************************************************/

void PQCLook::setFontSize(int val) {
    if(val != m_fontSize) {
        calculateFontSizes(val);
        Q_EMIT fontSizeChanged();
        Q_EMIT fontSizeSChanged();
        Q_EMIT fontSizeLChanged();
        Q_EMIT fontSizeXLChanged();
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

void PQCLook::calculateFontSizes(int sze) {
    m_fontSize = sze;
    m_fontSizeS = sze-3;
    m_fontSizeL = sze+4;
    m_fontSizeXL = sze+9;
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



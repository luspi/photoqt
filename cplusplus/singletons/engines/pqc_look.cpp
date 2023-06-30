#include <pqc_look.h>
#include <QColor>
#include <QFont>
#include <QtDebug>

PQCLook::PQCLook() {

    calculateColors("#ff111111");

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
    m_inverseColor = invcol.name(QColor::HexArgb);

    if(darkcolor) {

        m_baseColorAccent = col.lighter(150).name(QColor::HexArgb);
        m_baseColorHighlight = col.lighter(300).name(QColor::HexArgb);
        m_baseColorActive = col.lighter(900).name(QColor::HexArgb);

        m_inverseColorHighlight = invcol.darker(300).name(QColor::HexArgb);
        m_inverseColorActive = invcol.darker(900).name(QColor::HexArgb);

        m_transColorAccent = colTrans.lighter(150).name(QColor::HexArgb);
        m_transColorHighlight = colTrans.lighter(300).name(QColor::HexArgb);
        m_transColorActive = colTrans.lighter(900).name(QColor::HexArgb);

        QColor colText = QColor(255,255,255);
        m_textColor = colText.name(QColor::HexArgb);
        m_textColorHighlight = colText.darker(300).name(QColor::HexArgb);
        m_textColorActive = colText.darker(900).name(QColor::HexArgb);

        QColor colInverseText = QColor(75,75,75);
        m_textInverseColor = colInverseText.name(QColor::HexArgb);
        m_textInverseColorHighlight = colInverseText.lighter(300).name(QColor::HexArgb);
        m_textInverseColorActive = colInverseText.lighter(900).name(QColor::HexArgb);

    } else {

        m_baseColorAccent = col.darker(150).name(QColor::HexArgb);
        m_baseColorHighlight = col.darker(300).name(QColor::HexArgb);
        m_baseColorActive = col.darker(900).name(QColor::HexArgb);

        m_inverseColorHighlight = invcol.lighter(300).name(QColor::HexArgb);
        m_inverseColorActive = invcol.lighter(900).name(QColor::HexArgb);

        m_transColorAccent = colTrans.darker(150).name(QColor::HexArgb);
        m_transColorHighlight = colTrans.darker(300).name(QColor::HexArgb);
        m_transColorActive = colTrans.darker(900).name(QColor::HexArgb);

        QColor colText = QColor(0,0,0);
        m_textColor = colText.name(QColor::HexArgb);
        m_textColorHighlight = colText.lighter(300).name(QColor::HexArgb);
        m_textColorActive = colText.lighter(900).name(QColor::HexArgb);

        QColor colInverseText = QColor(180,180,180);
        m_textInverseColor = colInverseText.name(QColor::HexArgb);
        m_textInverseColorHighlight = colInverseText.darker(300).name(QColor::HexArgb);
        m_textInverseColorActive = colInverseText.darker(900).name(QColor::HexArgb);

    }

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
        Q_EMIT textColorActiveChanged();
        Q_EMIT textColorHighlightChanged();

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
QString PQCLook::getTextColorActive() { return m_textColorActive; }
QString PQCLook::getTextColorHighlight() { return m_textColorHighlight; }

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



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
    QColor colT = col;
    colT.setAlpha(222);

    m_baseColor = base;
    m_transColor = colT.name(QColor::HexArgb);

    bool darkcolor = false;
    if(col.toHsv().value() < 128)
        darkcolor = true;

    QColor invcol(0.8*(255-col.red()), 0.8*(255-col.green()), 0.8*(255-col.blue()));
    QColor invcolhalf((col.red()+invcol.red())/2, (col.green()+invcol.green())/2, (col.blue()+invcol.blue())/2);
    m_highlightColor = invcol.name(QColor::HexArgb);
    m_highlightColor75 = invcolhalf.name(QColor::HexArgb);

    if(darkcolor) {

        m_baseColor75 = col.lighter(600).name(QColor::HexArgb);
        m_baseColor50 = col.lighter(900).name(QColor::HexArgb);

        m_transColor75 = colT.lighter(600).name(QColor::HexArgb);
        m_transColor50 = colT.lighter(900).name(QColor::HexArgb);

        m_textColor = QColor(255,255,255).name(QColor::HexArgb);
        m_textColor75 = QColor(196,196,196).name(QColor::HexArgb);

        m_textHighlightColor = QColor(75,75,75).name(QColor::HexArgb);
        m_textHighlightColor75 = QColor(40,40,40).name(QColor::HexArgb);

    } else {

        m_baseColor75 = col.darker(600).name(QColor::HexArgb);
        m_baseColor50 = col.darker(900).name(QColor::HexArgb);

        m_transColor75 = colT.darker(600).name(QColor::HexArgb);
        m_transColor50 = colT.darker(900).name(QColor::HexArgb);

        m_textColor = QColor(0,0,0).name(QColor::HexArgb);
        m_textColor75 = QColor(60,60,60).name(QColor::HexArgb);

        m_textHighlightColor = QColor(165,165,165).name(QColor::HexArgb);
        m_textHighlightColor75 = QColor(210,210,210).name(QColor::HexArgb);

    }

}

/******************************************************/

QString PQCLook::getBaseColor() {
    return m_baseColor;
}
QString PQCLook::getBaseColor50() {
    return m_baseColor50;
}
QString PQCLook::getBaseColor75() {
    return m_baseColor75;
}

void PQCLook::setBaseColor(QString val) {

    if(val != m_baseColor) {

        calculateColors(val);

        Q_EMIT baseColorChanged();
        Q_EMIT baseColor50Changed();
        Q_EMIT baseColor75Changed();

        Q_EMIT highlightColorChanged();
        Q_EMIT highlightColor75Changed();

        Q_EMIT transColorChanged();
        Q_EMIT transColor50Changed();
        Q_EMIT transColor75Changed();

        Q_EMIT textColorChanged();
        Q_EMIT textColor75Changed();

        Q_EMIT textHighlightColorChanged();
        Q_EMIT textHighlightColor75Changed();

    }

}

/******************************************************/

QString PQCLook::getHighlightColor() {
    return m_highlightColor;
}

QString PQCLook::getHighlightColor75() {
    return m_highlightColor75;
}

/******************************************************/

QString PQCLook::getTransColor() {
    return m_transColor;
}
QString PQCLook::getTransColor50() {
    return m_transColor50;
}
QString PQCLook::getTransColor75() {
    return m_transColor75;
}

/******************************************************/

QString PQCLook::getTextColor() { return m_textColor; }
QString PQCLook::getTextColor75() { return m_textColor75; }

/******************************************************/

QString PQCLook::getTextHighlightColor() { return m_textHighlightColor; }
QString PQCLook::getTextHighlightColor75() { return m_textHighlightColor75; }

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



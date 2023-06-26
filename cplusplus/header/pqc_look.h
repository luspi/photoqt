#ifndef PQCLOOK_H
#define PQCLOOK_H

#include <QObject>

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
    Q_PROPERTY(QString baseColorContrast READ getBaseColorContrast NOTIFY baseColorContrastChanged)
    Q_PROPERTY(QString baseColorDisabled READ getBaseColorDisabled NOTIFY baseColorDisabledChanged)
    void setBaseColor(QString val);
    QString getBaseColor();
    QString getBaseColorContrast();
    QString getBaseColorDisabled();

    /******************************************************/

    Q_PROPERTY(QString highlightColor READ getHighlightColor NOTIFY highlightColorChanged)
    Q_PROPERTY(QString highlightColorContrast READ getHighlightColorContrast NOTIFY highlightColorContrastChanged)
    Q_PROPERTY(QString highlightColorDisabled READ getHighlightColorDisabled NOTIFY highlightColorDisabledChanged)
    QString getHighlightColor();
    QString getHighlightColorContrast();
    QString getHighlightColorDisabled();

    /******************************************************/

    Q_PROPERTY(QString transColor READ getTransColor NOTIFY transColorChanged)
    Q_PROPERTY(QString transColorContrast READ getTransColorContrast NOTIFY transColorContrastChanged)
    Q_PROPERTY(QString transColorDisabled READ getTransColorDisabled NOTIFY transColorDisabledChanged)
    QString getTransColor();
    QString getTransColorContrast();
    QString getTransColorDisabled();

    /******************************************************/

    Q_PROPERTY(QString textColor READ getTextColor NOTIFY textColorChanged)
    Q_PROPERTY(QString textColorContrast READ getTextColorContrast NOTIFY textColorContrastChanged)
    Q_PROPERTY(QString textColorDisabled READ getTextColorDisabled NOTIFY textColorDisabledChanged)
    QString getTextColor();
    QString getTextColorContrast();
    QString getTextColorDisabled();

    /******************************************************/

    Q_PROPERTY(QString textHighlightColor READ getTextHighlightColor NOTIFY textHighlightColorChanged)
    Q_PROPERTY(QString textHighlightColorContrast READ getTextHighlightColorContrast NOTIFY textHighlightColorContrastChanged)
    Q_PROPERTY(QString textHighlightColorDisabled READ getTextHighlightColorDisabled NOTIFY textHighlightColorDisabledChanged)
    QString getTextHighlightColor();
    QString getTextHighlightColorContrast();
    QString getTextHighlightColorDisabled();

    /******************************************************/

    Q_PROPERTY(int fontSize READ getFontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(int fontSizeS READ getFontSizeS NOTIFY fontSizeSChanged)
    Q_PROPERTY(int fontSizeL READ getFontSizeL NOTIFY fontSizeLChanged)
    Q_PROPERTY(int fontSizeXL READ getFontSizeXL NOTIFY fontSizeXLChanged)
    void setFontSize(int val);
    int getFontSize();
    int getFontSizeS();
    int getFontSizeL();
    int getFontSizeXL();

    void calculateFontSizes(int sze);

    /******************************************************/

    Q_PROPERTY(int fontWeightBold READ getFontWeightBold WRITE setFontWeightBold NOTIFY fontWeightBoldChanged)
    Q_PROPERTY(int fontWeightNormal READ getFontWeightNormal WRITE setFontWeightNormal NOTIFY fontWeightNormalChanged)
    int getFontWeightBold();
    int getFontWeightNormal();
    void setFontWeightBold(int val);
    void setFontWeightNormal(int val);

private:
    PQCLook();

    QString m_baseColor;
    QString m_baseColorContrast;
    QString m_baseColorDisabled;

    QString m_highlightColor;
    QString m_highlightColorContrast;
    QString m_highlightColorDisabled;

    QString m_transColor;
    QString m_transColorContrast;
    QString m_transColorDisabled;

    QString m_textColor;
    QString m_textColorContrast;
    QString m_textColorDisabled;

    QString m_textHighlightColor;
    QString m_textHighlightColorContrast;
    QString m_textHighlightColorDisabled;

    int m_fontSize;
    int m_fontSizeS;
    int m_fontSizeL;
    int m_fontSizeXL;

    int m_fontWeightBold;
    int m_fontWeightNormal;

Q_SIGNALS:
    void baseColorChanged();
    void baseColorContrastChanged();
    void baseColorDisabledChanged();

    void highlightColorChanged();
    void highlightColorContrastChanged();
    void highlightColorDisabledChanged();

    void transColorChanged();
    void transColorContrastChanged();
    void transColorDisabledChanged();

    void textColorChanged();
    void textColorContrastChanged();
    void textColorDisabledChanged();

    void textHighlightColorChanged();
    void textHighlightColorContrastChanged();
    void textHighlightColorDisabledChanged();

    void fontSizeChanged();
    void fontSizeSChanged();
    void fontSizeLChanged();
    void fontSizeXLChanged();

    void fontWeightBoldChanged();
    void fontWeightNormalChanged();

};

#endif

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
    Q_PROPERTY(QString baseColor50 READ getBaseColor50 NOTIFY baseColor50Changed)
    Q_PROPERTY(QString baseColor75 READ getBaseColor75 NOTIFY baseColor75Changed)
    void setBaseColor(QString val);
    QString getBaseColor();
    QString getBaseColor50();
    QString getBaseColor75();

    /******************************************************/

    Q_PROPERTY(QString highlightColor READ getHighlightColor NOTIFY highlightColorChanged)
    Q_PROPERTY(QString highlightColor75 READ getHighlightColor75 NOTIFY highlightColor75Changed)
    QString getHighlightColor();
    QString getHighlightColor75();

    /******************************************************/

    Q_PROPERTY(QString transColor READ getTransColor NOTIFY transColorChanged)
    Q_PROPERTY(QString transColor50 READ getTransColor50 NOTIFY transColor50Changed)
    Q_PROPERTY(QString transColor75 READ getTransColor75 NOTIFY transColor75Changed)
    QString getTransColor();
    QString getTransColor50();
    QString getTransColor75();

    /******************************************************/

    Q_PROPERTY(QString textColor READ getTextColor NOTIFY textColorChanged)
    Q_PROPERTY(QString textColor75 READ getTextColor75 NOTIFY textColor75Changed)
    QString getTextColor();
    QString getTextColor75();

    /******************************************************/

    Q_PROPERTY(QString textHighlightColor READ getTextHighlightColor NOTIFY textHighlightColorChanged)
    Q_PROPERTY(QString textHighlightColor75 READ getTextHighlightColor75 NOTIFY textHighlightColor75Changed)
    QString getTextHighlightColor();
    QString getTextHighlightColor75();

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
    QString m_baseColor50;
    QString m_baseColor75;

    QString m_highlightColor;
    QString m_highlightColor75;

    QString m_transColor;
    QString m_transColor50;
    QString m_transColor75;

    QString m_textColor;
    QString m_textColor75;

    QString m_textHighlightColor;
    QString m_textHighlightColor75;

    int m_fontSize;
    int m_fontSizeS;
    int m_fontSizeL;
    int m_fontSizeXL;

    int m_fontWeightBold;
    int m_fontWeightNormal;

Q_SIGNALS:
    void baseColorChanged();
    void baseColor50Changed();
    void baseColor75Changed();

    void highlightColorChanged();
    void highlightColor75Changed();

    void transColorChanged();
    void transColor50Changed();
    void transColor75Changed();

    void textColorChanged();
    void textColor75Changed();

    void textHighlightColorChanged();
    void textHighlightColor75Changed();

    void fontSizeChanged();
    void fontSizeSChanged();
    void fontSizeLChanged();
    void fontSizeXLChanged();

    void fontWeightBoldChanged();
    void fontWeightNormalChanged();

};

#endif

#ifndef PQCLOOK_H
#define PQCLOOK_H

#include <QObject>
#include <QRgb>
#include <QColor>

class PQCLook : public QObject {

    Q_OBJECT

public:
    static PQCLook& get() {
        static PQCLook instance;
        return instance;
    }
    ~PQCLook() {}

    PQCLook(PQCLook const&)        = delete;
    void operator=(PQCLook const&) = delete;

    Q_PROPERTY(QColor baseColor READ getBaseColor WRITE setBaseColor NOTIFY baseColorChanged)
    QColor getBaseColor() { return m_basecolor; }
    void setBaseColor(QColor val) {
        if(val != m_basecolor) {
            m_basecolor = val;
            m_basecolorTrans = m_basecolor;
            m_basecolorTrans.setAlpha(221);
            Q_EMIT baseColorChanged();
            Q_EMIT baseColor50Changed();
            Q_EMIT baseColor75Changed();
            Q_EMIT baseColor90Changed();
            Q_EMIT baseColorTransChanged();
            Q_EMIT baseColor50TransChanged();
            Q_EMIT baseColor75TransChanged();
            Q_EMIT baseColor90TransChanged();
        }
    }

    Q_PROPERTY(QString baseColor50 READ getBaseColor50 NOTIFY baseColor50Changed)
    Q_PROPERTY(QString baseColor75 READ getBaseColor75 NOTIFY baseColor75Changed)
    Q_PROPERTY(QString baseColor90 READ getBaseColor90 NOTIFY baseColor90Changed)
    QString getBaseColor50() { QColor col = m_basecolor.lighter(200); return col.name(); }
    QString getBaseColor75() { QColor col = m_basecolor.lighter(133); return col.name(); }
    QString getBaseColor90() { QColor col = m_basecolor.lighter(111); return col.name(); }

    Q_PROPERTY(QString baseColorTrans READ getBaseColorTrans NOTIFY baseColorTransChanged)
    Q_PROPERTY(QString baseColor50Trans READ getBaseColor50Trans NOTIFY baseColor50TransChanged)
    Q_PROPERTY(QString baseColor75Trans READ getBaseColor75Trans NOTIFY baseColor75TransChanged)
    Q_PROPERTY(QString baseColor90Trans READ getBaseColor90Trans NOTIFY baseColor90TransChanged)
    QString getBaseColorTrans() { return m_basecolorTrans.name(QColor::HexArgb); }
    QString getBaseColor50Trans() { QColor col = m_basecolor.lighter(200); return col.name(QColor::HexArgb); }
    QString getBaseColor75Trans() { QColor col = m_basecolor.lighter(133); return col.name(QColor::HexArgb); }
    QString getBaseColor90Trans() { QColor col = m_basecolor.lighter(111); return col.name(QColor::HexArgb); }

private:
    PQCLook() {
        m_basecolor = QColor(10,10,10);
        m_basecolorTrans = QColor(10,10,10,221);
    }

    QColor m_basecolor;
    QColor m_basecolorTrans;

Q_SIGNALS:
    void baseColorChanged();
    void baseColor50Changed();
    void baseColor75Changed();
    void baseColor90Changed();
    void baseColorTransChanged();
    void baseColor50TransChanged();
    void baseColor75TransChanged();
    void baseColor90TransChanged();

};

#endif

#ifndef TABIMAGEPOSITIONTILE_H
#define TABIMAGEPOSITIONTILE_H

#include <QLabel>

class PQTabImagePositionTile : public QLabel {

    Q_OBJECT

public:
    PQTabImagePositionTile(int id, bool selected);

    void setHovered();
    void setNotHovered();
    void setSelected();

    QString getBorder();

public Q_SLOTS:
    void checkIfIAmStillSelected(int newid);

private:
    int id;
    bool selected;

protected:
    void enterEvent(QEvent *) {
        setHovered();
    }
    void leaveEvent(QEvent *) {
        setNotHovered();
    }
    void mousePressEvent(QMouseEvent *) {
        setSelected();
    }

Q_SIGNALS:
    void newPosSelected(int id);

};

#endif // TABIMAGEPOSITIONTILE_H

#ifndef PRINTOPTIONSPAGE_H
#define PRINTOPTIONSPAGE_H

#include <QWidget>
#include <QLabel>
#include <QtDebug>

class PQTabImageOptions : public QWidget {

    Q_OBJECT

public:
    PQTabImageOptions(QWidget *parent = nullptr);

private:
    int posSelected;

private Q_SLOTS:
    void newPosSelected(int id);

Q_SIGNALS:
    void notifyNewPosSelected(int id);

};

class PQTabImagePositionTile : public QLabel {

    Q_OBJECT

public:
    PQTabImagePositionTile(int id, bool selected) : QLabel() {
        this->setFixedSize(40,40);
        this->id = id;
        this->selected = selected;
        if(selected)
            setSelected();
        else
            setNotHovered();
    }

    void setNotHovered() {
        if(!selected)
            this->setStyleSheet(getBorder()+";background: white;");
    }

    void setHovered() {
        if(!selected)
            this->setStyleSheet(getBorder()+";background: rgba(175,175,175,0.5);");
    }

    void setSelected() {
        this->setStyleSheet(getBorder()+";background: rgb(125,125,125);");
        selected = true;
        newPosSelected(id);
    }

    QString getBorder() {
        QString ret = "border: 1px solid rgb(200,200,200)";
        if(id <= 3)
            ret += ";border-top: 1px solid black";
        if(id > 6)
            ret += ";border-bottom: 1px solid black";
        if(id%3 == 0)
            ret += ";border-right: 1px solid black";
        if((id-1)%3 == 0)
            ret += ";border-left: 1px solid black";
        return ret;
    }

public Q_SLOTS:
    void checkIfIAmStillSelected(int newid) {
        if(newid != id) {
            selected = false;
            setNotHovered();
        }
    }

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


#endif // PRINTOPTIONSPAGE_H

#include "clipboard.h"
#include <QtDebug>
#include <QApplication>

Clipboard::Clipboard(QObject *parent) : QObject(parent) {}

void Clipboard::setText(QString text) {
    QApplication::clipboard()->setText(text, QClipboard::Clipboard);
    QApplication::clipboard()->setText(text, QClipboard::Selection);
}

void Clipboard::setImage(QString filepath) {
    if(filepath.startsWith("file:/"))
        filepath = filepath.remove(0,6);
    if(filepath.startsWith("image://full/"))
        filepath = filepath.remove(0,13);
    QImage img = image.requestImage(filepath,new QSize, QSize());
    img.save("/home/luspi/Desktop/tmp.jpg");
    QApplication::clipboard()->setImage(img, QClipboard::Clipboard);
    QApplication::clipboard()->setImage(img, QClipboard::Selection);
    setText(filepath);
    qDebug() << filepath;
}

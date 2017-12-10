#ifndef CLIPBOARD_H
#define CLIPBOARD_H

#include <QClipboard>
#include <QObject>
#include "../imageprovider/imageproviderfull.h"

class Clipboard : public QObject {

    Q_OBJECT

public:
    explicit Clipboard(QObject *parent = 0);
    Q_INVOKABLE void setText(QString text);
    Q_INVOKABLE void setImage(QString filepath);

private:
    ImageProviderFull image;

};


#endif // CLIPBOARD_H

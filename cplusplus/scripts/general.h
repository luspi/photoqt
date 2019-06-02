#ifndef PQHANDLINGGENERAL_H
#define PQHANDLINGGENERAL_H

#include <QObject>
#include <QRect>

#include "../logger.h"

class PQHandlingGeneral : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE bool isGraphicsMagickSupportEnabled();
    Q_INVOKABLE bool isLibRawSupportEnabled();
    Q_INVOKABLE bool isDevILSupportEnabled();
    Q_INVOKABLE bool isFreeImageSupportEnabled();
    Q_INVOKABLE bool isPopplerSupportEnabled();

    Q_INVOKABLE void saveWindowGeometry(int x, int y, int w, int h, bool maximized);
    Q_INVOKABLE QRect getWindowGeometry();

};

#endif // PQHandlingGeneral

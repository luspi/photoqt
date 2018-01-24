#ifndef HIDECLOSE_H
#define HIDECLOSE_H

#include <QObject>
#include <QQuickView>

#include "settings/settings.h"
#include "scripts/getanddostuff.h"

class HideClose : QObject {

public:
    static void handleCloseEvent(QEvent *e, Settings *settings, QQuickView *view) {

        if(settings->getTrayIcon() != 1) {

            GetAndDoStuff gads;
            gads.storeGeometry(QRect(view->x(), view->y(), view->width(), view->height()));

            e->accept();
            qApp->quit();

        } else
            view->hide();

    }

};

#endif // HIDECLOSE_H

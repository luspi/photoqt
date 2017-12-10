#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QObject>
#include <QQmlApplicationEngine>
#include <iostream>

class MainWindow : public QObject {

    Q_OBJECT

public:
    MainWindow(QQmlApplicationEngine *engine, QObject *parent = 0);

private:
    QQmlApplicationEngine *engine;

};



#endif // MAINWINDOW_H

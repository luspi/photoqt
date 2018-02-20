#ifndef GETANDDOSTUFFCONTEXTTEST_H
#define GETANDDOSTUFFCONTEXTTEST_H

#include <QtTest/QTest>
#include "../scripts/getanddostuff/context.h"
#include "../scripts/getanddostuff/file.h"
#include "../scripts/getanddostuff/manipulation.h"
#include "../scripts/getanddostuff/other.h"

class GetAndDoStuffTest : public QObject {

    Q_OBJECT

private slots:
    void checkIfBinaryExists() {
        GetAndDoStuffContext context;
        QCOMPARE(context.checkIfBinaryExists("abcdefghijklmnopqrstuvwxyz1234567890.abc"), false);
        QCOMPARE(context.checkIfBinaryExists("sh"), true);
        QCOMPARE(context.checkIfBinaryExists(""), false);
    }

    void removePathFromFilename() {
        GetAndDoStuffFile file;
        QCOMPARE(file.removePathFromFilename("/the/path/file.txt"), "file.txt");
        QCOMPARE(file.removePathFromFilename("/the/path/file.txt", false), "file.txt");
        QCOMPARE(file.removePathFromFilename("/the/path/file.txt", true), "file");
        QCOMPARE(file.removePathFromFilename(""), "");
    }

    void removeFilenameFromPath() {
        GetAndDoStuffFile file;
        QCOMPARE(file.removeFilenameFromPath("/the/path/file"), "/the/path");
        QCOMPARE(file.removeFilenameFromPath("file://the/path/file"), "/the/path");
        QCOMPARE(file.removeFilenameFromPath("file:///the/path/file"), "/the/path");
        QCOMPARE(file.removeFilenameFromPath("image://full//the/path/file"), "/the/path");
        QCOMPARE(file.removeFilenameFromPath(""), "");
    }

    void doesThisExist() {
        GetAndDoStuffFile file;
        QString path = QDir::currentPath();
        QCOMPARE(file.doesThisExist(path), true);
        QCOMPARE(file.doesThisExist("file://" + path), true);
        QCOMPARE(file.doesThisExist("file:/" + path), true);
        QCOMPARE(file.doesThisExist("image://full/" + path), true);
        QCOMPARE(file.doesThisExist("file:/" + path), true);
        QCOMPARE(file.doesThisExist("abcdefghijklmnopqrstuvwxyz1234567890.abc"), false);
        QCOMPARE(file.doesThisExist(""), false);
    }

    void canBeScaled() {
        GetAndDoStuffManipulation manip;
        QCOMPARE(manip.canBeScaled("/the/path/file.jpg"), true);
        QCOMPARE(manip.canBeScaled("/the/path/file.JPG"), true);
        QCOMPARE(manip.canBeScaled("/the/path/file.JpG"), true);
        QCOMPARE(manip.canBeScaled("/the/path/file.html"), false);
        QCOMPARE(manip.canBeScaled(""), false);
    }

    void convertRgbaToHex() {
        GetAndDoStuffOther other;
        QCOMPARE(other.convertRgbaToHex(173, 32, 1, 88), "#58ad2001");
        QCOMPARE(other.convertRgbaToHex(-100, -1, 256, 400), "#ff0000ff");
    }

};

#endif // GETANDDOSTUFFCONTEXTTEST_H

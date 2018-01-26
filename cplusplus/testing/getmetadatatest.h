#ifndef GETMETADATATEST_H
#define GETMETADATATEST_H

#include <QtTest/QTest>
#include "../scripts/getmetadata.h"

class GetMetaDataTest : public QObject {

    Q_OBJECT

private:
    GetMetaData meta;

private slots:
    void exifExposureTime() {
        QCOMPARE(meta.exifExposureTime("1/100 s"), "1/100");
        QCOMPARE(meta.exifExposureTime("1/100"), "1/100");
        QCOMPARE(meta.exifExposureTime("2/100"), "1/50");
        QCOMPARE(meta.exifExposureTime("1/0"), "0");
        QCOMPARE(meta.exifExposureTime("one/ten"), "0");
        QCOMPARE(meta.exifExposureTime(""), "");
    }

    void exifFNumberFLength() {
        QCOMPARE(meta.exifFNumberFLength("1/10"), "0.1");
        QCOMPARE(meta.exifFNumberFLength("10/2"), "5");
        QCOMPARE(meta.exifFNumberFLength("3/40"), "0.075");
        QCOMPARE(meta.exifFNumberFLength("f/4.0"), "4.0");
        QCOMPARE(meta.exifExposureTime("one/ten"), "0");
        QCOMPARE(meta.exifFNumberFLength(""), "");
    }

    void exifPhotoTaken() {
        QCOMPARE(meta.exifPhotoTaken("1991:07:23 13:32:21"), "23/07/1991, 13:32:21");
        QCOMPARE(meta.exifPhotoTaken("1991:07:23"), "1991:07:23");
        QCOMPARE(meta.exifPhotoTaken(""), "");
    }

    void exifGps() {
        QCOMPARE(meta.exifGps("W", "9/1 49/1 5257/100", "N", "53/1 37/1 5686/100"), QStringList() << "53°37'56.86'' N, 9°49'52.57'' W" << "53.6325 -9.83127");
        QCOMPARE(meta.exifGps("W", "9 49 52.57", "N", "53 37 56.86"), QStringList() << "53°37'56.86'' N, 9°49'52.57'' W" << "53.6325 -9.83127");
        QCOMPARE(meta.exifGps("W", "9 49", "N", "53 37"), QStringList() << "53°37'0'' N, 9°49'0'' W" << "53.6167 -9.81667");
        QCOMPARE(meta.exifGps("W", "9", "N", "53"), QStringList() << "53°0'0'' N, 9°0'0'' W" << "53 -9");
        QCOMPARE(meta.exifGps("W", "", "N", ""), QStringList() << "0°0'0'' N, 0°0'0'' W" << "0 0");
        QCOMPARE(meta.exifGps("", "", "", ""), QStringList() << "0°0'0'' N, 0°0'0'' E" << "0 0");
    }

};

#endif // GETMETADATATEST_H

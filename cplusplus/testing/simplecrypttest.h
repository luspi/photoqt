#ifndef SIMPLECRYPTTEST_H
#define SIMPLECRYPTTEST_H

#include <QtTest/QTest>

#include "../simplecrypt/simplecrypt.h"

class SimpleCryptTest : public QObject {

    Q_OBJECT

public:
    SimpleCryptTest(QObject *parent = 0) : QObject(parent) {
        crypt = new SimpleCrypt(123456789);
    }

private:
    SimpleCrypt *crypt;
    QString plaintext;
    QString crypttext;

private slots:

    void enDeCrypt() {
        plaintext = "This is a test string...";
        crypttext = crypt->encryptToString(plaintext);
        QCOMPARE(crypt->decryptToString(crypttext), plaintext);
    }

};

#endif // SIMPLECRYPTTEST_H

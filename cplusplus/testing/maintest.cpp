#include <QtTest/QtTest>

#include "getanddostufftest.h"
#include "getmetadatatest.h"

int main(int argc, char **argv) {

    // A simple main allowing easy and convenient splitting of tests into multiple files
    // Code snippet inspired by https://stackoverflow.com/questions/12194256/qt-how-to-organize-unit-test-with-more-than-one-class

    int status = 0;
    auto ASSERT_TEST = [&status, argc, argv](QObject* obj) {
        status |= QTest::qExec(obj, argc, argv);
        delete obj;
    };

    ASSERT_TEST(new GetAndDoStuffTest);
    ASSERT_TEST(new GetMetaDataTest);

    return status;

}

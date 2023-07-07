#include "pqc_test.h"

int main(int argc, char **argv) {

    QApplication app(argc, argv);

    PQCTest tc;
    return QTest::qExec(&tc, argc, argv);

}

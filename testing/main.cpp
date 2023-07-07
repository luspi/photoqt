#include <pqctest_scripts.h>
//QTEST_MAIN(PQCTESTScripts)

int main(int argc, char **argv) {

    QApplication app(argc, argv);

    PQCTESTScripts tc;
    return QTest::qExec(&tc, argc, argv);

}

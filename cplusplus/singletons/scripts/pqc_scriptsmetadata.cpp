#include <scripts/pqc_scriptsmetadata.h>

PQCScriptsMetaData::PQCScriptsMetaData() {

}

PQCScriptsMetaData::~PQCScriptsMetaData() {

}

QString PQCScriptsMetaData::convertGPSToDecimal(QString gps) {

    if(!gps.contains(", "))
        return "";

    const QString one = gps.split(", ")[0];
    const QString two = gps.split(", ")[1];

    if(!one.contains("°") || !one.contains("'") || !one.contains("''"))
        return "";
    if(!two.contains("°") || !two.contains("'") || !two.contains("''"))
        return "";

    float one_dec = one.split("°")[0].toFloat() + (one.split("°")[1].split("'")[0]).toFloat()/60.0 + (one.split("'")[1].split("''")[0]).toFloat()/3600.0;
    if(one.contains("S"))
        one_dec *= -1;


    float two_dec = two.split("°")[0].toFloat() + (two.split("°")[1].split("'")[0]).toFloat()/60.0 + (two.split("'")[1].split("''")[0]).toFloat()/3600.0;
    if(two.contains("W"))
        two_dec *= -1;

    return QString("%1/%2").arg(one_dec).arg(two_dec);

}

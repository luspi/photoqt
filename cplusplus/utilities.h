#ifndef UTILITIES_H
#define UTILITIES_H

#include <cstdlib>

inline bool ISZERO(double x) {
    double epsilon = 1e-12;
    return (std::abs(x) < epsilon);
}

#endif // UTILITIES_H

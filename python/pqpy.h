/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#ifndef PQPY_H
#define PQPY_H

#include <QMetaType>
#include <Python.h>
#include <list>
#include <string>

class PQPyObject {
    
private:
    PyObject *p;
    
public:
    PQPyObject() : p(NULL) { }

    PQPyObject(PyObject* _p) : p(_p) { }

    ~PQPyObject() {
        Py_XDECREF(p);
        p = nullptr;
    }

    std::list<std::string> asList() {
        size_t len = PyList_Size(p);
        std::list<std::string> ret;
        for(size_t i = 0; i < len; ++i)
            ret.push_back(PyUnicode_AsUTF8(PyList_GET_ITEM(p,i)));
        return ret;
    }

    PyObject* get() {
        return p;
    }

    PyObject* operator=(PyObject* p2) {
        p = p2;
        return p;
    }

    operator PyObject*() {
        return p;
    }


};
Q_DECLARE_METATYPE(PQPyObject)

#endif

/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef KEYMODIFIER_H
#define KEYMODIFIER_H

#include <QKeyEvent>

namespace KeyModifier {

    inline QString extract_(Qt::KeyboardModifiers keymods) {

        QStringList mods;
        bool isvalid = false;

        if(keymods & Qt::CTRL) {
            isvalid = true;
            mods.append("Ctrl");
        }
        if(keymods & Qt::ALT) {
            isvalid = true;
            mods.append("Alt");
        }
        if(keymods & Qt::SHIFT) {
            isvalid = true;
            mods.append("Shift");
        }
        if(keymods & Qt::META) {
            isvalid = true;
            mods.append("Meta");
        }
        if(keymods & Qt::KeypadModifier) {
            isvalid = true;
            mods.append("Keypad");
        }

        return (isvalid ? mods.join("+") : "");

    }

    inline QString extract(QKeyEvent *e) {
        return extract_(e->modifiers());
    }
    inline QString extract(QTouchEvent *e) {
        return extract_(e->modifiers());
    }
    inline QString extract(QMouseEvent *e) {
        return extract_(e->modifiers());
    }
    inline QString extract(QEvent *e) {
        return extract_(((QKeyEvent*)e)->modifiers());
    }

}


#endif // KEYMODIFIER_H

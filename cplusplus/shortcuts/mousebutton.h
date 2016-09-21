#ifndef MOUSEBUTTON_H
#define MOUSEBUTTON_H

#include <QMouseEvent>

namespace MouseButton {

	static QString extract(QMouseEvent *e) {

		switch(e->button()) {

			case Qt::RightButton:
				return "Right Button";
			case Qt::LeftButton:
				return "Left Button";
			case Qt::MiddleButton:
				return "Middle Button";
			case Qt::BackButton:
				return "Back Button";
			case Qt::ForwardButton:
				return "Forward Button";
			case Qt::TaskButton:
				return "Task Button";
			case Qt::ExtraButton4:
				return "Button #4";
			case Qt::ExtraButton5:
				return "Button #5";
			case Qt::ExtraButton6:
				return "Button #6";
			case Qt::ExtraButton7:
				return "Button #7";
			case Qt::ExtraButton8:
				return "Button #8";
			case Qt::ExtraButton9:
				return "Button #9";
			case Qt::ExtraButton10:
				return "Button #10";
			case Qt::ExtraButton11:
				return "Button #11";
			case Qt::ExtraButton12:
				return "Button #12";
			case Qt::ExtraButton13:
				return "Button #13";
			case Qt::ExtraButton14:
				return "Button #14";
			case Qt::ExtraButton15:
				return "Button #15";
			case Qt::ExtraButton16:
				return "Button #16";
			case Qt::ExtraButton17:
				return "Button #17";
			case Qt::ExtraButton18:
				return "Button #18";
			case Qt::ExtraButton19:
				return "Button #19";
			case Qt::ExtraButton20:
				return "Button #20";
			case Qt::ExtraButton21:
				return "Button #21";
			case Qt::ExtraButton22:
				return "Button #22";
			case Qt::ExtraButton23:
				return "Button #23";
			case Qt::ExtraButton24:
				return "Button #24";
			default:
				return "Unknown Button...?";
		}

	}

}

#endif // MOUSEBUTTON_H

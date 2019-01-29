#include "MsgHandler.h"

QVector<Message> Messages;

void MsgHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg) {

    Message MSG;
    MSG.type = type;

    QRegExp rx("css\\{(.*)\\}(.*)");

    if (rx.indexIn(msg)==-1) {

        MSG.css = QString("p");
        MSG.text = msg;

    } else {

        MSG.css = rx.cap(1);
        MSG.text = rx.cap(2).trimmed();

    }

    Messages.push_back(MSG);

}

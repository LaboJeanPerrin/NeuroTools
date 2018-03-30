#-------------------------------------------------
#
# Project created by QtCreator 2018-03-12T09:07:01
#
#-------------------------------------------------

QT += core gui network datavisualization

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = Viewer
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    MsgHandler.cpp \
    dataset.cpp \
    Channels.cpp

HEADERS  += mainwindow.h \
    MsgHandler.h \
    dataset.h \
    Channels.h

FORMS    += mainwindow.ui

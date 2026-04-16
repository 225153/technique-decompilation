QT       += core gui widgets

TARGET = mdql_gui
TEMPLATE = app

SOURCES += main.cpp \
           mainwindow.cpp

HEADERS += mainwindow.h

# On s'assure d'utiliser le C++17 (comme le parseur)
CONFIG += c++17

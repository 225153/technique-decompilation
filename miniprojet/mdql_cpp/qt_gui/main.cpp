#include "mainwindow.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    
    // Forcer le theme dark de base pour QT si possible
    QApplication::setStyle("Fusion");

    MainWindow w;
    w.show();

    return a.exec();
}

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTextEdit>
#include <QPushButton>
#include <QProcess>

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void runCode();
    void readOutput();
    void readError();
    void processFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    QTextEdit *codeEditor;
    QTextEdit *csvEditor;
    QTextEdit *consoleOutput;
    QPushButton *btnRun;
    QProcess *process;

    QString stripAnsi(const QString &text);
};

#endif // MAINWINDOW_H

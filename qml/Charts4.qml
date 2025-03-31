import QtQuick 2.7
import Lomiri.Components 1.3
import QtCharts 2.0
import QtQuick.Layouts 1.11
import Qt.labs.settings 1.0
import "../models/Main.js" as Model


/**************************
* Taskwise graph          *
**************************/
    Rectangle {
        id: rect5
//        anchors.top: rect4.bottom
        width: parent.width
        height: units.gu(40)

            ChartView {
                id: chart4
                title: "Taskwise Time Spent"
                anchors.fill: parent
                theme: ChartView.ChartThemeHighContrast
                legend.alignment: Qt.AlignBottom
                antialiasing: true

                BarSeries {
                    id: mySeries2
                    axisY: ValueAxis {
                            min: 0
                            max: 50
                            tickCount: 5
                            }
                }

                Component.onCompleted: {
                    get_task_chart_data();
                    var count = 0;
                    var count2 = Object.keys(task_data).length;
                    console.log("Count2 is: " + count2)
/*                    for (count = 0; count < count2; count++)
                        {
                            console.log("Task Timecat: " + task_timecat[count]);
                    }*/
                    mySeries2.append("Time", task_timecat);
                    mySeries2.axisX.categories =  task;
                }

            }
        }

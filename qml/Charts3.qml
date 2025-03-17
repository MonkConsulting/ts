import QtQuick 2.7
import Lomiri.Components 1.3
import QtCharts 2.0
import QtQuick.Layouts 1.11
import Qt.labs.settings 1.0
import "../models/Main.js" as Model


/**************************
* Projectwise graph       *
**************************/
        Rectangle {
            id: rect4
            width: parent.width
            height: units.gu(40)

                ChartView {
                    id: chart3
                    title: "Projectwise Time Spent"
                    anchors.fill: parent
                    legend.alignment: Qt.AlignBottom
                    antialiasing: true

                    BarSeries {
                        id: mySeries
                        axisY: ValueAxis {
                                min: 0
                                max: 50
                                tickCount: 5
                             }
                    }
        


                Component.onCompleted: {
                    get_project_chart_data();

                    var count = 0;
                    var count2 = Object.keys(project_data).length;
                    console.log("Count2 is: " + count2)
                    for (count = 0; count < count2; count++)
                        {
                            console.log("Project Timecat: " + project_timecat[count]);
                    }
                    mySeries.append("Time", project_timecat);
                    mySeries.axisX.categories =  project;

                }
            }

        }

/************************/
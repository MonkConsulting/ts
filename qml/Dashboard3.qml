import QtQuick 2.7
import Lomiri.Components 1.3
import QtCharts 2.0
import "../models/Main.js" as Model
import "../models/DbInit.js" as DbInit
import "../models/DemoData.js" as DemoData




Page{
    id: dashboard2
    title: "Task"
        header: PageHeader {
        title: dashboard2.title
    }



    LomiriShape {
        id: rect1
        anchors.centerIn: parent
        width: parent.width
        height: units.gu(40)

            ChartView {
                id: chart3
                title: "Taskwise Time Spent"
                anchors.fill: parent
                theme: ChartView.ChartThemeHighContrast
                legend.alignment: Qt.AlignBottom
                antialiasing: true

                BarSeries {
                    id: mySeries
                    axisX: BarCategoryAxis { categories: ["Task 1", "Task 2", "Task 3", "Task 4" ] }
                    BarSet { label: "Time"; values: [chart3.timecat[0], chart3.timecat[1], chart3.timecat[2], chart3.timecat[3]] }
               }
    
                property variant othersSlice: 0
                property variant timecat: []



                Component.onCompleted: {
                    DbInit.initializeDatabase();
                    DemoData.record_demo_data();
                    var quadrant_data = Model.get_tasks_spent_hours();
                    chart3.timecat = quadrant_data;

                }
            }

     }


/*    LomiriShape {
        id: rect3
        anchors.top: rect2.bottom
        width: parent.width
        height: units.gu(40)

            Column{
                    id: myCol1
                    spacing: 2
                    leftPadding: 10
                    Row{
                            spacing: 2
                            Rectangle { color: "lightskyblue" 
                                        width: 20 
                                        height: 20 
                            }
                            Text {
                                    id: myLabel_1
                                    text: qsTr("Important, Urgent")
                                }
                        }
                    Row{
                            spacing: 2
                            Rectangle { color: "deepskyblue"
                                        width: 20 
                                        height: 20 
                            }
                            Text {
                                    id: myLabel_2
                                    text: qsTr("Important, Not Urgent")
                                }
                    }       

            }
        Column{
                id: myCol2
                anchors.left: myCol1.right
                spacing: 2
                leftPadding: 10
                Row{
                        spacing: 2
                        Rectangle { color: "steelblue" 
                                    width: 20 
                                    height: 20 
                        }
                        Text {
                                id: myLabel_3
                                text: qsTr("Not Important, Urgent")
                            }
                }       
                Row{
                        spacing: 2
                        Rectangle { color: "#0e1a24" 
                                    width: 20 
                                    height: 20 
                        }
                        Text {
                                id: myLabel_4
                                text: qsTr("Not Important, Not Urgent")
                            }
                }       

        }

    }
*/


}
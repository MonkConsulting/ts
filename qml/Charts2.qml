import QtQuick 2.7
import Lomiri.Components 1.3
import QtCharts 2.0
import QtQuick.Layouts 1.11
import Qt.labs.settings 1.0
import "../models/Main.js" as Model


    /****************
    * Chart 2 comes below
    *****************/

        Rectangle {
            id: rect2
            width: parent.width
            height: units.gu(40)

                ChartView {
                    id: chart2
                    z: 100
                    title: "Time Spent this month"
                    margins { top: 50; bottom: 0; left: 0; right: 0 }
                    backgroundRoundness: 0
                    anchors { fill: parent; margins: 0}
                    antialiasing: true
                    legend.visible: false
        
                    property variant othersSlice: 0
                    property variant timecat: []


                    PieSeries {
                        id: pieSeries2
                        size: 0.5
                        PieSlice { label: "Important, Urgent"; value: chart2.timecat[0] } //  Data from Js
                        PieSlice { label: "Important, Not Urgent"; value: chart2.timecat[1] }
                        PieSlice { label: "Not Important, Urgent"; value: chart2.timecat[2]}
                        PieSlice { label: "Not Important, Not Urgent"; value: chart2.timecat[3]}
                    }
                    Component.onCompleted: {
                        var quadrant_data = Model.get_quadrant_current_month();
                        console.log('\n\n quadrant_data', quadrant_data)
                        chart2.timecat = quadrant_data;
                    }




                }


        Rectangle {
            id: rect3
            anchors.top: rect2.bottom
            width: parent.width
            height: units.gu(10)

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
    }


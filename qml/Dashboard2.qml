import QtQuick 2.7
import Lomiri.Components 1.3
import QtCharts 2.0
import "../models/Main.js" as Model
import "../models/DbInit.js" as DbInit
import "../models/DemoData.js" as DemoData




Page{
    id: dashboard
    title: "Project"
        header: PageHeader {
        title: dashboard.title
    }



    LomiriShape {
        id: rect1
        anchors.centerIn: parent
        width: parent.width
        height: units.gu(40)

            ChartView {
                id: chart
                title: "Projectwise Time Spent"
                anchors.fill: parent
                legend.alignment: Qt.AlignBottom
                antialiasing: true

                BarSeries {
                    id: mySeries
                    axisX: BarCategoryAxis { categories: ["Project 1", "Project 2", "Project 3", "Project 4" ] }
                    BarSet { label: "Time"; values: [2, 2, 3, 4, 5, 6] }
                }
    
                property variant othersSlice: 0
                property variant timecat: []



                Component.onCompleted: {
                    DbInit.initializeDatabase();
                    DemoData.record_demo_data();
                    var quadrant_data = Model.get_projects_spent_hours();
                    chart.timecat = quadrant_data;

                }
            }

     }




}
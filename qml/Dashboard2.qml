import QtQuick 2.7
import Lomiri.Components 1.3
import QtCharts 2.0
import "../models/Main.js" as Model
import "../models/DbInit.js" as DbInit
import "../models/DemoData.js" as DemoData




Page{
    id: dashboard
    title: "Charts"
        header: PageHeader {
        title: dashboard.title
    }



    property variant project_timecat: []
    property variant project: []
    property variant project_data: []

    property variant task_timecat: []
    property variant task: []
    property variant task_data: []

    function get_project_chart_data(){
        console.log("get_project_chart_data called");
        project_data = Model.get_projects_spent_hours();
        var count = 0;
        var timeval;
            for (var key in project_data) {
            project[count] = key;
            timeval = project_data[key];
            count = count+1;
        }
        var count2 = Object.keys(project_data).length;
        for (count = 0; count < count2; count++)
            {
                project_timecat[count] = project_data[project[count]];
        }
    }


    function get_task_chart_data(){
        console.log("get_task_chart_data called");
        task_data = Model.get_tasks_spent_hours();
        var count = 0;
        var timeval;
            for (var key in task_data) {
            task[count] = key;
            timeval = task_data[key];
            count = count+1;
        }
        var count2 = Object.keys(task_data).length;
        for (count = 0; count < count2; count++)
            {
                task_timecat[count] = task_data[task[count]];
        }
    }

    Flickable {
        id:flick1
        width: parent.width; height: 80
        anchors.top: header.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        contentWidth: parent.width; contentHeight: 3500

        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 1000
                easing.type: Easing.OutBounce
            }
        }


        Loader{
            id:load3
            anchors.left: parent.left
            anchors.right: parent.right
//            anchors.top: header.bottom
            source: "Charts3.qml"
        }

        Loader{
            id:load4
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: load3.bottom
            source: "Charts4.qml"
        }

        onFlickEnded: {
                load3.active = false
                load4.active = false
                console.log("Flickable flick ended")
                load3.active = true             
                load4.active = true             
        }


    }


    Scrollbar {
        flickableItem: flick1
        align: Qt.AlignTrailing
    }
}
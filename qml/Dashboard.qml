/*
 * Copyright (C) 2025  Monk Consulting
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * scrollbarex is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
import QtCharts 2.0
import QtQuick.Layouts 1.11
import Qt.labs.settings 1.0
import "../models/Main.js" as Model
import "../models/DbInit.js" as DbInit
import "../models/DemoData.js" as DemoData



    Page {
        id: mainPage
        title: "Timesheet"
        anchors.fill: parent
        property bool isMultiColumn: apLayout.columns > 1
        property var page: 0

        header: PageHeader {
            id: header
            title: "Dashboard"
            visible: true
            ActionBar {
                id: actionbar
                visible: isMultiColumn ? false : true
                numberOfSlots: 2
                anchors.right: parent.right
                actions: [
                   Action {
                        iconName: "appointment-new"
                        text: "Theme"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Timesheet.qml"))
                            page = 1
                            apLayout.setCurrentPage(page)

                        }
                    },
/*                   Action {
                        iconName: "torch-on"
                        text: "Theme"
                        onTriggered:{
                            mainView.theme.name = 'Lomiri.Components.Themes.SuruDark'

                        }
                    },*/                    
                    Action {
                        iconName: "clock"
                        text: "Timesheet"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Timesheet_Page.qml"))
                            console.log("Calling setCurrentPage Primarypage is " + apLayout.primaryPage)
                            page = 7
                            apLayout.setCurrentPage(page)

                        }
                    },
                    Action {
                        iconName: "calendar"
                        text: "Activities"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Activity_Page.qml"))
                            page = 2
                            apLayout.setCurrentPage(page)

                        }
                    },
                    Action {
                        iconName: "view-list-symbolic"
                        text: "Tasks"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Task_Page.qml"))
                            page = 3
                            apLayout.setCurrentPage(page)
                        }
                    },
                    Action {
                        iconName: "folder-symbolic"
                        text: "Projects"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Project_Page.qml"))
                            page = 4
                            apLayout.setCurrentPage(page)
                        }
                    },
                    Action {
                        iconName: "sync"
                        text: "Sync"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Sync_Page.qml"))
                            page = 5
                            apLayout.setCurrentPage(page)
                        }
                    },
                    Action {
                        iconName: "settings"
                        text: "Settings"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Settings_Page.qml"))
                            page = 6
                            apLayout.setCurrentPage(page)
                        }
                    }
                ]
            }       
         }

/*    function handle_convergence(){
            console.log(" In Dashboard convergence: " + apLayout.columns)
        if (apLayout.columns === 3){
            apLayout.addPageToNextColumn(mainPage, Qt.resolvedUrl("Dashboard2.qml"))
        }

    }*/

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
        width: parent.width; height: parent.height
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
            id:load
            anchors.left: parent.left
            anchors.right: parent.right
            source: "Charts1.qml"
        }

        Loader{
            id:load2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: load.bottom
            source: "Charts2.qml"
        }

        Loader{
            id:load3
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: load2.bottom
            source: apLayout.columns === 1 ? "Charts3.qml": ""
        }

        Loader{
            id:load4
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: load3.bottom
            source: apLayout.columns === 1 ? "Charts4.qml": ""
        }
/*        Button{
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: load4.bottom
            text: "Dashboard 2"
            onClicked:{
                console.log("Dashboard from button status is: " + mainPage.status)
                apLayout.addPageToNextColumn(mainPage, Qt.resolvedUrl("Dashboard2.qml")) 
            } 
            
        } */

        onFlickEnded: {
                load.active = false
                load2.active = false
                if (apLayout.columns === 1){
                    load3.active = false
                    load4.active = false
                }
                console.log("Flickable flick ended")
                load.active = true             
                load2.active = true             
                if (apLayout.columns === 1){
                    load3.active = true             
                    load4.active = true
                }
                else{
//                    apLayout.addPageToNextColumn(mainPage, Qt.resolvedUrl("Dashboard2.qml")) 
                }       
        }


    }


    Scrollbar {
        flickableItem: flick1
        align: Qt.AlignTrailing
    }
    Timer {
        interval: 100 
        running: true
        repeat: false
        onTriggered: {
                if( apLayout.columns === 3){
                    console.log("In Dashboard timer columns: " + apLayout.columns)
                    apLayout.addPageToNextColumn(mainPage, Qt.resolvedUrl("Dashboard2.qml"))
                } 
        }
    }


    Component.onCompleted: {
        console.log("Dashboard status is: " + mainPage.status)
    }

       

}

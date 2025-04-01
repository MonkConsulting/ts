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

import QtQuick 2.9
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import QtQuick.Window 2.2
import QtQml.Models 2.3
import "../models/Timesheet.js" as Model
import "../models/Project.js" as Project
import "../models/Task.js" as Task
import "../models/Utils.js" as Utils


Page{
    id: task
    title: "Tasks"
        header: PageHeader {
            id: taskheader
            title: task.title
                ActionBar {
                numberOfSlots: 2
                anchors.right: parent.right
            //    enable: true
                    actions: [
                        Action {
                            iconName: "add"
                            text: "New"
                            onTriggered:{
                                console.log("Create Task clicked");
                                apLayout.addPageToNextColumn(task, Qt.resolvedUrl("Task_Create.qml"))

                            }
                        },
                        Action {
                            iconName: "search"
                            text: "Search"
                            onTriggered:{
                                console.log("Search clicked");
                                nameFilter.visible = !nameFilter.visible

                            }
                        }

                    ]
                }
                TextField {
                    id: nameFilter
                    anchors.centerIn: parent
                    visible: false
                    placeholderText: qsTr("Search by name...")
                    onTextChanged: {
                        if (nameFilter.text === ""){
                            get_task_list(0)
                        }
                        else{
                            filter_task_list(nameFilter.text)
                        }
                    }
                }
        }


    
    function get_task_list(recordid){
//            var tasks = Utils.fetch_tasks_list(projectid, subProjectId)
            var tasks = Task.fetch_tasks_lists(recordid)
            var deadline
            console.log("get_task_list: Deadlline: " + tasks[0].deadline)
            taskModel.clear();
            for (var task = 0; task < tasks.length; task++) {
                if(tasks[task].deadline === 0){
                    deadline = "" 
                }
                else{
                    deadline = String(tasks[task].deadline)
                }
                taskModel.append({'id': tasks[task].id, 'name': tasks[task].name, 
                'taskHasSubTask': tasks[task].taskHasSubTask, 'favorites':tasks[task].favorites, 
                'spentHours': tasks[task].spentHours, 'allocated_hours': tasks[task].allocated_hours, 
                'state': tasks[task].state, 'parentTask': tasks[task].parentTask, 
                'accountName': tasks[task].accountName, 'deadline': deadline, 
                'project_id':tasks[task].project_id, 'project': tasks[task].project})
            } 
        }

    function filter_task_list(searchstr){
            var tasks = Task.get_filtered_tasklist(searchstr)
            var deadline
            taskModel.clear();
            for (var task = 0; task < tasks.length; task++) {
                if(tasks[task].deadline === 0){
                    deadline = "" 
                }
                else{
                    deadline = String(tasks[task].deadline)
                }
                taskModel.append({'id': tasks[task].id, 'name': tasks[task].name, 
                'taskHasSubTask': tasks[task].taskHasSubTask, 'favorites':tasks[task].favorites, 
                'spentHours': tasks[task].spentHours, 'allocated_hours': tasks[task].allocated_hours, 
                'state': tasks[task].state, 'parentTask': tasks[task].parentTask, 
                'accountName': tasks[task].accountName, 'deadline': deadline, 
                'project_id':tasks[task].project_id, 'project': tasks[task].project})
            } 
        }




    ListModel {
        id: taskModel
    }


    LomiriShape {
        anchors.top: taskheader.bottom
        height: parent.height
        width: parent.width

    
        Component {
            id: taskDelegate
            LomiriShape{
                width: parent.width
                height: units.gu(10)
                Row {
                    height: units.gu(10)
                    spacing: 10
                    Column{
                       leftPadding: units.gu(3)
                        width: units.gu(30)
                        height: units.gu(10)
/*                        Label{ 
                           id: tasklabel 
                            text: "Task: "}*/
                        Label { 
                            id: tasktext
                            width: units.gu(20)
//                            anchors.left: tasklabel.left
                            text: name 
                            clip: true
                            }
/*                        Label{ 
                            id: idlabel
                            text: "Spent Hours: "}*/
                        Label { 
                            anchors.left:tasktext.left
                            text: project }
                    }
/**********************************************/
                    Column{
                       leftPadding: units.gu(1)
                        width: units.gu(5)
                        height: units.gu(10)
                        Label { 
                            text: spentHours }
                    }

/********************************************/

                    Column{
                       leftPadding: units.gu(2)
                        width: units.gu(10)
                        height: units.gu(10)
//                        Label{ text: "Spent Hours: "}
                        Label {
                            id: deadlinetext
                            text: Qt.formatDate(deadline, "MM/dd/yyyy")
                         }
//                        Label{ text: " "}
//                        Text { text: allocated_hours }
                        Image {
                            id: starImageList
                            anchors.right: parent.right
                           source: favorites > 0 ? "images/star-active.svg" : "images/starinactive.svg" 
                            width: units.gu(3)
                            height: units.gu(3)
                            smooth: true  
                        }
                    }

                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
    					tasklist.currentIndex = index
//                        apLayout.addPageToNextColumn(task, Qt.resolvedUrl("Task_details.qml"),{"recordid":id});
                    }
                    onDoubleClicked: {
    					tasklist.currentIndex = index
                        apLayout.addPageToNextColumn(task, Qt.resolvedUrl("Task_details.qml"),{"recordid":id});
                    }
                }   
                Keys.onPressed: {
//                    console.log("list: " + event.key + " : " + event.text)
                    if (event.key === Qt.Key_Return)
                        apLayout.addPageToNextColumn(task, Qt.resolvedUrl("Task_details.qml"),{"recordid":id});
                     if (event.key === Qt.Key_Down)
                        tasklist.currentIndex = index
                }
            }

        }

        LomiriListView {
            id: tasklist
            focus: true
            anchors.fill: parent
//            anchors.top: taskheader.bottom
            model: taskModel


            pullToRefresh {
                enabled: true
//                refreshing: model.status === taskModel.Loading
                onRefresh: get_task_list(0)
                refreshing: true
            }            
            delegate: taskDelegate
            highlight: Rectangle { anchors.left: parent.left; anchors.right: parent.right; color: "lightsteelblue"; radius: 5 }
            highlightFollowsCurrentItem: true
            currentIndex: 0
            onCurrentIndexChanged: {
                    console.log("currentIndex changed")
                }            

           Component.onCompleted: {
                get_task_list(0)
            }
        }
    }
}
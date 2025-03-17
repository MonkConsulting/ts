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
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import QtQuick.Window 2.2
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
                numberOfSlots: 1
                anchors.right: parent.right
            //    enable: true
                    actions: [
                        Action {
                            iconName: "add"
                            text: "New"
                            onTriggered:{
                                console.log("Create Task clicked");
                                apLayout.addPageToCurrentColumn(task, Qt.resolvedUrl("Task_Create.qml"))

                            }
                        }
                    ]
                }
        }

    
    function get_task_list(recordid){
//            var tasks = Utils.fetch_tasks_list(projectid, subProjectId)
            var tasks = Task.fetch_tasks_lists(recordid)
            taskModel.clear();
            for (var task = 0; task < tasks.length; task++) {
                taskModel.append({'id': tasks[task].id, 'name': tasks[task].name, 
                'taskHasSubTask': tasks[task].taskHasSubTask, 'favorites':tasks[task].favorites, 
                'spentHours': tasks[task].spentHours, 'allocated_hours': tasks[task].allocated_hours, 
                'state': tasks[task].state, 'parentTask': tasks[task].parentTask, 
                'accountName': tasks[task].accountName})
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
                Row {
                    height: units.gu(12)
                    spacing: 10
                    Column{
                        Image {
                            id: starImageList
                           source: favorites > 0 ? "images/star-active.svg" : "images/starinactive.svg" 
                            width: 20
                            height: 20
                            smooth: true  
                        }
                    }
                    Column{
                        width: 200
                        height: units.gu(10)
                        Label{ 
                           id: tasklabel 
                            text: "Task: "}
                        Text { 
                            anchors.left: tasklabel.left
                            text: name 
                            }
                        Label{ 
                            id: idlabel
                            text: "ID: "}
                        Text { 
                            anchors.left:idlabel.left
                            text: id }
                    }
                    Column{
                        width: 150
                        height: units.gu(10)
                        Label{ text: "Spent Hours: "}
                        Text { text: spentHours }
                        Label{ text: "Planned: "}
                        Text { text: allocated_hours }
                    }

                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
    					tasklist.currentIndex = index
                        apLayout.addPageToNextColumn(task, Qt.resolvedUrl("Task_details.qml"),{"recordid":id});
                    }
                }   
            }

        }

        LomiriListView {
            id: tasklist
            anchors.fill: parent
//            anchors.top: taskheader.bottom
            model: taskModel
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
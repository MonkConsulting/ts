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
import Lomiri.Components.Popups 1.3
import Lomiri.Components.Pickers 1.3
import QtCharts 2.0
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import "../models/Task.js" as Task


Page{
    id: taskDetails
    title: "Task Details"
        header: PageHeader {
        title: taskDetails.title
        ActionBar {
                numberOfSlots: 2
                anchors.right: parent.right
            //    enable: true
                actions: [
                    Action {
                        iconName: "edit"
                        text: "Edit"
                        onTriggered:{
                            console.log("Edit Task clicked");
                            console.log("Account ID: " + tasks[0].account_id)
                            isReadOnly = !isReadOnly

                        }
                    },
                    Action {
                        iconName: "save"
                        text: "Save"
                        onTriggered:{
                            isReadOnly = !isReadOnly
                            console.log("Save Task clicked");
                            save_task_data();

                        }
                    }                
                ]
        }
    }


    property var recordid: 0
    property bool workpersonaSwitchState: true
    property bool isReadOnly: true
    property var tasks: []
    property var taskdata: []
    property var startdatestr: ""
    property var enddatestr: ""
    property var deadlinestr: ""
/*    property var project: ""
    property var parentname: ""
    property var account: ""
    property var user: "" */
    property int selectedAccountUserId: 0
    property int selectedProjectId: 0 
    property int selectedparentId: 0
    property int favorites: 0


    function get_task_list(recordid){
            console.log("In get_task_list()");
            var tasklist = Task.fetch_tasks_lists(recordid);
            console.log("Tasks: " + tasklist[0].name);
            return tasklist
       }


    function save_task_data(){
        var selectedProjectId = tasks[0].project_id
        var selectedAccountUserId = tasks[0].account_id
        var selectedassigneesUserId = tasks[0].userId
        console.log("Account ID: " + selectedAccountUserId)
        const editData = {
            selectedAccountUserId: selectedAccountUserId,
            nameInput: task_text.text,
            selectedProjectId: selectedProjectId,
            editselectedSubProjectId: 0,
            selectedparentId: tasks[0].parent_Id,
            startdateInput: start_text.text,
            enddateInput: end_text.text,
            deadlineInput: deadline_text.text,
            img_star: favorites,
            initialInput: hours_text.text,
            editdescription: description_text.text,
            selectedassigneesUserId: selectedassigneesUserId,
            'rowId':tasks[0].id,
        }
        Task.edittaskData(editData)
        PopupUtils.open(savepopover)
 
    }

    ListModel {
        id: taskModel
    }
    


    LomiriShape {
        id: rect1
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        radius: "large"
        width: parent.width
        height: parent.height


        Row{
                id: myRow1a
                anchors.left: parent.left 
                topPadding: 10
                Column{
                        leftPadding: units.gu(2)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                             Label {
                                id: instance_label                            
                                text: "Instance"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                            }
                        }
                }
                Column{
                       leftPadding: units.gu(3)                            
                        TextField {
                                id: instance_text
                                readOnly: isReadOnly
                                width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                                text: tasks[0].accountName

                        }
                }       
        }




        Row{
                id: myRow1
                anchors.top: myRow1a.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                        leftPadding: units.gu(2)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                             Label {
                                id: task_label                            
                                text: "Task Name"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                            }
                        }
                }
                Column{
                       leftPadding: units.gu(3)
                        TextField {
                            id: task_text
                            readOnly: isReadOnly
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            text: tasks[0].name

                    }

                }       
        }


        Row{
                id: myRow2
                anchors.top: myRow1.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                        leftPadding: units.gu(2)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: assignee_label                             
                                text: "Assignee"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                            }
                        }
                }
                Column{
                    leftPadding: units.gu(3)
                    TextField {
                            id: assignee_text
                            readOnly: isReadOnly
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            text: taskdata[0].user

                        }
                }       
        }

        Row{
                id: myRow9
                anchors.top: myRow2.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    id: myCol8
                        leftPadding: units.gu(2)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: description_label                             
                                text: "Description"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                    id: myCol9
                    leftPadding: units.gu(3)
                    TextField {
                        id: description_text
                        readOnly: isReadOnly
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        anchors.centerIn: parent.centerIn
                        text: tasks[0].description

                    }
                }       
        }

        Row{
                id: myRow3
                anchors.top: myRow9.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                        leftPadding: units.gu(2)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: project_label                             
                                text: "Project"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                    leftPadding: units.gu(3)
                    TextField {
                        id: project_text
                        readOnly: isReadOnly
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        text: taskdata[0].project

                    }
                }
    
        }


        Row{
                id: myRow10
                anchors.top: myRow3.bottom
                anchors.left: parent.left 
                topPadding: 10
               Column{
                    id: myCol10
                        leftPadding: units.gu(2)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: parent_label                             
                                text: "Parent Task"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                            }
                        }
                }
                Column{
                    id: myCol11
                    leftPadding: units.gu(3)                       
                    width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                    height: 40
                    TextField {
                        id: parent_text
                        readOnly: isReadOnly
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        anchors.centerIn: parent.centerIn
                        text: taskdata[0].parentname ? taskdata[0].parentname : ""

                    }
                }       
        }



        Row{
                id: myRow4
                anchors.top: myRow10.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: hours_label                             
                            text: "Planned Hours"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(3)
                        TextField {
                            id: hours_text
                            readOnly: isReadOnly
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            anchors.centerIn: parent.centerIn
                            text: tasks[0].allocated_hours                   
                        }                        
                    }
             
        }

        Row{
                id: myRow5
                anchors.top: myRow4.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: start_label                             
                            text: "Start Date"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(3)
                        TextField {
                            id: start_text
                            readOnly: isReadOnly
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            anchors.centerIn: parent.centerIn
                            text: tasks[0].start_date
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { 
                                    
                                    if(date_field.visible === false)
                                    {
                                        if (!isReadOnly)
                                        {
                                            date_field.visible = !date_field.visible 
                                            start_text.text = ""
                                        }
                                    }
                                    else
                                    {
                                        date_field.visible = !date_field.visible 
                                        start_text.text = Qt.formatDate(date_field.date, "dddd, dd-MMMM-yyyy")
                                        startdatestr = Qt.formatDate(date_field.date, "yyyy-MM-dd")

                                    }
                                    
                                }
                            }                        
                        }
                        DatePicker {
                            id: date_field
                            visible: false
                            z: 1
                            minimum: {
                                var d = new Date();
                                d.setFullYear(d.getFullYear() - 1);
                                return d;
                            }
                            maximum: Date.prototype.getInvalidDate.call()
                    }
                }       
        }

        Row{
                id: myRow6
                anchors.top: myRow5.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: end_label                             
                            text: "End Date"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(3)
                        TextField {
                            id: end_text
                            readOnly: isReadOnly
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            anchors.centerIn: parent.centerIn
                            text: tasks[0].end_date
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { 
                                    
                                    if(date_field2.visible === false)
                                    {
                                        if (!isReadOnly)
                                        {
                                            date_field2.visible = !date_field2.visible 
                                            end_text.text = ""
                                        }
                                    }
                                    else
                                    {
                                        date_field2.visible = !date_field2.visible 
                                        end_text.text = Qt.formatDate(date_field2.date, "dddd, dd-MMMM-yyyy")
                                        enddatestr = Qt.formatDate(date_field2.date, "yyyy-MM-dd")

                                    }
                                    
                                }
                            }                              
                        }
                        DatePicker {
                            id: date_field2
                            visible: false
                            z: 1
                            minimum: {
                                var d = new Date();
                                d.setFullYear(d.getFullYear() - 1);
                                return d;
                            }
                            maximum: Date.prototype.getInvalidDate.call()
                    }                        
                }            
        }


        Row{
                id: myRow7
                anchors.top: myRow6.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: deadline_label                             
                            text: "Deadline"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(3)
                        TextField {
                            id: deadline_text
                            readOnly: isReadOnly
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            anchors.centerIn: parent.centerIn
                            text: tasks[0].deadline
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { 
                                    
                                    if(date_field3.visible === false)
                                    {
                                        if (!isReadOnly)
                                        {
                                            date_field3.visible = !date_field3.visible 
                                            deadline_text.text = ""
                                        }
                                    }
                                    else
                                    {
                                        date_field3.visible = !date_field3.visible 
                                        deadline_text.text = Qt.formatDate(date_field3.date, "dddd, dd-MMMM-yyyy")
                                        deadlinestr = Qt.formatDate(date_field3.date, "yyyy-MM-dd")

                                    }
                                    
                                }
                            }                             
                        }
                        DatePicker {
                            id: date_field3
                            visible: false
                            z: 1
                            minimum: {
                                var d = new Date();
                                d.setFullYear(d.getFullYear() - 1);
                                return d;
                            }
                            maximum: Date.prototype.getInvalidDate.call()
                        }                          
                }         
        }


        Row{
                id: myRow8
                anchors.top: myRow7.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: priority_label                             
                            text: "Priority"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(3)
                        Row {
                            width: units.gu(20)
                            height: units.gu(20)
                            id: img_star
                            spacing: 5  
                            property int selectedPriority: 0  

                            Repeater {
                                model: 1  
                                delegate: Item {
                                    width: units.gu(5)  
                                    height: units.gu(5)

                                    Image {
                                        id: starImage
                                        source: (index < favorites) ? "images/star-active.svg" : "images/starinactive.svg"  
                                        anchors.fill: parent
                                        smooth: true  

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                
                                                if(!isReadOnly)
                                                {
                                                    if (index + 1 === favorites) {
                                                        favorites = !favorites
                                                        console.log("Favorites is: " + favorites);
                                                    } else {
                                                        favorites = !favorites
                                                        console.log("Favorites is: " + favorites);
                                                    }
                                                }
                                                else{
                                                    console.log("Favorites is: " + favorites + " Index is: " + index);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }                        

                }         
        }



/***************************************************************/

            Rectangle {
                id: popuprect
                width: units.gu(20)
                height: units.gu(20)
                border.color: "black"
                border.width: 2
                radius: 10
                anchors.centerIn: parent
                visible: false
/***************************************************************/

               Component {
                    id: savepopover

                    Popover {
                        id: popover
                        autoClose: true
                        anchors.centerIn: parent

                        Label {
                            id: save_label
                            anchors.centerIn: parent                            
                            text: "Task Saved!"
                            font.bold: true
                            color: LomiriColors.green
                        }
                        
                    }
                }
/**************************************************************/        
        
        }


        Component.onCompleted: {
            tasks = get_task_list(recordid);
            console.log("From Task Page " + apLayout.columns);
            console.log("From Task Page ID " + recordid);
            console.log("From Task Page  tasks: " + tasks[0].id);
            taskdata = Task.fetch_task_details(tasks);
            console.log("Taskdata: " + taskdata[0].project)
            favorites =   tasks[0].favorites;
            console.log("Description is: " + tasks[0].description);
            console.log("OnComplete Favorites is: " + tasks[0].favorites);
            tasks[0].description = tasks[0].description.replace(/<[^>]+>/g, " ") 
                    .replace(/<p>;/g,"")   
                    .replace(/&nbsp;/g, "")       
                    .replace(/&lt;/g, "<")         
                    .replace(/&gt;/g, ">")         
                    .replace(/&amp;/g, "&")        
                    .replace(/&quot;/g, "\"")      
                    .replace(/&#39;/g, "'")        
                    .trim() || ""; 
        }

    }





}

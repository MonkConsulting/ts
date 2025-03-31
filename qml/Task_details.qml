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
import "../models/Timesheet.js" as Timesheet


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
                            isReadOnly = !isReadOnly
                            if(!isReadOnly){
                                var searchdata = task_field.editText
                                prepare_task_list(selectedProjectId)
                                var myIndex = get_id(taskModel, searchdata)
                                task_field.currentIndex = myIndex

                                var searchdata = assigneeCombo.editText
                                prepare_assignee_list()
                                var myIndex = get_id(assigneeModel, searchdata)
                                console.log("Account ID: " + tasks[0].account_id + " myIndex: " + myIndex)
                                assigneeCombo.currentIndex = myIndex
                                var searchdata = projectCombo.editText
                                prepare_project_list()
                                var myIndex = get_id(projectModel, searchdata)
                                projectCombo.currentIndex = myIndex
                            }
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
    property int selectedassigneesUserId: 0
    property int selectedparentId: 0
    property int selectedInstanceId: 0
    property int selectedTaskId: 0 
    property int favorites: 0
    property var prevproject: ""
    property var prevInstanceId: 0
    property var prevassignee: ""
    property var prevtask: ""



    function get_id(model, criteria) {
        console.log("get_id criteria: " + criteria + " model.count: " + model.count)
        for(var i = 0; i < model.count; ++i){ 
            console.log("get_id criteria: " + criteria + " model.name: " + model.get(i).name.substring(0, model.get(i).name.indexOf("[")) )          
            if (model.get(i).name.substring(0, model.get(i).name.indexOf("[")) === criteria) 
                return i
        }
        return -1
}
    
    function get_task_list(recordid){
            console.log("In get_task_list()");
            var tasklist = Task.fetch_tasks_lists(recordid);
            console.log("Tasks: " + tasklist[0].name);
            console.log("Tasks: " + tasklist[0].user_id)
            return tasklist
       }


    function save_task_data(){
        var selectedProjectId = tasks[0].project_id
//        var selectedassigneesUserId = tasks[0].user_id
        console.log("Account ID: " + selectedassigneesUserId)
        const editData = {
            selectedAccountUserId: selectedassigneesUserId,
            nameInput: task_text.text,
            selectedProjectId: selectedProjectId,
            editselectedSubProjectId: 0,
            selectedparentId: selectedparentId,
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

    function prepare_assignee_list() {
        var assignees = Task.getAssigneeList()
        console.log("In prepare_assignee_list()  ")      
        assigneeModel.clear();
        assigneeModel1.clear();
        for (var assignee = 0; assignee < assignees.length; assignee++) {
            assigneeModel1.append({'id': assignees[assignee].id, 'name': assignees[assignee].name})
            assigneeModel.append({'name': assignees[assignee].name + "[" + assignees[assignee].id + "]"})
        }       
/*        for (var assignee = 0; assignee < assigneeModel.count; assignee++) {
            console.log("AssigneeModel1 " + "id: " + assigneeModel1.get(assignee).id + " Assignee: " + assigneeModel1.get(assignee).name)
            console.log("assigneeModel " + " Asignee: " + assigneeModel.get(assignee).name)
        } */
    }

    function prepare_project_list() {
        var projects = Timesheet.fetch_projects(selectedInstanceId, workpersonaSwitchState)
        console.log("In prepare_project_list()  " + selectedInstanceId)      
        projectModel.clear();
        projectModel1.clear();
        for (var project = 0; project < projects.length; project++) {
            projectModel1.append({'id': projects[project].id, 'name': projects[project].name, 'projectHasSubProject': projects[project].projectHasSubProject})
            projectModel.append({'name': projects[project].name + "[" + projects[project].id + "]"})
        }       
        for (var project = 0; project < projectModel.count; project++) {
            console.log("ProjectModel1 " + "id: " + projectModel1.get(project).id + " Project: " + projectModel1.get(project).name)
            console.log("ProjectModel " + " Project: " + projectModel.get(project).name)
        } 
    }
    

    function prepare_task_list(project_id) {
        var tasks = Timesheet.fetch_tasks_list(project_id, 0, workpersonaSwitchState)
        taskModel.clear();
        taskModel1.clear();
        selectedTaskId = 0;
//        console.log("Passed Project ID: " + project_id + " SubProjectID: " + selectedsubProjectId + " Tasks Found: " + tasks.length)
        for (var task = 0; task < tasks.length; task++) {
            taskModel1.append({'id': tasks[task].id, 'name': tasks[task].name, 'taskHasSubTask': tasks[task].taskHasSubTask})
            taskModel.append({'name': tasks[task].name + "[" + tasks[task].id + "]"})
        } 
    }

    function set_assignee_id(assignee_name) {
        for (var assignee = 0; assignee < assigneeModel.count; assignee++) {
            if(assigneeModel1.get(assignee).name === assignee_name) {
                console.log("set_assignee_id " + "id: " + assigneeModel1.get(assignee).id + " Assignee: " + assigneeModel1.get(assignee).name)
                selectedassigneesUserId = assigneeModel1.get(assignee).id   
            }
 
        }         
    }

    function set_project_id(project_name) {
        for (var project = 0; project < project_name.length; ++project) {
            if (project_name.substring(project, project + 1) === "[") {
            selectedProjectId = parseInt(project_name.substring(project + 1, ((project_name.length)-1)))
            break
            }  
        }  
        const name =    project_name.split("[")
        for (var project = 0; project < projectModel1.count; project++) {
            var index = prevproject.indexOf("[")
            console.log("Index of [ " + index)
        }
        if (prevproject != name[0]){
            console.log("prevproject = " + prevproject + " name = " + name[0])
            task_field.currentIndex = -1
        }
        prevproject = name[0]
        console.log("Set Project Id: Name = " + name[0])
        console.log("selectedProjectId = " + selectedProjectId)    
    }

    function set_task_id(task_name) {
        console.log("set_task_id called task_name: " + task_name)
        for (var task = 0; task < task_name.length; task++) {
            if(task_name.substring(task, task + 1) === "[") {
                selectedparentId = parseInt(task_name.substring(task + 1, ((task_name.length)-1)))
            }
        }
        const name =    task_name.split("[")

        if (prevtask != name[0]){
            console.log("prevtask = " + prevtask + " name = " + name[0])
        }
        prevtask = name[0]

        console.log("Set Task Id: Name = " + name[0] + " selectedparentId: " + selectedparentId)
        console.log("selectedparentId = " + selectedparentId)    
    }

    function set_instance_id(instance_name) {
        for (var instance = 0; instance < instanceModel.count; instance++) {
            if(instanceModel1.get(instance).name === instance_name) {
                console.log("set_instance_id " + "id: " + instanceModel1.get(instance).id + " Instance: " + instanceModel1.get(instance).name)
                selectedInstanceId = instanceModel1.get(instance).id            
            }

        }         
    }


    ListModel {
        id: taskModel1
    }    
    
    ListModel {
        id: assigneeModel1
    }

    ListModel {
        id: projectModel1
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
                        LomiriShape {
                            width: units.gu(10)
                            height: units.gu(5)
                            aspect: LomiriShape.Flat 
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
                        LomiriShape {
                            width: units.gu(10)
                            height: units.gu(5)
                            aspect: LomiriShape.Flat 
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
                        LomiriShape {
                            width: units.gu(10)
                            height: units.gu(5)
                            aspect: LomiriShape.Flat 
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
                        LomiriShape{                        
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            height: 60
                            
                            ComboBox {
                                    id: assigneeCombo
                                    enabled: !isReadOnly
                                    editable: true
                                    editText: taskdata[0].user
                                    width: parent.width
                                    height: parent.height
                                    anchors.centerIn: parent.centerIn
                                    flat: true
                                    model:  ListModel {
                                                id: assigneeModel
                                            }  

                                    onActivated: {
                                        console.log("In onActivated")
                                        set_assignee_id(editText.substring(0, editText.indexOf("["))) 
                                        console.log("Assignee ID: " + selectedassigneesUserId + " edittext: " + editText)                        
                                    }        
                                    onHighlighted: {
                                    }
                                    onAccepted: {
                                        console.log("In onAccepted")
                                        if (find(editText) != -1)
                                        {
                                         console.log("In onActivated")
                                        set_assignee_id(editText.substring(0, editText.indexOf("["))) 
                                        console.log("Assignee ID: " + selectedassigneesUserId + " edittext: " + editText)                        
                                       }
                                    } 

                            }
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
                        LomiriShape {
                            width: units.gu(10)
                            height: units.gu(5)
                            aspect: LomiriShape.Flat 
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
                    TextArea {
                        id: description_text
                        readOnly: isReadOnly
                        autoSize: true
                        maximumLineCount: 0
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
                        LomiriShape {
                            width: units.gu(10)
                            height: units.gu(5)
                            aspect: LomiriShape.Flat 
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
                    LomiriShape{                        
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: 60
                    ComboBox {
                            id: projectCombo
                            editable: true
                            editText: taskdata[0].project
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model:  ListModel {
                                        id: projectModel
                                    }  

                            onActivated: {
                                console.log("In onActivated")
                                if (prevproject != editText.substring(0, editText.indexOf("[")))
                                {
                                    set_project_id(editText) 
                                    prepare_task_list(selectedProjectId)
                                    console.log("Project ID: " + selectedProjectId + " edittext: " + editText)
                                }                        
                            }        
                            onHighlighted: {
                            }
                            onAccepted: {
                                console.log("In onAccepted")
                                if (find(editText) != -1)
                                {
                                    prevproject = editText
                                    set_project_id(editText) 
                                    prepare_task_list(selectedProjectId)
                                    console.log("Project ID: " + selectedProjectId)                        
                                }
                            } 

                        }
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
                        LomiriShape {
                            width: units.gu(10)
                            height: units.gu(5)
                            aspect: LomiriShape.Flat 
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
                    LomiriShape{                        
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: 60
                        ComboBox {
                            id: task_field
                            editable: true
                            editText: taskdata[0].parentname
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true

                            model:  ListModel {
                                        id: taskModel
                                    }  

                            onActivated: {
                                console.log("In onActivated")
                                if (prevtask != editText.substring(0, editText.indexOf("[")))
                                {
                                    set_task_id(editText) 
                                    console.log("Task ID: " + selectedTaskId)  
                                } 
                            }        
                            onHighlighted: {
                            }
                            onAccepted: {
                                console.log("In onAccepted")
                                if (find(editText) != -1){
                                    set_task_id(editText) 
                                    console.log("Task ID: " + selectedTaskId)                        

                                    }

                            } 

                        }
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
                    LomiriShape {
                        width: units.gu(10)
                        height: units.gu(5)
                        aspect: LomiriShape.Flat 
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
                    LomiriShape {
                        width: units.gu(10)
                        height: units.gu(5)
                        aspect: LomiriShape.Flat 
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
                    LomiriShape {
                        width: units.gu(10)
                        height: units.gu(5)
                        aspect: LomiriShape.Flat 
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
                    LomiriShape {
                        width: units.gu(10)
                        height: units.gu(5)
                        aspect: LomiriShape.Flat 
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
                    LomiriShape {
                        width: units.gu(10)
                        height: units.gu(5)
                        aspect: LomiriShape.Flat 
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
//            prepare_project_list();
            console.log("From Task Page " + apLayout.columns);
            console.log("From Task Page ID " + recordid);
            console.log("From Task Page  tasks: " + tasks[0].id);
            console.log("From Task Page  Account ID: " + tasks[0].account_id + " Account Name: " + tasks[0].accountName)
            taskdata = Task.fetch_task_details(tasks);
            console.log("Taskdata: " + taskdata[0].project + " User: " + taskdata[0].user + " Parentname: " + taskdata[0].parentname)
            favorites =   tasks[0].favorites;
            console.log("Description is: " + tasks[0].description);
            console.log("OnComplete Favorites is: " + tasks[0].favorites);
            selectedInstanceId = tasks[0].account_id
            selectedProjectId = tasks[0].project_id
            selectedparentId = (tasks[0].parent_id === null) ? 0 : tasks[0].parent_id
            selectedassigneesUserId = tasks[0].account_id

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

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
    id: taskCreate
    title: "New Task"
        header: PageHeader {
        title: taskCreate.title
        ActionBar {
                numberOfSlots: 1
                anchors.right: parent.right
            //    enable: true
                actions: [
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
    property bool isReadOnly: false
    property var tasks: []
    property var startdatestr: ""
    property var enddatestr: ""
    property var deadlinestr: ""
    property var project: ""
    property var parentname: ""
    property var account: ""
    property var user: ""
    property int selectedAccountUserId: 0
    property int selectedProjectId: 0 
    property int selectedparentId: 0
    property int favorites: 0
    property int subProjectId: 0
    property var prevproject: ""
    property var prevInstanceId: 0
    property int selectedInstanceId: 0
    property var prevassignee: ""
  

    function save_task_data(){
        selectedAccountUserId, nameInput, selectedProjectId, selectedparentTaskId, winterInput, 
        startdateInput, enddateInput, deadlineInput, imgstar, initialInput, descriptionInput,
        selectedassigneesUserId,selectedSubProjectId

        var selectedProjectId = tasks[0].project_id
        var selectedAccountUserId = tasks[0].account_id
//        var selectedassigneesUserId = tasks[0].userId
        console.log("Account ID: " + selectedAccountUserId)
        const saveData = {
            selectedAccountUserId: selectedAccountUserId,
            nameInput: task_text.text,
            selectedProjectId: selectedProjectId,
            editselectedSubProjectId: 0,
            selectedparentTaskId: tasks[0].parent_Id,
            startdateInput: start_text.text,
            enddateInput: end_text.text,
            deadlineInput: deadline_text.text,
            img_star: favorites,
            initialInput: hours_text.text,
            descriptionInput: description_text.text,
            selectedassigneesUserId: selectedassigneesUserId,
            selectedSubProjectId:subProjectId
        }
        Task.savetaskData(saveData)
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
        for (var assignee = 0; assignee < assigneeModel.count; assignee++) {
            console.log("AssigneeModel1 " + "id: " + assigneeModel1.get(assignee).id + " Assignee: " + assigneeModel1.get(assignee).name)
            console.log("assigneeModel " + " Asignee: " + assigneeModel.get(assignee).name)
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

/*******************************************************************/
    function set_project_id(project_name) {
        for (var project = 0; project < project_name.length; ++project) {
            if (project_name.substring(project, project + 1) === "[") {
            selectedProjectId = parseInt(project_name.substring(project + 1, ((project_name.length)-1)))
            break
            }  
        }  
        const name =    project_name.split("[")
        for (var project = 0; project < projectModel1.count; project++) {
            if(projectModel1.get(project).name === name[0]) {
                if (projectModel1.get(project).projectHasSubProject) {
                    myRow9.visible = true
                    prepare_subproject_list()
                } else {
                    myRow9.visible = false
                    selectedsubProjectId = 0
                }
            }
            var index = prevproject.indexOf("[")
            console.log("Index of [ " + index)
        }
        if (prevproject != name[0]){
            console.log("prevproject = " + prevproject + " name = " + name[0])
            combo3.currentIndex = -1
            task_field.currentIndex = -1
            combo4.currentIndex = -1
            myRow10.visible = false
        }
        prevproject = name[0]
        console.log("Set Project Id: Name = " + name[0])
        console.log("selectedProjectId = " + selectedProjectId)    
    }

    function prepare_instance_list() {
        var instances = Timesheet.get_accounts_list()
        console.log("In prepare_instance_list() instances.length = " + instances.length)      
        for (var instance = 0; instance < instances.length; instance++) {
            instanceModel1.append({'id': instances[instance].id, 'name': instances[instance].name})
            instanceModel.append({'name': instances[instance].name})
        }       
        for (var instance = 0; instance < instanceModel.count; instance++) {
            console.log("InstanceModel " + " Project: " + instanceModel.get(instance).name)

        } 
        combo5.currentIndex = instanceModel1.get(0).id //What is the error here?
        combo5.editText = instanceModel1.get(0).name
        prevInstanceId = instanceModel1.get(0).id
        selectedInstanceId = instanceModel1.get(0).id
        
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

    function set_instance_id(instance_name) {
        for (var instance = 0; instance < instanceModel.count; instance++) {
            if(instanceModel1.get(instance).name === instance_name) {
                console.log("set_instance_id " + "id: " + instanceModel1.get(instance).id + " Instance: " + instanceModel1.get(instance).name)
                selectedInstanceId = instanceModel1.get(instance).id            
            }

        }         
    }



/***************************************************************************************/


    ListModel {
        id: taskModel
    }
    
    ListModel {
        id: instanceModel1
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
                       LomiriShape{                        
                            width: units.gu(30)
                            height: 60
                            
                    ComboBox {
                            id: combo5
                            editable: true
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model:  ListModel {
                                        id: instanceModel
                                    }

                            onActivated: {
                                set_instance_id(editText) 
                                if (prevInstanceId != selectedInstanceId){
                                    console.log("Calling clearAllFields")
                                    clearAllFields()
                                }
                                prevInstanceId = selectedInstanceId
                                console.log("Instance ID: " + selectedInstanceId + " edittext: " + editText)
                            }        
                            onHighlighted: {
                            }
                            onAccepted: {
                                console.log("In onAccepted")
                                if (find(editText) != -1)
                                {
                                    set_instance_id(editText) 
                                    console.log("Instance ID: " + selectedInstanceId)                        
                                }
                            } 

                        }
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
                            text: ""

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
                    LomiriShape{                        
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: 60
                        
                    ComboBox {
                            id: combo1
                            editable: true
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model:  ListModel {
                                        id: assigneeModel
                                    }  

                            onActivated: {
                                console.log("In onActivated")
                                if (prevassignee != editText.substring(0, editText.indexOf("[")))
                                {
                                    set_assignee_id(editText) 
    //                                prepare_subproject_list()
 //                                   prepare_task_list(selectedProjectId)
                                    console.log("Assignee ID: " + selectedassigneesUserId + " edittext: " + editText)
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
                        text: ""

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
                    LomiriShape{                        
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: 60
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { date_field.visible = !date_field.visible }
                        }
                        
                    ComboBox {
                            id: projectCombo
                            editable: true
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
    //                                prepare_subproject_list()
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
                        text: ""

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
                            text: ""                 
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
                            text: ""
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
                            text: ""
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
                            text: ""
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
                                                
                                                if (index + 1 === favorites) {
                                                    favorites = !favorites
                                                } else {
                                                    favorites = !favorites
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
            console.log("From Task Page " + apLayout.columns);
            console.log("From Task Page ID " + recordid);
            tasks = Task.fetch_tasks_lists(recordid)
            console.log("From Task Page Task Name " + tasks[0].name);
            favorites =   tasks[0].favorites    
            prepare_instance_list();     
            prepare_assignee_list();                        
            prepare_project_list();

        }

    }





}

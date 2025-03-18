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
import "../models/Timesheet.js" as Model
import "../models/DbInit.js" as DbInit
import "../models/DemoData.js" as DemoData


Page{
    id: timeSheet
    title: "Timesheet"
        header: PageHeader {
        title: timeSheet.title
        ActionBar {
                numberOfSlots: 1
                anchors.right: parent.right
            //    enable: true
                actions: [
                    Action {
                        iconName: "save"
                        text: "Save"
                        onTriggered:{
                            save_timesheet();
                            console.log("Timesheet Save Button clicked");

                        }
                    }
                ]
        }
    }





    ListModel {
        id: instanceModel1
    }   

    ListModel {
        id: projectModel1
    }    





    function floattoint(x) {
    return Number.parseFloat(x).toFixed(0);
    }
 

    function clearAllFields(){
        selectedProjectId = 0
        selectedTaskId = 0
        selectedsubProjectId = 0
        selectedSubTaskId = 0
//        combo5.editText = ""
        combo1.editText = ""
        combo3.editText = ""
        task_field.editText = ""
        combo4.editText = ""
    }



    function save_timesheet() {
        console.log("Timesheet Saved");
        console.log("Date in save is: " + datestr);
        var timesheet_data = {
            'instance_id': selectedInstanceId,
            'dateTime': datestr,
            'project': selectedProjectId,
            'task': selectedTaskId,
            'subprojectId': selectedsubProjectId,
            'subTask': selectedSubTaskId,
            'description': description_text.text,
            'manualSpentHours': hours_text.text,
            'spenthours': hours_text.text,
            'isManualTimeRecord': isManualTime,
            'quadrant': floattoint(mySlider.value)
        }
//        myComponent.myFlag = true
        console.log("Data.quadrant: " + timesheet_data.quadrant)
        console.log("dbDirty is: " + mainView.dbDirty)
        PopupUtils.open(savepopover)
        Model.create_timesheet(timesheet_data)
        selectedInstanceId = 0
        date_text.text = ""
        selectedProjectId = 0
        selectedTaskId = 0
        selectedsubProjectId = 0
        selectedSubTaskId = 0
        combo5.editText = ""
        combo1.editText = ""
        combo3.editText = ""
        task_field.editText = ""
        combo4.editText = ""
        description_text.text = ""
        hours_text.readOnly = true
        elapsedTime = 0
    }




    function prepare_instance_list() {
        var instances = Model.get_accounts_list()
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
        var projects = Model.fetch_projects(selectedInstanceId, workpersonaSwitchState)
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


    function prepare_subproject_list(){
        var subprojects = Model.fetch_sub_project(selectedProjectId, workpersonaSwitchState)
        console.log("In prepare_subproject_list()")  
        subprojectModel.clear();
        if (subprojects.length > 0)
        {    
            myRow9.visible = true
            for (var subproject = 0; subproject < subprojects.length; subproject++) {
                subprojectModel.append({'name': subprojects[subproject].name + "[" + subprojects[subproject].id + "]"})
            }       
            for (var subproject = 0; subproject < subprojectModel.count; subproject++) {
                console.log("SubProjectModel " + " Subproject: " + subprojectModel.get(subproject).name)
            }
        }
    }

    function prepare_task_list(project_id) {
        var tasks = Model.fetch_tasks_list(project_id, selectedsubProjectId, workpersonaSwitchState)
        taskModel.clear();
        taskModel1.clear();
        selectedTaskId = 0;
        console.log("Passed Project ID: " + project_id)
        for (var task = 0; task < tasks.length; task++) {
            taskModel1.append({'id': tasks[task].id, 'name': tasks[task].name, 'taskHasSubTask': tasks[task].taskHasSubTask})
            taskModel.append({'name': tasks[task].name + "[" + tasks[task].id + "]"})
        } 
     }


    function prepare_subtask_list(task_id) {
        var subtasks = Model.fetch_sub_tasks(task_id, workpersonaSwitchState)
        subtaskModel.clear();
        console.log("Passed Task ID: " + task_id)
        for (var subtask = 0; subtask < subtasks.length; subtask++) {
           subtaskModel.append({'name': subtasks[subtask].name + "[" + subtasks[subtask].id + "]"})
        } 
     }

    function set_instance_id(instance_name) {
        for (var instance = 0; instance < instanceModel.count; instance++) {
            if(instanceModel1.get(instance).name === instance_name) {
                console.log("set_instance_id " + "id: " + instanceModel1.get(instance).id + " Instance: " + instanceModel1.get(instance).name)
                selectedInstanceId = instanceModel1.get(instance).id            
            }
        prepare_project_list()

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
            if(projectModel1.get(project).name === name[0]) {
                if (projectModel1.get(project).projectHasSubProject) {
                    myRow9.visible = true
                    prepare_subproject_list()
                } else {
                    myRow9.visible = false
                    selectedsubProjectId = 0
                }
/*                combo3.currentIndex = -1
                task_field.currentIndex = -1
                combo4.currentIndex = -1
                myRow10.visible = false*/
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


    function set_subproject_id(subproject_name) {
        for (var subproject = 0; subproject < subproject_name.length; subproject++) {
            if(subproject_name.substring(subproject, subproject + 1) === "[") {
                selectedsubProjectId = parseInt(subproject_name.substring(subproject + 1, ((subproject_name.length)-1)))
            }
        }         
        console.log("selectedsubProjectId = " + selectedsubProjectId)    
    }


    function set_task_id(task_name) {
        for (var task = 0; task < task_name.length; task++) {
            if(task_name.substring(task, task + 1) === "[") {
                selectedTaskId = parseInt(task_name.substring(task + 1, ((task_name.length)-1)))
            }
        }
        const name =    task_name.split("[")
        for (var task = 0; task < taskModel1.count; task++) {
            if(taskModel1.get(task).name === name[0]) {
                if (taskModel1.get(task).taskHasSubTask) {
                    myRow10.visible = true
                    prepare_subtask_list(selectedTaskId)
                } 
                else {
                    myRow10.visible = false
                }
            combo4.currentIndex = -1
            }
        }
        console.log("Set Task Id: Name = " + name[0])
        console.log("selectedTaskId = " + selectedTaskId)    
    }

    function set_subtask_id(subtask_name) {
        for (var subtask = 0; subtask < subtask_name.length; subtask++) {
            if(subtask_name.substring(subtask, subtask + 1) === "[") {
                selectedSubTaskId = parseInt(subtask_name.substring(subtask + 1, ((subtask_name.length)-1)))
            }
        }         
        console.log("selectedSubTaskId = " + selectedSubTaskId)    
    }




    function formatTime(seconds) {
        var hours = Math.floor(seconds / 3600);  
        var minutes = Math.floor((seconds % 3600) / 60);  
        var secs = seconds % 60; 

        return (hours < 10 ? "0" + hours : hours) + ":" +  
            (minutes < 10 ? "0" + minutes : minutes) + ":" +
            (secs < 10 ? "0" + secs : secs);
    }



    ListModel {
        id: taskModel1
    }

    property var textval: ""
    property bool workpersonaSwitchState: true
    property bool isTimesheetClicked: false
    property bool isManualTime: false
    property var currentTime: false
    property int elapsedTime: 0
    property int storedElapsedTime: 0
    property bool running: false
    property int selectedProjectId: 0
    property int selectedInstanceId: 0
    property int selectedsubProjectId: 0
    property int selectedTaskId: 0 
    property bool hasSubProject: false;
    property bool edithasSubProject: false;
    property bool hasSubTask: false;
    property bool edithasSubTask: false;
    property int selectedSubTaskId: 0
    property var datestr: ""
    property var prevInstanceId: 0
    property var defaultInstance: ""
    property var prevproject: ""

    Timer {
        id: stopwatchTimer
        interval: 1000  
        repeat: true
        onTriggered: {
            elapsedTime += 1
        }
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
                topPadding: 40
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
                       leftPadding: units.gu(1)
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
                                id: date_label                            
                                text: "Date"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                            }
                        }
                }
                Column{
                       leftPadding: units.gu(1)
                        TextField {
                            id: date_text
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { 
                                    
                                    if(date_field.visible === false)
                                    {
                                        date_field.visible = !date_field.visible 
                                        date_text.text = ""
//                                        myComponent.customFlag()
                                    }
                                    else
                                    {
                                        date_field.visible = !date_field.visible 
                                        date_text.text = Qt.formatDate(date_field.date, "dddd, dd-MMMM-yyyy")
                                        datestr = Qt.formatDate(date_field.date, "yyyy-MM-dd")

                                    }
                                    
                                }
                            }
                    }
                    DatePicker {
                            id: date_field
                            visible: false
                            z: 1
//                            anchors.top: date_label.bottom
//                            anchors.left:date_label.left
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
                id: myRow2
                anchors.top: myRow1.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    id: myCol
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
                    id: myCol1
                    leftPadding: units.gu(1)
                    LomiriShape{                        
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: 60
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { date_field.visible = !date_field.visible }
                        }
                        
                    ComboBox {
                            id: combo1
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
                                    console.log("prevproject != editText")
                                    console.log("prevproject: " + prevproject + " editText: " + editText)
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
/************************************************************
*       Added Sub Project below                             *
************************************************************/
        Row{
                id: myRow9
                anchors.top: myRow2.bottom
                anchors.left: parent.left 
                topPadding: 10
                visible: false
                Column{
                    id: myCol8
                        leftPadding: units.gu(2)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: subproject_label                             
                                text: "Sub Project"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                    id: myCol9
                    leftPadding: units.gu(1)
                    LomiriShape{                        
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: 60
                        ComboBox {
                            id: combo3
                            editable: true
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model:  ListModel {
                                        id: subprojectModel
                                    }  

                            onActivated: {
                                console.log("In onActivated")
                                set_subproject_id(editText) 
//                                prepare_task_list(selectedProjectId)
                                console.log("Sub Project ID: " + selectedsubProjectId + " edittext: " + editText)                        
                            }        
                            onHighlighted: {
                            }
                            onAccepted: {
                                console.log("In onAccepted")
                                if (find(editText) != -1)
                                {
                                    set_subproject_id(editText) 
//                                    prepare_task_list(selectedProjectId)
                                    console.log("Sub Project ID: " + selectedsubProjectId)                        
                                }
                            } 

                        }
                }

                }       
        }


/**********************************************************/

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
                                id: task_label                             
                                text: "Task"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(1)
                        LomiriShape{                        
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            height: 60
                            ComboBox {
                                id: task_field
                                editable: true
                                width: parent.width
                                height: parent.height
                                anchors.centerIn: parent.centerIn
                                flat: true

                                model:  ListModel {
                                            id: taskModel
                                        }  

                                onActivated: {
                                    console.log("In onActivated")
                                    set_task_id(editText) 
                                    console.log("Task ID: " + selectedTaskId)   
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

/************************************************************
*       Added Sub Task below                             *
************************************************************/
        Row{
                id: myRow10
                anchors.top: myRow3.bottom
                anchors.left: parent.left 
                topPadding: 10
                visible: false
               Column{
                    id: myCol10
                        leftPadding: units.gu(2)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: subtask_label                             
                                text: "Sub Task"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                    id: myCol11
                    leftPadding: units.gu(1)
                    LomiriShape{                        
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: 60
                        ComboBox {
                            id: combo4
                            editable: true
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model:  ListModel {
                                        id: subtaskModel
                                    }  

                            onActivated: {
                                console.log("In onActivated")
                                date_field.visible = false                     
                            }        
                            onHighlighted: {
                            }
                            onAccepted: {
                                console.log("In onAccepted")
                                if (find(editText) != -1)
                                {
                                    console.log("Sub Task: " + editText)                        
                                }
                            } 

                        }
                }

                }       
        }


/**********************************************************/


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
                                id: description_label                             
                                text: "Description"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(1)
                        TextField {
                            id: description_text
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
//                            text: "Enter Description"                   
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
                                id: hours_label                             
                                text: "Spent Hours"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(1)
                        TextField {
                            id: hours_text
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            text: formatTime(elapsedTime)
                            readOnly: true
                        }
                }       
        }
        Row{
                id: myRow6
                anchors.top: myRow5.bottom
                anchors.horizontalCenter: parent.horizontalCenter 
                topPadding: units.gu(5)
                Column{
//                       leftPadding: units.gu(2)
                        Button {
                                objectName: "button_start"
                               width: units.gu(10)
                                iconName: "save"
                                action: Action {
                                    text: i18n.tr("Start")
                                    property bool flipped
                                    onTriggered: flipped = !flipped
                                }
                                color: action.flipped ? LomiriColors.blue : LomiriColors.green
                                onClicked: {
                                    if (running) {
                                        currentTime = false;
                                        storedElapsedTime = elapsedTime;
                                        stopwatchTimer.stop();
                                    } else {
                                        console.log("Started")
                                        currentTime = new Date()
                                        stopwatchTimer.start();
                                    }
                                    running = !running                                
                                }
                        }
                }
                Column{
                       leftPadding: units.gu(1)
                        Button {
                                objectName: "button_stop"
                                width: units.gu(10)
                                action: Action {
                                    text: i18n.tr("Stop")
                                    property bool flipped
                                    onTriggered: flipped = !flipped
                                }
                                color: action.flipped ? LomiriColors.green : LomiriColors.red
                                onClicked: {
                                                running = !running
                                                 stopwatchTimer.stop();
//                                                 hours_text.text = formatTime(elapsedTime)
                                }
                        }
                }
                Column{
                       leftPadding: units.gu(1)
                        Button {
                                objectName: "button_manual"
                                width: units.gu(10)
                                action: Action {
                                    text: i18n.tr("Manual")
                                    property bool flipped
                                    onTriggered: {flipped = !flipped
                                    isManualTime = true
                                    hours_text.readOnly = false
                                    running = !running
                                    stopwatchTimer.stop();}
                                }
                                color: action.flipped ? LomiriColors.blue : LomiriColors.slate
                        }
                }       
        }

/**********************************************************
* 18022025: Added Slider for the Quadrants         *
**********************************************************/

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
                                id: priority_label                            
                                text: "Priority"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                            }
                        }
                }
                Column{
                       leftPadding: units.gu(12)
                        Slider {
                            id: mySlider
                            minimumValue: 1
                            maximumValue: 4
                            stepSize: 100
                            width: units.gu(20)
                            value: 0
                            live: true
                            onValueChanged: {
                                var selection = floattoint(value)
                                if(selection === "1")
                                {
                                    priority_label.text = "Important, Urgent"
                                }
                                if(selection === "2")
                                {
                                    priority_label.text = "Important, Not Urgent"
                                }
                                if(selection === "3")
                                {
                                    priority_label.text = "Not Important, Urgent"
                                }
                                if(selection === "4")
                                {
                                    priority_label.text = "Not Important, Not Urgent"
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
                            text: "Timesheet Saved!"
                            font.bold: true
                            color: LomiriColors.green
                        }
                        
                    }
                }
/**************************************************************/        
        
        }




/**********************************************************/


        Component.onCompleted: {
            console.log("From Timesheet " + apLayout.columns);
            console.log("From Timesheet projectModel " + projectModel);
            console.log("From Timesheet textval: " + textval)
            prepare_instance_list()
            prepare_project_list()

        }

    }





}

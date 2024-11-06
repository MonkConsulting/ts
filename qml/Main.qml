/*
 * Copyright (C) 2024  Synconics Technologies Pvt. Ltd.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * odooprojecttimesheet is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import io.thp.pyotherside 1.4
import QtGraphicalEffects 1.7
import QtQuick.LocalStorage 2.7
import Ubuntu.Components 1.3 as Ubuntu




ApplicationWindow {
    visible: true
    width: Screen.width
    height: Screen.height
    title: "Timesheets"

    property var optionList: []
    property var tasksList: []
    property int elapsedTime: 0
    property int selectedquadrantId: 0
    property int selectededitquadrantId: 0
    property int selectedProjectId: 0
    property int selectedSubProjectId: 0
    property int selectedTaskId: 0
    property int selectedSubTaskId: 0
    property int selectedAccountUserId: 0
    property bool running: false
    property bool hasSubProject: false;
    property bool hasSubTask: false;
    property string selected_username: ""
    property bool isTimesheetSaved: false
    property bool isTimesheetClicked: false
    property bool isManualTime: false
    property var currentTime: false
    property int storedElapsedTime: 0
    property var timesheetList: []
    property int currentUserId: 0
    property var timesheetListobject: []
    property bool workpersonaSwitchState: true
    property bool penalOpen: true
    property bool headermainOpen: true
    property int selectedId: -1
    property bool isTimesheetEdit: false
    property bool isEditTimesheetClicked: false
    property bool issearchHeadermain: false 


    onActiveChanged: {
        if (active) {
            if (currentTime) {
                if (running) {
                    elapsedTime = parseInt((new Date() - currentTime) / 1000) + storedElapsedTime
                }
            }
        }
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            importModule_sync("backend");
        }

        onError: {
            console.log('Python error: ' + traceback);
        }
    }

    Timer {
        id: stopwatchTimer
        interval: 1000  // 1 second
        repeat: true
        onTriggered: {
            elapsedTime += 1
        }
    }

    function formatTime(seconds) {
    var hours = Math.floor(seconds / 3600);  
    var minutes = Math.floor((seconds % 3600) / 60);  
    var secs = seconds % 60; 

    return (hours < 10 ? "0" + hours : hours) + ":" +  
           (minutes < 10 ? "0" + minutes : minutes) + ":" +
           (secs < 10 ? "0" + secs : secs);
    }

    function isDesktop() {
        if(Screen.width > 1300 ){
            if(Screen.width > 2000 && Screen.height < 1300){
                return false;
            }else{
                return true;
            }
        }else{
            return false;
        }
    }
    function phoneLarg(){
        if(!isDesktop()){
            if(Screen.width > 1300){
                return true;
            }else{
                return false;
            }
        }
        return false;
    }
    ListModel {
    id: treeModel
    }
    function accountlistDataGet(){
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var accountlist = [];

        db.transaction(function(tx) {
                var result = tx.executeSql('SELECT * FROM users');
                for (var i = 0; i < result.rows.length; i++) {
                    accountlist.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name})
                }
            })
        return accountlist
    
    }

    function fetch_projects(selectedAccountUserId) {
        console.log(workpersonaSwitchState,"/workpersonaSwitchState")
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var projectList = []
        db.transaction(function(tx) {
            console.log('\n\n selectedAccountUserId', selectedAccountUserId)
            if(workpersonaSwitchState){
                var result = tx.executeSql('SELECT * FROM project_project_app WHERE account_id = ? AND parent_id IS 0', [selectedAccountUserId]);
            }else{
                var result = tx.executeSql('SELECT * FROM project_project_app WHERE account_id IS NULL AND parent_id IS NULL');
            }
            for (var i = 0; i < result.rows.length; i++) {
                var child_projects = tx.executeSql('SELECT count(*) as count FROM project_project_app where parent_id = ?', [result.rows.item(i).id]);
                projectList.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'projectkHasSubProject': true ? child_projects.rows.item(0).count > 0 : false})
            }
        })
        return projectList;
    }

    function fetch_sub_project(project_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var subProjectsList = []
        db.transaction(function(tx) {
            if(workpersonaSwitchState){
                var child_projects = tx.executeSql('SELECT * FROM project_project_app where parent_id = ?', [project_id]);
            }else{
                var child_projects = tx.executeSql('SELECT * FROM project_project_app where account_id IS NULL AND parent_id = ?', [project_id]);
            }
            for (var i = 0; i < child_projects.rows.length; i++) {
                console.log('\n\n child_projects.rows.item(i).id', child_projects.rows.item(i).id)
                subProjectsList.push({'id': child_projects.rows.item(i).id, 'name': child_projects.rows.item(i).name})
            }
        })
        return subProjectsList;
    }

    function fetch_tasks_list(project_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var tasks_list = []
        db.transaction(function(tx) {
            if(workpersonaSwitchState){
                var result = tx.executeSql('SELECT * FROM project_task_app where project_id = ?', [project_id]);
            }else{
                var result = tx.executeSql('SELECT * FROM project_task_app where account_id IS NULL AND project_id = ?', [project_id]);
            }
            for (var i = 0; i < result.rows.length; i++) {
                var child_tasks = tx.executeSql('SELECT count(*) as count FROM project_task_app where parent_id = ?', [result.rows.item(i).id]);
                // tasksListModel.append({'id': result[i].id, 'name': result[i].name, 'taskHasSubTask': true ? child_tasks.rows.item(0).count > 0 : false})
                tasks_list.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'taskHasSubTask': true ? child_tasks.rows.item(0).count > 0 : false})
                // projectList.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name})
            }
        })
        return tasks_list;    
    }

    function fetch_sub_tasks(task_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        // subTasksListModel.clear();
        var sub_tasks_list = []
        db.transaction(function(tx) {
            if(workpersonaSwitchState){
                var child_tasks = tx.executeSql('SELECT * FROM project_task_app where parent_id = ?', [task_id]);
            }else{
                var child_tasks = tx.executeSql('SELECT * FROM project_task_app where account_id IS NULL AND parent_id = ?', [task_id]);
            }
            for (var i = 0; i < child_tasks.rows.length; i++) {
                sub_tasks_list.push({'id': child_tasks.rows.item(i).id, 'name': child_tasks.rows.item(i).name})
            }
        })
        return sub_tasks_list
    }

    function convTimeFloat(value) {
        var vals = value.split(':');
        var hours = parseInt(vals[0], 10);  // Extract the hours part
        var minutes = parseInt(vals[1], 10);  // Extract the minutes part

        // Handle overflow in minutes
        hours += Math.floor(minutes / 60);  // Add extra hours from minutes overflow
        minutes = minutes % 60;  // Remainder minutes after overflow

        // Return the normalized time in HH:MM format
        return hours.toString().padStart(2, '0') + ':' + minutes.toString().padStart(2, '0');

    }
    
    function reverseConvTimeFloat(value) {
        console.log(value)
        var totalHours = Math.floor(value); // whole number part is the total hours
        var totalMinutes = Math.round((value - totalHours) * 60); // fractional part converted to minutes

        var hours = totalHours % 24; // get the remainder of hours after full days
        var days = Math.floor(totalHours / 24); // calculate the full days

        // Format hours and minutes to ensure two digits
        var formattedHours = String(hours).padStart(2, '0');
        var formattedMinutes = String(totalMinutes).padStart(2, '0');

        return `${formattedHours}:${formattedMinutes}`;
    }

    function timesheetData(data) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function(tx) {
            var unitAmount = 0
            if (data.isManualTimeRecord) {
                unitAmount = convTimeFloat(data.manualSpentHours)
            } else {
                unitAmount = convTimeFloat(data.spenthours)
            }
            tx.executeSql('INSERT INTO account_analytic_line_app \
                (account_id, record_date, project_id, task_id, name,  \
                unit_amount, last_modified) VALUES (?, ?, ?, ?, ?, ?, ?)',
                 [data.instance_id, data.dateTime, data.project, data.subTask == 0 ? data.task : data.subTask, data.description, unitAmount, new Date().toISOString()]);
        });

    }
 
    ListModel {
        id: filteredTimesheetList
    }

    function timesheetlistData(query) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        
        timesheetListobject = [];
        filteredTimesheetList.clear();

        db.transaction(function (tx) {
            // tx.executeSql('DELETE FROM account_analytic_line_app');
            if(workpersonaSwitchState){
                var result = tx.executeSql('select * from account_analytic_line_app');
            }else{
                var result = tx.executeSql('SELECT * FROM account_analytic_line_app where account_id IS NULL');
            }
            
            for (var i = 0; i < result.rows.length; i++) { 
                console.log(result.rows.item(i)); 

                var projectId = result.rows.item(i).project_id || 0;  
                var taskId = result.rows.item(i).task_id || 0;        
                
                var project = tx.executeSql('select name from project_project_app where id = ?', [projectId]);
                var projectName = (project.rows.length > 0) ? project.rows.item(0).name : "";
                
                var task = tx.executeSql('select name from project_task_app where id = ?', [taskId]);
                var taskName = (task.rows.length > 0) ? task.rows.item(0).name : "";
                
                var unitAmount = result.rows.item(i).unit_amount;
                var spentHoursDecimal = unitAmount ? unitAmount : "0";
                
                timesheetListobject.push({
                    'id': result.rows.item(i).id,  
                    'project_id': projectName,          
                    'task_id': taskName,                
                    'name': result.rows.item(i).name || "",  
                    'spent_hours': spentHoursDecimal,   
                    // 'quadrant_id':result.rows.item(i).quadrant_id,
                    'date': result.rows.item(i).record_date || ""  
                });

                console.log(JSON.stringify(timesheetListobject, null, 2));
            }
        });
        for (var j = 0; j < timesheetListobject.length; j++) {
                    filteredTimesheetList.append({
                        id: timesheetListobject[j].id,
                        project_id: timesheetListobject[j].project_id,
                        task_id: timesheetListobject[j].task_id,
                        name: timesheetListobject[j].name,
                        spent_hours: timesheetListobject[j].spent_hours,
                        quadrant_id: timesheetListobject[j].quadrant_id,
                        date: timesheetListobject[j].date
                    });
                }
    }
    function filterTimesheetList(query) {
        filteredTimesheetList.clear(); 

        for (var i = 0; i < timesheetListobject.length; i++) {
            var entry = timesheetListobject[i];
            // Check if the query matches the name, project_id or task_id (case insensitive)
            if (entry.name.toLowerCase().includes(query.toLowerCase()) || 
                entry.project_id.toLowerCase().includes(query.toLowerCase()) || 
                entry.task_id.toLowerCase().includes(query.toLowerCase())) {
                filteredTimesheetList.append(entry);

            }
        }
    }


    function toggleChildren(index, expanded) {
        let parent = treeModel.get(index);
        if (expanded) {
            // Collapse children
            for (var i = index + 1; i < treeModel.count; ++i) {
                if (treeModel.get(i).type === "child") {
                    treeModel.setProperty(i, "visible", false);
                } else {
                    break;  // Stop if we reach the next parent
                }
            }
            treeModel.setProperty(index, "expanded", false);
        } else {
            // Expand children
            for (var i = index + 1; i < treeModel.count; ++i) {
                if (treeModel.get(i).type === "child") {
                    treeModel.setProperty(i, "visible", true);
                } else {
                    break;  // Stop if we reach the next parent
                }
            }
            treeModel.setProperty(index, "expanded", true);
        }
    }
    function groupByUserData(filtered) {
        let filter = false
        if(filtered){
            filter = true
            var groupedData = groupByUser(filtered);  // Group data by user
        }else{
            var groupedData = groupByUser(timesheetList);  // Group data by user
        }
        treeModel.clear();  // Clear existing tree model

        // Loop over each user in the grouped data
        for (let user_id in groupedData) {
            let userGroup = groupedData[user_id];
            treeModel.append({
                type: "parent",
                user_id: user_id,
                user_name: userGroup.user_name,
                count: userGroup.tasks.length,  // Set the count of tasks (children) for this user
                expanded: filter ? true : false  // Start collapsed
            });
            userGroup.tasks.forEach(task => {
                treeModel.append({
                    type: "child",
                    id: task.id,
                    user_name: task.user_name,
                    task_id: task.task_id,
                    date: task.date,
                    project_id: task.project_id,
                    description: task.description,
                    spenthours: task.spenthours,
                    visible: filter ? true : false  // Children are hidden by default
                });
            });
        }
    }
    
    function edittimesheetData(data){
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            // Update the record in the database
            
            tx.executeSql('UPDATE account_analytic_line_app SET \
                account_id = ?, record_date = ?, project_id = ?, task_id = ?, \
                name = ?,  unit_amount = ?, last_modified = ? WHERE id = ?',
                [data.updatedAccount, data.updatedDate, data.updatedProject, 
                data.subtask == 0 ? data.updatedTask : data.subTask, data.updatedDescription,
                data.updatedSpentHours, new Date().toISOString(), data.rowId]  // Pass the `id` of the row you want to edit here
            );
            timesheetlistData()


        });
    
    }
    function notaddDataPro(model){
        if(model.project_id ){
            return "#000000"
        }else{
            return "#ff0000"
        }
    }
    function notaddDatatask(model){
        if(model.task_id){
            return "#000000"
        }else{
            return "#ff0000"
        }
    }

    ListModel { 
     id: quadrantsListModel
        ListElement { itemId: 1; name: "Urgent and important tasks" }
        ListElement { itemId: 2; name: "Not urgent, yet important tasks" } 
        ListElement { itemId: 3; name: "Important but not urgent tasks" }
        ListElement { itemId: 4; name: "Not urgent and not important tasks" }
    }
    
    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: listPage
        // Header
       
        Rectangle {
            // visible: headermainOpen
            id: header_main
            width: parent.width
            height: isDesktop() ? 60 : 120
            color: "#121944"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            z: 1
            
            Row{
                anchors.verticalCenter: parent.verticalCenter
                anchors.fill: parent
                height: parent.height 
                spacing: 20 

                Rectangle {
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width / 2
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    height: parent.height 

                    Row {
                        // anchors.centerIn: parent
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height + 20 
                        spacing: 10

                        Image {
                            id: img_id
                            source: "images/timemanagementapp_logo_only_white.png"
                            width: isDesktop() ? 65 : 110
                            height: isDesktop() ? 50 : 90
                            anchors.verticalCenter: parent.verticalCenter
                            // anchors.left: parent.left
                            // anchors.leftMargin: time_id.width + 20
                            anchors.left: parent.left
                            anchors.leftMargin: isDesktop() ? 7: 10
                        }

                        Label {
                            id: time_id
                            text: "Time Management"
                            color: "white"
                            font.pixelSize: isDesktop() ? 20 : 40
                            // anchors.left: parent.left
                            // anchors.leftMargin: isDesktop() ? 7: 10
                            anchors.left: parent.left
                            anchors.leftMargin: img_id.width - (isDesktop() ? 0: 5)
                            // anchors.bottom: parent.bottom
                            // anchors.bottomMargin: 20
                            anchors.verticalCenter: parent.verticalCenter 
                        }


                        // Label {
                        //     text: "Management"
                        //     color: "white"
                        //     font.pixelSize: isDesktop() ? 20 : 40
                        //     anchors.verticalCenter: parent.verticalCenter
                        //     anchors.left: parent.left
                        //     anchors.leftMargin: (time_id.width + img_id.width) - (isDesktop() ?0 :0)  
                        // }
                    }
                }


                Rectangle {
                    color: "transparent"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.fill: parent
                    height: parent.height 

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        spacing: 10  // Adjust spacing as needed
                        height: parent.height 

                        
                        Text {
                            id: personalId
                            text: workpersonaSwitchState ? "Work" : "Personal"
                            color: "white"
                            font.pixelSize: isDesktop() ? 20 : 40
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        // Switch Background and Toggle
                        Rectangle {
                            id: switchBackground
                            width: isDesktop() ? 50 : 110
                            height: isDesktop() ? 20 : 50
                            radius: isDesktop() ? 2 : 4
                            color: workpersonaSwitchState ? "#CCCCCC" : "#008000"
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                id: switchHandle
                                width: isDesktop() ? 22 : 45
                                height: isDesktop() ? 22 : 52
                                radius: isDesktop() ? 2 : 4
                                color: "#FFFFFF"
                                anchors.verticalCenter: parent.verticalCenter
                                visible: !mySwitch.checked
                                anchors.left: parent.left
                            }

                            Rectangle {
                                id: switchHandleright
                                width: isDesktop() ? 22 : 45
                                height: isDesktop() ? 22 : 52
                                radius: isDesktop() ? 2 : 4
                                color: "#FFFFFF"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                visible: mySwitch.checked
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mySwitch.checked = !mySwitch.checked
                                }
                            }
                        }

                        Switch {
                            id: mySwitch
                            visible: false
                            checked: false
                            onCheckedChanged: {
                                workpersonaSwitchState = !mySwitch.checked;
                                stackView.push(listPage);
                                timesheetlistData();
                                console.log(mySwitch.checked ? "Switch is OFF" : "Switch is ON");
                            }
                        }

                        // Text label positioned to the right of the switch
                       

                        // Hamburger Button positioned to the left of the switch
                        Button {
                            id: hamburgerButton
                            width: isDesktop() ? 60 : 120
                            height: isDesktop() ? 60 : 120
                            anchors.verticalCenter: parent.verticalCenter

                            background: Rectangle {
                                color: "#121944"
                                border.color: "#121944"
                            }

                            Label {
                                text: "☰"
                                font.pixelSize: isDesktop() ? 20 : 40
                                color: "#fff"
                                anchors.centerIn: parent
                            }

                            onClicked: hamburgerButtonmenu.open()
                        }
                        // // // Dropdown Menu
                        Menu {
                            id: hamburgerButtonmenu
                            x: parent.width - 100
                            y: hamburgerButton.y + hamburgerButton.height
                            width: isDesktop() ? 250 : Screen.width - 100
                            // width: isDesktop() ? 250 : 400
                            // height: isDesktop() ? 200 : 500
                            height: isDesktop() ? 200 : Screen.height
                            
                            background: Rectangle {
                                color: "#121944" 
                                radius: 4
                                border.color: "#121944"
                                width: Screen.width + 10  
                                
                                // spacing:20
                                }

                                Rectangle {
                                    visible: isDesktop() ? false: true
                                    id: closeButton
                                    width: isDesktop() ?0:150
                                    height: isDesktop() ?0:150
                                    color: "transparent"  // Close button background color
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    radius: 5
                                    border.color: "#121944"
                                    Image {
                                        source: "images/cross_wait.svg" // Replace with your image path
                                        anchors.centerIn: parent
                                        width: isDesktop() ?0:100
                                        height: isDesktop() ?0:100
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            hamburgerButtonmenu.visible = false  // Hide the menu on click
                                        }
                                    }
                                }
                                MenuItem {
                                width: parent.width
                                height: isDesktop() ? 37 : 100
                                
                                background: Rectangle {
                                    color: "#121944" 
                                    radius: 4
                                    // border.color: "#ffffff" 
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    width: parent.width
                                    Rectangle {
                                        visible: isDesktop() ? false: true
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 2  // Border height
                                        color: "#ffffff"  // Border color
                                    }
                                    Rectangle {
                                        visible: isDesktop() ? false: true
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 2  // Border height
                                        color: "#ffffff"  // Border color
                                    }
                                    }

                                Text {
                                    text: "Projects"
                                    font.pixelSize: isDesktop() ? 18 : 40
                                    anchors.centerIn: parent
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: "#fff"
                                }
                                // text: 
                                onClicked: {
                                    stackView.push(projectList);
                                }
                                
                            }

                            MenuItem {
                                width: parent.width
                                height: isDesktop() ? 35 : 100
                                
                                background: Rectangle {
                                    color: "#121944" 
                                    radius: 4
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    width: parent.width
                                    
                                    Rectangle {
                                        visible: isDesktop() ? false: true
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 2  // Border height
                                        color: "#ffffff"  // Border color
                                    }
                                }

                                Text {
                                    text: "Tasks"
                                    font.pixelSize: isDesktop() ? 18 : 40
                                    anchors.centerIn: parent
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: "#fff"
                                }
                                // text: 
                                onClicked: {
                                    stackView.push(taskList);
                                }
                            }

                            MenuItem {
                                width: parent.width
                                height: isDesktop() ? 35 : 100
                                // color: "#121944"
                                background: Rectangle {
                                    color: "#121944" // Background color of the MenuItem
                                    radius: 4
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    width: parent.width
                                    
                                    Rectangle {
                                        visible: isDesktop() ? false: true
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 2  // Border height
                                        color: "#ffffff"  // Border color
                                    }
                                }

                                Text {
                                    text: "Timesheets"
                                    font.pixelSize: isDesktop() ? 18 : 40
                                    anchors.centerIn: parent
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: "#fff"
                                }
                                // text: 
                                onClicked: {
                                    // Add logout logic here
                                    stackView.push(storedTimesheets);
                                    console.log("Timesheets out...")
                                    
                                }
                                
                            }
                            // MenuItem {
                            //     width: parent.width
                            //     height: isDesktop() ? 35 : 100
                            //     // color: "#121944"
                            //     background: Rectangle {
                            //         color: "#121944" // Background color of the MenuItem
                            //         radius: 4
                            //         anchors.left: parent.left
                            //         anchors.leftMargin: 20
                            //         width: parent.width
                                    
                            //         Rectangle {
                            //             visible: isDesktop() ? false: true
                            //             anchors.bottom: parent.bottom
                            //             anchors.left: parent.left
                            //             anchors.right: parent.right
                            //             height: 2  // Border height
                            //             color: "#ffffff"  // Border color
                            //         }
                            //     }

                            //     Text {
                            //         text: "Stages Project"
                            //         font.pixelSize: isDesktop() ? 18 : 40
                            //         anchors.centerIn: parent
                            //         anchors.horizontalCenter: parent.horizontalCenter
                            //         color: "#fff"
                            //     }
                            //     // text: 
                            //     onClicked: {
                            //         // Add logout logic here
                            //         console.log("Stages Project")
                                    
                            //     }
                                
                            // }
                            // MenuItem {
                            //     width: parent.width
                            //     height: isDesktop() ? 35 : 100
                            //     background: Rectangle {
                            //         color: "#121944" // Background color of the MenuItem
                            //         radius: 4
                            //         anchors.left: parent.left
                            //         anchors.leftMargin: 20
                            //         width: parent.width
                                    
                            //         Rectangle {
                            //             visible: isDesktop() ? false: true
                            //             anchors.bottom: parent.bottom
                            //             anchors.left: parent.left
                            //             anchors.right: parent.right
                            //             height: 2  // Border height
                            //             color: "#ffffff"  // Border color
                            //         }
                            //     }

                            //     Text {
                            //         text: "Stages Task"
                            //         font.pixelSize: isDesktop() ? 18 : 40
                            //         anchors.centerIn: parent
                            //         anchors.horizontalCenter: parent.horizontalCenter
                            //         color: "#fff"
                            //     }
                            //     onClicked: {
                            //         console.log("Stages Task")
                            //     }
                                
                            // }
                        }
                    }
                }


            
            }
        }

        // Login tabs
        Component {
            id: loginPage
            Item {

                Login {
                    anchors.centerIn: parent
                    onLoggedIn: {
                        currentUserId = courant_userid
                        selected_username = username;
                        currentTime = false;
                        stopwatchTimer.stop();
                        elapsedTime = 0;    
                        storedElapsedTime = 0;
                        running = false;
                        stackView.push(listPage);
                        horizontalPanel.activeImageIndex = 1
                        verticalPanel.activeImageIndex = 1              
                        penalOpen= true
                        headermainOpen= true
                        
                    }
                     

                }
            }
        }

        // ActivityLists tabs
        Component {
            id: activityLists
            Item {
                objectName: "activityLists"
                ActivityList {
                    anchors.centerIn: parent
                    onNewRecordActivity: {
                        stackView.push(activityForm)
                    }
                }
            }
        }

        // ActivityForm Tabs
        Component {
            id: activityForm
            Item {
                objectName: "activityForm"
                ActivityForm {
                    anchors.centerIn: parent
                }
            }
        }

        // Account Tabs
        Component {
            id: manageAccounts
            Item {
                ManageAccounts {
                    anchors.top: parent.top
                    anchors.topMargin: 100
                    anchors.centerIn: parent
                    onLogInPage: {
                        stackView.push(loginPage, {'user_name': username, 'account_name': name, 'selected_database': db, 'selected_link': link})
                        // stackView.push(loginPage, {'Accountuser_id': Accountuser_id,})
                        penalOpen= true
                        headermainOpen= false
                    }
                    onBackPage: {
                        currentTime = false;
                        stopwatchTimer.stop();
                        storedElapsedTime = 0;
                        elapsedTime = 0;
                        running = false;
                        stackView.push(listPage)
                    }
                    onGoToLogin: {
                        stackView.push(loginPage)
                        penalOpen= true
                        headermainOpen= false
                    }
                   
                }
            }
        }

        // SettingAccounts Tabs
        Component {
            id: settingAccounts
            Item {
                Setting {
                    anchors.centerIn: parent
                    onLogInPage: {
                        stackView.push(loginPage, {'user_name': username, 'account_name': name, 'selected_database': db, 'selected_link': link})
                        // stackView.push(loginPage, {'Accountuser_id': Accountuser_id,})
                        penalOpen= true
                        headermainOpen= false
                    }
                    onBackPage: {
                        currentTime = false;
                        stopwatchTimer.stop();
                        storedElapsedTime = 0;
                        elapsedTime = 0;
                        running = false;
                        stackView.push(listPage)
                    }
                    onGoToLogin: {
                        stackView.push(loginPage)
                        penalOpen= true
                        headermainOpen= false
                    }
                   
                }
            }
        }

        // wipmanageAccounts tabs
        Component {
            id: wipmanageAccounts
            Rectangle {
                width: parent.width
                height: parent.height
                // color: "#ffffff"
                Column {
                    spacing: 0
                    anchors.fill: parent
                    Rectangle {
                        width: parent.width
                        height: 100
                        color: "#121944"
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        Rectangle {
                            width: parent.width
                            height: 100
                            color: "#121944"
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 20
                            Image {
                                id: logo
                                source: "images/timeManagemetLogo.png" // Path to your logo image
                                width: 100 // Width of the logo
                                height: 100 // Height of the logo
                                anchors.top: parent.top
                            }
                        }
                        Text {
                            text: "Manage Accounts"
                            anchors.centerIn: parent
                            font.pixelSize: 40
                            color: "#ffffff"
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 80
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 130
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    Label {
                        font.bold: true
                        font.pixelSize: 50
                        text: "This page is under development"
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 80
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 200
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    Label {
                        font.pixelSize: 40
                        text: "Agenda of this page is to work with multiple accounts \nwithout logging out, and provide facility to switching \naccounts."
                    }
                }
                Rectangle {
                    width: parent.width
                    height: 80
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 400
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    Button {
                        id: backButton
                        width: 150
                        height: 130
                        anchors.verticalCenter: parent.verticalCenter

                        background: Rectangle {
                            color: "#121944"
                            border.color: "#121944"
                        }

                        // Hamburger Icon
                        Label {
                            text: "Back"
                            font.pixelSize: 40
                            color: "#fff"
                            anchors.centerIn: parent
                        }

                        // Show/hide the menu on click
                        onClicked: {
                            currentTime = false;
                            stopwatchTimer.stop();
                            storedElapsedTime = 0;
                            elapsedTime = 0;
                            running = false;
                            stackView.push(listPage)
                        }
                    }
                }
            }

        }

        // Timesheet list Tabs
        Component {
            id: storedTimesheets
            Rectangle {
                objectName: "storedTimesheets"
                width: parent.width
                height: parent.height
                color: "#ffffff"
                Column {
                    spacing: 0
                    anchors.fill: parent

                    Rectangle {
                        id:timesheetHeader
                        width: parent.width
                        height: isDesktop()? 60 : 120 // Make height of the header adaptive based on content
                        anchors.top: parent.top
                        anchors.topMargin: isDesktop() ? 60 : 120
                        color: "#FFFFFF"   // Background color for the header
                        z: 1

                        // Bottom border
                        Rectangle {
                            width: parent.width
                            height: 2                    // Border height
                            color: "#DDDDDD"             // Border color
                            anchors.bottom: parent.bottom
                        }

                        Row {
                            id: row_id
                            width: parent.width
                            anchors.verticalCenter: parent.verticalCenter 
                            anchors.fill: parent
                            spacing: isDesktop() ? 20 : 40 
                            anchors.left: parent.left
                            anchors.leftMargin: isDesktop()? 55 : -10 
                            anchors.right: parent.right
                            anchors.rightMargin: isDesktop()?15 : 20 

                            // Left section with ToolButton and "Activities" label
                            Rectangle {
                                id: header_tital
                                visible: !issearchHeadermain
                                color: "transparent"
                                width: parent.width / 5
                                anchors.verticalCenter: parent.verticalCenter
                                height: parent.height 

                                Row {
                                    // anchors.centerIn: parent
                                    anchors.verticalCenter: parent.verticalCenter

                                ToolButton {
                                    width: isDesktop() ? 40 : 80
                                    height: isDesktop() ? 35 : 80 
                                    background: Rectangle {
                                        color: "transparent"  // Transparent button background
                                    }
                                    contentItem: Ubuntu.Icon {
                                        name: "back" 
                                    }
                                    onClicked: {
                                        stackView.push(listPage)
                                    }
                                }    

                                Label {
                                    text: "Timesheets"
                                    font.pixelSize: isDesktop() ? 20 : 40
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: ToolButton.right
                                    font.bold: true
                                    color: "#121944"
                                }
                                
                                }
                            }

                            // Right section with Button
                            Rectangle {
                                id: header_btnADD
                                visible: !issearchHeadermain
                                color: "transparent"
                                width: parent.width / 8
                                anchors.verticalCenter: parent.verticalCenter
                                height: parent.height 
                                anchors.right: parent.right

                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: isDesktop() ? 10 : 20
                                    anchors.right: parent.right

                                    ToolButton {
                                        id: search_id
                                        width: isDesktop() ? 40 : 80
                                        height: isDesktop() ? 35 : 80
                                        background: Rectangle {
                                            color: "transparent"  // Transparent button background
                                        }
                                        contentItem: Ubuntu.Icon {
                                            name: "search" 
                                        }
                                        onClicked: {
                                            issearchHeadermain = true
                                        }
                                    }
                                }
                                
                            }


                                Rectangle{
                                    id: search_header
                                    visible: issearchHeadermain
                                    width:parent.width
                                    anchors.verticalCenter: parent.verticalCenter
                                    ToolButton {
                                        id: back_idn
                                        width: isDesktop() ? 35 : 80
                                        height: isDesktop() ? 35 : 80
                                        anchors.verticalCenter: parent.verticalCenter
                                        background: Rectangle {
                                            color: "transparent"  // Transparent button background
                                        }
                                        contentItem: Ubuntu.Icon {
                                            name: "back"
                                        }
                                        onClicked: {
                                            issearchHeadermain = false
                                        }
                                    }

                                    // Full-width TextField
                                    TextField {
                                        id: searchField
                                        placeholderText: "Search..."
                                        anchors.left: back_idn.right // Start from the right of ToolButton
                                        anchors.leftMargin: isDesktop() ? 0 : 5
                                        anchors.right: parent.right // Extend to the right edge of the Row
                                        anchors.verticalCenter: parent.verticalCenter
                                        onTextChanged: {
                                            filterTimesheetList(searchField.text)  // Call the filter function when the text changes
                                        }
                                    }
                            }
                        }
                    }
                    
                   
                    Column {
                        spacing: 10
                        anchors.fill: parent
                        anchors.top: parent.top
                        anchors.topMargin: isDesktop() ? 65 : 120
                        anchors.left: parent.left
                        anchors.leftMargin: isDesktop()?70 : 20
                        anchors.right: parent.right
                        anchors.rightMargin: isDesktop()?10 : 20
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: isDesktop()?0:100
                        // Row {
                        //     id: searchId
                        //     spacing: 10
                        //     anchors.top: parent.top  // Position below the search row
                        //     anchors.topMargin: isDesktop() ? 20 : 80
                        //     anchors.left: parent.left
                        //     anchors.leftMargin: isDesktop() ? 20 : 10
                        //     anchors.right: parent.right  // Float the search field to the right
                        //     width: parent.width

                        //     // Label on the left side
                        //     Label {
                        //         text: "Timesheets"
                        //         font.pixelSize: isDesktop() ? 20 : 40
                        //         anchors.verticalCenter: parent.verticalCenter
                        //         anchors.left: parent.left
                        //         font.bold: true
                        //         color:"#121944"
                        //         width: parent.width * (isDesktop() ? 0.8 :0.5)
                        //     }

                        //     // Search field on the right side
                        //     TextField {
                        //         id: searchField
                        //         placeholderText: "Search..."
                        //         anchors.verticalCenter: parent.verticalCenter
                        //         anchors.right: parent.right
                        //         width: parent.width * (isDesktop() ? 0.2 :0.5)
                        //         onTextChanged: {
                        //             filterTimesheetList(searchField.text);  // Call the filter function when the text changes
                        //         }
                        //     }
                        // }
                        Rectangle {
                            // spacing: 0
                            anchors.fill: parent
                            anchors.top: searchId.bottom  // Position below the search row
                            anchors.topMargin: isDesktop() ? 68 : 170
                            border.color: "#CCCCCC"
                            border.width: isDesktop() ? 1 : 2

                        Column {
                            spacing: 0
                            anchors.fill: parent
                            anchors.top: searchId.bottom // Position below the search row
                            anchors.topMargin: isDesktop()?1 : 2

                            Flickable {
                                id: timesheetFlickable
                                anchors.fill: parent
                                width: 100
                                contentHeight: column.height 
                                clip: true 
                                property string edit_id: ""
                                visible: isDesktop() ? true : phoneLarg()? true : rightPanel.visible? false : true



                                Column {
                                    id: column
                                    width: rightPanel.visible? parent.width / 2 : parent.width
                                    spacing: 0

                                    Repeater {
                                        model: filteredTimesheetList
                                        delegate: Rectangle {
                                            id: row_main_id
                                            width: parent.width
                                            height: isDesktop()?81:100 
                                            color: selectedId === model.id ? "#F5F5F5" : "#FFFFFF"
                                            border.color: "#CCCCCC"
                                            border.width:isDesktop()? 1 : 2
                                            
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                        selectedId = model.id  // Set the selected ID to the clicked row's ID
                                                        timesheetFlickable.edit_id= model.id; // Replace with dynamic data from model
                                                        rightPanel.loadProjectData();  // Load project data for the right panel
                                                        rightPanel.visible = true  // Hide the panel when close button is clicked
                                                        isTimesheetEdit = false
                                                        isEditTimesheetClicked = false

                                                }
                                            }

                                            // Main Row

                                            Column {
                                                spacing: 0
                                                anchors.fill: parent

                                                Row {
                                                    width: parent.width
                                                    height: isDesktop() ? 50 : 50
                                                    spacing: 0  // No spacing here, as we'll manage the spacing with the color bar

                                                    // Left color bar
                                                        Rectangle {
                                                            width: 10  // Width of the color bar
                                                            height: isDesktop()?79:97
                                                            anchors.top: parent.top
                                                            anchors.topMargin: 1
                                                            color: getColorBasedOnIndex(index)
                                                            function getColorBasedOnIndex(index) {
                                                                switch(index % 4) {
                                                                    case 0: return "#ff0000";  // Red for index divisible by 4
                                                                    case 1: return "#00ff00";  // Green for index+1
                                                                    case 2: return "#0000ff";  // Blue for index+2
                                                                    case 3: return "#ffff00";  // Yellow for index+3
                                                                    default: return "#cccfff";  // Fallback to black
                                                                }
                                                            }
                                                        }

                                                    // Main content of the Row
                                                    Column {
                                                        spacing: 0
                                                        width: parent.width - 10  // Subtract color bar width from total width

                                                        // First Row: Date, Name, and Spent Hours
                                                        Row {
                                                            width: parent.width
                                                            height: isDesktop() ? 40 : 50
                                                            spacing: 20

                                                            Text {
                                                                id: date_id
                                                                text: model.date
                                                                font.pixelSize: isDesktop() ? 18 : 26
                                                                color: "#000000"
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                anchors.left: parent.left
                                                                anchors.leftMargin: 10
                                                                width: parent.width * 0.4
                                                            }

                                                            // Center: Name in Bold
                                                            Text {
                                                                text: rightPanel.visible ? (model.name.length > 15 ?  model.name.substring(0, 15) + "..." : model.name) : (model.name.length > 30 ?  model.name.substring(0, 30) + "..." : model.name)
                                                                id: name_id
                                                                font.pixelSize: isDesktop() ? 18 : 30
                                                                color: "#000000"
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                anchors.left: date_id.right
                                                                anchors.leftMargin: 10
                                                                width: parent.width * 0.4
                                                            }

                                                            // Spent Hours on the right in bold green
                                                            Text {
                                                                id: hrs_id
                                                                text: model.spent_hours + " Hrs"
                                                                font.pixelSize: isDesktop() ? 18 : 26
                                                                color: "#000000"
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                anchors.right: parent.right
                                                                horizontalAlignment: Text.AlignRight 
                                                                anchors.rightMargin: 10
                                                                width: parent.width * 0.3
                                                            }
                                                        }

                                                        // Second Row: Project and Task Info
                                                        Row {
                                                            width: parent.width
                                                            height: isDesktop() ? 40 : 50
                                                            spacing: 20

                                                            // Project Name on the left with fixed width
                                                            Text {
                                                                id: project_name
                                                                text: rightPanel.visible ? (model.project_id.length > 15 ? "Project: " + model.project_id.substring(0, 15) + "..." : "Project: " + model.project_id) : (model.project_id.length > 20 ? "Project: " + model.project_id.substring(0, 20) + "..." : "Project: " + model.project_id)

                                                                font.pixelSize: isDesktop() ? 18 : 26
                                                                color: notaddDataPro(model)
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                anchors.left: parent.left
                                                                anchors.leftMargin: 10
                                                                width: (parent.width * 0.5) - (parent.width * 0.1)
                                                            }

                                                            // Task Name on the right of Project Name
                                                            Text {
                                                                text: rightPanel.visible ? (model.task_id.length > 15 ? "Tasks: " + model.task_id.substring(0, 15) + "..." : "Tasks: " + model.task_id) : (model.task_id.length > 20 ? "Tasks: " + model.task_id.substring(0, 20) + "..." : "Tasks: " + model.task_id)

                                                                font.pixelSize: isDesktop() ? 18 : 26
                                                                color: notaddDatatask(model)
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                anchors.left: project_name.right
                                                                anchors.leftMargin: 10
                                                            }
                                                        }
                                                    }
                                                }
                                            }


                                        }
                                    }
                                }
                            }
                            Rectangle {
                                id: rightPanel
                                z: 1
                                visible: false
                                width: isDesktop() ? parent.width /2 : phoneLarg()? parent.width /2 : parent.width
                                height: parent.height
                                anchors.top: parent.top
                                anchors.topMargin: phoneLarg()? 0 :0
                                color: "#EFEFEF"
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom

                                function loadProjectData() {
                                    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
                                    var rowId = timesheetFlickable.edit_id;

                                    db.transaction(function (tx) {
                                        if(workpersonaSwitchState){
                                            var result = tx.executeSql('SELECT * FROM account_analytic_line_app WHERE id = ?', [rowId]);
                                        }else{
                                            var result = tx.executeSql('SELECT * FROM account_analytic_line_app where account_id IS NULL AND id = ?', [rowId] );
                                        }
                                        if (result.rows.length > 0) {
                                            var rowData = result.rows.item(0);
                                            console.log(JSON.stringify(rowData, null, 2), "////rowData////");

                                            var projectId = rowData.project_id || "";  
                                            var taskId = rowData.task_id || "";        
                                            var accountId = rowData.account_id || "";  
                                            var rowDate = new Date(rowData.record_date || new Date());  

                                            var project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?', [projectId]);
                                            var task = tx.executeSql('SELECT name FROM project_task_app WHERE id = ?', [taskId]);
                                            if(workpersonaSwitchState){
                                             var account = tx.executeSql('SELECT name FROM users WHERE id = ?', [accountId]);
                                            }
                                            
                                            editprojectInput.text = project.rows.length > 0 ? project.rows.item(0).name || "" : "";
                                            selectedProjectId = projectId;
                                            if(workpersonaSwitchState){
                                                editaccountInput.text = account.rows.length > 0 ? account.rows.item(0).name || "" : "";
                                                selectedAccountUserId = accountId;
                                            }
                                            var formattedDate = formatDate(rowDate);  
                                            datetimeInput.text = formattedDate;

                                            editdescriptionInput.text = rowData.name || "";  
                                            edittaskInput.text = task.rows.length > 0 ? task.rows.item(0).name || "" : "";
                                            selectedTaskId = taskId;

                                            editspenthoursManualInput.text = rowData.unit_amount || "";  
                                            // selectededitquadrantId = rowData.quadrant_id
                                            // if(rowData.quadrant_id === 0){
                                            //     editquadrantInput.text = ""
                                            // }
                                            // if(rowData.quadrant_id === 1){
                                            //     editquadrantInput.text = "Urgent and important tasks"
                                            // }
                                            // if(rowData.quadrant_id === 2){
                                            //     editquadrantInput.text = "Not urgent, yet important tasks"
                                            // }
                                            // if(rowData.quadrant_id === 3){
                                            //     editquadrantInput.text = "Important but not urgent tasks"
                                            // }
                                            // if(rowData.quadrant_id === 4){
                                            //     editquadrantInput.text = "Not urgent and not important tasks"
                                            // }
                                        }
                                    });

                                    function formatDate(date) {
                                        var month = date.getMonth() + 1;  // Months are zero-based, so we add 1
                                        var day = date.getDate();
                                        var year = date.getFullYear();
                                        
                                        month = (month < 10 ? '0' : '') + month;
                                        day = (day < 10 ? '0' : '') + day;
                                        
                                        return month + '/' + day + '/' + year;
                                    }
                                }

                                Column {
                                    anchors.fill: parent
                                    spacing: 20
                                    // timesheetFlickable.edit_id = row get id
                                    Row {
                                        width: parent.width
                                        anchors.top: parent.top
                                        anchors.topMargin: 5
                                        // anchors.horizontalCenter: parent.horizontalCenter  // Center the row horizontally
                                        spacing: 10  // Add spacing between buttons if needed

                                        Button {
                                            id: crossButton
                                            anchors.left: parent.left
                                            width: isDesktop() ? 24 : 65
                                            height: isDesktop() ? 24 : 65
                                            anchors.leftMargin: 10
                                            // anchors.top: parent.top
                                            // anchors.topMargin: 10

                                            Image {
                                                source: "images/cross.svg" // Replace with your image path
                                                width: isDesktop() ? 24 : 65
                                                height: isDesktop() ? 24 : 65
                                            }

                                            background: Rectangle {
                                                color: "transparent"
                                                radius: 10
                                                border.color: "transparent"
                                            }

                                            onClicked: {
                                                rightPanel.visible = false 
                                                selectedId = -1
                                                // row_main_id.color="EFEFEF"
                                            }
                                        }


                                        Button {
                                            id: rightButton
                                            // Position this button on the right side
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.topMargin: 10
                                            width: isDesktop() ? 20 : 50
                                            height: isDesktop() ? 20 : 50
                                            anchors.rightMargin: isDesktop() ? 15 : 20

                                            Image {
                                                source: "images/right.svg" // Replace with your image path
                                                width: isDesktop() ? 20 : 50
                                                height: isDesktop() ? 20 : 50
                                            }

                                            background: Rectangle {
                                                color: "transparent"
                                                radius: 10
                                                border.color: "transparent"
                                            }

                                            onClicked: {
                                            var rowId = timesheetFlickable.edit_id;
                                                const editData = {
                                                    updatedProject: selectedProjectId ,
                                                    updatedTask: selectedTaskId,
                                                    updatedAccount: selectedAccountUserId,
                                                    updatedDescription: editdescriptionInput.text,
                                                    updatedSpentHours: editspenthoursManualInput.text,
                                                    updatedDate: datetimeInput.text,
                                                    // updatedquadrant: selectededitquadrantId,
                                                    subtask: 0,
                                                    rowId: rowId
                                                }
                                                if(editprojectInput.text && edittaskInput.text && workpersonaSwitchState?editaccountInput.text : true  && editspenthoursManualInput.text && editdescriptionInput.text){
                                                    isTimesheetEdit = true
                                                    isEditTimesheetClicked = true
                                                    edittimesheetData(editData)
                                                    filterTimesheetList(searchField.text)
                                                    // isEditTimesheetClicked = false

                                                }else{
                                                    isTimesheetEdit = false
                                                    isEditTimesheetClicked = true

                                                }
                                                
                                            
                                        }
                                        }
                                    }
                                    Flickable {
                                        id: flickableContainertimesheet
                                        width: parent.width
                                        // height: phoneLarg() ? parent.height - 50 : parent.height  // Adjust height for large phones
                                        height: parent.height  // Set the height to match the parent or a fixed value
                                        contentHeight: timesheetedit.childrenRect.height + (isDesktop()?0:100)  // The total height of the content inside Flickable
                                        anchors.fill: parent
                                        flickableDirection: Flickable.VerticalFlick  // Allow only vertical scrolling
                                        anchors.top: parent.top
                                        anchors.topMargin: isDesktop() ? 85 : phoneLarg()? 100 : 120
                                        

                                        // Make sure to enable clipping so the content outside the viewable area is not displayed
                                        clip: true
                                        Item {
                                            id: timesheetedit
                                            height: timesheetedit.childrenRect.height + 100
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.topMargin: isDesktop() ? 0 : phoneLarg()? 0 : 120
                                        // anchors.top: main_title.bottom
                                        // anchors.leftMargin: 10  
                                        
                                        

                                        Row {
                                            spacing: isDesktop() ? 100 : phoneLarg()? 260 :220
                                            anchors.verticalCenterOffset: -height * 1.5
                                            anchors.left: parent.left
                                            anchors.leftMargin: 23
                                            
                                            Component.onCompleted: {
                                                if (!isDesktop()) {
                                                    anchors.horizontalCenter = parent.horizontalCenter; // Apply only for desktop
                                                }
                                            }

                                            Column {
                                                spacing: isDesktop() ? 20 : 40
                                                width: isDesktop() ?40:phoneLarg()?50:80
                                                Label { text: "Account" 
                                                width: 150
                                                visible: workpersonaSwitchState
                                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                                font.pixelSize: isDesktop() ? 18 : 40
                                                }
                                                Label { text: "Date" 
                                                    width: 150
                                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                                    font.pixelSize: isDesktop() ? 18 : 40
                                                    }
                                                Label { text: "Project" 
                                                width: 150
                                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                                font.pixelSize: isDesktop() ? 18 : 40
                                                }
                                                
                                                Label { text: "Sub Project" 
                                                width: 150
                                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                                font.pixelSize: isDesktop() ? 18 : 40

                                                visible: hasSubProject}
                                                Label { text: "Task" 
                                                width: 150
                                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                                font.pixelSize: isDesktop() ? 18 : 40}
                                                Label { text: "Sub Task" 
                                                width: 150
                                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                                font.pixelSize: isDesktop() ? 18 : 40
                                                visible: hasSubTask}
                                                Label { text: "Description" 
                                                width: 150
                                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                                font.pixelSize: isDesktop() ? 18 : 40}
                                                // Label { text: "Quadrant" 
                                                // width: 150
                                                // height: isDesktop() ? 25 : phoneLarg()?50:80
                                                // font.pixelSize: isDesktop() ? 18 : 40}
                                                Label { text: "Spent Hours" 
                                                width: 150
                                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                                font.pixelSize: isDesktop() ? 18 : 40}
                                            }

                                            Column {
                                                spacing: isDesktop() ? 20 : 40
                                                Component.onCompleted: {
                                                if (!isDesktop()) {
                                                    width: 250
                                                    }
                                                }

                                                Rectangle {
                                                    width: isDesktop() ? 420 : 700
                                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                                    color: "transparent"
                                                    visible: workpersonaSwitchState

                                                    // Border at the bottom
                                                    Rectangle {
                                                        width: parent.width
                                                        height: isDesktop() ? 1 : 2
                                                        color: "black"  // Border color
                                                        anchors.bottom: parent.bottom
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                    }

                                                    ListModel {
                                                        id: editaccountList
                                                        // Example data
                                                    }

                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        anchors.fill: parent
                                                        // anchors.margins: 5                                                        
                                                        id: editaccountInput
                                                        Text {
                                                            id: editaccountplaceholder
                                                            text: "Instance"                                            
                                                            font.pixelSize:isDesktop() ? 18 : 40
                                                            color: "#aaa"
                                                            anchors.fill: parent
                                                            verticalAlignment: Text.AlignVCenter
                                                            
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                var result = accountlistDataGet(); 
                                                                    if(result){
                                                                        editaccountList.clear();
                                                                        for (var i = 0; i < result.length; i++) {
                                                                            editaccountList.append(result[i]);
                                                                        }
                                                                        menuAccount.open();
                                                                    }
                                                            }
                                                        }

                                                        Menu {
                                                            id: menuAccount
                                                            x: editaccountInput.x
                                                            y: editaccountInput.y + editaccountInput.height
                                                            width: editaccountInput.width  // Match width with TextField


                                                            Repeater {
                                                                model: editaccountList

                                                                MenuItem {
                                                                    width: parent.width
                                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                                                    property int editaccountId: model.id  // Custom property for ID
                                                                    property string editaccuntName: model.name || ''
                                                                    Text {
                                                                        text: editaccuntName
                                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                                        bottomPadding: 5
                                                                        topPadding: 5
                                                                        //anchors.centerIn: parent
                                                                        color: "#000"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                        anchors.left: parent.left
                                                                        anchors.leftMargin: 10                                                 
                                                                        wrapMode: Text.WordWrap
                                                                        elide: Text.ElideRight   
                                                                        maximumLineCount: 2      
                                                                    }

                                                                    onClicked: {
                                                                        edittaskInput.text = ''
                                                                        selectedTaskId = 0
                                                                        editsubTaskInput.text = ''
                                                                        selectedSubTaskId = 0
                                                                        hasSubTask = false
                                                                        editaccountInput.text = editaccuntName
                                                                        selectedAccountUserId = editaccountId
                                                                        menuAccount.close()
                                                                    }
                                                                }
                                                            }
                                                        }

                                                        onTextChanged: {
                                                            if (editaccountInput.text.length > 0) {
                                                                editaccountplaceholder.visible = false
                                                            } else {
                                                                editaccountplaceholder.visible = true
                                                            }
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    width: isDesktop() ? 420 : 700
                                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                                    color: "transparent"


                                                    Rectangle {
                                                        width: parent.width
                                                        height: isDesktop() ? 1 : 2
                                                        color: "black"
                                                        anchors.bottom: parent.bottom
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                    }
                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 : 50
                                                        anchors.fill: parent
                                                        id: datetimeInput
                                                        Text {
                                                            id: datetimeplaceholder
                                                            text: "Date"
                                                            font.pixelSize: isDesktop() ? 18 : 30
                                                            color: "#aaa"
                                                            anchors.fill: parent
                                                            verticalAlignment: Text.AlignVCenter
                                                        }

                                                        Dialog {
                                                            id: calendarDialog
                                                            width: isDesktop() ? 0 : 700
                                                            height: isDesktop() ? 0 : 650
                                                            padding: 0
                                                            margins: 0
                                                            visible: false

                                                            DatePicker {
                                                                id: datePicker
                                                                onClicked: {
                                                                    datetimeInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                                                }
                                                            }
                                                        }
                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                var now = new Date()
                                                                datePicker.selectedDate = now
                                                                datePicker.currentIndex = now.getMonth()
                                                                datePicker.selectedYear = now.getFullYear()
                                                                calendarDialog.visible = true
                                                            }
                                                        }

                                                        onTextChanged: {
                                                            if (datetimeInput.text.length > 0) {
                                                                datetimeplaceholder.visible = false
                                                            } else {
                                                                datetimeplaceholder.visible = true
                                                            }
                                                        }
                                                        function formatDate(date) {
                                                            var month = date.getMonth() + 1; // Months are 0-based
                                                            var day = date.getDate();
                                                            var year = date.getFullYear();
                                                            return month + '/' + day + '/' + year;
                                                        }

                                                        // Set the current date when the component is completed
                                                        Component.onCompleted: {
                                                            var currentDate = new Date().toISOString();
                                                            datetimeInput.text = formatDate(currentDate);
                                                        }

                                                    }
                                                }

                                                Rectangle {
                                                    width: isDesktop() ? 420 : 700
                                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                                    color: "transparent"

                                                    // Border at the bottom
                                                    Rectangle {
                                                        width: parent.width
                                                        height: isDesktop() ? 1 : 2
                                                        color: "black"  // Border color
                                                        anchors.bottom: parent.bottom
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                    }

                                                    ListModel {
                                                        id: editprojectsListModel
                                                        // Example data
                                                    }

                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        anchors.fill: parent
                                                        // anchors.margins: 5                                                        
                                                        id: editprojectInput
                                                        Text {
                                                            id: editprojectplaceholder
                                                            text: "Project"                                            
                                                            font.pixelSize:isDesktop() ? 18 : 40
                                                            color: "#aaa"
                                                            anchors.fill: parent
                                                            verticalAlignment: Text.AlignVCenter
                                                            
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                // python.call("backend.fetch_options", {} , function(result) {
                                                                //     // optionList = result;
                                                                //     projectsListModel.clear();
                                                                //     for (var i = 0; i < result.length; i++) {
                                                                //         // projectsListModel.append(result[i]);
                                                                //         // for (var i = 0; i < result.length; i++) {
                                                                //         projectsListModel.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': true ? result[i].child_ids.length > 0 : false})
                                                                //     // }
                                                                //     }
                                                                //     menu.open(); // Open the menu after fetching options
                                                                // });

                                                                editprojectsListModel.clear();
                                                                var result = fetch_projects(selectedAccountUserId);
                                                                for (var i = 0; i < result.length; i++) {
                                                                    console.log('\n\n result[i].name', '>>>>>>>>>>>', result[i].projectkHasSubProject)
                                                                    editprojectsListModel.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': result[i].projectkHasSubProject})
                                                                }
                                                                menu.open();

                                                            }
                                                        }

                                                        Menu {
                                                            id: menu
                                                            x: editprojectInput.x
                                                            y: editprojectInput.y + editprojectInput.height
                                                            width: editprojectInput.width  // Match width with TextField


                                                            Repeater {
                                                                model: editprojectsListModel

                                                                MenuItem {
                                                                    width: parent.width
                                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                                                    property int editprojectId: model.id  // Custom property for ID
                                                                    property string editprojectName: model.name || ''
                                                                    Text {
                                                                        text: editprojectName
                                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                                        bottomPadding: 5
                                                                        topPadding: 5
                                                                        //anchors.centerIn: parent
                                                                        color: "#000"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                        anchors.left: parent.left
                                                                        anchors.leftMargin: 10                                                 
                                                                        wrapMode: Text.WordWrap
                                                                        elide: Text.ElideRight   
                                                                        maximumLineCount: 2      
                                                                    }

                                                                    onClicked: {
                                                                        edittaskInput.text = ''
                                                                        selectedTaskId = 0
                                                                        editsubTaskInput.text = ''
                                                                        selectedSubTaskId = 0
                                                                        hasSubTask = false
                                                                        editprojectInput.text = editprojectName
                                                                        selectedProjectId = editprojectId
                                                                        selectedSubProjectId = 0
                                                                        hasSubProject = model.projectkHasSubProject
                                                                        editsubProjectInput.text = ''
                                                                        menu.close()
                                                                    }
                                                                }
                                                            }
                                                        }

                                                        onTextChanged: {
                                                            if (editprojectInput.text.length > 0) {
                                                                editprojectplaceholder.visible = false
                                                            } else {
                                                                editprojectplaceholder.visible = true
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                Rectangle {
                                                    width: isDesktop() ? 420 : 700
                                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                                    visible: hasSubProject
                                                    color: "transparent"

                                                    // Border at the bottom
                                                    Rectangle {
                                                        width: parent.width
                                                        height: isDesktop() ? 1 : 2
                                                        color: "black"  // Border color
                                                        anchors.bottom: parent.bottom
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                    }

                                                    ListModel {
                                                        id: editsubProjectsListModel
                                                        // Example data
                                                    }

                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: 40
                                                        anchors.fill: parent
                                                        //anchors.margins: 5                                
                                                        id: editsubProjectInput
                                                        Text {
                                                            id: editsubProjectplaceholder
                                                            text: "Sub Project"                                            
                                                            font.pixelSize:40
                                                            color: "#aaa"
                                                            anchors.fill: parent
                                                            verticalAlignment: Text.AlignVCenter
                                                            
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                var sub_project_list = fetch_sub_project(selectedProjectId);
                                                                subProjectsListModel.clear();
                                                                for (var i = 0; i <= sub_project_list.length; i++) {
                                                                    subProjectsListModel.push(sub_project_list[i]);
                                                                }
                                                                // python.call("backend.fetch_options_sub_projects", [selectedProjectId] , function(result) {
                                                                //     // optionList = result;
                                                                //     subProjectsListModel.clear();
                                                                //     for (var i = 0; i < result.length; i++) {
                                                                //         subProjectsListModel.append(result[i]);
                                                                //     }
                                                                //     subProjectmenu.open(); // Open the menu after fetching options
                                                                // });
                                                                subProjectmenu.open();

                                                            }
                                                        }

                                                        Menu {
                                                            id: subProjectmenu
                                                            x: editsubProjectInput.x
                                                            y: editsubProjectInput.y + editsubProjectInput.height
                                                            width: editsubProjectInput.width  // Match width with TextField


                                                            Repeater {
                                                                model: editsubProjectsListModel

                                                                MenuItem {
                                                                    width: parent.width
                                                                    height: phoneLarg()?50:80
                                                                    property int projectId: model.id  // Custom property for ID
                                                                    property string projectName: model.name || ''
                                                                    Text {
                                                                        text: projectName
                                                                        font.pixelSize: 40
                                                                        bottomPadding: 5
                                                                        topPadding: 5
                                                                        //anchors.centerIn: parent
                                                                        color: "#000"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                        anchors.left: parent.left
                                                                        anchors.leftMargin: 10                                                 
                                                                        wrapMode: Text.WordWrap
                                                                        elide: Text.ElideRight   
                                                                        maximumLineCount: 2      
                                                                    }

                                                                    onClicked: {
                                                                        edittaskInput.text = ''
                                                                        selectedTaskId = 0
                                                                        editsubTaskInput.text = ''
                                                                        selectedSubTaskId = 0
                                                                        hasSubTask = false
                                                                        editsubProjectInput.text = projectName
                                                                        selectedSubProjectId = projectId
                                                                        subProjectmenu.close()
                                                                    }
                                                                }
                                                            }
                                                        }

                                                        onTextChanged: {
                                                            if (subProjectInput.text.length > 0) {
                                                                editsubProjectplaceholder.visible = false
                                                            } else {
                                                                editsubProjectplaceholder.visible = true
                                                            }
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    width: isDesktop() ? 420 : 700
                                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                                    color: "transparent"

                                                    Rectangle {
                                                        width: parent.width
                                                        height: isDesktop() ? 1 : 2
                                                        color: "black"
                                                        anchors.bottom: parent.bottom
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                    }

                                                    ListModel {
                                                        id: edittasksListModel
                                                        // Example data
                                                    }

                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        anchors.fill: parent
                                                        // anchors.margins: isDesktop() ? 0 : 10
                                                        id: edittaskInput
                                                        // text: gridModel.get(index).task
                                                        Text {
                                                            id: edittaskplaceholder
                                                            text: "Task"
                                                            color: "#aaa"
                                                            font.pixelSize: isDesktop() ? 18 : 40
                                                            anchors.fill: parent
                                                            verticalAlignment: Text.AlignVCenter
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                edittasksListModel.clear()
                                                                var tasks_list = fetch_tasks_list((selectedSubProjectId == 0) ? selectedProjectId : selectedSubProjectId)
                                                                for (var i = 0; i < tasks_list.length; i++) {
                                                                    edittasksListModel.append({'id': tasks_list[i].id, 'name': tasks_list[i].name, 'taskHasSubTask': tasks_list[i].taskHasSubTask})
                                                                }
                                                                // python.call("backend.fetch_options_tasks", [(selectedSubProjectId == 0) ? selectedProjectId : selectedSubProjectId] , function(result) {
                                                                //     // tasksList = result;
                                                                //     tasksListModel.clear();
                                                                //     for (var i = 0; i < result.length; i++) {
                                                                //         tasksListModel.append({'id': result[i].id, 'name': result[i].name, 'taskHasSubTask': true ? result[i].child_ids.length > 0 : false})
                                                                //     }
                                                                //     menuTasks.open(); // Open the menu after fetching options
                                                                // });
                                                                menuTasks.open();

                                                            }
                                                        }

                                                        Menu {
                                                            id: menuTasks
                                                            x: edittaskInput.x
                                                            y: edittaskInput.y + edittaskInput.height
                                                            width: edittaskInput.width

                                                            Repeater {
                                                                model: edittasksListModel

                                                                MenuItem {
                                                                    width: parent.width
                                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                                                    property int taskId: model.id  // Custom property for ID
                                                                    property string taskName: model.name || ''
                                                                    // property bool taskHasSubTask: true ? model.child_ids.length > 0 : false
                                                                    Text {
                                                                        text: taskName
                                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                                        bottomPadding: 5
                                                                        topPadding: 5                                                    
                                                                        color: "#000"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                        anchors.left: parent.left
                                                                        anchors.leftMargin: 10          
                                                                        wrapMode: Text.WordWrap
                                                                        elide: Text.ElideRight   
                                                                        maximumLineCount: 2  
                                                                    }
                                                                    onClicked: {
                                                                        edittaskInput.text = taskName
                                                                        selectedTaskId = taskId
                                                                        editsubTaskInput.text = ''
                                                                        selectedSubTaskId = 0
                                                                        hasSubTask = model.taskHasSubTask
                                                                        menu.close()
                                                                    }
                                                                }
                                                            }
                                                        }

                                                        onTextChanged: {
                                                            if (edittaskInput.text.length > 0) {
                                                                edittaskplaceholder.visible = false
                                                            } else {
                                                                edittaskplaceholder.visible = true
                                                            }
                                                            if(!isDesktop()){
                                                            if (edittaskInput.text.length > 10) {
                                                                edittaskInput.text = edittaskInput.text.slice(0, 25) + "...";
                                                            } }
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    width: isDesktop() ? 420 : 700
                                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                                    color: "transparent"
                                                    visible: hasSubTask

                                                    Rectangle {
                                                        width: parent.width
                                                        height: isDesktop() ? 1 : 2
                                                        color: "black"
                                                        anchors.bottom: parent.bottom
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                    }

                                                    ListModel {
                                                        id: editsubTasksListModel
                                                        // Example data
                                                    }

                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        anchors.fill: parent
                                                        // anchors.margins: 10
                                                        id: editsubTaskInput
                                                        visible: hasSubTask
                                                        // text: gridModel.get(index).task
                                                        Text {
                                                            id: editsubtaskplaceholder
                                                            text: "Sub Task"
                                                            color: "#aaa"
                                                            font.pixelSize: isDesktop() ? 18 : 40                                       
                                                            anchors.fill: parent
                                                            verticalAlignment: Text.AlignVCenter
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                editsubTasksListModel.clear();
                                                                var sub_tasks_list = fetch_sub_tasks(selectedTaskId);
                                                                for (var i = 0; i < sub_tasks_list.length; i++) {
                                                                    editsubTasksListModel.append(sub_tasks_list[i])
                                                                }
                                                                menuSubTasks.open();

                                                            }
                                                        }

                                                        Menu {
                                                            id: menuSubTasks
                                                            x: editsubTaskInput.x
                                                            y: editsubTaskInput.y + editsubTaskInput.height
                                                            width: editsubTaskInput.width

                                                            Repeater {
                                                                model: editsubTasksListModel

                                                                MenuItem {
                                                                    width: parent.width
                                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                                                    property int subTaskId: model.id  // Custom property for ID
                                                                    property string subTaskName: model.name || ''
                                                                    Text {
                                                                        text: editsubTaskName
                                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                                        bottomPadding: 5
                                                                        topPadding: 5
                                                                        color: "#000"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                        anchors.left: parent.left
                                                                        anchors.leftMargin: 10                                                 
                                                                        wrapMode: Text.WordWrap
                                                                        elide: Text.ElideRight   
                                                                        maximumLineCount: 2  
                                                                    }
                                                                    onClicked: {
                                                                        editsubTaskInput.text = subTaskName
                                                                        selectedSubTaskId = subTaskId
                                                                        menu.close()
                                                                    }
                                                                }
                                                            }
                                                        }

                                                        onTextChanged: {
                                                            if (editsubTaskInput.text.length > 0) {
                                                                editsubtaskplaceholder.visible = false
                                                            } else {
                                                                editsubtaskplaceholder.visible = true
                                                            }
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    width: isDesktop() ? 420 : 700
                                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                                    color: "transparent"

                                                    Rectangle {
                                                        width: parent.width
                                                        height: isDesktop() ? 1 : 2
                                                        color: "black"
                                                        anchors.bottom: parent.bottom
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                    }

                                                    Flickable {
                                                        id: flickable
                                                        width: parent.width
                                                        height: parent.height
                                                        contentWidth: editdescriptionInput.width
                                                        clip: true  
                                                        interactive: true  
                                                        property int previousCursorPosition: 0
                                                        onContentWidthChanged: {
                                                            if (editdescriptionInput.cursorPosition > previousCursorPosition) {
                                                                contentX = contentWidth - width;  
                                                            }
                                                            else if (editdescriptionInput.cursorPosition < previousCursorPosition) {
                                                                contentX = Math.max(0, editdescriptionInput.cursorRectangle.x - 20); 
                                                            }
                                                            previousCursorPosition = editdescriptionInput.cursorPosition;
                                                        }

                                                        TextInput {
                                                            id: editdescriptionInput
                                                            width: Math.max(parent.width, textMetrics.width)  
                                                            height: parent.height
                                                            font.pixelSize: isDesktop() ? 18 : 40
                                                            wrapMode: Text.NoWrap  
                                                            anchors.fill: parent

                                                            Text {
                                                                id: editdescriptionplaceholder
                                                                text: "Description"
                                                                color: "#aaa"
                                                                font.pixelSize: isDesktop() ? 18 : 40
                                                                anchors.fill: parent
                                                                verticalAlignment: Text.AlignVCenter
                                                                visible: editdescriptionInput.text.length === 0
                                                            }

                                                            onFocusChanged: {
                                                                editdescriptionplaceholder.visible = !focus && editdescriptionInput.text.length === 0
                                                            }
                                                            property real textWidth: textMetrics.width
                                                            TextMetrics {
                                                                id: textMetrics
                                                                font: editdescriptionInput.font
                                                                text: editdescriptionInput.text
                                                            }

                                                            onTextChanged: {
                                                                contentWidth = textMetrics.width;
                                                            }

                                                            onCursorPositionChanged: {
                                                                flickable.contentX = Math.max(0, editdescriptionInput.cursorRectangle.x - flickable.width + 20);
                                                            }
                                                        }
                                                    }
                                                }

                                                // Rectangle {
                                                //     width: isDesktop() ? 420 : 700
                                                //     height: isDesktop() ? 25 : phoneLarg()? 50:80
                                                //     color: "transparent"

                                                //     // Border at the bottom
                                                //     Rectangle {
                                                //         width: parent.width
                                                //         height: isDesktop() ? 1 : 2
                                                //         color: "black"  // Border color
                                                //         anchors.bottom: parent.bottom
                                                //         anchors.left: parent.left
                                                //         anchors.right: parent.right
                                                //     }

                                                    

                                                //     TextInput {
                                                //         width: parent.width
                                                //         height: parent.height
                                                //         font.pixelSize: isDesktop() ? 18 : 40
                                                //         anchors.fill: parent
                                                //         // anchors.margins: 5                                                        
                                                //         id: editquadrantInput
                                                //         Text {
                                                //             id: editquadrantplaceholder
                                                //             text: "editQuadrant"                                            
                                                //             font.pixelSize:isDesktop() ? 18 : 40
                                                //             color: "#aaa"
                                                //             anchors.fill: parent
                                                //             verticalAlignment: Text.AlignVCenter
                                                //         }

                                                //         MouseArea {
                                                //             anchors.fill: parent
                                                //             onClicked: {
                                                //                 editquadrantmenu.open();
                                                //             }
                                                //         }

                                                //         Menu {
                                                //             id: editquadrantmenu
                                                //             x: editquadrantInput.x
                                                //             y: editquadrantInput.y + editquadrantInput.height
                                                //             width: editquadrantInput.width  // Match width with TextField

                                                //             Repeater {
                                                //                 model: quadrantsListModel

                                                //                 MenuItem {
                                                //                     width: parent.width
                                                //                     height: isDesktop() ? 40 :phoneLarg()? 50: 80
                                                //                     property int editquadrantId: model.itemId  // Custom property for ID
                                                //                     property string editquadrantName: model.name || ''
                                                //                     Text {
                                                //                         text: editquadrantName
                                                //                         font.pixelSize: isDesktop() ? 18 :40
                                                //                         bottomPadding: 5
                                                //                         topPadding: 5
                                                //                         //anchors.centerIn: parent
                                                //                         color: "#000"
                                                //                         anchors.verticalCenter: parent.verticalCenter
                                                //                         anchors.left: parent.left
                                                //                         anchors.leftMargin: 10                                                 
                                                //                         wrapMode: Text.WordWrap
                                                //                         elide: Text.ElideRight   
                                                //                         maximumLineCount: 2      
                                                //                     }

                                                //                     onClicked: {
                                                //                         editquadrantInput.text = editquadrantName
                                                //                         selectededitquadrantId = editquadrantId
                                                //                         editquadrantmenu.close()
                                                //                     }
                                                //                 }
                                                //             }
                                                //         }

                                                //         onTextChanged: {
                                                //             if (editquadrantInput.text.length > 0) {
                                                //                 editquadrantplaceholder.visible = false
                                                //             } else {
                                                //                 editquadrantplaceholder.visible = true
                                                //             }
                                                //         }
                                                //     }
                                                // } 

                                                Rectangle {
                                                    width: isDesktop() ? 420 : 700
                                                    height: isDesktop() ? 25 : phoneLarg()?50:80

                                                    color: "transparent"

                                                    Rectangle {
                                                        width: parent.width
                                                        height: isDesktop() ? 1 : 2
                                                        color: "black"
                                                        anchors.bottom: parent.bottom
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                    }
                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 20 : 40
                                                        anchors.fill: parent
                                                        // anchors.margins: isDesktop() ? 0 : 10
                                                        id: editspenthoursManualInput
                                                        // text: gridModel.get(index).task
                                                        Text {
                                                            id: editspenthoursManualInputPlaceholder
                                                            text: "00:00"
                                                            color: "#aaa"
                                                            font.pixelSize: isDesktop() ? 20 : 50
                                                            anchors.fill: parent
                                                            verticalAlignment: Text.AlignVCenter
                                                        }

                                                        onTextChanged: {
                                                            if (editspenthoursManualInput.text.length > 0) {
                                                                editspenthoursManualInputPlaceholder.visible = false
                                                            } else {
                                                                editspenthoursManualInputPlaceholder.visible = true
                                                            }
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    width: parent.width
                                                    height: 50
                                                    anchors.left: parent.left
                                                    anchors.topMargin: 20
                                                    color: "#EFEFEF"
                                                

                                                    Text {
                                                        id: timesheedSavedMessage
                                                        text: isTimesheetEdit ? "Timesheet is Edit successfully!" : "Timesheet could not be Edit!"
                                                        color: isTimesheetEdit ? "green" : "red"
                                                        visible: isEditTimesheetClicked
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        horizontalAlignment: Text.AlignHCenter // Align text horizontally (redundant here but useful for multi-line)
                                                        anchors.centerIn: parent

                                                    }
                                                }
                                                
                                                
                                            }
                                           
                                           

                                        }
                                    }}
                                    

                                    
                                }
                            }
                        }}
                    }
                }
            }
        }

        // Project List Tabs
        Component {
            id: projectList
            Item {
                objectName: "projectList"
                Projectlist {
                    anchors.top: parent.top
                    anchors.topMargin: 100
                    anchors.centerIn: parent
                    // workpersonaSwitchState: workpersonaSwitchState // Pass the property to ProjectList

                }
            }
        }

        // Task List Tabs
        Component {
            id: taskList
            Item {
                objectName: "taskList"
                TaskList {
                    // anchors.centerIn: parent
                }
            }
        }

        // Task List Tabs
        Component {
            id: taskForm
            Item {
                objectName: "taskForm"
                Taskform {
                    // anchors.centerIn: parent
                }
            }
        }

        // Timesheet Form Tabs
        Component {
            id: listPage
            Item{
            Rectangle {
                id:timesheet_id
                width: parent.width
                height: isDesktop()? 60 : 120 // Make height of the header adaptive based on content
                anchors.top: parent.top
                anchors.topMargin: isDesktop() ? 60 : 120
                color: "#FFFFFF"   // Background color for the header
                z: 1

                // Bottom border
                Rectangle {
                    width: parent.width
                    height: 2                    // Border height
                    color: "#DDDDDD"             // Border color
                    anchors.bottom: parent.bottom
                }

                Row {
                    id: row_id
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter 
                    anchors.fill: parent
                    spacing: isDesktop() ? 20 : 40 
                    anchors.left: parent.left
                    anchors.leftMargin: isDesktop()?70 : 10
                    anchors.right: parent.right
                    anchors.rightMargin: isDesktop()?15 : 20 

                    // Left section with ToolButton and "Activities" label
                    Rectangle {
                        color: "transparent"
                        width: parent.width / 3
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height 

                        Row {
                            // anchors.centerIn: parent
                            anchors.verticalCenter: parent.verticalCenter



                        // ToolButton {
                        //     width: isDesktop() ? 40 : 80
                        //     height: isDesktop() ? 35 : 80 
                        //     background: Rectangle {
                        //         color: "transparent"  // Transparent button background
                        //     }
                        //     contentItem: Ubuntu.Icon {
                        //         name: "back" 
                        //     }
                        //     onClicked: {
                        //         stackView.push(activityLists)
                        //     }
                        // }

                        Label {
                            text: "Time Sheet"
                            font.pixelSize: isDesktop() ? 20 : 40
                            anchors.verticalCenter: parent.verticalCenter
                            // anchors.right: ToolButton.right
                            font.bold: true
                            color: "#121944"
                        }
                        
                        }
                    }

                    // Center section with status message label
                    Rectangle {
                        color: "transparent"
                        width: parent.width / 3
                        height: parent.height 
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: timesheedSavedMessage
                            text: isTimesheetSaved ? "Timesheet is Saved successfully!" : "Timesheet could not be saved!"
                            color: isTimesheetSaved ? "green" : "red"
                            visible: isTimesheetClicked
                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                            horizontalAlignment: Text.AlignHCenter // Align text horizontally (redundant here but useful for multi-line)
                            anchors.centerIn: parent

                        }
                    }

                    // Right section with Button
                    Rectangle {
                        color: "transparent"
                        width: parent.width / 3
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height 
                        anchors.right: parent.right


                        Button {
                            id: rightButton
                            width: isDesktop() ? 20 : 50
                            height: isDesktop() ? 20 : 50
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right


                            Image {
                                source: "images/right.svg" // Image source
                                width: isDesktop() ? 20 : 50
                                height: isDesktop() ? 20 : 50
                            }

                            background: Rectangle {
                                color: "transparent"
                                radius: 10
                                border.color: "transparent"
                            }
                            onClicked: {
                                console.log(field_id.height,"/fastrow.height")
                                var dataArray = [];
                                
                                var dataObject = {
                                    dateTime: datetimeInput.text,
                                    project: selectedSubProjectId == 0 ? selectedProjectId : selectedSubProjectId,
                                    task: selectedTaskId,
                                    subTask: selectedSubTaskId,
                                    isManualTimeRecord: isManualTime,
                                    manualSpentHours: spenthoursManualInput.text,
                                    description: descriptionInput.text,
                                    spenthours: spenthoursInput.text,
                                    projecName:projectInput.text,
                                    instance_id: selectedAccountUserId,
                                    // quadrant: selectedquadrantId,
                                    taskName:taskInput.text
                                };
                                dataArray.push(dataObject);
                                // elapsedTime = 0;
                                // storedElapsedTime = 0;
                                currentTime = false;
                                if (running) {
                                    stopwatchTimer.stop()
                                    running = !running
                                }
                                if(workpersonaSwitchState?accountInput.text : true  && (spenthoursManualInput.text || spenthoursInput.text)){
                                    console.log("yes timesheet save")
                                    isTimesheetClicked = true;
                                    isTimesheetSaved = true;
                                    timesheetData(dataObject);
                                    typingTimer.start()
                                    timesheetlistData()
                                }else{
                                    isTimesheetClicked = true;
                                    isTimesheetSaved = false;
                                    typingTimer.start()
                                }
                                
                            }

                        }
                        Timer {
                            id: typingTimer
                            interval: 1500 // Time in milliseconds (1.5 second)
                            running: false
                            repeat: false
                            onTriggered: {
                                if (isTimesheetSaved) {
                                    elapsedTime = 0;
                                    storedElapsedTime = 0;
                                    isTimesheetClicked = false;
                                    isTimesheetSaved = false;
                                    isManualTime = false;
                                    projectInput.text = "";
                                    selectedProjectId = 0
                                    selectedSubProjectId = 0
                                    selectedTaskId = 0
                                    hasSubTask = false
                                    selectedSubTaskId = 0
                                    taskInput.text = "";
                                    hasSubProject = false
                                    subProjectInput.text = ""
                                    spenthoursManualInput.text = "";
                                    descriptionInput.text = "";
                                    selectedAccountUserId = 0
                                    accountInput.text = "";
                                    // selectedquadrantId = 0;
                                    // quadrantInput.text = "";


                                }else{
                                    isTimesheetClicked = false;
                                    isTimesheetSaved = false;
                                }
                            }
                        }
                    }
                }
            }
            Flickable {
                id: flickablelistpage
                width: parent.width
                // height: phoneLarg() ? parent.height - 50 : parent.height  // Adjust height for large phones
                height: parent.height  // Set the height to match the parent or a fixed value
                contentHeight: fastrow.childrenRect.height + (isDesktop() ?100 :500 )// The total height of the content inside Flickable
                anchors.fill: parent
                flickableDirection: Flickable.VerticalFlick  // Allow only vertical scrolling
                clip: true
            
                Rectangle {
                    width: parent.width
                    height: parent.height
                    anchors.top: parent.top 
                    anchors.topMargin: 100
                    color: "#ffffff"
                    id: list_id
                    Column {
                        spacing: 0
                        anchors.fill: parent
                        
                        
                        Rectangle {
                            id: main_title
                            anchors.top: parent.top  // Anchored to the bottom of header_main
                            width: parent.width
                            height: isDesktop() ? 60 : phoneLarg()? 45:phoneLarg()?50:80
                            // color: "#121944"
                            anchors.topMargin: isDesktop() ? 15 : 150
                            anchors.left: parent.left
                            anchors.right: parent.right
                            Text {
                                text: "Hello," + selected_username 
                                anchors.centerIn: parent
                                font.pixelSize: isDesktop() ? 20 : phoneLarg()? 30:40
                                color: "#000"
                            }
                        
                        }

                        Item {
                            id: fastrow
                            height: parent.height
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: isDesktop() ? 25 : phoneLarg()? 50:80
                            anchors.top: main_title.bottom
                            // anchors.leftMargin: 30

                            Row {
                                spacing: isDesktop() ? 100 : phoneLarg()? 150:200
                                anchors.verticalCenterOffset: -height * 1.5
                                anchors.horizontalCenter: parent.horizontalCenter; // Apply only for desktop
                                
                                

                                Column {
                                    spacing: isDesktop() ? 20 : phoneLarg()? 30:40
                                    width: 60
                                    Label { text: "Instance" 
                                    visible: workpersonaSwitchState
                                    width: 150
                                    height: isDesktop() ? 25 : phoneLarg()? 45:80
                                    font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                    }
                                    Label { text: "Date" 
                                        width: 150
                                    height: isDesktop() ? 25 : phoneLarg()? 45:80
                                        font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                        }
                                    Label { text: "Project" 
                                    width: 150
                                    height: isDesktop() ? 25 : phoneLarg()? 45:80
                                    font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                    }
                                    
                                    Label { text: "Sub Project" 
                                    width: 150
                                    height: isDesktop() ? 25 : phoneLarg()? 45:80
                                    font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40

                                    visible: hasSubProject}
                                    Label { text: "Task" 
                                    width: 150
                                    height: isDesktop() ? 25 : phoneLarg()? 45:80
                                    font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40}
                                    Label { text: "Sub Task" 
                                    width: 150
                                    height: isDesktop() ? 25 : phoneLarg()? 45:80
                                    font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                    visible: hasSubTask}
                                    Label { text: "Description" 
                                    width: 150
                                    height: isDesktop() ? 25 : phoneLarg()? 45:80
                                    font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40}
                                    // Label { text: "Quadrant" 
                                    // width: 150
                                    // height: isDesktop() ? 25 : phoneLarg()? 45:80
                                    // font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40}
                                    Label { text: "Spent Hours" 
                                    width: 150
                                    height: isDesktop() ? 25 : phoneLarg()? 45:80
                                    font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40}
                                    
                                }

                                Column {
                                    id: field_id
                                    spacing: isDesktop() ? 20 : phoneLarg()? 30:40
                                    // Component.onCompleted: {
                                    // if (!isDesktop()) {
                                    //     width: 350
                                    //     }
                                    // }
                                    // if(!workpersonaSwitchState){
                                        
                                    // }

                                    Rectangle {
                                        width: isDesktop() ? 500 : 750
                                        visible: workpersonaSwitchState
                                        height: isDesktop() ? 25 : phoneLarg()? 45:80
                                        color: "transparent"

                                        // Border at the bottom
                                        Rectangle {
                                            width: parent.width
                                            height: isDesktop() ? 1 : 2
                                            color: "black"  // Border color
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                        }

                                        ListModel {
                                            id: accountList
                                            // Example data
                                        }

                                        TextInput {
                                            width: parent.width
                                            height: parent.height
                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                            anchors.fill: parent
                                            // anchors.margins: 5                                                        
                                            id: accountInput
                                            Text {
                                                id: accountplaceholder
                                                text: "Instance"                                            
                                                font.pixelSize:isDesktop() ? 18 : phoneLarg()? 30:40
                                                color: "#aaa"
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                                
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    var result = accountlistDataGet(); 
                                                        if(result){
                                                            accountList.clear();
                                                            for (var i = 0; i < result.length; i++) {
                                                                accountList.append(result[i]);
                                                            }
                                                            menuAccount.open();
                                                        }
                                                }
                                            }

                                            Menu {
                                                id: menuAccount
                                                x: accountInput.x
                                                y: accountInput.y + accountInput.height
                                                width: accountInput.width  // Match width with TextField

                                                Repeater {
                                                    model: accountList

                                                    MenuItem {
                                                        width: parent.width
                                                        height: isDesktop() ? 40 : phoneLarg()? 45:80
                                                        property int accountId: model.id  // Custom property for ID
                                                        property string accuntName: model.name || ''
                                                        Text {
                                                            text: accuntName
                                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                                            bottomPadding: 5
                                                            topPadding: 5
                                                            //anchors.centerIn: parent
                                                            color: "#000"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: 10                                                 
                                                            wrapMode: Text.WordWrap
                                                            elide: Text.ElideRight   
                                                            maximumLineCount: 2      
                                                        }

                                                        onClicked: {
                                                            taskInput.text = ''
                                                            selectedTaskId = 0
                                                            subTaskInput.text = ''
                                                            selectedSubTaskId = 0
                                                            hasSubTask = false
                                                            accountInput.text = accuntName
                                                            selectedAccountUserId = accountId
                                                            menuAccount.close()
                                                        }
                                                    }
                                                }
                                            }

                                            onTextChanged: {
                                                if (accountInput.text.length > 0) {
                                                    accountplaceholder.visible = false
                                                } else {
                                                    accountplaceholder.visible = true
                                                }
                                            }
                                            Component.onCompleted: {
                                                var result = accountlistDataGet(); 
                                                        if(result){
                                                            accountList.clear();
                                                            for (var i = 0; i < result.length; i++) {
                                                                accountList.append(result[i]);
                                                            }
                                                }
                                                if (accountList.count > 0) {
                                                    // Default selection when component loads and has items
                                                    accountInput.text = accountList.get(0).name;
                                                    selectedAccountUserId = accountList.get(0).id;
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: isDesktop() ? 500 : 750
                                        height: isDesktop() ? 25 : phoneLarg()? 45:80
                                        color: "transparent"


                                        Rectangle {
                                            width: parent.width
                                            height: isDesktop() ? 1 : 2
                                            color: "black"
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                        }
                                        TextInput {
                                            width: parent.width
                                            height: parent.height
                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 35:50
                                            anchors.fill: parent
                                            id: datetimeInput
                                            Text {
                                                id: datetimeplaceholder
                                                text: "Date"
                                                font.pixelSize: isDesktop() ? 18 : phoneLarg()? 20:30
                                                color: "#aaa"
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            Dialog {
                                                id: calendarDialog
                                                width: isDesktop() ? 0 : phoneLarg()? 550: 700 
                                                height: isDesktop() ? 0 : phoneLarg()? 450:650
                                                padding: 0
                                                margins: 0
                                                visible: false

                                                DatePicker {
                                                    id: datePicker
                                                    onClicked: {
                                                        datetimeInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                                        calendarDialog.visible = false;
                                                    }
                                                }
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    var now = new Date()
                                                    datePicker.selectedDate = now
                                                    datePicker.currentIndex = now.getMonth()
                                                    datePicker.selectedYear = now.getFullYear()
                                                    calendarDialog.visible = true
                                                }
                                            }

                                            onTextChanged: {
                                                if (datetimeInput.text.length > 0) {
                                                    datetimeplaceholder.visible = false
                                                } else {
                                                    datetimeplaceholder.visible = true
                                                }
                                            }
                                            function formatDate(date) {
                                                var month = date.getMonth() + 1; // Months are 0-based
                                                var day = date.getDate();
                                                var year = date.getFullYear();
                                                return month + '/' + day + '/' + year;
                                            }

                                            // Set the current date when the component is completed
                                            Component.onCompleted: {
                                                var currentDate = new Date();
                                                datetimeInput.text = formatDate(currentDate);
                                            }

                                        }
                                    }

                                    Rectangle {
                                        width: isDesktop() ? 500 : 750
                                        height: isDesktop() ? 25 : phoneLarg()? 45:80
                                        color: "transparent"

                                        // Border at the bottom
                                        Rectangle {
                                            width: parent.width
                                            height: isDesktop() ? 1 : 2
                                            color: "black"  // Border color
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                        }

                                        ListModel {
                                            id: projectsListModel
                                            // Example data
                                        }

                                        TextInput {
                                            width: parent.width
                                            height: parent.height
                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                            anchors.fill: parent
                                            // anchors.margins: 5                                                        
                                            id: projectInput
                                            Text {
                                                id: projectplaceholder
                                                text: "Project"                                            
                                                font.pixelSize:isDesktop() ? 18 : phoneLarg()? 30:40
                                                color: "#aaa"
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    // python.call("backend.fetch_options", {} , function(result) {
                                                    //     // optionList = result;
                                                    //     projectsListModel.clear();
                                                    //     for (var i = 0; i < result.length; i++) {
                                                    //         // projectsListModel.append(result[i]);
                                                    //         // for (var i = 0; i < result.length; i++) {
                                                    //         projectsListModel.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': true ? result[i].child_ids.length > 0 : false})
                                                    //     // }
                                                    //     }
                                                    //     menu.open(); // Open the menu after fetching options
                                                    // });

                                                    projectsListModel.clear();
                                                    var result = fetch_projects(selectedAccountUserId);
                                                    console.log(selectedAccountUserId)
                                                    for (var i = 0; i < result.length; i++) {
                                                        projectsListModel.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': result[i].projectkHasSubProject})
                                                        console.log(result[i].projectkHasSubProject,"//...result[i].projectkHasSubProject")
                                                    }
                                                    menu.open();
                                                }
                                            }

                                            Menu {
                                                id: menu
                                                x: projectInput.x
                                                y: projectInput.y + projectInput.height
                                                width: projectInput.width  // Match width with TextField

                                                Repeater {
                                                    model: projectsListModel

                                                    MenuItem {
                                                        width: parent.width
                                                        height: isDesktop() ? 40 :phoneLarg()? 45: 80
                                                        property int projectId: model.id  // Custom property for ID
                                                        property string projectName: model.name || ''
                                                        Text {
                                                            text: projectName
                                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                                            bottomPadding: 5
                                                            topPadding: 5
                                                            //anchors.centerIn: parent
                                                            color: "#000"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: 10                                                 
                                                            wrapMode: Text.WordWrap
                                                            elide: Text.ElideRight   
                                                            maximumLineCount: 2      
                                                        }

                                                        onClicked: {
                                                            taskInput.text = ''
                                                            selectedTaskId = 0
                                                            subTaskInput.text = ''
                                                            selectedSubTaskId = 0
                                                            hasSubTask = false
                                                            projectInput.text = projectName
                                                            selectedProjectId = projectId
                                                            selectedSubProjectId = 0
                                                            hasSubProject = model.projectkHasSubProject
                                                            subProjectInput.text = ''
                                                            menu.close()
                                                            console.log(model.projectkHasSubProject,"///////123")
                                                        }
                                                    }
                                                }
                                            }

                                            onTextChanged: {
                                                if (projectInput.text.length > 0) {
                                                    projectplaceholder.visible = false
                                                } else {
                                                    projectplaceholder.visible = true
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: isDesktop() ? 500 : 750
                                        height: isDesktop() ? 25 : phoneLarg()? 45:80
                                        visible: hasSubProject
                                        color: "transparent"

                                        // Border at the bottom
                                        Rectangle {
                                            width: parent.width
                                            height: isDesktop() ? 1 : 2
                                            color: "black"  // Border color
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                        }

                                        ListModel {
                                            id: subProjectsListModel
                                            // Example data
                                        }

                                        TextInput {
                                            width: parent.width
                                            height: parent.height
                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                            anchors.fill: parent
                                            //anchors.margins: 5                                
                                            id: subProjectInput
                                            Text {
                                                id: subProjectplaceholder
                                                text: "Sub Project"                                            
                                                font.pixelSize:isDesktop() ? 18 : phoneLarg()? 30:40
                                                color: "#aaa"
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                                
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    var sub_project_list = fetch_sub_project(selectedProjectId);
                                                    subProjectsListModel.clear();
                                                    for (var i = 0; i < sub_project_list.length; i++) {
                                                        subProjectsListModel.append({'id': sub_project_list[i].id, 'name': sub_project_list[i].name});
                                                    }
                                                    subProjectmenu.open();

                                                }
                                            }

                                            Menu {
                                                id: subProjectmenu
                                                x: subProjectInput.x
                                                y: subProjectInput.y + subProjectInput.height
                                                width: subProjectInput.width  // Match width with TextField


                                                Repeater {
                                                    model: subProjectsListModel

                                                    MenuItem {
                                                        width: parent.width
                                                        height: isDesktop() ? 40 :phoneLarg()? 45: 80
                                                        property int projectId: model.id  // Custom property for ID
                                                        property string projectName: model.name || ''
                                                        Text {
                                                            text: projectName
                                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                                            bottomPadding: 5
                                                            topPadding: 5
                                                            //anchors.centerIn: parent
                                                            color: "#000"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: 10                                                 
                                                            wrapMode: Text.WordWrap
                                                            elide: Text.ElideRight   
                                                            maximumLineCount: 2      
                                                        }

                                                        onClicked: {
                                                            taskInput.text = ''
                                                            selectedTaskId = 0
                                                            subTaskInput.text = ''
                                                            selectedSubTaskId = 0
                                                            hasSubTask = false
                                                            subProjectInput.text = projectName
                                                            selectedSubProjectId = projectId
                                                            subProjectmenu.close()
                                                        }
                                                    }
                                                }
                                            }

                                            onTextChanged: {
                                                if (subProjectInput.text.length > 0) {
                                                    subProjectplaceholder.visible = false
                                                } else {
                                                    subProjectplaceholder.visible = true
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: isDesktop() ? 500 : 750
                                        height: isDesktop() ? 25 : phoneLarg()? 45:80
                                        color: "transparent"

                                        Rectangle {
                                            width: parent.width
                                            height: isDesktop() ? 1 : 2
                                            color: "black"
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                        }

                                        ListModel {
                                            id: tasksListModel
                                            // Example data
                                        }

                                        TextInput {
                                            width: parent.width
                                            height: parent.height
                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                            anchors.fill: parent
                                            // anchors.margins: isDesktop() ? 0 : 10
                                            id: taskInput
                                            // text: gridModel.get(index).task
                                            Text {
                                                id: taskplaceholder
                                                text: "Task"
                                                color: "#aaa"
                                                font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    tasksListModel.clear()
                                                    var tasks_list = fetch_tasks_list((selectedSubProjectId == 0) ? selectedProjectId : selectedSubProjectId)
                                                    for (var i = 0; i < tasks_list.length; i++) {
                                                        tasksListModel.append({'id': tasks_list[i].id, 'name': tasks_list[i].name, 'taskHasSubTask': tasks_list[i].taskHasSubTask})
                                                    }
                                                    // python.call("backend.fetch_options_tasks", [(selectedSubProjectId == 0) ? selectedProjectId : selectedSubProjectId] , function(result) {
                                                    //     // tasksList = result;
                                                    //     tasksListModel.clear();
                                                    //     for (var i = 0; i < result.length; i++) {
                                                    //         tasksListModel.append({'id': result[i].id, 'name': result[i].name, 'taskHasSubTask': true ? result[i].child_ids.length > 0 : false})
                                                    //     }
                                                    //     menuTasks.open(); // Open the menu after fetching options
                                                    // });
                                                    menuTasks.open();

                                                }
                                            }

                                            Menu {
                                                id: menuTasks
                                                x: taskInput.x
                                                y: taskInput.y + taskInput.height
                                                width: taskInput.width

                                                Repeater {
                                                    model: tasksListModel

                                                    MenuItem {
                                                        width: parent.width
                                                        height: isDesktop() ? 40 : phoneLarg()? 45:80
                                                        property int taskId: model.id  // Custom property for ID
                                                        property string taskName: model.name || ''
                                                        // property bool taskHasSubTask: true ? model.child_ids.length > 0 : false
                                                        Text {
                                                            text: taskName
                                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                                            bottomPadding: 5
                                                            topPadding: 5                                                    
                                                            color: "#000"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: 10          
                                                            wrapMode: Text.WordWrap
                                                            elide: Text.ElideRight   
                                                            maximumLineCount: 2  
                                                        }
                                                        onClicked: {
                                                            taskInput.text = taskName
                                                            selectedTaskId = taskId
                                                            subTaskInput.text = ''
                                                            selectedSubTaskId = 0
                                                            hasSubTask = model.taskHasSubTask
                                                            menu.close()
                                                        }
                                                    }
                                                }
                                            }

                                            onTextChanged: {
                                                if (taskInput.text.length > 0) {
                                                    taskplaceholder.visible = false
                                                } else {
                                                    taskplaceholder.visible = true
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: isDesktop() ? 500 : 750
                                        height: isDesktop() ? 25 : phoneLarg()? 45:80
                                        color: "transparent"
                                        visible: hasSubTask

                                        Rectangle {
                                            width: parent.width
                                            height: isDesktop() ? 1 : 2
                                            color: "black"
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                        }

                                        ListModel {
                                            id: subTasksListModel
                                            // Example data
                                        }

                                        TextInput {
                                            width: parent.width
                                            height: parent.height
                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                            anchors.fill: parent
                                            // anchors.margins: 10
                                            id: subTaskInput
                                            visible: hasSubTask
                                            // text: gridModel.get(index).task
                                            Text {
                                                id: subtaskplaceholder
                                                text: "Sub Task"
                                                color: "#aaa"
                                                font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40                                       
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    subTasksListModel.clear();
                                                    var sub_tasks_list = fetch_sub_tasks(selectedTaskId);
                                                    for (var i = 0; i < sub_tasks_list.length; i++) {
                                                        subTasksListModel.append({'id': sub_tasks_list[i].id, 'name': sub_tasks_list[i].name})
                                                    }
                                                    menuSubTasks.open();

                                                }
                                            }

                                            Menu {
                                                id: menuSubTasks
                                                x: subTaskInput.x
                                                y: subTaskInput.y + subTaskInput.height
                                                width: subTaskInput.width

                                                Repeater {
                                                    model: subTasksListModel

                                                    MenuItem {
                                                        width: parent.width
                                                        height: isDesktop() ? 40 : phoneLarg()? 45:80
                                                        property int subTaskId: model.id  // Custom property for ID
                                                        property string subTaskName: model.name || ''
                                                        Text {
                                                            text: subTaskName
                                                            font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                                            bottomPadding: 5
                                                            topPadding: 5
                                                            color: "#000"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: 10                                                 
                                                            wrapMode: Text.WordWrap
                                                            elide: Text.ElideRight   
                                                            maximumLineCount: 2  
                                                        }
                                                        onClicked: {
                                                            subTaskInput.text = subTaskName
                                                            selectedSubTaskId = subTaskId
                                                            menu.close()
                                                        }
                                                    }
                                                }
                                            }

                                            onTextChanged: {
                                                if (subTaskInput.text.length > 0) {
                                                    subtaskplaceholder.visible = false
                                                } else {
                                                    subtaskplaceholder.visible = true
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: isDesktop() ? 500 : 750
                                        height: isDesktop() ? 25 : phoneLarg()? 45:80
                                        color: "transparent"

                                        Rectangle {
                                            width: parent.width
                                            height: isDesktop() ? 1 : 2
                                            color: "black"
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                        }

                                        Flickable {
                                            id: flickable
                                            width: parent.width
                                            height: parent.height
                                            contentWidth: descriptionInput.width
                                            clip: true  
                                            interactive: true  
                                            property int previousCursorPosition: 0
                                            onContentWidthChanged: {
                                                if (descriptionInput.cursorPosition > previousCursorPosition) {
                                                    contentX = contentWidth - width;  
                                                }
                                                else if (descriptionInput.cursorPosition < previousCursorPosition) {
                                                    contentX = Math.max(0, descriptionInput.cursorRectangle.x - 20); 
                                                }
                                                previousCursorPosition = descriptionInput.cursorPosition;
                                            }

                                            TextInput {
                                                id: descriptionInput
                                                width: Math.max(parent.width, textMetrics.width)  
                                                height: parent.height
                                                font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                                wrapMode: Text.NoWrap  
                                                anchors.fill: parent

                                                Text {
                                                    id: descriptionplaceholder
                                                    text: "Description"
                                                    color: "#aaa"
                                                    font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                                    anchors.fill: parent
                                                    verticalAlignment: Text.AlignVCenter
                                                    visible: descriptionInput.text.length === 0
                                                }

                                                onFocusChanged: {
                                                    descriptionplaceholder.visible = !focus && descriptionInput.text.length === 0
                                                }
                                                property real textWidth: textMetrics.width
                                                TextMetrics {
                                                    id: textMetrics
                                                    font: descriptionInput.font
                                                    text: descriptionInput.text
                                                }

                                                onTextChanged: {
                                                    contentWidth = textMetrics.width;
                                                }

                                                onCursorPositionChanged: {
                                                    flickable.contentX = Math.max(0, descriptionInput.cursorRectangle.x - flickable.width + 20);
                                                }
                                            }
                                        }
                                    }
                                    // Rectangle {
                                    //     width: isDesktop() ? 500 : 750
                                    //     height: isDesktop() ? 25 : phoneLarg()? 45:80
                                    //     color: "transparent"

                                    //     // Border at the bottom
                                    //     Rectangle {
                                    //         width: parent.width
                                    //         height: isDesktop() ? 1 : 2
                                    //         color: "black"  // Border color
                                    //         anchors.bottom: parent.bottom
                                    //         anchors.left: parent.left
                                    //         anchors.right: parent.right
                                    //     }

                                        

                                    //     TextInput {
                                    //         width: parent.width
                                    //         height: parent.height
                                    //         font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                    //         anchors.fill: parent
                                    //         // anchors.margins: 5                                                        
                                    //         id: quadrantInput
                                    //         Text {
                                    //             id: quadrantplaceholder
                                    //             text: "Quadrant"                                            
                                    //             font.pixelSize:isDesktop() ? 18 : phoneLarg()? 30:40
                                    //             color: "#aaa"
                                    //             anchors.fill: parent
                                    //             verticalAlignment: Text.AlignVCenter
                                    //         }

                                    //         MouseArea {
                                    //             anchors.fill: parent
                                    //             onClicked: {
                                    //                 quadrantmenu.open();
                                    //             }
                                    //         }

                                    //         Menu {
                                    //             id: quadrantmenu
                                    //             x: quadrantInput.x
                                    //             y: quadrantInput.y + quadrantInput.height
                                    //             width: quadrantInput.width  // Match width with TextField

                                    //             Repeater {
                                    //                 model: quadrantsListModel

                                    //                 MenuItem {
                                    //                     width: parent.width
                                    //                     height: isDesktop() ? 40 :phoneLarg()? 45: 80
                                    //                     property int quadrantId: model.itemId  // Custom property for ID
                                    //                     property string quadrantName: model.name || ''
                                    //                     Text {
                                    //                         text: quadrantName
                                    //                         font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                    //                         bottomPadding: 5
                                    //                         topPadding: 5
                                    //                         //anchors.centerIn: parent
                                    //                         color: "#000"
                                    //                         anchors.verticalCenter: parent.verticalCenter
                                    //                         anchors.left: parent.left
                                    //                         anchors.leftMargin: 10                                                 
                                    //                         wrapMode: Text.WordWrap
                                    //                         elide: Text.ElideRight   
                                    //                         maximumLineCount: 2      
                                    //                     }

                                    //                     onClicked: {
                                    //                         quadrantInput.text = quadrantName
                                    //                         selectedquadrantId = quadrantId
                                    //                         quadrantmenu.close()
                                    //                     }
                                    //                 }
                                    //             }
                                    //         }

                                    //         onTextChanged: {
                                    //             if (quadrantInput.text.length > 0) {
                                    //                 quadrantplaceholder.visible = false
                                    //             } else {
                                    //                 quadrantplaceholder.visible = true
                                    //             }
                                    //         }
                                    //     }
                                    // } 

                                    TextInput {
                                        width: 300
                                        height: 50
                                        font.pixelSize: isDesktop() ? 30 : phoneLarg()? 35:50
                                        id: spenthoursInput
                                        text: formatTime(elapsedTime)
                                        validator: RegExpValidator { regExp: /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/ }
                                        visible: !isManualTime
                                    }

                                    Rectangle {
                                        width: isDesktop() ? 500 : 750
                                        height: isDesktop() ? 25 : phoneLarg()? 45:80

                                        color: "transparent"
                                        visible: isManualTime

                                        Rectangle {
                                            width: parent.width
                                            height: isDesktop() ? 1 : 2
                                            color: "black"
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                        }
                                        TextInput {
                                            width: parent.width
                                            height: parent.height
                                            font.pixelSize: isDesktop() ? 20 : phoneLarg()? 30:40
                                            anchors.fill: parent
                                            // anchors.margins: isDesktop() ? 0 : 10
                                            id: spenthoursManualInput
                                            // text: gridModel.get(index).task
                                            Text {
                                                id: spenthoursManualInputPlaceholder
                                                text: "00:00"
                                                color: "#aaa"
                                                font.pixelSize: isDesktop() ? 20 : phoneLarg()? 35:50
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onTextChanged: {
                                                if (spenthoursManualInput.text.length > 0) {
                                                    spenthoursManualInputPlaceholder.visible = false
                                                } else {
                                                    spenthoursManualInputPlaceholder.visible = true
                                                }
                                            }
                                        }
                                    }

                                    Row {
                                        spacing: 10
                                        Button {
                                            background: Rectangle {
                                                color: running ? "lightcoral" : "lightgreen"
                                                radius: isDesktop() ? 5 : 10
                                                border.color: running ? "red" : "green"
                                                border.width: 2
                                            }

                                            contentItem: Text {
                                                text: running ? "Stop" : "Start"
                                                color: running ? "darkred" : "darkgreen"
                                                font.pixelSize: isDesktop() ? 20 : phoneLarg()? 20:30
                                            }
                                            visible: isManualTime? false : true

                                            onClicked: {
                                                if (running) {
                                                    currentTime = false;
                                                    storedElapsedTime = elapsedTime;
                                                    stopwatchTimer.stop();
                                                } else {
                                                    currentTime = new Date()
                                                    // storedElapsedTime = 0
                                                    stopwatchTimer.start();
                                                }
                                                running = !running;
                                            }
                                        }

                                        Button {

                                            background: Rectangle {
                                                color: "#121944"
                                                radius: isDesktop() ? 5 : 10
                                                border.color: "#87ceeb"
                                                border.width: 2
                                            }

                                            contentItem: Text {
                                                text: "Reset"
                                                color: "#ffffff"
                                                font.pixelSize: isDesktop() ? 20 : phoneLarg()? 20:30
                                            }
                                            visible: isManualTime? false : true

                                            text: "Reset"
                                            onClicked: {
                                                currentTime = false;
                                                stopwatchTimer.stop();
                                                elapsedTime = 0;
                                                storedElapsedTime = 0;
                                                running = false;
                                            }
                                        }
                                        Button {

                                            background: Rectangle {
                                                color: "#121944"
                                                radius: isDesktop() ? 5 : 10
                                                border.color: "#87ceeb"
                                                border.width: 2
                                            }

                                            contentItem: Text {
                                                text: isManualTime ? "Auto" : "Manual"
                                                color: "#ffffff"
                                                font.pixelSize: isDesktop() ? 20 :phoneLarg()? 20: 30
                                            }


                                            text: "Reset"
                                            onClicked: {
                                                stopwatchTimer.stop();
                                                elapsedTime = 0;
                                                running = false;
                                                storedElapsedTime = 0
                                                spenthoursManualInput.text = ""
                                                isManualTime = !isManualTime
                                            }
                                        }
                                    }
                                

                                }
                            }
                        }

                    }
                }
            }}
        }
        
        // HorizontalPanel
        Rectangle {
            id: horizontalPanel
            visible: (penalOpen && !isDesktop()) ? true : false
            anchors.bottom: parent.bottom  
            anchors.left: parent.left  
            anchors.right: parent.right  
            height: 100  
            color: "#121944"  
            z: 1
            
            property int activeImageIndex: 1  
            property int imageCount: 4
            property real totalImageHeight: imageCount * (isDesktop() ? 40 : 80)  
            property real dynamicSpacing: (parent.width - totalImageHeight) / (imageCount)  
            Row {
                anchors.fill: parent
                anchors.margins: 10  
                spacing: horizontalPanel.dynamicSpacing 
                anchors.left: parent.left
                anchors.leftMargin: horizontalPanel.dynamicSpacing / 2
                
                Image {
                    id: image1
                    source: "images/home.svg"
                    width: 80  
                    height: 80  
                    opacity: horizontalPanel.activeImageIndex === 1 ? 1 : 0.5  

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stackView.push(listPage); 
                            horizontalPanel.activeImageIndex = 1;  
                            console.log("Home clicked")
                            headermainOpen= true
                            
                        }
                    }
                }
                
                Image {
                    id: image2
                    source: "images/refresh.svg"
                    width: 80  
                    height: 80  
                    opacity: horizontalPanel.activeImageIndex === 2 ? 1 : 0.5  

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stackView.push(manageAccounts);
                            horizontalPanel.activeImageIndex = 2;  
                            headermainOpen= true
                            console.log("Refresh clicked")
                            
                        }
                    }
                }

                Image {
                    id: image3
                    source: "images/activity.svg"
                    width: 80  
                    height: 80  
                    opacity: horizontalPanel.activeImageIndex === 3 ? 1 : 0.5  

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            horizontalPanel.activeImageIndex = 3;  
                            console.log("Activity clicked")
                            stackView.push(activityLists)
                            headermainOpen= true
                            // Change to the activity tab
                        }
                    }
                }
                
                Image {
                    id: image4
                    source: "images/setting.svg"
                    anchors.rightMargin: 20
                    width: 80  
                    height: 80  
                    opacity: horizontalPanel.activeImageIndex === 4 ? 1 : 0.5  

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            horizontalPanel.activeImageIndex = 4;  
                            console.log("Settings clicked")
                            
                            stackView.push(settingAccounts); 
                            headermainOpen= true
                        }
                    }
                }
            }
        }

        // VerticalPanel
        Rectangle {
            id: verticalPanel
            visible: (penalOpen && isDesktop()) ? true : false
            anchors.top: header_main.bottom  
            width: isDesktop() ? 60 : 100  
            anchors.bottom: parent.bottom  
            anchors.left: parent.left  
            color: "#121944"  
            z: 1
            
            property int activeImageIndex: 1  

            Column {
                anchors.fill: parent
                anchors.margins: 20  
                spacing:30
                
                Image {
                    id: verticalHome
                    source: "images/home.svg"
                    width: isDesktop() ? 40 : 80  
                    height: isDesktop() ? 40 : 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: verticalPanel.activeImageIndex === 1 ? 1 : 0.5  

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            verticalPanel.activeImageIndex = 1;  
                            stackView.push(listPage);
                            console.log("Home clicked")
                            headermainOpen= true
                            
                        }
                    }
                }
                
                Image {
                    id: verticalRefresh
                    source: "images/refresh.svg"
                    width: isDesktop() ? 40 : 80
                    height: isDesktop() ? 40 : 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: verticalPanel.activeImageIndex === 2 ? 1 : 0.5  

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            verticalPanel.activeImageIndex = 2;  
                            stackView.push(manageAccounts);
                            console.log("Refresh clicked")
                            headermainOpen= true
                            
                        }
                    }
                }
                
                Image {
                    id: verticalActivity
                    source: "images/activity.svg"
                    width: isDesktop() ? 40 : 80
                    height: isDesktop() ? 40 : 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: verticalPanel.activeImageIndex === 3 ? 1 : 0.5  

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            verticalPanel.activeImageIndex = 3;  
                            console.log("Activity clicked")
                            // Change to the activity tab
                            stackView.push(activityLists); 
                            headermainOpen = true
                        }
                    }
                }

                Image {
                    id: verticalSetting
                    source: "images/setting.svg"
                    width: isDesktop() ? 40 : 80
                    height: isDesktop() ? 40 : 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: verticalPanel.activeImageIndex === 4 ? 1 : 0.5  

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            verticalPanel.activeImageIndex = 4;  
                            console.log("Settings clicked")
                            stackView.push(settingAccounts); 
                            headermainOpen= true
                        }
                    }
                }
            }
        }

    }

    Component.onCompleted: {
        timesheetlistData();
        issearchHeadermain = false
        console.log(Screen.width,"////////",Screen.height)
    }
}

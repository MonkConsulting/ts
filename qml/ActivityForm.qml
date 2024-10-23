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
    import QtQuick.Window 2.2
    import QtQuick.Controls 2.2
    import QtQuick.LocalStorage 2.7

Item {
    width: parent.width
    height: parent.height
    property int selectedActivityTypeId: 0
    property int currentRecordId: 0
    property int selectedcontactId: 0
    property bool isactivitySaved: false
    property bool isactivityClicked: false
    property int selectedUserId: 0 
    property int selectedlinkUserId: 0 
    property int selectedprojectUserId: 0
    property int selectedtaskUserId: 0

    function createActivity(selectedAccountUserId, selectedActivityTypeId, datetimeInput, summaryInput, notesInput, user_id,selectedlinkUserId,selectedprojectUserId,selectedtaskUserId,resModelInput,resIdInput) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function (tx) {
            // tx.executeSql('DROP TABLE IF EXISTS mail_activity_app')
            if(selectedActivityTypeId && datetimeInput){
                var result = tx.executeSql('INSERT INTO mail_activity_app (account_id, activity_type_id, summary, due_date, notes, user_id, link_id, project_id, task_id, resId, resModel)\
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [selectedAccountUserId, selectedActivityTypeId, summaryInput, datetimeInput, notesInput, user_id, selectedlinkUserId, selectedprojectUserId, selectedtaskUserId, resIdInput, resModelInput])
                isactivitySaved = true
                isactivityClicked = true
                dataClear()
            } else{
                isactivitySaved = false
                isactivityClicked = true
            }
            

        });
    }
    


    function dataClear(){
        selectedAccountUserId = 0
        selectedUserId = 0
        accountInput.text = ""
        selectedActivityTypeId = 0
        activityTypeInput.text = ""
        summaryInput.text = ""
        notesInput.text = ""
        userInput.text = ""
        isactivitySaved = false
        isactivityClicked = false
        projectInput.text = ""
        selectedprojectUserId = 0
        taskInput.text = ""
        selectedtaskUserId = 0
        linkInput.text = ""  // Set the selected name to the TextInput
        selectedlinkUserId = 0
        resModelInput.text=""
        resIdInput.text = ""
    }

    function fetch_activity_types(selectedAccountUserId) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var activity_type_list = []
        db.transaction(function (tx) {
            var activity_types = tx.executeSql('select * from mail_activity_type_app where account_id = ?', [selectedAccountUserId])
            for (var type = 0; type < activity_types.rows.length; type++) {
                activity_type_list.push({'id': activity_types.rows.item(type).id, 'name': activity_types.rows.item(type).name});
            }
        })
        return activity_type_list;
    }

    function fetch_current_users(selectedAccountUserId) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var activity_type_list = []
        db.transaction(function (tx) {
            var instance_users = tx.executeSql('select * from res_users_app where account_id = ?', [selectedAccountUserId])
            console.log('\n\n instance_users.rows.length', instance_users.rows.length)
            var all_users = tx.executeSql('select * from res_users_app')
            for (var user = 0; user < all_users.rows.length; user++) {
                console.log('\n\n current_user', all_users.rows.item(user).account_id)
            }
            for (var instance_user = 0; instance_user < instance_users.rows.length; instance_user++) {
                activity_type_list.push({'id': instance_users.rows.item(instance_user).id, 'name': instance_users.rows.item(instance_user).name});
            }
        })
        return activity_type_list;
    }
    ListModel {
        id: linkList
        ListElement { itemId: 0; name: "" }   // Option 1: Blank
        ListElement { itemId: 1; name: "Project" }  // Option 2: Project
        ListElement { itemId: 2; name: "Task" }   // Option 3: Task
        ListElement { itemId: 3; name: "Other" }   // Option 4: Other
    }
    function projects_get(selectedAccountUserId) {
        console.log(selectedAccountUserId,"//////////////")
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var projectList = []
        db.transaction(function(tx) {
            if(workpersonaSwitchState){
                var result = tx.executeSql('SELECT * FROM project_project_app where account_id = ?', [selectedAccountUserId]);
            }else{
                var result = tx.executeSql('SELECT * FROM project_project_app WHERE account_id IS NULL');
            }
            for (var i = 0; i < result.rows.length; i++) {
                var child_projects = tx.executeSql('SELECT count(*) FROM project_project_app where account_id = ?', [result.rows.item(i).id]);
                projectList.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'projectkHasSubProject': true ? child_projects.rows.item(0).count > 0 : false})
            }
        })
        return projectList;
    }
    function tasks_list_get(selectedAccountUserId) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var tasks_list = []
        db.transaction(function(tx) {
            if(workpersonaSwitchState){
                var result = tx.executeSql('SELECT * FROM project_task_app where account_id = ?', [selectedAccountUserId]);
            }else{
                var result = tx.executeSql('SELECT * FROM project_task_app where account_id IS NULL AND account_id = ?', [selectedAccountUserId]);
            }
            for (var i = 0; i < result.rows.length; i++) {
                var child_tasks = tx.executeSql('SELECT count(*) FROM project_task_app where parent_id = ?', [result.rows.item(i).id]);
                // tasksListModel.append({'id': result[i].id, 'name': result[i].name, 'taskHasSubTask': true ? child_tasks.rows.item(0).count > 0 : false})
                tasks_list.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'taskHasSubTask': true ? child_tasks.rows.item(0).count > 0 : false})
                // projectList.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name})
            }
        })
        return tasks_list;    
    }
    
    Row {
        id: newActivity
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: isDesktop() ? 100 : 200
        spacing: isDesktop() ? 20 : 40  
        anchors.left: parent.left
        anchors.leftMargin: isDesktop() ? 70 : 20
        anchors.right: parent.right
        anchors.rightMargin: isDesktop() ? 10 : 20
        anchors.horizontalCenter: parent.horizontalCenter
        z:1

        //
        Label {
            text: "Create Activities"
            font.pixelSize: isDesktop() ? 20 : 40
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
            color: "#121944"
            
            width: parent.width * 0.7  
        }
        Rectangle {
            width: 1
            height: 1
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Button {
            width: isDesktop() ? 120 : 240
            height: isDesktop() ? 40 : 80
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right  
            background: Rectangle {
                color: "#121944"
                radius: isDesktop() ? 5 : 10
                border.color: "#87ceeb"
                border.width: 2
                anchors.fill: parent
            }
            contentItem: Text {
                text: "Back"
                color: "#ffffff"
                font.pixelSize: isDesktop() ? 20 : 40
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
               stackView.push(activityLists);;  
            }
        }
    }
Flickable {
    id: flickableContainer
    width: parent.width
    // height: phoneLarg() ? parent.height - 50 : parent.height  // Adjust height for large phones
    height: parent.height  // Set the height to match the parent or a fixed value
    contentHeight: activityForm.childrenRect.height + (phoneLarg()? 320 : 0 )// The total height of the content inside Flickable
    anchors.fill: parent
    flickableDirection: Flickable.VerticalFlick  // Allow only vertical scrolling
    clip: true
    
    
    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: isDesktop()?200:phoneLarg()?200:300
        anchors.left: parent.left
        anchors.leftMargin: isDesktop()?70 : 20
        anchors.right: parent.right
        anchors.rightMargin: isDesktop()?10 : 20
        color: "#ffffff"
        id:"activityForm"
        height: childrenRect.height + 20 // Additional space to ensure no clipping

        
        
        Row {
            spacing: isDesktop() ? 100 : 200
            anchors.verticalCenterOffset: -height * 1.5
            anchors.horizontalCenter: parent.horizontalCenter; // Apply only for desktop
            

            Column {
                spacing: isDesktop() ? 20 : phoneLarg()?30:40
                width: 60
                Label { text: "Instance" 
                width: 150
                visible:workpersonaSwitchState
                height: isDesktop() ? 25 : phoneLarg()?45:80
                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                }
                Label { text: "Activity Type" 
                    width: 150
                    height: isDesktop() ? 25 : phoneLarg()?45:80
                    font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                }
                Label { text: "Assigned To" 
                    width: 150
                    height: isDesktop() ? 25 : phoneLarg()?45:80
                    font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                }
                Label { text: "Summary" 
                width: 150
                height: isDesktop() ? 25 : phoneLarg()?45:80
                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                }
                
                Label { text: "Due Date" 
                width: 150
                height: isDesktop() ? 25 : phoneLarg()?45:80
                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                }
                Label { text: "Notes" 
                width: 150
                height: isDesktop() ? 25 : phoneLarg()?45:80
                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                }
                Label { text: "Link To" 
                width: 150
                height: isDesktop() ? 25 : phoneLarg()?45:80
                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                }
                Label { text: "Project Id" 
                width: 150
                height: isDesktop() ? 25 : phoneLarg()?45:80
                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                visible: selectedlinkUserId === 1
                }
                Label { text: "Task Id" 
                width: 150
                height: isDesktop() ? 25 : phoneLarg()?45:80
                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                visible: selectedlinkUserId === 2
                }
                Label { text: "Res Model" 
                width: 150
                height: isDesktop() ? 25 : phoneLarg()?45:80
                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                visible: selectedlinkUserId === 3
                }
                Label { text: "Res Id" 
                width: 150
                height: isDesktop() ? 25 : phoneLarg()?45:80
                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                visible: selectedlinkUserId === 3
                }
            }

            Column {
                spacing: isDesktop() ? 20 : phoneLarg()?30:40
                Component.onCompleted: { 
                if (!isDesktop()) {
                    width: 350
                    }
                }

                Rectangle {
                    width: isDesktop() ? 500 : 750
                    visible: workpersonaSwitchState
                    height: isDesktop() ? 25 : phoneLarg()?45:80
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
                        font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                        anchors.fill: parent
                        // anchors.margins: 5                                                        
                        id: accountInput
                        Text {
                            id: accountplaceholder
                            text: "Instance"                                            
                            font.pixelSize:isDesktop() ? 18 : phoneLarg()?30:40
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
                                    height: isDesktop() ? 40 : phoneLarg()?50: 80
                                    property int accountId: model.id  // Custom property for ID
                                    property string accuntName: model.name || ''
                                    Text {
                                        text: accuntName
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
                                        activityTypeInput.text = ''
                                        selectedActivityTypeId = 0
                                        projectInput.text = ''
                                        selectedprojectUserId = 0
                                        taskInput.text = ''
                                        selectedtaskUserId = 0
                                        // subTaskInput.text = ''
                                        // selectedSubTaskId = 0
                                        // hasSubTask = false
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
                    }
                }

                Rectangle {
                    width: isDesktop() ? 500 : 750
                    height: isDesktop() ? 25 : phoneLarg()?45:80
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
                        id: activityTypeListModel
                        // Example data
                    }

                    TextInput {
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                        anchors.fill: parent
                        // anchors.margins: 5                                                        
                        id: activityTypeInput
                        Text {
                            id: activitytypeplaceholder
                            text: "Activity Type"                                            
                            font.pixelSize:isDesktop() ? 18 : phoneLarg()?30:40
                            color: "#aaa"
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                activityTypeListModel.clear();
                                var result = fetch_activity_types(selectedAccountUserId);
                                for (var i = 0; i < result.length; i++) {
                                    activityTypeListModel.append({'id': result[i].id, 'name': result[i].name})
                                }
                                menu.open();
                            }
                        }

                        Menu {
                            id: menu
                            x: activityTypeInput.x
                            y: activityTypeInput.y + activityTypeInput.height
                            width: activityTypeInput.width


                            Repeater {
                                model: activityTypeListModel

                                MenuItem {
                                    width: parent.width
                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                    property int activityTypeId: model.id
                                    property string activityTypeName: model.name || ''
                                    Text {
                                        text: activityTypeName
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
                                        selectedActivityTypeId = activityTypeId
                                        activityTypeInput.text = activityTypeName
                                        menu.close()
                                    }
                                }
                            }
                        }

                        onTextChanged: {
                            if (activityTypeInput.text.length > 0) {
                                activitytypeplaceholder.visible = false
                            } else {
                                activitytypeplaceholder.visible = true
                            }
                        }
                    }
                }
                

                Rectangle {
                    width: isDesktop() ? 500 : 750
                    height: isDesktop() ? 25 : phoneLarg()?45:80
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
                        id: accountUsersList
                        // Example data
                    }

                    TextInput {
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                        anchors.fill: parent
                        // anchors.margins: 5                                                        
                        id: userInput
                        Text {
                            id: userplaceholder
                            text: "Assignee"                                            
                            font.pixelSize:isDesktop() ? 18 : phoneLarg()?30:40
                            color: "#aaa"
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                accountUsersList.clear();
                                console.log('\n\n selectedAccountUserId', selectedAccountUserId)
                                var result = fetch_current_users(selectedAccountUserId);
                                for (var i = 0; i < result.length; i++) {
                                    accountUsersList.append({'id': result[i].id, 'name': result[i].name})
                                }
                                usermenu.open();
                            }
                        }

                        Menu {
                            id: usermenu
                            x: userInput.x
                            y: userInput.y + userInput.height
                            width: userInput.width


                            Repeater {
                                model: accountUsersList

                                MenuItem {
                                    width: parent.width
                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                    property int userId: model.id
                                    property string userName: model.name || ''
                                    Text {
                                        text: userName
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
                                        selectedUserId = userId
                                        userInput.text = userName
                                        usermenu.close()
                                    }
                                }
                            }
                        }

                        onTextChanged: {
                            if (userInput.text.length > 0) {
                                userplaceholder.visible = false
                            } else {
                                userplaceholder.visible = true
                            }
                        }
                    }
                }

                Rectangle {
                    width: isDesktop() ? 500 : 750
                    height: isDesktop() ? 25 : phoneLarg()?45:80
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
                        id: flickableSummary
                        width: parent.width
                        height: parent.height
                        contentWidth: summaryInput.width
                        clip: true  
                        interactive: true  
                        property int previousCursorPosition: 0
                        onContentWidthChanged: {
                            if (summaryInput.cursorPosition > previousCursorPosition) {
                                contentX = contentWidth - width;  
                            }
                            else if (summaryInput.cursorPosition < previousCursorPosition) {
                                contentX = Math.max(0, summaryInput.cursorRectangle.x - 20); 
                            }
                            previousCursorPosition = summaryInput.cursorPosition;
                        }

                        TextInput {
                            id: summaryInput
                            width: Math.max(parent.width, textMetrics.width)  
                            height: parent.height
                            font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                            wrapMode: Text.NoWrap  
                            anchors.fill: parent

                            Text {
                                id: summaryplaceholder
                                text: "Description"
                                color: "#aaa"
                                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                visible: summaryInput.text.length === 0
                            }

                            onFocusChanged: {
                                summaryplaceholder.visible = !focus && summaryInput.text.length === 0
                            }
                            property real textWidth: textMetrics.width
                            TextMetrics {
                                id: textMetrics
                                font: summaryInput.font
                                text: summaryInput.text
                            }

                            onTextChanged: {
                                contentWidth = textMetrics.width;
                            }

                            onCursorPositionChanged: {
                                flickableSummary.contentX = Math.max(0, summaryInput.cursorRectangle.x - flickableSummary.width + 20);
                            }
                        }
                    }
                }

                Rectangle {
                    width: isDesktop() ? 500 : 750
                    height: isDesktop() ? 25 : phoneLarg()?45:80
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
                        font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:50
                        anchors.fill: parent
                        id: datetimeInput
                        Text {
                            id: datetimeplaceholder
                            text: "Date"
                            font.pixelSize: isDesktop() ? 18 : phoneLarg()?20:30
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
                    height: isDesktop() ? 25 : phoneLarg()?45:80
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
                        id: flickableNotes
                        width: parent.width
                        height: parent.height
                        contentWidth: notesInput.width
                        clip: true  
                        interactive: true  
                        property int previousCursorPosition: 0
                        onContentWidthChanged: {
                            if (notesInput.cursorPosition > previousCursorPosition) {
                                contentX = contentWidth - width;  
                            }
                            else if (notesInput.cursorPosition < previousCursorPosition) {
                                contentX = Math.max(0, notesInput.cursorRectangle.x - 20); 
                            }
                            previousCursorPosition = notesInput.cursorPosition;
                        }

                        TextInput {
                            id: notesInput
                            width: Math.max(parent.width, textNotesMetrics.width)  
                            height: parent.height
                            font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                            wrapMode: Text.NoWrap  
                            anchors.fill: parent

                            Text {
                                id: notesplaceholder
                                text: "Notes"
                                color: "#aaa"
                                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                visible: notesInput.text.length === 0
                            }

                            onFocusChanged: {
                                notesplaceholder.visible = !focus && notesInput.text.length === 0
                            }
                            property real textWidth: textNotesMetrics.width
                            TextMetrics {
                                id: textNotesMetrics
                                font: notesInput.font
                                text: notesInput.text
                            }

                            onTextChanged: {
                                contentWidth = textNotesMetrics.width;
                            }

                            onCursorPositionChanged: {
                                flickableNotes.contentX = Math.max(0, notesInput.cursorRectangle.x - flickableNotes.width + 20);
                            }
                        }
                    }
                }
// link
                Rectangle {
                    width: isDesktop() ? 500 : 750
                    height: isDesktop() ? 25 : phoneLarg()?45:80
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

                   
                    TextInput {
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                        anchors.fill: parent
                        id: linkInput

                        // Placeholder text
                        Text {
                            id: linkplaceholder
                            text: "Link to project or task"                                            
                            font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                            color: "#aaa"
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                menulink.open()
                            }
                        }

                        Menu {
                            id: menulink
                            x: linkInput.x
                            y: linkInput.y + linkInput.height
                            width: linkInput.width  // Match width with TextField

                            Repeater {
                                model: linkList

                                MenuItem {
                                    width: parent.width
                                    height: isDesktop() ? 40 : phoneLarg()?50: 80
                                    property int linkId: model.itemId || 0  // Fallback to 0 if model.id is undefined
                                    property string linkName: model.name || ''
                                    
                                    Text {
                                        text: linkName
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        color: "#000"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10                                                 
                                        wrapMode: Text.WordWrap
                                        elide: Text.ElideRight   
                                        maximumLineCount: 2      
                                    }

                                    // When the menu item is clicked, update the TextInput and close the menu
                                    onClicked: {
                                        linkInput.text = linkName  // Set the selected name to the TextInput
                                        selectedlinkUserId = linkId  // Store the selected ID (if needed)
                                        console.log(linkId,"selectedlinkUserId: " + selectedlinkUserId);  // Debugging check

                                        menulink.close()  // Close the menu
                                    }
                                }
                            }
                        }

                        // Placeholder visibility logic
                        onTextChanged: {
                            linkplaceholder.visible = linkInput.text.length === 0
                        }
                    }
                }
// project
                Rectangle {
                    width: isDesktop() ? 500 : 750
                    height: isDesktop() ? 25 : phoneLarg()?45:80
                    color: "transparent"
                    visible: selectedlinkUserId === 1

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
                        id: projectList
                        // Example data
                    }

                    TextInput {
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                        anchors.fill: parent
                        // anchors.margins: 5                                                        
                        id: projectInput
                        Text {
                            id: projectplaceholder
                            text: "Project"                                            
                            font.pixelSize:isDesktop() ? 18 : phoneLarg()?30:40
                            color: "#aaa"
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                projectList.clear();
                                if(selectedAccountUserId != 0){
                                    var result = projects_get(selectedAccountUserId); 
                                        if(result){
                                            for (var i = 0; i < result.length; i++) {
                                                projectList.append(result[i]);
                                            }
                                        }
                                }
                                            menuproject.open();
                            }
                        }

                        Menu {
                            id: menuproject
                            x: projectInput.x
                            y: projectInput.y + projectInput.height
                            width: projectInput.width  // Match width with TextField


                            Repeater {
                                model: projectList

                                MenuItem {
                                    width: parent.width
                                    height: isDesktop() ? 40 : phoneLarg()?50: 80
                                    property int projectId: model.id  // Custom property for ID
                                    property string projectName: model.name || ''
                                    Text {
                                        text: projectName
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
                                        projectInput.text = projectName
                                        selectedprojectUserId = projectId
                                        menuproject.close()
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
// task
                Rectangle {
                    width: isDesktop() ? 500 : 750
                    height: isDesktop() ? 25 : phoneLarg()?45:80
                    color: "transparent"
                    visible: selectedlinkUserId === 2

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
                        id: taskList
                        // Example data
                    }

                    TextInput {
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                        anchors.fill: parent
                        // anchors.margins: 5                                                        
                        id: taskInput
                        Text {
                            id: taskplaceholder
                            text: "Task"                                            
                            font.pixelSize:isDesktop() ? 18 : phoneLarg()?30:40
                            color: "#aaa"
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var result = tasks_list_get(selectedAccountUserId); 
                                    if(result){
                                        taskList.clear();
                                        for (var i = 0; i < result.length; i++) {
                                            taskList.append(result[i]);
                                        }
                                        menutask.open();
                                    }
                            }
                        }

                        Menu {
                            id: menutask
                            x: taskInput.x
                            y: taskInput.y + taskInput.height
                            width: taskInput.width  // Match width with TextField


                            Repeater {
                                model: taskList

                                MenuItem {
                                    width: parent.width
                                    height: isDesktop() ? 40 : phoneLarg()?50: 80
                                    property int taskId: model.id  // Custom property for ID
                                    property string taskName: model.name || ''
                                    Text {
                                        text: taskName
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
                                        // activityTypeInput.text = ''
                                        // selectedActivityTypeId = 0
                                        // subTaskInput.text = ''
                                        // selectedSubTaskId = 0
                                        // hasSubTask = false
                                        taskInput.text = taskName
                                        selectedtaskUserId = taskId
                                        menutask.close()
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
// res model
                Rectangle {
                    width: isDesktop() ? 500 : 750
                    height: isDesktop() ? 25 : phoneLarg()?45:80
                    color: "transparent"
                    visible: selectedlinkUserId === 3

                    Rectangle {
                        width: parent.width
                        height: isDesktop() ? 1 : 2
                        color: "black"
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }

                    Flickable {
                        id: flickableresModel
                        width: parent.width
                        height: parent.height
                        contentWidth: resModelInput.width
                        clip: true  
                        interactive: true  
                        property int previousCursorPosition: 0
                        onContentWidthChanged: {
                            if (resModelInput.cursorPosition > previousCursorPosition) {
                                contentX = contentWidth - width;  
                            }
                            else if (resModelInput.cursorPosition < previousCursorPosition) {
                                contentX = Math.max(0, resModelInput.cursorRectangle.x - 20); 
                            }
                            previousCursorPosition = resModelInput.cursorPosition;
                        }

                        TextInput {
                            id: resModelInput
                            width: Math.max(parent.width, textresModelMetrics.width)  
                            height: parent.height
                            font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                            wrapMode: Text.NoWrap  
                            anchors.fill: parent

                            Text {
                                id: resModelplaceholder
                                text: "Res Model"
                                color: "#aaa"
                                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                visible: resModelInput.text.length === 0
                            }

                            onFocusChanged: {
                                resModelplaceholder.visible = !focus && resModelInput.text.length === 0
                            }
                            property real textWidth: textresModelMetrics.width
                            TextMetrics {
                                id: textresModelMetrics
                                font: resModelInput.font
                                text: resModelInput.text
                            }

                            onTextChanged: {
                                contentWidth = textresModelMetrics.width;
                            }

                            onCursorPositionChanged: {
                                flickableresModel.contentX = Math.max(0, resModelInput.cursorRectangle.x - flickableresModel.width + 20);
                            }
                        }
                    }
                }
// res ID       
                Rectangle {
                    width: isDesktop() ? 500 : 750
                    height: isDesktop() ? 25 : phoneLarg()?45:80
                    color: "transparent"
                    visible: selectedlinkUserId === 3

                    Rectangle {
                        width: parent.width
                        height: isDesktop() ? 1 : 2
                        color: "black"
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }

                    TextInput {
                        id: resIdInput
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                        anchors.fill: parent
                        Text {
                                id: resIdInputplaceholder
                                text: "Res Id"
                                color: "#aaa"
                                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                visible: resIdInput.text.length === 0
                            }

                        onTextChanged: {
                            resIdInputplaceholder.visible = resIdInput.text.length === 0

                            // Remove any non-numeric characters
                            resIdInput.text = resIdInput.text.replace(/[^0-9]/g, "");
                        }
                    }

                }
                


            }
        }
        Rectangle {
            id: save_activity
            property int buttonTopMargin :isDesktop() ? selectedlinkUserId=== 0 ? 350: 400 : phoneLarg()? selectedlinkUserId=== 3? 670:600: selectedlinkUserId=== 0 ? 850:1100
            width: parent.width
            height: isDesktop() ? 30 : phoneLarg()?45:80
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: buttonTopMargin
            anchors.leftMargin: 20
            anchors.right: parent.right
            Button {
                width: isDesktop() ? 400 : 480
                // height: isDesktop() ? 40 : 90
                anchors.centerIn: parent
                background: Rectangle {
                    color: "#121944"
                    radius: isDesktop() ? 5 : 10
                    border.color: "#87ceeb"
                    border.width: 2
                    anchors.fill: parent
                }

                contentItem: Text {
                    text: "Save Activity"
                    color: "#ffffff"
                    font.pixelSize: isDesktop() ? 20 : phoneLarg()?30:40
                    horizontalAlignment: Text.AlignHCenter // Align text horizontally (redundant here but useful for multi-line)

                }
                onClicked: {
                    
                    createActivity(selectedAccountUserId, selectedActivityTypeId, datetimeInput.text, summaryInput.text, notesInput.text, selectedUserId,selectedlinkUserId,selectedprojectUserId,selectedtaskUserId,resModelInput.text,resIdInput.text)
                    // stackView.push(activityLists)
                }
            }
        }
        Rectangle {
            width: parent.width
            height: 50
            anchors.top: save_activity.bottom
            anchors.left: parent.left
            anchors.topMargin: 20

            Text {
                id: activitySavedMessage
                text: isactivitySaved ? "Activity is Saved successfully!" : "Activity could not be saved!"
                color: isactivitySaved ? "green" : "red"
                visible: isactivityClicked
                font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                horizontalAlignment: Text.AlignHCenter // Align text horizontally (redundant here but useful for multi-line)
                anchors.centerIn: parent

            }
        }
    }
    }
    Component.onCompleted: {
        console.log('\n\n stackView.currentItem.data', currentRecordId)
        console.log('\n\n stackView.currentItem.data', currentRecordId)
        dataClear()
    }
}
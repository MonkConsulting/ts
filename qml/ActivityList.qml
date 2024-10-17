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

    property int currentRecordId: 0
    property int editselectedAccountUserId: 0
    property int editselectedActivityTypeId: 0
    property bool isActivityEdit: false
    property bool isEditActivityClicked: false
    property var filterActivityListData: []

    function queryData() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function (tx) {
            filterActivityListData = []
            activityListModel.clear();
            // tx.executeSql('DELETE FROM mail_activity_app');
            if(workpersonaSwitchState){
                var existing_activities = tx.executeSql('select * from mail_activity_app')
            }else{
                var existing_activities = tx.executeSql('SELECT * FROM mail_activity_app where account_id IS NULL');
            }

            for (var activity = 0; activity < existing_activities.rows.length; activity++) {
                activityListModel.append({'summary': existing_activities.rows.item(activity).summary, 'due_date': existing_activities.rows.item(activity).due_date, 'id': existing_activities.rows.item(activity).id})
                filterActivityListData.push({'summary': existing_activities.rows.item(activity).summary, 'due_date': existing_activities.rows.item(activity).due_date, 'id': existing_activities.rows.item(activity).id})
            }
        })
    }
    function filterActivityList(query) {
        activityListModel.clear(); // Clear existing data in the model

            for (var i = 0; i < filterActivityListData.length; i++) {
                var entry = filterActivityListData[i];
                // Check if the query matches the name, project_id or task_id (case insensitive)
                if (entry.summary.toLowerCase().includes(query.toLowerCase()) 
                    // entry.project_id.toLowerCase().includes(query.toLowerCase()) || 
                    // entry.task_id.toLowerCase().includes(query.toLowerCase())
                    ) {
                    activityListModel.append(entry);

                }
            }
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

    function isDesktop() {
        if(Screen.width > 1200){
            return true;
        }else{
            return false;
        }
    }

    ListModel {
        id: activityListModel
    }
    
    function editActivityData(data){
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            // Update the record in the database
            tx.executeSql('UPDATE mail_activity_app SET \
                account_id = ?, activity_type_id = ?, summary = ?, due_date = ?, \
                notes = ? WHERE id = ?',
                [data.updatedAccount, data.updatedActivity, data.updatedSummary, 
                data.updatedDate,data.updatedNote, data.rowId]  
            );
            queryData()
        });
    
    }

    Rectangle {
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: isDesktop()?80:120
        anchors.left: parent.left
        anchors.leftMargin: isDesktop()?70 : 20
        anchors.right: parent.right
        anchors.rightMargin: isDesktop()?10 : 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: isDesktop()?0:100
        color: "#ffffff"

        Row {
            id: newActivity
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: isDesktop() ? 10 : 25
            spacing: isDesktop() ? 20 : 30  
            anchors.horizontalCenter: parent.horizontalCenter  
            
            Label {
                text: "Activities"
                font.pixelSize: isDesktop() ? 20 : 40   
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true
                color: "#121944"
                width: parent.width * (isDesktop() ? 0.453   : 0.2)  
            }
            
            Rectangle {
                width: parent.width * (isDesktop() ? 0.2   : 0.1)    
                height: 1
                color: "transparent"
            }
            
            TextField {
                id: searchField
                placeholderText: "Search..."
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * (isDesktop() ? 0.2 : 0.4)  
                onTextChanged: {
                    filterActivityList(searchField.text);  
                }
            }
            
            Button {
                width: isDesktop() ? 120 : 220
                height: isDesktop() ? 40 : 80
                anchors.verticalCenter: parent.verticalCenter
                background: Rectangle {
                    color: "#121944"
                    radius: isDesktop() ? 5 : 10
                    border.color: "#87ceeb"
                    border.width: 2
                    anchors.fill: parent
                }
                contentItem: Text {
                    text: "New"
                    color: "#ffffff"
                    font.pixelSize: isDesktop() ? 20 : 40
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    newRecordActivity();  // Call function to create new activity
                }
            }
        }
       
        Rectangle {
            // spacing: 0
            anchors.fill: parent
            anchors.top: newActivity.bottom  
            anchors.topMargin: isDesktop() ? 68 : 170
            border.color: "#CCCCCC"
            border.width: isDesktop() ? 1 : 2
        Column {
            spacing: 0
            anchors.fill: parent
            anchors.top: newActivity.bottom
            anchors.topMargin: isDesktop() ? 1 : 2
            Flickable {
                id: editActivity
                anchors.fill: parent
                width: rightPanel.visible? parent.width / 2 : parent.width
                contentHeight: column.height
                clip: true
                property string edit_id: ""


                Column {
                    id: column
                    width: rightPanel.visible? parent.width / 2 : parent.width
                    spacing: 0

                    Repeater {
                        model: activityListModel
                        delegate: Rectangle {
                            width:  parent.width
                            height: isDesktop() ? 80 : 100
                            // border.color: "#000000"87ceeb
                            color: currentRecordId === model.id ? "#F5F5F5" : "#FFFFFF"  // Change color only for selected row
                            border.color: "#CCCCCC"
                            border.width: isDesktop()? 1 : 2
                            // radius: 10

                            Column {
                                spacing: 0
                                anchors.fill: parent

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log("Column clicked!", model.id);
                                        currentRecordId = model.id;
                                        rightPanel.visible = true
                                        editActivity.edit_id= model.id; // Replace with dynamic data from model
                                        rightPanel.loadActivityData();
                                        isEditActivityClicked = false
                                        isActivityEdit = false
                                        // stackView.push(activityForm);
                                    }
                                }

                                Row {
                                    width: parent.width
                                    height: isDesktop() ? 40 : 50
                                    spacing: 20
                                    anchors.topMargin: 20

                                    Text {
                                        text: model.summary
                                        font.pixelSize: isDesktop() ? 20 : 40
                                        color: "#000000"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        anchors.top: isDesktop() ?0:parent.top
                                        anchors.topMargin: 10
                                    }
                                }

                                Row {
                                    width: parent.width
                                    height: isDesktop()? 40 : 50
                                    spacing: 20
                                    anchors.bottom: parent.bottom
                                    Text {
                                        text: model.due_date
                                        font.pixelSize: isDesktop() ? 18 : 26
                                        color: "#000000"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 10
                                        anchors.leftMargin: 10
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
                width: isDesktop() ? parent.width /2 : parent.width
                height: parent.height
                color: "#EFEFEF"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                function loadActivityData() {
                    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
                    var rowId = editActivity.edit_id;

                        db.transaction(function (tx) {
                            var result = tx.executeSql('SELECT * FROM mail_activity_app WHERE id = ?', [rowId]);
                            if (result.rows.length > 0) {
                                var rowData = result.rows.item(0);
                                console.log(JSON.stringify(rowData, null, 2), "////rowData////")
                                
                                var activityId = rowData.activity_type_id;
                                var accountId = rowData.account_id;

                                // Fetch activity and account data
                                var account = tx.executeSql('SELECT name FROM users WHERE id = ?', [accountId]);
                                var activity = tx.executeSql('SELECT name FROM mail_activity_type_app WHERE id = ?', [activityId]);

                                // Set values to inputs and properties editselectedAccountUserId
                                accountInput.text = account.rows.item(0).name;
                                editselectedAccountUserId = accountId;
                                activityTypeInput.text = activity.rows.item(0).name;
                                editselectedActivityTypeId = activityId;
                                summaryInput.text = rowData.summary;
                                
                                // Format date
                                var dueDate = new Date(rowData.due_date);
                                datetimeInput.text = formatDate(dueDate);
                                notesInput.text = rowData.notes;
                            }
                        });
                        function formatDate(date) {
                            var month = date.getMonth() + 1; // Months are 0-based
                            var day = date.getDate();
                            var year = date.getFullYear();
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
                                currentRecordId = -1
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
                                var rowId = editActivity.edit_id;
                                const editData = {
                                    updatedAccount: editselectedAccountUserId,
                                    updatedActivity: editselectedActivityTypeId,
                                    updatedSummary: summaryInput.text,
                                    updatedDate: datetimeInput.text,
                                    updatedNote: notesInput.text,
                                    rowId: rowId
                                }
                                editActivityData(editData)
                                isEditActivityClicked = true
                                isActivityEdit = true
                                activityEditTimer.start(); // Use the QML Timer to handle the delay
                                filterActivityList(searchField.text)
                            }
                            Timer {
                                id: activityEditTimer
                                interval: 2000 // 3 seconds delay
                                repeat: false
                                onTriggered: {
                                    isActivityEdit = false;
                                    isEditActivityClicked = false;
                                }
                            }
                        }
                    }
                    Item {
                        id: activityItemedit
                        height: parent.height
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: isDesktop() ? 100 : 120
                            Row {
                                spacing: isDesktop() ? 100 : 200
                                anchors.verticalCenterOffset: -height * 1.5
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                
                                    Component.onCompleted: {
                                    if (isDesktop()) {
                                        anchors.horizontalCenter = parent.horizontalCenter; // Apply only for desktop
                                    }
                                }

                                Column {
                                    spacing: isDesktop() ? 20 : 40
                                    width: isDesktop() ?40:80
                                    Label { text: "Instance" 
                                    width: 150
                                    height: isDesktop() ? 25 : 80
                                    visible: workpersonaSwitchState
                                    font.pixelSize: isDesktop() ? 18 : 40
                                    }
                                    Label { text: "Activity Type" 
                                        width: 150
                                        height: isDesktop() ? 25 : 80
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        }
                                    Label { text: "Summary" 
                                    width: 150
                                    height: isDesktop() ? 25 : 80
                                    font.pixelSize: isDesktop() ? 18 : 40
                                    }
                                    
                                    Label { text: "Due Date" 
                                    width: 150
                                    height: isDesktop() ? 25 : 80
                                    font.pixelSize: isDesktop() ? 18 : 40

                                    }
                                    Label { text: "Notes" 
                                    width: 150
                                    height: isDesktop() ? 25 : 80
                                    font.pixelSize: isDesktop() ? 18 : 40}
                                }

                                Column {
                                    spacing: isDesktop() ? 20 : 40
                                    Component.onCompleted: {
                                    if (!isDesktop()) {
                                        width: 350
                                        }
                                    }

                                    Rectangle {
                                        width: isDesktop() ? 430 : 700
                                        visible: workpersonaSwitchState
                                        height: isDesktop() ? 25 : 80
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
                                            font.pixelSize: isDesktop() ? 18 : 40
                                            anchors.fill: parent
                                            // anchors.margins: 5                                                        
                                            id: accountInput
                                            Text {
                                                id: accountplaceholder
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
                                                        height: isDesktop() ? 40 : 80
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
                                                            activityTypeInput.text=""
                                                            editselectedActivityTypeId = 0
                                                            accountInput.text = accuntName
                                                            editselectedAccountUserId = accountId
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
                                        width: isDesktop() ? 430 : 700
                                        height: isDesktop() ? 25 : 80
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
                                            font.pixelSize: isDesktop() ? 18 : 40
                                            anchors.fill: parent
                                            // anchors.margins: 5                                                        
                                            id: activityTypeInput
                                            Text {
                                                id: activitytypeplaceholder
                                                text: "Activity Type"                                            
                                                font.pixelSize:isDesktop() ? 18 : 40
                                                color: "#aaa"
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                                
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    activityTypeListModel.clear();
                                                    console.log(editselectedAccountUserId,"//////selectedAccountUserId/////")
                                                    var result = fetch_activity_types(editselectedAccountUserId);
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
                                                        height: isDesktop() ? 40 : 80
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
                                                            editselectedActivityTypeId = activityTypeId
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
                                        width: isDesktop() ? 430 : 700
                                        height: isDesktop() ? 25 : 80
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
                                                font.pixelSize: isDesktop() ? 18 : 40
                                                wrapMode: Text.NoWrap  
                                                anchors.fill: parent

                                                Text {
                                                    id: summaryplaceholder
                                                    text: "Description"
                                                    color: "#aaa"
                                                    font.pixelSize: isDesktop() ? 18 : 40
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
                                        width: isDesktop() ? 430 : 700
                                        height: isDesktop() ? 25 : 80
                                        color: "transparent"

                                        // Border at the bottom
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
                                                bottomMargin: 500
                                                padding: 0
                                                margins: 0
                                                visible: false

                                                DatePicker {
                                                    id: datePicker
                                                    onClicked: {
                                                        datetimeInput.text = Qt.formatDate(datePicker.selectedDate, 'M/d/yyyy');
                                                        calendarDialog.visible = false;
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    var now = new Date();
                                                    datePicker.selectedDate = now;
                                                    calendarDialog.visible = true;
                                                }
                                            }

                                            onTextChanged: {
                                                datetimeplaceholder.visible = datetimeInput.text.length === 0;
                                            }

                                            // Set the current date on completion
                                            Component.onCompleted: {
                                                var currentDate = new Date();
                                                datetimeInput.text = formatDate(currentDate);
                                            }

                                            function formatDate(date) {
                                                var month = date.getMonth() + 1; // Months are 0-based
                                                var day = date.getDate();
                                                var year = date.getFullYear();
                                                return month + '/' + day + '/' + year;
                                            }
                                        }
                                    }

                                    
                                    Rectangle {
                                        width: isDesktop() ? 430 : 700
                                        height: isDesktop() ? 25 : 80
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
                                                font.pixelSize: isDesktop() ? 18 : 40
                                                wrapMode: Text.NoWrap  
                                                anchors.fill: parent

                                                Text {
                                                    id: notesplaceholder
                                                    text: "Notes"
                                                    color: "#aaa"
                                                    font.pixelSize: isDesktop() ? 18 : 40
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
                                    Rectangle {
                                        width: parent.width
                                        height: 50
                                        anchors.left: parent.left
                                        anchors.topMargin: 20
                                        color: "#EFEFEF"
                                    

                                        Text {
                                            id: activitySavedMessage
                                            text: isActivityEdit ? "Activity is Edit successfully!" : "Activity could not be Edit!"
                                            color: isActivityEdit ? "green" : "red"
                                            visible: isEditActivityClicked
                                            font.pixelSize: isDesktop() ? 18 : 40
                                            horizontalAlignment: Text.AlignHCenter // Align text horizontally (redundant here but useful for multi-line)
                                            anchors.centerIn: parent

                                        }
                                    }

                                }
                            }
                    }
        
                    
                }
            }

        }}

        // Drawer {
        //     id: bottomDrawer
        //     edge: Qt.BottomEdge  // Attach to the bottom edge
        //     width: parent.width
        //     height: isDesktop() ? 300 : 500  // Height of the drawer
        //     background: Rectangle {
        //         color: "#F0F0F0"
        //     }
            
        //     StackView {
        //         id: stackView
        //         anchors.fill: parent
        //         initialItem: activityForm // Ensure there's an initial item or you can use `push` here
        //     }

              
        //     // stackView.push(activityForm)

        // }
        // Button {
        //     text: "Open Bottom Drawer"
        //     anchors.bottom: parent.bottom
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     onClicked: {
        //         bottomDrawer.open();
        //     }
        // }
            
    }

    Component.onCompleted: {
        // initializeDatabase();
        queryData();
    }

    signal newRecordActivity()
}

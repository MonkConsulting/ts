import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.7
import Ubuntu.Components 1.3 as Ubuntu

    

Item {
    width: parent.width
    height: parent.height
    property var filterprojectlistData: []
    property int currentRecordId: 0
    property bool issearchHeader: false

    // property bool workpersonaSwitchState: true 

    function fetch_projects_list() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        filterprojectlistData = []
        projectsListModel.clear()
        db.transaction(function(tx) {
            if(workpersonaSwitchState){
                var result = tx.executeSql('SELECT * FROM project_project_app');
            }else{
                var result = tx.executeSql('SELECT * FROM project_project_app where account_id IS NULL');
            }
            for (var i = 0; i < result.rows.length; i++) {
                var task_total = tx.executeSql('SELECT id, COUNT(*) AS count FROM project_task_app WHERE account_id = ? AND project_id = ?', [result.rows.item(i).account_id, result.rows.item(i).id]);
                var plannedEndDate = result.rows.item(i).planned_end_date;
                if (typeof plannedEndDate !== 'string') {
                    plannedEndDate = String(plannedEndDate);  // Convert to string if it isn't
                }

                projectsListModel.append({'id': result.rows.item(i).id, 'total_tasks': task_total.rows.item(0).count, 'name': result.rows.item(i).name, 'allocated_hours': result.rows.item(i).allocated_hours, 'planned_end_date': plannedEndDate})
                filterprojectlistData.push({'id': result.rows.item(i).id, 'total_tasks': task_total.rows.item(0).count, 'name': result.rows.item(i).name, 'allocated_hours': result.rows.item(i).allocated_hours, 'planned_end_date': plannedEndDate})
            }
        })
    }
    
    function filterProjectList(query) {
        projectsListModel.clear(); // Clear existing data in the model

            for (var i = 0; i < filterprojectlistData.length; i++) {
                var entry = filterprojectlistData[i];
                // Check if the query matches the name, project_id or task_id (case insensitive)
                if (entry.name.toLowerCase().includes(query.toLowerCase()) 
                    // entry.project_id.toLowerCase().includes(query.toLowerCase()) || 
                    // entry.task_id.toLowerCase().includes(query.toLowerCase())
                    ) {
                    projectsListModel.append(entry);

                }
            }
    }

    ListModel {
        id: projectsListModel
    }
    Rectangle {
        id:projectHeader
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
                visible: !issearchHeader
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
                    text: "Projects"
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
                visible: !issearchHeader
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
                            issearchHeader = true
                        }
                    }
                }
                
            }


                Rectangle{
                    id: search_header
                    visible: issearchHeader
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
                            issearchHeader = false
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
                            filterProjectList(searchField.text);  // Call the filter function when the text changes
                        }
                    }
            }
        }
    }
    Rectangle {
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: isDesktop()?65:120
        anchors.left: parent.left
        anchors.leftMargin: isDesktop()?70 : 20
        anchors.right: parent.right
        anchors.rightMargin: isDesktop()?10 : 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: isDesktop()?0:100
        color: "#ffffff"


        // Scrollable Content
            Rectangle {
                // spacing: 0
                anchors.fill: parent
                anchors.top: searchId.bottom  
                anchors.topMargin: isDesktop() ? 68 : 170
                border.color: "#CCCCCC"
                border.width: isDesktop() ? 1 : 2
        Column {
            spacing: 0
            anchors.fill: parent
            anchors.top: searchId.bottom 
            anchors.topMargin: isDesktop()?1 : 2

            // Project Section
            Flickable {
                id: projectFlickable
                anchors.fill: parent
                contentHeight: column.height 
                clip: true 
                width: rightPanel.visible? parent.width / 2 : parent.width
                property string edit_id: ""
                visible: isDesktop() ? true : phoneLarg()? true : rightPanel.visible? false : true



                Column {
                    id: column
                    width: rightPanel.visible? parent.width / 2 : parent.width
                    spacing: 0
                    
                    Repeater {
                        model: projectsListModel
                        delegate: Rectangle {
                            width: parent.width
                            height: isDesktop()?80:100 
                            color: currentRecordId === model.id ? "#F5F5F5" : "#FFFFFF"  // Change color only for selected row
                            border.color: "#CCCCCC"
                            border.width:isDesktop()? 1 : 2

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {

                                    console.log("Column clicked!", model.id);
                                    currentRecordId = model.id;
                                    rightPanel.visible = true
                                    projectFlickable.edit_id= model.id; // Replace with dynamic data from model
                                    rightPanel.loadprojectData();
                                    console.log(model.planned_end_date)
                                    // isEditActivityClicked = false
                                    // isActivityEdit = false
                                    // stackView.push(activityForm);
                                }
                            }
                            
                            Column {
                                spacing: 0
                                anchors.fill: parent 

                                Row {
                                    width: parent.width
                                    height: isDesktop()? 40 :40 
                                    spacing: 20 
                                    
                                    Text {
                                        text: model.name 
                                        font.pixelSize: isDesktop()? 20:30
                                        color: "#000000"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                    }
                                    
                                    
                                }

                                Row {
                                    width: parent.width
                                    height: isDesktop()? 40 :50 // Height for the first row
                                    spacing: 20 // Spacing between elements

                                    // Task Name
                                    Text {
                                        text: "(" + model.total_tasks + ") Tasks" // Dynamic task names
                                        font.pixelSize: isDesktop()?18:26
                                        color: "#000000"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                    }

                                    // Allocated Status
                                    Text {
                                        text: "Allocated H : " + model.allocated_hours // Dynamic allocated status
                                        font.pixelSize: isDesktop()? 18 :26
                                        color: "#4CAF50" // Green for allocated status
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter // Center in this row
                                    }

                                    // Separator Status
                                    Text {
                                        text: "End Date : " + model.planned_end_date // Dynamic separator
                                        font.pixelSize: isDesktop()?18:26
                                        color: "#4CAF50" // Green for allocated status
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.right: parent.right
                                        anchors.rightMargin: 15
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: rightPanel
                z: 20
                visible: false
                width: isDesktop() ? parent.width /2 : phoneLarg()? parent.width /2 : parent.width
                height: parent.height
                anchors.top: parent.top
                anchors.topMargin: phoneLarg()?0 :0
                color: "#EFEFEF"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                function loadprojectData() {
                    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
                    var rowId = projectFlickable.edit_id;

                        db.transaction(function (tx) {
                            if(workpersonaSwitchState){
                                var result = tx.executeSql('SELECT * FROM project_project_app WHERE id = ?', [rowId]);
                            }else{
                                var result = tx.executeSql('SELECT * FROM project_project_app where account_id IS NULL AND id = ?', [rowId] );
                            }
                            if (result.rows.length > 0) {
                                var rowData = result.rows.item(0);
                                var accountId = rowData.account_id || ""; 
                                if(rowData.planned_start_date != 0) {
                                    var rowDate = new Date(rowData.planned_start_date || "");  
                                    var formattedDate = formatDate(rowDate);  
                                    startDateInput.text = formattedDate;
                                }else{
                                    startDateInput.text = "mm/dd/yy"
                                }
                                if(rowData.planned_end_date != 0) {
                                    var rowDate = new Date(rowData.planned_end_date || "");  
                                    var formattedDate = formatDate(rowDate);  
                                    endDateInput.text = formattedDate;
                                }else{
                                    endDateInput.text = "mm/dd/yy"
                                }

                                var parent_project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?',[rowData.parent_id]);
                                // , 
                                if(workpersonaSwitchState){
                                    var account = tx.executeSql('SELECT name FROM users WHERE id = ?', [accountId]);
                                }
                                
                                if(workpersonaSwitchState){
                                    accountInput.text = account.rows.length > 0 ? account.rows.item(0).name || "" : "";
                                }
                                nameInput.text = rowData.name
                                allocatedhoursInput.text = rowData.allocated_hours
                                parentProjectInput.text = parent_project.rows.length > 0 ? parent_project.rows.item(0).name || "" : "";
                                img_star.selectedPriority = rowData.favorites || 0; // Set default to 0 if favorites is null

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

                        // Button {
                        //     id: rightButton
                        //     // Position this button on the right side
                        //     anchors.right: parent.right
                        //     anchors.top: parent.top
                        //     anchors.topMargin: 10
                        //     width: isDesktop() ? 20 : 50
                        //     height: isDesktop() ? 20 : 50
                        //     anchors.rightMargin: isDesktop() ? 15 : 20

                        //     Image {
                        //         source: "images/right.svg" // Replace with your image path
                        //         width: isDesktop() ? 20 : 50
                        //         height: isDesktop() ? 20 : 50
                        //     }

                        //     background: Rectangle {
                        //         color: "transparent"
                        //         radius: 10
                        //         border.color: "transparent"
                        //     }

                        //     onClicked: {
                        //         // var rowId = editActivity.edit_id;
                        //         // const editData = {
                        //         //     updatedAccount: editselectedAccountUserId,
                        //         //     updatedActivity: editselectedActivityTypeId,
                        //         //     updatedSummary: summaryInput.text,
                        //         //     updatedDate: datetimeInput.text,
                        //         //     updatedNote: notesInput.text,
                        //         //     rowId: rowId
                        //         // }
                        //         // editActivityData(editData)
                        //         // isEditActivityClicked = true
                        //         // isActivityEdit = true
                        //         // activityEditTimer.start(); // Use the QML Timer to handle the delay
                        //         // filterActivityList(searchField.text)
                        //     }
                        //     // Timer {
                        //     //     id: activityEditTimer
                        //     //     interval: 2000 // 3 seconds delay
                        //     //     repeat: false
                        //     //     onTriggered: {
                        //     //         isActivityEdit = false;
                        //     //         isEditActivityClicked = false;
                        //     //     }
                        //     // }
                        // }
                    }

                    Flickable {
                        id: flickableContainerProject
                        width: parent.width
                        // height: phoneLarg() ? parent.height - 50 : parent.height  // Adjust height for large phones
                        height: parent.height  // Set the height to match the parent or a fixed value
                        contentHeight: projectItemedit.childrenRect.height + (isDesktop()?0:100)  // The total height of the content inside Flickable
                        anchors.fill: parent
                        flickableDirection: Flickable.VerticalFlick  // Allow only vertical scrolling
                        anchors.top: parent.top
                        anchors.topMargin: isDesktop() ? 85 : phoneLarg()? 100 : 120
                        

                        // Make sure to enable clipping so the content outside the viewable area is not displayed
                        clip: true
                    Item {
                        id: projectItemedit
                        height: projectItemedit.childrenRect.height + 100
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: phoneLarg()? 20:0
                        anchors.topMargin: isDesktop() ? 0 : phoneLarg()? 0 : 120
                        Row {
                            spacing: isDesktop() ? 130 : phoneLarg()? 260 :260
                            anchors.verticalCenterOffset: -height * 1.5
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            
                                Component.onCompleted: {
                                if (isDesktop() || phoneLarg()) {
                                    anchors.horizontalCenter = parent.horizontalCenter; // Apply only for desktop
                                }
                            }
                            
                            Column {
                                spacing: isDesktop() ? 20 : 40
                                width: isDesktop() ?50:80
                                Label { text: "Name" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Planned Start Date" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Planned End Date " 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Instance" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Parent Project" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Allocated Hours" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                
                                Label { text: "Favorites" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                
                                
                            }
                            Column {
                                spacing: isDesktop() ? 20 : 40
                                
                                Rectangle {
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                    color: "transparent"

                                    // Bottom Border for TextInput
                                    Rectangle {
                                        width:  parent.width
                                        height: isDesktop() ? 1 : 2
                                        color: "black"
                                        anchors.bottom: parent.bottom
                                    }

                                    TextInput {
                                        id: nameInput
                                        width: parent.width
                                        height: parent.height
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        anchors.fill: parent
                                        readOnly: true

                                        Text {
                                            id: namePlaceholder
                                            text: "Name"
                                            font.pixelSize: isDesktop() ? 18 : 40
                                            color: "#aaa"
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onTextChanged: {
                                            namePlaceholder.visible = nameInput.text.length === 0;
                                        }
                                    }
                                }
                                Rectangle {
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                    color: "transparent"


                                    Rectangle {
                                        width:  parent.width
                                        height: isDesktop() ? 1 : 2
                                        color: "black"
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                    }
                                    TextInput {
                                        width: parent.width
                                        height: parent.height
                                        font.pixelSize: isDesktop() ? 18 : phoneLarg()?35:50
                                        anchors.fill: parent
                                        id: startDateInput
                                        readOnly: true
                                        Text {
                                            id: startDateplaceholder
                                            text: "Date"
                                            font.pixelSize: isDesktop() ? 18 : 30
                                            color: "#aaa"
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Dialog {
                                            id: startDateDialog
                                            width: isDesktop() ? 0 : 700
                                            height: isDesktop() ? 0 : 650
                                            padding: 0
                                            margins: 0
                                            visible: false

                                            DatePicker {
                                                id: datePickerstartDate
                                                onClicked: {
                                                    startDateInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                                }
                                            }
                                        }
                                        // MouseArea {
                                        //     anchors.fill: parent
                                        //     onClicked: {
                                        //         var now = new Date()
                                        //         datePickerstartDate.selectedDate = now
                                        //         datePickerstartDate.currentIndex = now.getMonth()
                                        //         datePickerstartDate.selectedYear = now.getFullYear()
                                        //         startDateDialog.visible = true
                                        //     }
                                        // }

                                        onTextChanged: {
                                            if (startDateInput.text.length > 0) {
                                                startDateplaceholder.visible = false
                                            } else {
                                                startDateplaceholder.visible = true
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
                                            startDateInput.text = formatDate(currentDate);
                                        }

                                    }
                                }
                                Rectangle {
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                    color: "transparent"


                                    Rectangle {
                                        width:  parent.width 
                                        height: isDesktop() ? 1 : 2
                                        color: "black"
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                    }
                                    TextInput {
                                        width: parent.width
                                        height: parent.height
                                        font.pixelSize: isDesktop() ? 18 : phoneLarg()?35:50
                                        anchors.fill: parent
                                        readOnly: true
                                        id: endDateInput
                                        Text {
                                            id: endDateplaceholder
                                            text: "Date"
                                            font.pixelSize: isDesktop() ? 18 : 30
                                            color: "#aaa"
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Dialog {
                                            id: endDateDialog
                                            width: isDesktop() ? 0 : 700
                                            height: isDesktop() ? 0 : 650
                                            padding: 0
                                            margins: 0
                                            visible: false

                                            DatePicker {
                                                id: datePickerendDate
                                                onClicked: {
                                                    endDateInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                                }
                                            }
                                        }
                                        // MouseArea {
                                        //     anchors.fill: parent
                                        //     onClicked: {
                                        //         var now = new Date()
                                        //         datePickerendDate.selectedDate = now
                                        //         datePickerendDate.currentIndex = now.getMonth()
                                        //         datePickerendDate.selectedYear = now.getFullYear()
                                        //         endDateDialog.visible = true
                                        //     }
                                        // }

                                        onTextChanged: {
                                            if (endDateInput.text.length > 0) {
                                                endDateplaceholder.visible = false
                                            } else {
                                                endDateplaceholder.visible = true
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
                                            endDateInput.text = formatDate(currentDate);
                                        }

                                    }
                                }
                                Rectangle {
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                    color: "transparent"

                                    // Border at the bottom
                                    Rectangle {
                                        width:  parent.width
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
                                            // onClicked: {
                                            //     var result = accountlistDataGet(); 
                                            //         if(result){
                                            //             accountList.clear();
                                            //             for (var i = 0; i < result.length; i++) {
                                            //                 accountList.append(result[i]);
                                            //             }
                                            //             menuAccount.open();
                                            //         }
                                            // }
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
                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
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
                                                        // taskInput.text = ''
                                                        // selectedTaskId = 0
                                                        // subTaskInput.text = ''
                                                        // selectedSubTaskId = 0
                                                        // hasSubTask = false
                                                        accountInput.text = accuntName
                                                        selectedAccountUserId = accountId
                                                        // menuAccount.close()
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
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                    color: "transparent"

                                    // Border at the bottom
                                    Rectangle {
                                        width:  parent.width
                                        height: isDesktop() ? 1 : 2
                                        color: "black"  // Border color
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                    }

                                    ListModel {
                                        id: parentProject
                                        // Example data
                                    }

                                    TextInput {
                                        width: parent.width
                                        height: parent.height
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        anchors.fill: parent
                                        // anchors.margins: 5                                                        
                                        id: parentProjectInput
                                        Text {
                                            id: parentProjectplaceholder
                                            text: "Parent Project"                                            
                                            font.pixelSize:isDesktop() ? 18 : 40
                                            color: "#aaa"
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            // onClicked: {
                                            //     // python.call("backend.fetch_options", {} , function(result) {
                                            //     //     // optionList = result;
                                            //     //     parentProject.clear();
                                            //     //     for (var i = 0; i < result.length; i++) {
                                            //     //         // parentProject.append(result[i]);
                                            //     //         // for (var i = 0; i < result.length; i++) {
                                            //     //         parentProject.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': true ? result[i].child_ids.length > 0 : false})
                                            //     //     // }
                                            //     //     }
                                            //     //     menu.open(); // Open the menu after fetching options
                                            //     // });

                                            //     parentProject.clear();
                                            //     var result = fetch_projects();
                                            //     for (var i = 0; i < result.length; i++) {
                                            //         parentProject.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': false})
                                            //     }
                                            //     parentProjectnenu.open();

                                            // }
                                        }

                                        Menu {
                                            id: parentProjectmenu
                                            x: parentProjectInput.x
                                            y: parentProjectInput.y + parentProjectInput.height
                                            width: parentProjectInput.width  // Match width with TextField


                                            Repeater {
                                                model: parentProject

                                                MenuItem {
                                                    width: parent.width
                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                                    property int parentProjectId: model.id  // Custom property for ID
                                                    property string parentProjectName: model.name || ''
                                                    Text {
                                                        text: parentProjectName
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
                                                        // taskInput.text = ''
                                                        // selectedTaskId = 0
                                                        // subTaskInput.text = ''
                                                        // selectedSubTaskId = 0
                                                        // hasSubTask = false
                                                        parentProjectInput.text = parentProjectName
                                                        // selectedparentId = parentId
                                                        // selectedSubProjectId = 0
                                                        // hasSubProject = model.projectkHasSubProject
                                                        // subProjectInput.text = ''
                                                        // parentProjectmenu.close()
                                                    }
                                                }
                                            }
                                        }

                                        onTextChanged: {
                                            if (parentProjectInput.text.length > 0) {
                                                parentProjectplaceholder.visible = false
                                            } else {
                                                parentProjectplaceholder.visible = true
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                    color: "transparent"

                                    Rectangle {
                                        width:  parent.width
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
                                        readOnly: true
                                        // anchors.margins: isDesktop() ? 0 : 10
                                        id: allocatedhoursInput
                                        // text: gridModel.get(index).task
                                        Text {
                                            id: allocatedhoursInputPlaceholder
                                            text: "00:00"
                                            color: "#aaa"
                                            font.pixelSize: isDesktop() ? 20 : 50
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onTextChanged: {
                                            if (allocatedhoursInput.text.length > 0) {
                                                allocatedhoursInputPlaceholder.visible = false
                                            } else {
                                                allocatedhoursInputPlaceholder.visible = true
                                            }
                                        }
                                    }
                                }
                                Row {
                                    width: isDesktop() ? 400 : 700
                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                    id: img_star
                                    spacing: 5  // Space between stars
                                    property int selectedPriority: 0  // Initially no stars selected

                                    Repeater {
                                        model: 5  // 5 stars
                                        delegate: Item {
                                            width: isDesktop() ? 30 : 50  // Star size
                                            height: isDesktop() ? 30 : 50

                                            Image {
                                                id: starImage
                                                source: (index < img_star.selectedPriority) ? "images/star-active.svg" : "images/starinactive.svg"  // Set star state based on selectedPriority
                                                anchors.fill: parent
                                                smooth: true  // Smooth edges

                                                // MouseArea {
                                                //     anchors.fill: parent
                                                //     onClicked: {
                                                //         // Determine new selected priority based on star index
                                                //         if (index + 1 === img_star.selectedPriority) {
                                                //             img_star.selectedPriority = 0;  // Deselect all stars if the current star is clicked again
                                                //         } else {
                                                //             img_star.selectedPriority = index + 1;  // Set selected priority based on star index
                                                //         }
                                                //     }
                                                // }
                                            }
                                        }
                                    }
                                }

                            }
                        }
                    }}
                    
                }
            }
        }}
    }

    Component.onCompleted: {
        // Initialization code if needed
        console.log(workpersonaSwitchState,"/////////////++++++++")
        fetch_projects_list()
        issearchHeader = false
    }
}

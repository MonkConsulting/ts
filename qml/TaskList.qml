import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.7

Item {
    width: parent.width
    height: parent.height
    property var filtertasklistData: []
    property int currentRecordId: 0


    function fetch_tasks_list() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        tasksListModel.clear()
        db.transaction(function(tx) {
            if(workpersonaSwitchState){
                var result = tx.executeSql('SELECT * FROM project_task_app');
            }else{
                var result = tx.executeSql('SELECT * FROM project_task_app where account_id IS NULL');
            }
            for (var i = 0; i < result.rows.length; i++) {
                console.log(' result.rows.item(i).name', result.rows.item(i).name)
                tasksListModel.append({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'allocated_hours': result.rows.item(i).initial_planned_hours, 'state': result.rows.item(i).state})
                filtertasklistData.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'allocated_hours': result.rows.item(i).initial_planned_hours, 'state': result.rows.item(i).state})
            }
        })
    }

    function filterTaskList(query) {
        tasksListModel.clear(); // Clear existing data in the model

            for (var i = 0; i < filtertasklistData.length; i++) {
                var entry = filtertasklistData[i];
                // Check if the query matches the name, project_id or task_id (case insensitive)
                if (entry.name.toLowerCase().includes(query.toLowerCase()) 
                    // entry.project_id.toLowerCase().includes(query.toLowerCase()) || 
                    // entry.task_id.toLowerCase().includes(query.toLowerCase())
                    ) {
                    tasksListModel.append(entry);

                }
            }
    }

    ListModel {
        id: tasksListModel
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

        // Search Row
        Row {
            id: searchId
            spacing: 10
            anchors.top: parent.top  // Position below the search row
            anchors.topMargin: isDesktop() ? 20 : 80
            anchors.left: parent.left
            anchors.leftMargin: isDesktop() ? 0 : 10
            anchors.right: parent.right  // Float the search field to the right
            width: parent.width

            Label {
                text: "Tasks"
                font.pixelSize: isDesktop() ? 20 : 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                font.bold: true
                color:"#121944"
                width: parent.width * (isDesktop() ? 0.8 :0.5)
            }

            TextField {
                id: searchField
                placeholderText: "Search..."
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: parent.width *  (isDesktop() ? 0.2 :0.5)  
                onTextChanged: {
                    filterTaskList(searchField.text);  
                }
            }
        }

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

            
            Flickable {
                id: taskFlickable
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
                        model: tasksListModel
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
                                    taskFlickable.edit_id= model.id; // Replace with dynamic data from model
                                    rightPanel.loadtaskData();
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
                                    
                                    Text {
                                        text: model.state
                                        font.pixelSize: isDesktop()? 20:30
                                        color: "#000000"
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.rightMargin: 10
                                    }
                                      
                                }

                                Row {
                                    width: parent.width
                                    height: isDesktop()?40:80
                                    spacing: 20

                                    Text {
                                        text: "(" + model.allocated_hours + ") Allocated Hours"
                                        font.pixelSize: isDesktop()? 18:26
                                        color: "#000000"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                    }

                                    // Text {
                                    //     text: "Sep " + (index + 1)
                                    //     font.pixelSize: isDesktop()? 18:26
                                    //     color: "#4CAF50"
                                    //     anchors.verticalCenter: parent.verticalCenter
                                    //     anchors.horizontalCenter: parent.horizontalCenter
                                    // }

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
                color: "#EFEFEF"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                anchors.topMargin: phoneLarg()? -165 :0
                function loadtaskData() {
                    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
                    var rowId = taskFlickable.edit_id;

                        db.transaction(function (tx) {
                            // var result = tx.executeSql('SELECT * FROM project_task_app WHERE id = ?', [rowId]);
                            if(workpersonaSwitchState){
                                var result = tx.executeSql('SELECT * FROM project_task_app WHERE id = ?', [rowId]);
                            }else{
                                var result = tx.executeSql('SELECT * FROM project_task_app where account_id IS NULL AND id = ?', [rowId] );
                            }
                            if (result.rows.length > 0) {
                                var rowData = result.rows.item(0);
                                console.log(JSON.stringify(rowData, null, 2), "////rowData////");

                                var projectId = rowData.project_id || "";  
                                var parentId = rowData.parent_id === null ? rowData.parent_id || "":"";
                                var accountId = rowData.account_id || ""; 
                                if(rowData.scheduled_date != 0) {
                                    var rowDate = new Date(rowData.scheduled_date || "");  
                                    var formattedDate = formatDate(rowDate);  
                                    scheduletimeInput.text = formattedDate;
                                }else{
                                    scheduletimeInput.text = "mm/dd/yy"
                                }
                                if(rowData.deadline != 0) {
                                    var rowDate = new Date(rowData.deadline || "");  
                                    var formattedDate = formatDate(rowDate);  
                                    deadlineInput.text = formattedDate;
                                }else{
                                    deadlineInput.text = "mm/dd/yy"
                                }

                                var project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?', [projectId]);
                                var parentname = tx.executeSql('SELECT name FROM project_task_app WHERE id = ?', [parentId]);
                                if(workpersonaSwitchState){
                                    var account = tx.executeSql('SELECT name FROM users WHERE id = ?', [accountId]);
                                }
                                
                                projectInput.text = project.rows.length > 0 ? project.rows.item(0).name || "" : "";
                                // selectedProjectId = projectId;
                                if(workpersonaSwitchState){
                                    accountInput.text = account.rows.length > 0 ? account.rows.item(0).name || "" : "";
                                    // selectedAccountUserId = accountId;
                                }
                                nameInput.text = rowData.name
                                // console.log(parentname.rows.item(0).name,"/////,/,,/,.,.")
                                parentInput.text = parentname.rows.length > 0 ? parentname.rows.item(0).name || "" : "";
                                img_star.selectedPriority = rowData.favorites || 0; // Set default to 0 if favorites is null
                                initialInput.text = rowData.initial_planned_hours || 0;

                                

                                // editdescriptionInput.text = rowData.name || "";  
                                // edittaskInput.text = task.rows.length > 0 ? task.rows.item(0).name || "" : "";
                                // selectedTaskId = taskId;

                                // editspenthoursManualInput.text = rowData.unit_amount || "";  
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
                    Item {
                        id: taskItemedit
                        height: parent.height
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: phoneLarg()? 20:0
                        anchors.topMargin: isDesktop() ? 100 : phoneLarg()? 70 : 120
                        Row {
                            spacing: isDesktop() ? 100 : phoneLarg()? 260 :220
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
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Name" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Projects" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Parent Task" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Schedule Date" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Deadline" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                // Label { text: "Assigned" 
                                // width: 150
                                // height: isDesktop() ? 25 : phoneLarg()?50:80
                                // font.pixelSize: isDesktop() ? 18 : 40
                                // }
                                Label { text: "Priority" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Initially Hours" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                // Label { text: "Speat Hours" 
                                // width: 150
                                // height: isDesktop() ? 25 : phoneLarg()?50:80
                                // font.pixelSize: isDesktop() ? 18 : 40
                                // }
                                // Label { text: "Stage" 
                                // width: 150
                                // height: isDesktop() ? 25 : phoneLarg()?50:80
                                // font.pixelSize: isDesktop() ? 18 : 40
                                // }
                                
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
                                    width: parent.width
                                    height: isDesktop() ? 25 : phoneLarg()?50:80
                                    color: "transparent"

                                    // Bottom Border for TextInput
                                    Rectangle {
                                        width: parent.width
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
                                    width: isDesktop() ? 430 : 700
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
                                        id: projectsListModel
                                        // Example data
                                    }

                                    TextInput {
                                        width: parent.width
                                        height: parent.height
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        anchors.fill: parent
                                        // anchors.margins: 5                                                        
                                        id: projectInput
                                        Text {
                                            id: projectplaceholder
                                            text: "Project"                                            
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
                                            //     //     projectsListModel.clear();
                                            //     //     for (var i = 0; i < result.length; i++) {
                                            //     //         // projectsListModel.append(result[i]);
                                            //     //         // for (var i = 0; i < result.length; i++) {
                                            //     //         projectsListModel.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': true ? result[i].child_ids.length > 0 : false})
                                            //     //     // }
                                            //     //     }
                                            //     //     menu.open(); // Open the menu after fetching options
                                            //     // });

                                            //     projectsListModel.clear();
                                            //     var result = fetch_projects();
                                            //     for (var i = 0; i < result.length; i++) {
                                            //         projectsListModel.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': false})
                                            //     }
                                            //     menu.open();

                                            // }
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
                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
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
                                    width: isDesktop() ? 430 : 700
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
                                        id: parentTask
                                        // Example data
                                    }

                                    TextInput {
                                        width: parent.width
                                        height: parent.height
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        anchors.fill: parent
                                        // anchors.margins: 5                                                        
                                        id: parentInput
                                        Text {
                                            id: parentplaceholder
                                            text: "Parent Task"                                            
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
                                            //     //     parentTask.clear();
                                            //     //     for (var i = 0; i < result.length; i++) {
                                            //     //         // parentTask.append(result[i]);
                                            //     //         // for (var i = 0; i < result.length; i++) {
                                            //     //         parentTask.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': true ? result[i].child_ids.length > 0 : false})
                                            //     //     // }
                                            //     //     }
                                            //     //     menu.open(); // Open the menu after fetching options
                                            //     // });

                                            //     parentTask.clear();
                                            //     var result = fetch_projects();
                                            //     for (var i = 0; i < result.length; i++) {
                                            //         parentTask.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': false})
                                            //     }
                                            //     parentmenu.open();

                                            // }
                                        }

                                        Menu {
                                            id: parentmenu
                                            x: parentInput.x
                                            y: parentInput.y + parentInput.height
                                            width: parentInput.width  // Match width with TextField


                                            Repeater {
                                                model: parentTask

                                                MenuItem {
                                                    width: parent.width
                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                                    property int parentId: model.id  // Custom property for ID
                                                    property string parentName: model.name || ''
                                                    Text {
                                                        text: parentName
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
                                                        parentInput.text = parentName
                                                        // selectedparentId = parentId
                                                        // selectedSubProjectId = 0
                                                        // hasSubProject = model.projectkHasSubProject
                                                        // subProjectInput.text = ''
                                                        // parentmenu.close()
                                                    }
                                                }
                                            }
                                        }

                                        onTextChanged: {
                                            if (projectInput.text.length > 0) {
                                                parentplaceholder.visible = false
                                            } else {
                                                parentplaceholder.visible = true
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    width: isDesktop() ? 430 : 700
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
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        anchors.fill: parent
                                        id: scheduletimeInput
                                        readOnly: true
                                        Text {
                                            id: scheduleTime
                                            text: "Date"
                                            font.pixelSize: isDesktop() ? 18 : 40
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
                                                    scheduletimeInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                                }
                                            }
                                        }
                                        // MouseArea {
                                        //     anchors.fill: parent
                                        //     onClicked: {
                                        //         var now = new Date()
                                        //         datePicker.selectedDate = now
                                        //         datePicker.currentIndex = now.getMonth()
                                        //         datePicker.selectedYear = now.getFullYear()
                                        //         calendarDialog.visible = true
                                        //     }
                                        // }

                                        onTextChanged: {
                                            if (scheduletimeInput.text.length > 0) {
                                                scheduleTime.visible = false
                                            } else {
                                                scheduleTime.visible = true
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
                                            scheduletimeInput.text = formatDate(currentDate);
                                        }

                                    }
                                }
                                Rectangle {
                                    width: isDesktop() ? 430 : 700
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
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        anchors.fill: parent
                                        id: deadlineInput
                                        readOnly: true
                                        Text {
                                            id: deadlineplaceholder
                                            text: "Date"
                                            font.pixelSize: isDesktop() ? 18 : 40
                                            color: "#aaa"
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Dialog {
                                            id: deadlineDialog
                                            width: isDesktop() ? 0 : 700
                                            height: isDesktop() ? 0 : 650
                                            padding: 0
                                            margins: 0
                                            visible: false

                                            DatePicker {
                                                id: datePickerdeadline
                                                onClicked: {
                                                    deadlineInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                                }
                                            }
                                        }
                                        // MouseArea {
                                        //     anchors.fill: parent
                                        //     onClicked: {
                                        //         var now = new Date()
                                        //         datePickerdeadline.selectedDate = now
                                        //         datePickerdeadline.currentIndex = now.getMonth()
                                        //         datePickerdeadline.selectedYear = now.getFullYear()
                                        //         deadlineDialog.visible = true
                                        //     }
                                        // }

                                        onTextChanged: {
                                            if (deadlineInput.text.length > 0) {
                                                deadlineplaceholder.visible = false
                                            } else {
                                                deadlineplaceholder.visible = true
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
                                            deadlineInput.text = formatDate(currentDate);
                                        }

                                    }
                                }
                                // Rectangle {
                                //     width: isDesktop() ? 430 : 700
                                //     height: isDesktop() ? 25 : phoneLarg()?50:80
                                //     color: "transparent"


                                //     Rectangle {
                                //         width: parent.width
                                //         height: isDesktop() ? 1 : 2
                                //         color: "black"
                                //         anchors.bottom: parent.bottom
                                //         anchors.left: parent.left
                                //         anchors.right: parent.right
                                //     }
                                //     TextInput {
                                //         width: parent.width
                                //         height: parent.height
                                //         font.pixelSize: isDesktop() ? 18 : 50
                                //         anchors.fill: parent
                                //         id: assignedInput
                                //         Text {
                                //             id: assignedplaceholder
                                //             text: "Date"
                                //             font.pixelSize: isDesktop() ? 18 : 30
                                //             color: "#aaa"
                                //             anchors.fill: parent
                                //             verticalAlignment: Text.AlignVCenter
                                //         }

                                //         Dialog {
                                //             id: assignedDialog
                                //             width: isDesktop() ? 0 : 700
                                //             height: isDesktop() ? 0 : 650
                                //             padding: 0
                                //             margins: 0
                                //             visible: false

                                //             DatePicker {
                                //                 id: datePickerassigned
                                //                 onClicked: {
                                //                     assignedInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                //                 }
                                //             }
                                //         }
                                //         MouseArea {
                                //             anchors.fill: parent
                                //             onClicked: {
                                //                 var now = new Date()
                                //                 datePickerassigned.selectedDate = now
                                //                 datePickerassigned.currentIndex = now.getMonth()
                                //                 datePickerassigned.selectedYear = now.getFullYear()
                                //                 assignedDialog.visible = true
                                //             }
                                //         }

                                //         onTextChanged: {
                                //             if (assignedInput.text.length > 0) {
                                //                 assignedplaceholder.visible = false
                                //             } else {
                                //                 assignedplaceholder.visible = true
                                //             }
                                //         }
                                //         function formatDate(date) {
                                //             var month = date.getMonth() + 1; // Months are 0-based
                                //             var day = date.getDate();
                                //             var year = date.getFullYear();
                                //             return month + '/' + day + '/' + year;
                                //         }

                                //         // Set the current date when the component is completed
                                //         Component.onCompleted: {
                                //             var currentDate = new Date();
                                //             assignedInput.text = formatDate(currentDate);
                                //         }

                                //     }
                                // }
                                Row {
                                    width: isDesktop() ? 430 : 700
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

                                Rectangle {
                                    width: isDesktop() ? 430 : 700
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
                                        id: initialInput
                                        readOnly: true
                                        // text: gridModel.get(index).task
                                        Text {
                                            id: initialInputPlaceholder
                                            text: "00:00"
                                            color: "#aaa"
                                            font.pixelSize: isDesktop() ? 20 : 50
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onTextChanged: {
                                            if (initialInput.text.length > 0) {
                                                initialInputPlaceholder.visible = false
                                            } else {
                                                initialInputPlaceholder.visible = true
                                            }
                                        }
                                    }
                                }
                                // Rectangle {
                                //     width: isDesktop() ? 430 : 700
                                //     height: isDesktop() ? 25 : phoneLarg()?50:80
                                //     color: "transparent"

                                //     Rectangle {
                                //         width: parent.width
                                //         height: isDesktop() ? 1 : 2
                                //         color: "black"
                                //         anchors.bottom: parent.bottom
                                //         anchors.left: parent.left
                                //         anchors.right: parent.right
                                //     }
                                //     TextInput {
                                //         width: parent.width
                                //         height: parent.height
                                //         font.pixelSize: isDesktop() ? 20 : 40
                                //         anchors.fill: parent
                                //         // anchors.margins: isDesktop() ? 0 : 10
                                //         id: spenthoursManualInput
                                //         // text: gridModel.get(index).task
                                //         Text {
                                //             id: spenthoursManualInputPlaceholder
                                //             text: "00:00"
                                //             color: "#aaa"
                                //             font.pixelSize: isDesktop() ? 20 : 50
                                //             anchors.fill: parent
                                //             verticalAlignment: Text.AlignVCenter
                                //         }

                                //         onTextChanged: {
                                //             if (spenthoursManualInput.text.length > 0) {
                                //                 spenthoursManualInputPlaceholder.visible = false
                                //             } else {
                                //                 spenthoursManualInputPlaceholder.visible = true
                                //             }
                                //         }
                                //     }
                                // }
                                // Rectangle {
                                //     width: isDesktop() ? 430 : 700
                                //     height: isDesktop() ? 25 : phoneLarg()?50:80
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

                                //     ListModel {
                                //         id: stageList
                                //         // Example data
                                //     }

                                //     TextInput {
                                //         width: parent.width
                                //         height: parent.height
                                //         font.pixelSize: isDesktop() ? 18 : 40
                                //         anchors.fill: parent
                                //         // anchors.margins: 5                                                        
                                //         id: stageInput
                                //         Text {
                                //             id: stageplaceholder
                                //             text: "Stage"                                            
                                //             font.pixelSize:isDesktop() ? 18 : 40
                                //             color: "#aaa"
                                //             anchors.fill: parent
                                //             verticalAlignment: Text.AlignVCenter
                                            
                                //         }

                                //         MouseArea {
                                //             anchors.fill: parent
                                //             onClicked: {
                                //                 // python.call("backend.fetch_options", {} , function(result) {
                                //                 //     // optionList = result;
                                //                 //     parentTask.clear();
                                //                 //     for (var i = 0; i < result.length; i++) {
                                //                 //         // parentTask.append(result[i]);
                                //                 //         // for (var i = 0; i < result.length; i++) {
                                //                 //         parentTask.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': true ? result[i].child_ids.length > 0 : false})
                                //                 //     // }
                                //                 //     }
                                //                 //     menu.open(); // Open the menu after fetching options
                                //                 // });

                                //                 // stageTask.clear();
                                //                 // var result = fetch_projects();
                                //                 // for (var i = 0; i < result.length; i++) {
                                //                 //     stageTask.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': false})
                                //                 // }
                                //                 stagemenu.open();

                                //             }
                                //         }

                                //         Menu {
                                //             id: stagemenu
                                //             x: stageInput.x
                                //             y: stageInput.y + stageInput.height
                                //             width: stageInput.width  // Match width with TextField


                                //             Repeater {
                                //                 model: stageTask

                                //                 MenuItem {
                                //                     width: parent.width
                                //                     height: isDesktop() ? 40 : phoneLarg()?50:80
                                //                     property int projectId: model.id  // Custom property for ID
                                //                     property string projectName: model.name || ''
                                //                     Text {
                                //                         text: projectName
                                //                         font.pixelSize: isDesktop() ? 18 : 40
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
                                //                         // taskInput.text = ''
                                //                         // selectedTaskId = 0
                                //                         // subTaskInput.text = ''
                                //                         // selectedSubTaskId = 0
                                //                         // hasSubTask = false
                                //                         // projectInput.text = projectName
                                //                         // selectedProjectId = projectId
                                //                         // selectedSubProjectId = 0
                                //                         // hasSubProject = model.projectkHasSubProject
                                //                         // subProjectInput.text = ''
                                //                         stagemenu.close()
                                //                     }
                                //                 }
                                //             }
                                //         }

                                //         onTextChanged: {
                                //             if (projectInput.text.length > 0) {
                                //                 stageplaceholder.visible = false
                                //             } else {
                                //                 stageplaceholder.visible = true
                                //             }
                                //         }
                                //     }
                                // }
                            }
                        }
                    }
                    
                }
            }
        }}
    }

    Component.onCompleted: {
        fetch_tasks_list()
    }
}

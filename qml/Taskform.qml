import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.7



    

Item {
    width: parent.width
    height: parent.height


    function projectTasklistData(){
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {

                var result = tx.executeSql('SELECT * FROM tasksLists');
                taskList = [];
                for (var i = 0; i < result.rows.length; i++) {
                    taskList.push({
                        'id': result.rows.item(i).id, 
                        'name': result.rows.item(i).name,
                        'account_id': result.rows.item(i).account_id,
                        'project_id': result.rows.item(i).project_id,
                        'parent_id': result.rows.item(i).parent_id,
                        'scheduled_date': result.rows.item(i).scheduled_date,
                        'deadline': result.rows.item(i).deadline,
                        'initial_planned_hours': result.rows.item(i).initial_planned_hours,
                        'favorites': result.rows.item(i).favorites,
                        'state': result.rows.item(i).state,
                        'last_modified': result.rows.item(i).last_modified,
                        'odoo_record_id': result.rows.item(i).odoo_record_id,
                    });
                }
            });
    }
    function showGroupOptions() {
            console.log("Showing group options...");
    }

    function filterProjects(searchText) {
        console.log("Filtering projects with: ", searchText);
    }
    function isDesktop() {
        if(Screen.width > 1200){
            return true;
        }else{
            return false;
        }
    }
    // This function updates the star images based on the selected priority
       


    Rectangle {
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: isDesktop()?50:70
        anchors.left: parent.left
        anchors.leftMargin: isDesktop()?70 : 20
        anchors.right: parent.right
        anchors.rightMargin: isDesktop()?10 : 20
        color: "#ffffff"
        Column {
            anchors.top: parent.top
            anchors.topMargin: isDesktop()?20 : 100
            width: parent.width
            id: tabsHeader

            TabBar {
                width: parent.width
                TabButton {
                    text: "Sub-tasks"
                    onClicked: {
                        subTaskTab.visible = true
                        timesheetTab.visible = false
                    }

                    background: Rectangle {
                        color: subTaskButton.checked ? "#3498db" : "#bdc3c7" // Blue when checked, Gray otherwise
                        border.color: "#2980b9"
                    }
                }
                TabButton {
                    text: "Timesheet"
                    onClicked: {
                        subTaskTab.visible = false
                        timesheetTab.visible = true
                    }
                    background: Rectangle {
                        color: subTaskButton.checked ? "#3498db" : "#bdc3c7" // Blue when checked, Gray otherwise
                        border.color: "#2980b9"
                    }
                }
            }

            Rectangle {
                id: subTaskTab
                visible: true  
                width: parent.width
                height: parent.height * 0.5
                color: "#f5f5f5"
                Text {
                    text: "Sub-tasks content goes here"
                    anchors.centerIn: parent
                    font.pixelSize: isDesktop() ? 18 : 40
                }
            }

            Rectangle {
                id: c
                visible: false // Hidden by default
                width: parent.width
                height: parent.height * 0.5
                color: "#f5f5f5"
                Text {
                    text: "Timesheet content goes here"
                    anchors.centerIn: parent
                    font.pixelSize: isDesktop() ? 18 : 40
                }
                // Add your dynamic timesheet content here (e.g., Repeater for timesheet entries)
            }
        }

        Row {
            anchors.top: tabsHeader.bottom
            anchors.topMargin: 20
            spacing: isDesktop() ? 100 : 200
            anchors.verticalCenterOffset: -height * 1.5
            
                Component.onCompleted: {
                if (isDesktop()) {
                    anchors.horizontalCenter = parent.horizontalCenter; // Apply only for desktop
                }
            }
            Column {
                spacing: isDesktop() ? 20 : 40
                width: 60
                Label { text: "Account" 
                width: 150
                height: isDesktop() ? 25 : 80
                font.pixelSize: isDesktop() ? 18 : 40
                }
                Label { text: "Name" 
                width: 150
                height: isDesktop() ? 25 : 80
                font.pixelSize: isDesktop() ? 18 : 40
                }
                Label { text: "Projects" 
                width: 150
                height: isDesktop() ? 25 : 80
                font.pixelSize: isDesktop() ? 18 : 40
                }
                Label { text: "Parent Task" 
                width: 150
                height: isDesktop() ? 25 : 80
                font.pixelSize: isDesktop() ? 18 : 40
                }
                Label { text: "Schedule Date" 
                width: 150
                height: isDesktop() ? 25 : 80
                font.pixelSize: isDesktop() ? 18 : 40
                }
                Label { text: "Deadline" 
                width: 150
                height: isDesktop() ? 25 : 80
                font.pixelSize: isDesktop() ? 18 : 40
                }
                Label { text: "Assigned" 
                width: 150
                height: isDesktop() ? 25 : 80
                font.pixelSize: isDesktop() ? 18 : 40
                }
                Label { text: "Priority" 
                width: 150
                height: isDesktop() ? 25 : 80
                font.pixelSize: isDesktop() ? 18 : 40
                }
                Label { text: "Initially House" 
                width: 150
                height: isDesktop() ? 25 : 80
                font.pixelSize: isDesktop() ? 18 : 40
                }
                Label { text: "Speat Houre" 
                width: 150
                height: isDesktop() ? 25 : 80
                font.pixelSize: isDesktop() ? 18 : 40
                }
                
            }
            Column {
                spacing: isDesktop() ? 20 : 40
                Component.onCompleted: {
                if (!isDesktop()) {
                    width: 350
                    }
                }

                Rectangle {
                    width: isDesktop() ? 500 : 750
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
                            text: "Account"                                            
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
                    }
                }
                Rectangle {
                    width: parent.width
                    height: isDesktop() ? 25 : 80
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
                    width: isDesktop() ? 500 : 750
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
                                var result = fetch_projects();
                                for (var i = 0; i < result.length; i++) {
                                    projectsListModel.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': false})
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
                                    height: isDesktop() ? 40 : 80
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
                    width: isDesktop() ? 500 : 750
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
                                //     parentTask.clear();
                                //     for (var i = 0; i < result.length; i++) {
                                //         // parentTask.append(result[i]);
                                //         // for (var i = 0; i < result.length; i++) {
                                //         parentTask.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': true ? result[i].child_ids.length > 0 : false})
                                //     // }
                                //     }
                                //     menu.open(); // Open the menu after fetching options
                                // });

                                parentTask.clear();
                                var result = fetch_projects();
                                for (var i = 0; i < result.length; i++) {
                                    parentTask.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': false})
                                }
                                parentmenu.open();

                            }
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
                                    height: isDesktop() ? 40 : 80
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
                                        parentmenu.close()
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
                    width: isDesktop() ? 500 : 750
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
                    TextInput {
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 18 : 50
                        anchors.fill: parent
                        id: scheduletimeInput
                        Text {
                            id: scheduleTime
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
                                    scheduletimeInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
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
                    width: isDesktop() ? 500 : 750
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
                    TextInput {
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 18 : 50
                        anchors.fill: parent
                        id: deadlineInput
                        Text {
                            id: deadlineplaceholder
                            text: "Date"
                            font.pixelSize: isDesktop() ? 18 : 30
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
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var now = new Date()
                                datePickerdeadline.selectedDate = now
                                datePickerdeadline.currentIndex = now.getMonth()
                                datePickerdeadline.selectedYear = now.getFullYear()
                                deadlineDialog.visible = true
                            }
                        }

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
                Rectangle {
                    width: isDesktop() ? 500 : 750
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
                    TextInput {
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 18 : 50
                        anchors.fill: parent
                        id: assignedInput
                        Text {
                            id: assignedplaceholder
                            text: "Date"
                            font.pixelSize: isDesktop() ? 18 : 30
                            color: "#aaa"
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                        }

                        Dialog {
                            id: assignedDialog
                            width: isDesktop() ? 0 : 700
                            height: isDesktop() ? 0 : 650
                            padding: 0
                            margins: 0
                            visible: false

                            DatePicker {
                                id: datePickerassigned
                                onClicked: {
                                    assignedInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var now = new Date()
                                datePickerassigned.selectedDate = now
                                datePickerassigned.currentIndex = now.getMonth()
                                datePickerassigned.selectedYear = now.getFullYear()
                                assignedDialog.visible = true
                            }
                        }

                        onTextChanged: {
                            if (assignedInput.text.length > 0) {
                                assignedplaceholder.visible = false
                            } else {
                                assignedplaceholder.visible = true
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
                            assignedInput.text = formatDate(currentDate);
                        }

                    }
                }
                Row {
                    width: isDesktop() ? 500 : 750
                    height: isDesktop() ? 25 : 80
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

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        // Determine new selected priority based on star index
                                        if (index + 1 === img_star.selectedPriority) {
                                            img_star.selectedPriority = 0;  // Deselect all stars if the current star is clicked again
                                        } else {
                                            img_star.selectedPriority = index + 1;  // Set selected priority based on star index
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: isDesktop() ? 500 : 750
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
                    TextInput {
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 20 : 40
                        anchors.fill: parent
                        // anchors.margins: isDesktop() ? 0 : 10
                        id: initialInput
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
                Rectangle {
                    width: isDesktop() ? 500 : 750
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
                    TextInput {
                        width: parent.width
                        height: parent.height
                        font.pixelSize: isDesktop() ? 20 : 40
                        anchors.fill: parent
                        // anchors.margins: isDesktop() ? 0 : 10
                        id: spenthoursManualInput
                        // text: gridModel.get(index).task
                        Text {
                            id: spenthoursManualInputPlaceholder
                            text: "00:00"
                            color: "#aaa"
                            font.pixelSize: isDesktop() ? 20 : 50
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
            }
        }
        
        
    }
    Component.onCompleted: {
        // Initialization code if needed
    }
}

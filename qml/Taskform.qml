import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.7
import Ubuntu.Components 1.3 as Ubuntu

Item {
    width: parent.width
    height: parent.height

    property int selectedAccountUserId: 0 
    property int selectedProjectId: 0 
    property int selectedparentTaskId: 0 
    property int selectedSubProjectId: 0 
    property int selectedassigneesUserId: 0 
    property int selectedwinterId: 1
    property bool isTaskSaved: false 
    property bool isTaskClicked: false 
    property bool hasSubProject: false;

    ListModel {
        id: wintermodel
        ListElement { itemId: 0; name: "Today" }   
        ListElement { itemId: 1; name: "This week" }  
        ListElement { itemId: 2; name: "Next week" }   
        ListElement { itemId: 3; name: "This month" }   
        ListElement { itemId: 4; name: "Next month" }   
    }

    function formatDate(date) {
        var month = date.getMonth() + 1; 
        var day = date.getDate();
        var year = date.getFullYear();
        return month + '/' + day + '/' + year;
    }
    function createTask(selectedAccountUserId, nameInput, selectedProjectId, selectedparentTaskId, winterInput, startdateInput, enddateInput, deadlineInput, imgstar, initialInput, descriptionInput,selectedassigneesUserId,selectedSubProjectId) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function (tx) {
            var result = tx.executeSql('INSERT INTO project_task_app (account_id, name, project_id, parent_id, start_date, end_date, deadline, favorites, initial_planned_hours, description, user_id,sub_project_id, last_modified) \
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [selectedAccountUserId, nameInput, selectedProjectId, selectedparentTaskId, startdateInput,enddateInput, deadlineInput, imgstar, initialInput, descriptionInput, selectedassigneesUserId,selectedSubProjectId, new Date().toISOString()]);
            tx.executeSql('commit')
            isTaskSaved = true;
            isTaskClicked = true;
        });
    }

    function fetch_current_users_task(selectedAccountUserId) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var activity_type_list = []
        db.transaction(function (tx) {
            var instance_users = tx.executeSql('select * from res_users_app where account_id = ? AND share = ? AND active = ?', [selectedAccountUserId, 0, 1])
            var all_users = tx.executeSql('select * from res_users_app')
            for (var user = 0; user < all_users.rows.length; user++) {
            }
            for (var instance_user = 0; instance_user < instance_users.rows.length; instance_user++) {
                activity_type_list.push({'id': instance_users.rows.item(instance_user).id, 'name': instance_users.rows.item(instance_user).name});
            }
        })
        return activity_type_list;
    }

    Rectangle {
        id: newTask
        width: parent.width
        height: isDesktop()? 60 : 120 
        anchors.top: parent.top
        anchors.topMargin: isDesktop() ? 60 : 120
        color: "#FFFFFF"   
        z: 1

        
        Rectangle {
            width: parent.width
            height: 2                    
            color: "#DDDDDD"             
            anchors.bottom: parent.bottom
        }

        Row {
            id: row_id
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter 
            anchors.fill: parent
            spacing: isDesktop() ? 20 : 40 
            anchors.left: parent.left
            anchors.leftMargin: isDesktop()?55 : -10
            anchors.right: parent.right
            anchors.rightMargin: isDesktop()?15 : 20 

            
            Rectangle {
                color: "transparent"
                width: parent.width / 3
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height 

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                ToolButton {
                    width: isDesktop() ? 40 : 80
                    height: isDesktop() ? 35 : 80 
                    background: Rectangle {
                        color: "transparent"  
                    }
                    contentItem: Ubuntu.Icon {
                        name: "back" 
                    }
                    onClicked: {
                        stackView.push(taskList)
                    }
                }

                Label {
                    text: "Task"
                    font.pixelSize: isDesktop() ? 20 : 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: ToolButton.right
                    font.bold: true
                    color: "#121944"
                }
                
                }
            }

            Rectangle {
                color: "transparent"
                width: parent.width / 3
                height: parent.height 
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: activitySavedMessage
                    text: isTaskSaved ? "Task is Saved successfully!" : "Task could not be saved!"
                    color: isTaskSaved ? "green" : "red"
                    visible: isTaskClicked
                    font.pixelSize: isDesktop() ? 18 : phoneLarg()?30:40
                    horizontalAlignment: Text.AlignHCenter 
                    anchors.centerIn: parent

                }
            }

            Rectangle {
                color: "transparent"
                width: parent.width / 3
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height 
                anchors.right: parent.right

                Button {
                    id: rightButton
                    width: isDesktop() ? 20 : 70
                    height: isDesktop() ? 20 : 70
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right

                    Image {
                        source: "images/right.svg" 
                        width: isDesktop() ? 20 : 50
                        height: isDesktop() ? 20 : 50
                    }

                    background: Rectangle {
                        color: "transparent"
                        radius: 10
                        border.color: "transparent"
                    }
                   onClicked: {
                    if(nameInput.text.length > 1){
                        createTask(
                           selectedAccountUserId,
                           nameInput.text,
                           selectedProjectId,
                           selectedparentTaskId,
                           winterInput.text,
                           startdateInput.text,
                           enddateInput.text,
                           deadlineInput.text,
                           img_star.selectedPriority,
                           initialInput.text,
                           descriptionInput.text,
                           selectedassigneesUserId,
                           selectedSubProjectId
                        )
                        isTaskSaved= true
                        isTaskClicked = true
                        typingTimers.start()
                    }else{
                        isTaskSaved = false
                        isTaskClicked = true
                        typingTimers.start()
                    }       
                        
                    }

                }
                Timer {
                    id: typingTimers
                    interval: 1500 
                    running: false
                    repeat: false
                    onTriggered: {
                        if (isTaskSaved) {
                            selectedAccountUserId = 0
                            nameInput.text = ""
                            selectedProjectId = 0
                            selectedparentTaskId = 0
                            selectedwinterId = 1
                            winterInput.text = "This week"
                            deadlineInput.text = ""
                            img_star.selectedPriority = 0
                            initialInput.text = ""
                            descriptionInput.text = ""
                            selectedassigneesUserId = 0
                            assigneesInput.text = ""
                            selectedSubProjectId = 0
                            subProjectInput.text = ""
                            parentInput.text = ""
                            projectInput.text = ""
                            var today = new Date();
                            var dayOfWeek = today.getDay(); 
                            var fridayOffset = (5 - dayOfWeek + 7) % 7; 
                            var thisFriday = new Date(today.getFullYear(), today.getMonth(), today.getDate() + fridayOffset);
                            enddateInput.text = formatDate(thisFriday);
                            deadlineInput.text = formatDate(thisFriday);

                            
                            isTaskSaved = false;
                            isTaskClicked = false;
                            

                        }else{
                            isTimesheetClicked = false;
                            isTaskClicked = false;
                        }
                    }
                }
            }
        }
    }

    Flickable {
        id: flickableContainer
        width: parent.width
        
        height: parent.height  
        contentHeight: taskForm.childrenRect.height + 350 
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick  
        clip: true
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: isDesktop()?200:phoneLarg()?270:300
                anchors.left: parent.left
                anchors.leftMargin: isDesktop()?70 : 20
                anchors.right: parent.right
                anchors.rightMargin: isDesktop()?10 : 20
                color: "#ffffff"
                height: childrenRect.height + 20 
                id: taskForm
                
                Row {
                    id: add_date_flow
                    spacing: isDesktop() ? 100 : phoneLarg()? 250:250
                    anchors.verticalCenterOffset: -height * 1.5
                    anchors.horizontalCenter: parent.horizontalCenter; 
                    
                    Column {
                        spacing: isDesktop() ? 20 : 40
                        width: 60
                        Label { text: "Instance" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        Label { text: "Task Title" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        Label { text: "Assignees"
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        Label { text: "Description" 
                        width: 150
                        height: descriptionInput.height
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        Label { text: "Projects" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        Label { text: "Sub Project" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        visible: hasSubProject
                        }
                        Label { text: "Parent Task" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        Label { text: "Planned Hours" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        Label { text: "Select Period" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        } 
                        
                        Label { text: "Start Date" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        Label { text: "End Date" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        Label { text: "Deadline" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        
                        Label { text: "Priority" 
                        width: 150
                        height: isDesktop() ? 25 : 80
                        font.pixelSize: isDesktop() ? 18 : 40
                        }
                        
                    }
                    Column {
                        spacing: isDesktop() ? 20 : 40
                        
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

                            ListModel {
                                id: accountList
                                
                            }

                            TextInput {
                                width: parent.width
                                height: parent.height
                                font.pixelSize: isDesktop() ? 18 : 40
                                anchors.fill: parent
                                
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
                                    width: accountInput.width  


                                    Repeater {
                                        model: accountList

                                        MenuItem {
                                            width: parent.width
                                            height: isDesktop() ? 40 : 80
                                            property int accountId: model.id  
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
                            width: isDesktop() ? 500 : 750
                            height: isDesktop() ? 25 : 80
                            color: "transparent"

                            
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
                                wrapMode: Text.NoWrap 
                                clip: true             
                                

                                Text {
                                    id: namePlaceholder
                                    text: "Task Title"
                                    font.pixelSize: isDesktop() ? 18 : 40
                                    color: "#aaa"
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    visible: nameInput.text.length === 0
                                }

                                onFocusChanged: {
                                    namePlaceholder.visible = !focus && nameInput.text.length === 0
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

                            ListModel {
                                id: assigneesList
                                
                            }

                            TextInput {
                                width: parent.width
                                height: parent.height
                                font.pixelSize: isDesktop() ? 18 : 40
                                anchors.fill: parent
                                
                                id: assigneesInput
                                Text {
                                    id: assigneesplaceholder
                                    text: "Assignees"                                            
                                    font.pixelSize:isDesktop() ? 18 : 40
                                    color: "#aaa"
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        var result = fetch_current_users_task(selectedAccountUserId); 
                                            if(result){
                                                assigneesList.clear();
                                                for (var i = 0; i < result.length; i++) {
                                                    assigneesList.append(result[i]);
                                                }
                                                menuassignees.open();
                                            }
                                    }
                                }

                                Menu {
                                    id: menuassignees
                                    x: assigneesInput.x
                                    y: assigneesInput.y + assigneesInput.height
                                    width: assigneesInput.width  


                                    Repeater {
                                        model: assigneesList

                                        MenuItem {
                                            width: parent.width
                                            height: isDesktop() ? 40 : 80
                                            property int assigneesId: model.id  
                                            property string assigneesName: model.name || ''
                                            Text {
                                                text: assigneesName
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

                                                hasSubTask = false
                                                assigneesInput.text = assigneesName
                                                selectedassigneesUserId = assigneesId
                                                menuassignees.close()
                                            }
                                        }
                                    }
                                }

                                onTextChanged: {
                                    if (assigneesInput.text.length > 0) {
                                        assigneesplaceholder.visible = false
                                    } else {
                                        assigneesplaceholder.visible = true
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: isDesktop() ? 500 : 750
                            height: descriptionInput.height
                            color: "transparent"

                            Rectangle {
                                width: parent.width
                                height: isDesktop() ? 1 : 2
                                color: "black"
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                            }
                                TextArea {
                                    id: descriptionInput
                                    width: parent.width
                                    font.pixelSize: isDesktop() ? 18 : phoneLarg()? 30:40
                                    wrapMode: TextArea.Wrap 
                                    background: null 
                                    padding: 0
                                    color: "black"
                                    anchors.left: parent.left
                                    anchors.leftMargin: (!descriptionPlaceholder.visible && !isDesktop()) ? -30 : 0

                                    Text {
                                        id: descriptionplaceholder
                                        text: "Description"
                                        color: "#aaa"
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        visible: descriptionInput.text.length === 0
                                    }
                                   
                                    onFocusChanged: {
                                        descriptionplaceholder.visible = !focus && descriptionInput.text.length === 0;
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

                            ListModel {
                                id: projectsListModel
                                
                            }

                            TextInput {
                                width: parent.width
                                height: parent.height
                                font.pixelSize: isDesktop() ? 18 : 40
                                anchors.fill: parent
                                
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
                                        projectsListModel.clear();
                                        var result = fetch_projects(selectedAccountUserId);
                                        for (var i = 0; i < result.length; i++) {
                                            projectsListModel.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': result[i].projectkHasSubProject})
                                        }
                                        
                                        menu.open(); 

                                    }
                                }

                                Menu {
                                    id: menu
                                    x: projectInput.x
                                    y: projectInput.y + projectInput.height
                                    width: projectInput.width  


                                    Repeater {
                                        model: projectsListModel

                                        MenuItem {
                                            width: parent.width
                                            height: isDesktop() ? 40 : 80
                                            property int projectId: model.id  
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
                            height: isDesktop() ? 25 : phoneLarg()? 45:80
                            visible: hasSubProject
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
                                id: subProjectsListModel
                                
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
                                    width: subProjectInput.width  


                                    Repeater {
                                        model: subProjectsListModel

                                        MenuItem {
                                            width: parent.width
                                            height: isDesktop() ? 40 :phoneLarg()? 45: 80
                                            property int projectId: model.id  
                                            property string projectName: model.name || ''
                                            Text {
                                                text: projectName
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
                                                parentInput.text = ''
                                                selectedparentTaskId = 0
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

                            ListModel {
                                id: parentTask
                                
                            }

                            TextInput {
                                width: parent.width
                                height: parent.height
                                font.pixelSize: isDesktop() ? 18 : 40
                                anchors.fill: parent
                                
                                id: parentInput
                                wrapMode: Text.NoWrap 
                                clip: true
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
                                    onClicked: {
                                        parentTask.clear();
                                        var tasks_list = fetch_tasks_list(selectedProjectId, selectedSubProjectId)
                                            for (var i = 0; i < tasks_list.length; i++) {
                                                if(tasks_list[i].parent_id == 0){
                                                    parentTask.append({'id': tasks_list[i].id, 'name': tasks_list[i].name, 'taskHasSubTask': tasks_list[i].taskHasSubTask})
                                                }
                                            }
                                        parentplaceholder.visible = false
                                        parentmenu.open();

                                    }
                                }

                                Menu {
                                    id: parentmenu
                                    x: parentInput.x
                                    y: parentInput.y + parentInput.height
                                    width: parentInput.width  


                                    Repeater {
                                        model: parentTask

                                        MenuItem {
                                            width: parent.width
                                            height: isDesktop() ? 40 : 80
                                            property int parentTaskId: model.id  
                                            property string parentTaskName: model.name || ''
                                            Text {
                                                text: parentTaskName
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
                                                parentInput.text = parentTaskName
                                                selectedparentTaskId = parentTaskId
                                                
                                                
                                                
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
                                font.pixelSize: isDesktop() ? 20 : 40
                                anchors.fill: parent
                                
                                id: initialInput
                                
                                Text {
                                    id: initialInputPlaceholder
                                    text: "0.0"
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
                            width: (isDesktop() ? 500 : 750)
                            height: isDesktop() ? 20 : 50
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
                                
                                id: winterInput
                                Text {
                                    id: winterplaceholder
                                    text: "Winter Select"                                            
                                    font.pixelSize:isDesktop() ? 18 : 40
                                    color: "#aaa"
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        
                                        wintermenu.open();

                                    }
                                }

                                Menu {
                                    id: wintermenu
                                    x: winterInput.x
                                    y: winterInput.y + winterInput.height
                                    width: winterInput.width  

                                    Repeater {
                                        model: wintermodel

                                        MenuItem {
                                            width: parent.width
                                            height: isDesktop() ? 40 : 80
                                            property int winterId: model.itemId  
                                            property string winterName: model.name || ''
                                            
                                            Text {
                                                text: winterName
                                                font.pixelSize: isDesktop() ? 18 : 40
                                                color: "#000"
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left: parent.left
                                                anchors.leftMargin: 10                                                 
                                            }

                                            onClicked: {
                                                winterInput.text = winterName
                                                selectedwinterId = winterId
                                                wintermenu.close()

                                                
                                                var today = new Date();
                                                var dayOfWeek = today.getDay(); 
                                                var fridayOffset = (5 - dayOfWeek + 7) % 7; 

                                                switch (winterId) {
                                                    case 0:  
                                                        startdateInput.text = formatDate(today);
                                                        deadlineInput.text = formatDate(new Date(today.getFullYear(), today.getMonth(), today.getDate() + fridayOffset));
                                                        enddateInput.text = formatDate(new Date(today.getFullYear(), today.getMonth(), today.getDate() + fridayOffset));
                                                        break;
                                                        
                                                    case 1:  
                                                        var thisFriday = new Date(today.getFullYear(), today.getMonth(), today.getDate() + fridayOffset);
                                                        startdateInput.text = formatDate(today);
                                                        deadlineInput.text = formatDate(thisFriday);
                                                        enddateInput.text = formatDate(thisFriday);
                                                        break;
                                                        
                                                    case 2:  
                                                        var nextMonday = new Date(today.getFullYear(), today.getMonth(), today.getDate() + (8 - dayOfWeek)); 
                                                        var nextFriday = new Date(nextMonday.getFullYear(), nextMonday.getMonth(), nextMonday.getDate() + 4); 
                                                        startdateInput.text = formatDate(nextMonday);
                                                        deadlineInput.text = formatDate(nextFriday);
                                                        enddateInput.text = formatDate(nextFriday);
                                                        break;

                                                    case 3:  
                                                        var lastDayThisMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0); 
                                                        startdateInput.text = formatDate(today);
                                                        deadlineInput.text = formatDate(lastDayThisMonth);
                                                        enddateInput.text = formatDate(lastDayThisMonth);
                                                        break;


                                                    case 4:  
                                                        var firstDayNextMonth = new Date(today.getFullYear(), today.getMonth() + 1, 1);
                                                        var lastDayNextMonth = new Date(today.getFullYear(), today.getMonth() + 2, 0);
                                                        startdateInput.text = formatDate(firstDayNextMonth);
                                                        deadlineInput.text = formatDate(lastDayNextMonth);
                                                        enddateInput.text = formatDate(lastDayNextMonth);
                                                        break;
                                                }
                                            }
                                        }
                                    }
                                }

                                onTextChanged: {
                                    if (winterInput.text.length > 0) {
                                        winterplaceholder.visible = false
                                    } else {
                                        winterplaceholder.visible = true
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
                                font.pixelSize: isDesktop() ? 18 : 40
                                anchors.fill: parent
                                id: startdateInput
                                Text {
                                    id: startdate
                                    text: "Date"
                                    font.pixelSize: isDesktop() ? 18 : 40
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
                                    bottomMargin: 500
                                    visible: false

                                    DatePicker {
                                        id: datePicker
                                        onClicked: {
                                            startdateInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
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
                                    if (startdateInput.text.length > 0) {
                                        startdate.visible = false
                                    } else {
                                        startdate.visible = true
                                    }
                                }
                                function formatDate(date) {
                                    var month = date.getMonth() + 1; 
                                    var day = date.getDate();
                                    var year = date.getFullYear();
                                    return month + '/' + day + '/' + year;
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
                                font.pixelSize: isDesktop() ? 18 : 40
                                anchors.fill: parent
                                id: enddateInput
                                Text {
                                    id: enddate
                                    text: "Date"
                                    font.pixelSize: isDesktop() ? 18 : 40
                                    color: "#aaa"
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Dialog {
                                    id: enddateDialog
                                    width: isDesktop() ? 0 : phoneLarg()? 550: 700 
                                                height: isDesktop() ? 0 : phoneLarg()? 450:650
                                    padding: 0
                                    margins: 0
                                    bottomMargin: 500
                                    visible: false

                                    DatePicker {
                                        id: datePickerenddate
                                        onClicked: {
                                            enddateInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                        }
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        var now = new Date()
                                        datePickerenddate.selectedDate = now
                                        datePickerenddate.currentIndex = now.getMonth()
                                        datePickerenddate.selectedYear = now.getFullYear()
                                        enddateDialog.visible = true
                                    }
                                }

                                onTextChanged: {
                                    if (enddateInput.text.length > 0) {
                                        enddate.visible = false
                                    } else {
                                        enddate.visible = true
                                    }
                                }
                                function formatDate(date) {
                                    var month = date.getMonth() + 1; 
                                    var day = date.getDate();
                                    var year = date.getFullYear();
                                    return month + '/' + day + '/' + year;
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
                                font.pixelSize: isDesktop() ? 18 : 40
                                anchors.fill: parent
                                id: deadlineInput
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
                                    width: isDesktop() ? 0 : phoneLarg()? 550: 700 
                                    height: isDesktop() ? 0 : phoneLarg()? 450:650
                                    padding: 0
                                    margins: 0
                                    bottomMargin: 500
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
                                    var month = date.getMonth() + 1; 
                                    var day = date.getDate();
                                    var year = date.getFullYear();
                                    return month + '/' + day + '/' + year;
                                }
                            }
                        }
                       
                        Row {
                            width: isDesktop() ? 500 : 750
                            height: isDesktop() ? 25 : 80
                            id: img_star
                            spacing: 5  
                            property int selectedPriority: 0  

                            Repeater {
                                model: 1  
                                delegate: Item {
                                    width: isDesktop() ? 30 : 60  
                                    height: isDesktop() ? 30 : 60

                                    Image {
                                        id: starImage
                                        source: (index < img_star.selectedPriority) ? "images/star-active.svg" : "images/starinactive.svg"  
                                        anchors.fill: parent
                                        smooth: true  

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                
                                                if (index + 1 === img_star.selectedPriority) {
                                                    img_star.selectedPriority = 0;  
                                                } else {
                                                    img_star.selectedPriority = index + 1;  
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
            }
    }
    Component.onCompleted: {
        
        selectedwinterId = 1
        winterInput.text = "This week"

        var today = new Date();
        var dayOfWeek = today.getDay(); 
        var fridayOffset = (5 - dayOfWeek + 7) % 7; 
        var thisFriday = new Date(today.getFullYear(), today.getMonth(), today.getDate() + fridayOffset);
        startdateInput.text = formatDate(today);
        enddateInput.text = formatDate(thisFriday);
        deadlineInput.text = formatDate(thisFriday);
        var result = accountlistDataGet();
        selectedAccountUserId = result[0].id
        accountInput.text = result[0].name
        var contacts_list = fetch_current_users_task(result[0].id)
    }
}

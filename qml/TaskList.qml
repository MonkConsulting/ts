import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.7
import Ubuntu.Components 1.3 as Ubuntu


Item {
    width: parent.width
    height: parent.height
    property var filtertasklistData: []
    property int currentRecordId: 0
    property int selectedAccountUserId: 0
    property int selectedProjectId: 0 
    property int selectedparentId: 0
    property int editselectedSubProjectId: 0 
    property int selectedassigneesUserId: 0
    property string dayLeft: ""
    property bool issearchHeader: false
    property bool isTaskEdit: false
    property bool isTaskClicked: false
    property bool hasSubProject: false;
    function formatDate(date) {
        var month = date.getMonth() + 1; 
        var day = date.getDate();
        var year = date.getFullYear();
        return month + '/' + day + '/' + year;
    }
    function edittaskData(data){
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            tx.executeSql('UPDATE project_task_app SET \
                account_id = ?, name = ?, project_id = ?, parent_id = ?, initial_planned_hours = ?, favorites = ?, description = ?, user_id = ?, sub_project_id = ?, \
                start_date = ?, end_date = ?, deadline = ?, last_modified = ? WHERE id = ?',
                [data.selectedAccountUserId, data.nameInput, data.selectedProjectId,data.selectedparentId, data.initialInput,data.img_star,data.editdescription, data.selectedassigneesUserId, data.editselectedSubProjectId,
                data.startdateInput, data.enddateInput,data.deadlineInput, new Date().toISOString(), data.rowId]  
            );
            tx.executeSql('commit');
            fetch_tasks_lists()
        });
    }
    function fetch_tasks_lists() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        filtertasklistData = []
        tasksListModel.clear()
        db.transaction(function(tx) {
            if(workpersonaSwitchState){
                var result = tx.executeSql('SELECT * FROM project_task_app order by last_modified desc');
            }else{
                var result = tx.executeSql('SELECT * FROM project_task_app where account_id IS NULL');
            }
            for (var i = 0; i < result.rows.length; i++) {
                var parent_task = tx.executeSql('SELECT name FROM project_task_app WHERE id = ?',[result.rows.item(i).parent_id]);
                var parentTask = parent_task.rows.length > 0 ? parent_task.rows.item(0).name || "" : "";

                var accunt_id = tx.executeSql('SELECT name FROM users WHERE id = ?',[result.rows.item(i).account_id]);
                var accountName = accunt_id.rows.length > 0 ? accunt_id.rows.item(0).name || "" : "";


                var id = result.rows.item(i).id
                var spentHoursQuery = tx.executeSql('SELECT unit_amount FROM account_analytic_line_app WHERE task_id = ?', [id]);

                var totalMinutes = 0;
                for (var j = 0; j < spentHoursQuery.rows.length; j++) {
                    var timeString = spentHoursQuery.rows.item(j).unit_amount || "00:00";
                    var parts = timeString.split(":");
                    var hours = parseInt(parts[0], 10) || 0;
                    var minutes = parseInt(parts[1], 10) || 0;

                    totalMinutes += hours * 60 + minutes;  
                }

                var totalHours = Math.floor(totalMinutes / 60);
                var remainingMinutes = totalMinutes % 60;
                var spentHours =  totalHours + ":" + (remainingMinutes < 10 ? "0" : "") + remainingMinutes;

                tasksListModel.append({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'allocated_hours': result.rows.item(i).initial_planned_hours, 'state': result.rows.item(i).state, 'parentTask': parentTask, 'accountName':accountName,'favorites':result.rows.item(i).favorites,'spentHours':spentHours, 'timerRunning': false})
                filtertasklistData.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'allocated_hours': result.rows.item(i).initial_planned_hours, 'state': result.rows.item(i).state,'parentTask': parentTask, 'accountName':accountName,'favorites':result.rows.item(i).favorites,'spentHours':spentHours, 'timerRunning': false})
            }
        })
    }

    function filterTaskList(query) {
        tasksListModel.clear(); 

            for (var i = 0; i < filtertasklistData.length; i++) {
                var entry = filtertasklistData[i];
                
                if (entry.name.toLowerCase().includes(query.toLowerCase()) ||
                    entry.parentTask.toLowerCase().includes(query.toLowerCase()) || 
                    entry.state.toLowerCase().includes(query.toLowerCase()) ||
                    entry.accountName.toLowerCase().includes(query.toLowerCase()) ||
                    (entry.spentHours.toString().includes(query)) ||  
                    (entry.allocated_hours.toString().includes(query))
                    ) {
                    tasksListModel.append(entry);

                }
            }
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
    

    ListModel {
        id: tasksListModel
    }
    Rectangle {
        id:taskHeader
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
            anchors.leftMargin: isDesktop()?  55 : -10 
            anchors.right: parent.right
            anchors.rightMargin: isDesktop()?15 : 20 

            
            Rectangle {
                id: header_tital
                visible: !issearchHeader
                color: "transparent"
                width: parent.width / 5
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
                        stackView.push(listPage)
                    }
                }    

                Label {
                    text: "Tasks"
                    font.pixelSize: isDesktop() ? 20 : 40
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: ToolButton.right
                    font.bold: true
                    color: "#121944"
                }
                
                }
            }

            
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
                        width: isDesktop() ? 40 : 80
                        height: isDesktop() ? 35 : 80
                        background: Rectangle {
                            color: "transparent"  
                        }
                        contentItem: Ubuntu.Icon {
                            name: "add" 
                        }
                        onClicked: {
                            
                            stackView.push(taskForm)
                        }
                    }

                    ToolButton {
                        id: search_id
                        width: isDesktop() ? 40 : 80
                        height: isDesktop() ? 35 : 80
                        background: Rectangle {
                            color: "transparent"  
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
                            color: "transparent"  
                        }
                        contentItem: Ubuntu.Icon {
                            name: "back"
                        }
                        onClicked: {
                            issearchHeader = false
                            searchField.text = ""
                        }
                    }

                    
                    TextField {
                        id: searchField
                        placeholderText: "Search..."
                        anchors.left: back_idn.right 
                        anchors.leftMargin: isDesktop() ? 0 : 5
                        anchors.right: parent.right 
                        anchors.verticalCenter: parent.verticalCenter
                        onTextChanged: {
                            filterTaskList(searchField.text);  
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

        Rectangle {
            
            anchors.fill: parent
            anchors.topMargin: isDesktop() ? 68 : 170
            border.color: "#CCCCCC"
            border.width: isDesktop() ? 1 : 2
        Column {
            spacing: 0
            anchors.fill: parent
            anchors.topMargin: isDesktop()?1 : 2

            
            Flickable {
                id: taskFlickable
                anchors.fill: parent
                contentHeight: column.height 
                clip: true 
                width: rightPanel.visible? parent.width / 2 : parent.width
                property string edit_id: ""
                property var modeldatas: null 

                visible: isDesktop() ? true : phoneLarg()? true : rightPanel.visible? false : true


                Column {
                    id: column 
                    width: rightPanel.visible? parent.width / 2 : parent.width
                    spacing: 0
                    Repeater {
                        model: tasksListModel
                        delegate: Rectangle {
                            width: parent.width
                            height: isDesktop()?80:133
                            color: currentRecordId === model.id ? "#F5F5F5" : "#FFFFFF"  
                            border.color: "#CCCCCC"
                            border.width:isDesktop()? 1 : 2

                             MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    taskFlickable.modeldatas = model
                                    currentRecordId = model.id;
                                    rightPanel.visible = true
                                    taskFlickable.edit_id= model.id; 
                                    rightPanel.loadtaskData();
                                    
                                    
                                    
                                }
                            }

                             Row {
                                width: parent.width
                                height: isDesktop() ? 50 : 50
                                spacing: 0  

                                Rectangle {
                                    width: 10  
                                    height: isDesktop() ? 78 : 130
                                    anchors.top: parent.top
                                    anchors.topMargin: 1
                                    color: getColorBasedOnIndex(index)
                                    function getColorBasedOnIndex(index) {
                                        switch (index % 4) {
                                            case 0: return "#ff0000";  
                                            case 1: return "#00ff00";  
                                            case 2: return "#0000ff";  
                                            case 3: return "#ffff00";  
                                            default: return "#cccfff";  
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width - 10  
                                    spacing: 0

                                    Row {
                                        width: parent.width
                                        height: isDesktop() ? 40 : 65
                                        spacing: 20 
                                        Row {
                                            spacing: 10
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width * 0.4  
                                            id: left_row

                                            Image {
                                                id: starImageList
                                                source: model.favorites > 0 ? "images/star-active.svg" : "images/starinactive.svg" 
                                                width: isDesktop() ? 20 : 30
                                                height: isDesktop() ? 20 : 30
                                                smooth: true  
                                            }

                                            Text {
                                                text: "Task: " + model.name
                                                font.pixelSize: isDesktop() ? 20 : 30
                                                color: "#000000"
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width * 0.8  
                                                elide: Text.ElideRight
                                            }
                                        }


                                        
                                        Text {
                                            text: model.parentTask
                                            font.pixelSize: isDesktop() ? 18 : 26
                                            color: "#000000"  
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: left_row.right
                                            anchors.leftMargin: 10
                                            width: parent.width * 0.4
                                            elide: Text.ElideRight  

                                        }
                                        
                                        
                                        Text {
                                            text: model.state
                                            font.pixelSize: isDesktop() ? 18 : 26
                                            color: "#000000"  
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.right: parent.right
                                            horizontalAlignment: Text.AlignRight 
                                            anchors.rightMargin: 15
                                            width: parent.width * 0.3
                                        }
                                    }

                                    Row {
                                        width: parent.width
                                        height: isDesktop() ? 40 : 55  
                                        spacing: 20
                                        Component.onCompleted: {
                                            if(idstarttime === model.id){
                                                model.timerRunning = true
                                            }
                                        }


                                        Row {
                                            spacing: 10
                                            
                                            
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width * 0.4  
                                            id: enddate_id
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10

                                            ToolButton {
                                                width: isDesktop() ? 40 : 70
                                                height: isDesktop() ? 35 : 70
                                                visible: !timestart && !(model.timerRunning)
                                               
                                                background: Rectangle {
                                                    color: "transparent"  
                                                    radius: 10  
                                                }

                                                contentItem: Image {
                                                    source: "images/start.svg" 
                                                    width: isDesktop() ? 20 : 50
                                                    height: isDesktop() ? 20 : 50
                                                }
                                                
                                                onClicked: {
                                                        taskssmartBtn = model
                                                        currentTime = new Date()
                                                        timestart = true
                                                        stopwatchTimer.start();
                                                        idstarttime = model.id
                                                        model.timerRunning = true
                                                        running = true  
                                                        var currentDate = new Date();
                                                        datesmartBtnStart = formatDate(currentDate);
                                                        taskFlickable.modeldatas = model
                                                        
                                                }
                                            
                                            }
                                            ToolButton {
                                                width: isDesktop() ? 40 : 70
                                                height: isDesktop() ? 35 : 70
                                                visible: timestart && model.timerRunning
                                                background: Rectangle {
                                                    color: "red"  
                                                    radius: 10
                                                }
                                                contentItem: Ubuntu.Icon {
                                                    name: "media-playback-stop" 
                                                    color: "white"
                                                }
                                                onClicked: {
                                                    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

                                                        db.transaction(function (tx) {
                                                            
                                                            if(workpersonaSwitchState){
                                                                var result = tx.executeSql('SELECT * FROM project_task_app WHERE id = ?', [taskssmartBtn.id]);
                                                            }else{
                                                                var result = tx.executeSql('SELECT * FROM project_task_app where account_id IS NULL AND id = ?', [taskssmartBtn.id] );
                                                            }
                                                            if (result.rows.length > 0) {
                                                                var rowData = result.rows.item(0);
                                                                var descriptionData = rowData.description.replace(/<[^>]+>/g, " ")     
                                                                                    .replace(/&nbsp;/g, "")       
                                                                                    .replace(/&lt;/g, "<")         
                                                                                    .replace(/&gt;/g, ">")         
                                                                                    .replace(/&amp;/g, "&")        
                                                                                    .replace(/&quot;/g, "\"")      
                                                                                    .replace(/&#39;/g, "'")        
                                                                                    .trim() || "";
                                                                var dataObject = {
                                                                    dateTime: datesmartBtnStart,
                                                                    project:  rowData.project_id,
                                                                    task: taskssmartBtn.id,
                                                                    subTask: rowData.parent_id,
                                                                    isManualTimeRecord: false,
                                                                    manualSpentHours: "",
                                                                    description: " ",
                                                                    spenthours: formatTime(elapsedTime),
                                                                    instance_id: rowData.account_id,
                                                                    quadrant: 4,
                                                                    subprojectId:rowData.sub_project_id
                                                                };
                                                                timesheetData(dataObject);

                                                            }

                                                           })
                                                        
                                                        taskssmartBtn = null
                                                        currentTime = false;
                                                        stopwatchTimer.stop();
                                                        running = false;
                                                        timestart = false
                                                        idstarttime = 0
                                                        storedElapsedTime = 0   
                                                        elapsedTime = 0
                                                        
                                                        model.timerRunning = false
                                                        taskFlickable.modeldatas = model
                                                }
                                            
                                            }

                                            Text {
                                            
                                            text: "Planned Hours: " + model.allocated_hours
                                            font.pixelSize: isDesktop() ? 18 : 26
                                            color: "#000000"                                                                                                                                
                                            anchors.verticalCenter: parent.verticalCenter
                                            
                                            
                                            width: parent.width * 0.4
                                        }
                                        }
                                        Text {
                                            text: "Spent Hours: " + model.spentHours
                                            font.pixelSize: isDesktop() ? 18 : 26
                                            color: "#000000"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: enddate_id.right
                                            anchors.leftMargin: 10
                                            width: parent.width * 0.4
                                        }

                                            Text {
                                            text: model.accountName
                                            font.pixelSize: isDesktop() ? 18 : 26
                                            color: "#000000"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.right: parent.right
                                            horizontalAlignment: Text.AlignRight 
                                            anchors.rightMargin: 15
                                            width: parent.width * 0.3
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
                color: "#EFEFEF"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                anchors.topMargin: phoneLarg()? 0 :0
                function loadtaskData() {
                    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
                    var rowId = taskFlickable.edit_id;

                        db.transaction(function (tx) {
                            
                            if(workpersonaSwitchState){
                                var result = tx.executeSql('SELECT * FROM project_task_app WHERE id = ?', [rowId]);
                            }else{
                                var result = tx.executeSql('SELECT * FROM project_task_app where account_id IS NULL AND id = ?', [rowId] );
                            }
                            if (result.rows.length > 0) {
                                var rowData = result.rows.item(0);

                                var projectId = rowData.project_id || "";  
                                var parentId = rowData.parent_id != null ? rowData.parent_id || "":"";
                                var sub_pro_Id = rowData.sub_project_id != null ? rowData.sub_project_id || "":"";
                                var accountId = rowData.account_id || ""; 
                                var userId = rowData.user_id || ""; 
                                
                                if(sub_pro_Id != 0){
                                hasSubProject = true
                                var sub_project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?', [sub_pro_Id]);
                                subProjectInput.text = sub_project.rows.length > 0 ? sub_project.rows.item(0).name || "" : "";
                                editselectedSubProjectId = sub_pro_Id
                                }else{
                                hasSubProject = false
                                    
                                }


                                if(rowData.start_date != 0 && rowData.start_date != "mm/dd/yy") {
                                    var rowDate = new Date(rowData.start_date || "");  
                                    var formattedDate = formatDate(rowDate);  
                                    startdateInput.text = formattedDate;
                                }else{
                                    startdateInput.text = "mm/dd/yy"
                                }
                                if(rowData.end_date != 0 && rowData.end_date != "mm/dd/yy") {
                                    var rowDate = new Date(rowData.end_date || "");  
                                    var formattedDate = formatDate(rowDate);  
                                    enddateInput.text = formattedDate;
                                }else{
                                    enddateInput.text = "mm/dd/yy"
                                }
                                if(rowData.deadline != 0 && rowData.deadline != "mm/dd/yy") {
                                    var rowDate = new Date(rowData.deadline || "");  
                                    var formattedDate = formatDate(rowDate);  
                                    deadlineInput.text = formattedDate;
                                    var currentDate = new Date();                    
                                    currentDate.setHours(0, 0, 0, 0);                
                                    rowDate.setHours(0, 0, 0, 0);                    

                                    var timeDiff = rowDate - currentDate;            
                                    var dayLefts = Math.ceil(timeDiff / (1000 * 60 * 60 * 24));  

                                    dayLeft = dayLefts
                                   
                                }else{
                                    deadlineInput.text = "mm/dd/yy"
                                    dayLeft = ""
                                }

                                var project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?', [projectId]);
                                var parentname = tx.executeSql('SELECT name FROM project_task_app WHERE id = ?', [parentId]);
                                if(workpersonaSwitchState){
                                    var account = tx.executeSql('SELECT name FROM users WHERE id = ?', [accountId]);
                                    var user = tx.executeSql('SELECT name FROM res_users_app WHERE id = ?', [userId]);
                                }
                                
                                projectInput.text = project.rows.length > 0 ? project.rows.item(0).name || "" : "";
                                selectedProjectId = projectId

                                if(workpersonaSwitchState){
                                    accountInput.text = account.rows.length > 0 ? account.rows.item(0).name || "" : "";
                                    selectedAccountUserId = accountId

                                    assigneesInput.text = user.rows.length > 0 ? user.rows.item(0).name || "" : "";
                                    selectedassigneesUserId = userId

                                }
                                nameInput.text = rowData.name
                                parentInput.text = parentname.rows.length > 0 ? parentname.rows.item(0).name || "" : "";
                                selectedparentId = parentId
                                img_star.selectedPriority = rowData.favorites || 0; 
                                initialInput.text = rowData.initial_planned_hours || 0;
                                editdescription.text = rowData.description
                                    .replace(/<[^>]+>/g, " ")     
                                    .replace(/&nbsp;/g, "")       
                                    .replace(/&lt;/g, "<")         
                                    .replace(/&gt;/g, ">")         
                                    .replace(/&amp;/g, "&")        
                                    .replace(/&quot;/g, "\"")      
                                    .replace(/&#39;/g, "'")        
                                    .trim() || "";
                            }
                        });
                        function formatDate(date) {
                            var month = date.getMonth() + 1; 
                            var day = date.getDate();
                            var year = date.getFullYear();
                            return month + '/' + day + '/' + year;
                        }
                }
                
                Column {
                    anchors.fill: parent
                    spacing: 20
                    
                    Row {
                        width: parent.width
                        anchors.top: parent.top
                        anchors.topMargin: 5
                        
                        spacing: 10  

                        Button {
                            id: crossButton
                            anchors.left: parent.left
                            width: isDesktop() ? 24 : 65
                            height: isDesktop() ? 24 : 65
                            anchors.leftMargin: 10
                            
                            

                            Image {
                                source: "images/cross.svg" 
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
                                
                            }
                        }
                        Timer {
                            id: taskEditTimer
                            interval: 2000  
                            repeat: false
                            onTriggered: {
                                isTaskEdit = false;
                                isTaskClicked = false;
                            }
                        }
                        Text {
                            text: dayLeft + (" Day Left")
                            font.pixelSize: isDesktop() ? 20 : 40  
                            anchors.verticalCenter: parent.verticalCenter  
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            anchors.horizontalCenter: parent.horizontalCenter  
                            color: dayLeft < 0 ? "red" :"#000000" 
                            visible: dayLeft
                        }
                        Button {
                            id: rightButton
                            
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            width: isDesktop() ? 20 : 60
                            height: isDesktop() ? 20 : 60
                            anchors.rightMargin: isDesktop() ? 15 : 20

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
                                const editData = {
                                    selectedAccountUserId: selectedAccountUserId ,
                                    nameInput: nameInput.text,
                                    selectedProjectId: selectedProjectId,
                                    editselectedSubProjectId: editselectedSubProjectId,
                                    selectedparentId: selectedparentId,
                                    startdateInput: startdateInput.text,
                                    enddateInput: enddateInput.text,
                                    deadlineInput: deadlineInput.text,
                                    img_star: img_star.selectedPriority,
                                    initialInput: initialInput.text,
                                    editdescription: editdescription.text,
                                    selectedassigneesUserId: selectedassigneesUserId,
                                    'rowId':taskFlickable.edit_id,
                                }
                                if(nameInput.text.length > 1){
                                    isTaskEdit = true
                                    isTaskClicked = true
                                    edittaskData(editData)
                                    filterTaskList(searchField.text)
                                    taskEditTimer.start();

                                }else{
                                    isTaskEdit = false
                                    isTaskClicked = true
                                    taskEditTimer.start();
                                }
                            }

                        }

                    }
                    Row{
                        anchors.top: parent.top
                        anchors.topMargin: isDesktop() ? 40 : phoneLarg()? 75 : 85
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        ToolButton {
                            width: isDesktop() ? 40 : 100
                            height: isDesktop() ? 35 : 100
                            visible: !timestart && !(taskFlickable.modeldatas.timerRunning)
                            
                            background: Rectangle {
                                color: "transparent"  
                                radius: 10  
                            }

                            contentItem: Image {
                                source: "images/start.svg" 
                                
                                
                            }
                            
                            onClicked: {
                                    taskssmartBtn = taskFlickable.modeldatas
                                    currentTime = new Date()
                                    timestart = true
                                    stopwatchTimer.start();
                                    idstarttime = taskFlickable.modeldatas.id
                                    taskFlickable.modeldatas.timerRunning = true
                                    running = true  
                                    var currentDate = new Date();
                                    datesmartBtnStart = formatDate(currentDate);
                                    
                            }
                        
                        }

                        ToolButton {
                            width: isDesktop() ? 40 : phoneLarg()? 80 :100
                            height: isDesktop() ? 35 : phoneLarg()? 80: 100
                            visible: timestart && taskFlickable.modeldatas.timerRunning
                            background: Rectangle {
                                color: "red"  
                                radius: 10
                            }
                            contentItem: Ubuntu.Icon {
                                name: "media-playback-stop" 
                                color: "white"
                            }
                            onClicked: {
                                var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

                                    db.transaction(function (tx) {
                                        
                                        if(workpersonaSwitchState){
                                            var result = tx.executeSql('SELECT * FROM project_task_app WHERE id = ?', [taskssmartBtn.id]);
                                        }else{
                                            var result = tx.executeSql('SELECT * FROM project_task_app where account_id IS NULL AND id = ?', [taskssmartBtn.id] );
                                        }
                                        if (result.rows.length > 0) {
                                            var rowData = result.rows.item(0);
                                            var descriptionData = rowData.description.replace(/<[^>]+>/g, " ")     
                                                                .replace(/&nbsp;/g, "")       
                                                                .replace(/&lt;/g, "<")         
                                                                .replace(/&gt;/g, ">")         
                                                                .replace(/&amp;/g, "&")        
                                                                .replace(/&quot;/g, "\"")      
                                                                .replace(/&#39;/g, "'")        
                                                                .trim() || "";
                                            var dataObject = {
                                                dateTime: datesmartBtnStart,
                                                project:  rowData.project_id,
                                                task: taskssmartBtn.id,
                                                subTask: rowData.parent_id,
                                                isManualTimeRecord: false,
                                                manualSpentHours: "",
                                                description: " ",
                                                spenthours: formatTime(elapsedTime),
                                                instance_id: rowData.account_id,
                                                quadrant: 4,
                                                subprojectId:rowData.sub_project_id
                                            };
                                            timesheetData(dataObject);

                                        }

                                        })
                                    
                                    taskssmartBtn = null
                                    currentTime = false;
                                    stopwatchTimer.stop();
                                    running = false;
                                    timestart = false
                                    idstarttime = 0
                                    storedElapsedTime = 0   
                                    elapsedTime = 0
                                    taskFlickable.modeldatas.timerRunning = false
                            }
                        
                        }
                    }

                    Flickable {
                        id: flickableContainertask
                        width: parent.width
                        
                        height: parent.height  
                        contentHeight: taskItemedit.childrenRect.height + (isDesktop()?0:100)  
                        anchors.fill: parent
                        flickableDirection: Flickable.VerticalFlick  
                        anchors.top: parent.top
                        anchors.topMargin: isDesktop() ? 85 : phoneLarg()? 165 : 190
                        

                        
                        clip: true
                    Item {
                        id: taskItemedit
                        height: taskItemedit.childrenRect.height + 100
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: phoneLarg()? 20:0
                        anchors.topMargin: isDesktop() ? 0 : phoneLarg()? 10 : 75
                        Row {
                            spacing: isDesktop() ? 100 : phoneLarg()? 260 :220
                            anchors.verticalCenterOffset: -height * 1.5
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            
                                Component.onCompleted: {
                                if (isDesktop()) {
                                    anchors.horizontalCenter = parent.horizontalCenter; 
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
                                Label { text: "Task Title" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Assignees" 
                                width: 150
                                height: isDesktop() ? 25 : 80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Description" 
                                width: 150
                                height: editdescription.height
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Projects" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Sub Project" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                visible: hasSubProject
                                }   
                                Label { text: "Parent Task" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Planned Hours" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Start Date" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "End Date" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                Label { text: "Deadline" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: isDesktop() ? 18 : 40
                                }
                                
                                Label { text: "Priority" 
                                width: 150
                                height: isDesktop() ? 25 : phoneLarg()?50:80
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
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
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
                                        id: accountList
                                        
                                    }

                                    TextInput {
                                        width: parent.width
                                        height: parent.height
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        anchors.fill: parent
                                        
                                        id: accountInput
                                        wrapMode: Text.NoWrap 
                                        clip: true                  
                                        focus: true 
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
                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
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
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        accountInput.text = accuntName
                                                        selectedAccountUserId = accountId
                                                        selectedProjectId = 0
                                                        projectInput.text = ""
                                                        selectedparentId = 0 
                                                        parentInput.text = ""

                                                        
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
                                        focus: true 

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
                                        wrapMode: Text.NoWrap 
                                        clip: true                  
                                        focus: true 
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
                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                                    property int assigneesId: model.id  
                                                    property string assigneesName: model.name || ''
                                                    Text {
                                                        text: assigneesName
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
                                                        assigneesInput.text = assigneesName
                                                        selectedassigneesUserId = assigneesId
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
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
                                    height: editdescription.height
                                    color: "transparent"

                                    
                                    Rectangle {
                                        width: parent.width
                                        height: isDesktop() ? 1 : 2
                                        color: "black"
                                        anchors.bottom: parent.bottom
                                    }

                                    TextArea {
                                        id: editdescription
                                        width: parent.width
                                        
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        
                                        wrapMode: TextArea.Wrap 
                                        background: null 
                                        padding: 0
                                        color: "black"
                                        anchors.left: parent.left
                                        anchors.leftMargin: (!editdescriptionPlaceholder.visible && !isDesktop()) ? -30 : 0
                                        

                                        Text {
                                            id: editdescriptionPlaceholder
                                            text: "Description"
                                            font.pixelSize: isDesktop() ? 18 : 40
                                            color: "#aaa"
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            visible: editdescription.text.length === 0

                                        }

                                        onTextChanged: {
                                            editdescriptionPlaceholder.visible = !focus && editdescription.text.length === 0;
                                        }
                                    }
                                }
                                Rectangle {
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
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
                                        id: projectsListModel
                                        
                                    }

                                    TextInput {
                                        width: parent.width
                                        height: parent.height
                                        font.pixelSize: isDesktop() ? 18 : 40
                                        anchors.fill: parent
                                        
                                        id: projectInput
                                        wrapMode: Text.NoWrap 
                                        clip: true                  
                                        focus: true 
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
                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
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
                                                        editselectedSubProjectId = 0 
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
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
                                    height: isDesktop() ? 25 : phoneLarg()?50:80
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
                                        font.pixelSize: isDesktop() ? 18 :40
                                        anchors.fill: parent
                                        //anchors.margins: 5                                
                                        id: subProjectInput
                                        Text {
                                            id: subProjectplaceholder
                                            text: "Sub Project"                                            
                                            font.pixelSize:isDesktop() ? 18 :40
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
                                                    height: isDesktop() ? 40 :phoneLarg()? 50: 80
                                                    property int projectId: model.id  
                                                    property string projectName: model.name || ''
                                                    Text {
                                                        text: projectName
                                                        font.pixelSize: isDesktop() ? 18 :40
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
                                                        parentInput.text = ''
                                                        selectedparentId = 0
                                                        subProjectInput.text = projectName
                                                        editselectedSubProjectId = projectId
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
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
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
                                        focus: true 
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
                                                var result = fetch_tasks_list(selectedProjectId, editselectedSubProjectId);
                                                for (var i = 0; i < result.length; i++) {
                                                    if(result[i].parent_id == 0){
                                                         parentTask.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': false})
                                                    }
                                                }
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
                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                                    property int parentId: model.id  
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
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        parentInput.text = parentName
                                                        selectedparentId = parentId
                                                        
                                                        
                                                        
                                                        
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
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
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
                                        
                                        id: initialInput
                                        
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
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
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
                                            id: startDialog
                                            width: isDesktop() ? 0 : 700
                                            height: isDesktop() ? 0 : 650
                                            bottomMargin: 500
                                            padding: 0
                                            margins: 0
                                            visible: false

                                            DatePicker {
                                                id: startdatePicker
                                                onClicked: {
                                                    startdateInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                                }
                                            }
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                var now = new Date()
                                                startdatePicker.selectedDate = now
                                                startdatePicker.currentIndex = now.getMonth()
                                                startdatePicker.selectedYear = now.getFullYear()
                                                startDialog.visible = true
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

                                        
                                        Component.onCompleted: {
                                            var currentDate = new Date();
                                            startdateInput.text = formatDate(currentDate);
                                        }

                                    }
                                }
                                Rectangle {
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
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
                                            id: endDialog
                                            width: isDesktop() ? 0 : 700
                                            height: isDesktop() ? 0 : 650
                                            bottomMargin: 500
                                            padding: 0
                                            margins: 0
                                            visible: false

                                            DatePicker {
                                                id: enddatePicker
                                                onClicked: {
                                                    enddateInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                                }
                                            }
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                var now = new Date()
                                                enddatePicker.selectedDate = now
                                                enddatePicker.currentIndex = now.getMonth()
                                                enddatePicker.selectedYear = now.getFullYear()
                                                endDialog.visible = true
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

                                        
                                        Component.onCompleted: {
                                            var currentDate = new Date();
                                            enddateInput.text = formatDate(currentDate);
                                        }

                                    }
                                }
                                Rectangle {
                                    width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
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
                                            bottomMargin: 500
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
                                            var month = date.getMonth() + 1; 
                                            var day = date.getDate();
                                            var year = date.getFullYear();
                                            return month + '/' + day + '/' + year;
                                        }

                                        
                                        Component.onCompleted: {
                                            var currentDate = new Date();
                                            deadlineInput.text = formatDate(currentDate);
                                        }

                                    }
                                }
                                
                                Row {
                                    width: isDesktop() ? 430 : 700
                                    height: isDesktop() ? 25 : phoneLarg()?50:80
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
                                 Rectangle {
                                        width: parent.width
                                        height: 50
                                        anchors.left: parent.left
                                        anchors.topMargin: 20
                                        color: "#EFEFEF"
                                    

                                        Text {
                                            id: taskSavedMessage
                                            text: isTaskEdit ? "Task is Edit successfully!" : "Task could not be Edit!"
                                            color: isTaskEdit ? "green" : "red"
                                            visible: isTaskClicked
                                            font.pixelSize: isDesktop() ? 18 : 40
                                            horizontalAlignment: Text.AlignHCenter 
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

    Component.onCompleted: {
        fetch_tasks_lists()
        issearchHeader = false

    }
}

import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.7
import Ubuntu.Components 1.3 as Ubuntu

    

Item {
    width: parent.width
    height: parent.height

    property var timesheetListobject: []
    property bool isTimesheetEdit: false
    property bool isEditTimesheetClicked: false
    property bool edithasSubProject: false;
    property bool edithasSubTask: false;
    property int selectededitSubTaskId: 0
    property int editselectedTaskId: 0 
    property int selectededitSubProjectId: 0
    property int editselectedProjectId: 0
    property int selectededitquadrantId: 0
    property int selectedAccountUserId: 0


    ListModel {
        id: filteredTimesheetList
    }

    function timesheetlistData(query) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        
        timesheetListobject = [];
        filteredTimesheetList.clear();

        db.transaction(function (tx) {
            
            if(workpersonaSwitchState){
                var result = tx.executeSql('select * from account_analytic_line_app where account_id != 0 order by last_modified desc');
            }else{
                var result = tx.executeSql('SELECT * FROM account_analytic_line_app where account_id = 0');
            }
            
            for (var i = 0; i < result.rows.length; i++) { 
                var projectId = result.rows.item(i).project_id || 0;  
                var taskId = result.rows.item(i).task_id || 0;        
                
                var color_pallet = ''
                var projectName = ''
                if (result.rows.item(i).sub_project_id != 0) {
                    var project = tx.executeSql('select name, color_pallet from project_project_app where id = ?', [result.rows.item(i).sub_project_id]);
                    projectName = (project.rows.length > 0) ? project.rows.item(0).name : "";
                    color_pallet = (project.rows.length > 0) ? project.rows.item(0).color_pallet : "";
                } else {
                    var project = tx.executeSql('select name, color_pallet from project_project_app where id = ?', [projectId]);
                    projectName = (project.rows.length > 0) ? project.rows.item(0).name : "";
                    color_pallet = (project.rows.length > 0) ? project.rows.item(0).color_pallet : "";
                }
                
                var task = tx.executeSql('select name from project_task_app where id = ?', [taskId]);
                var taskName = (task.rows.length > 0) ? task.rows.item(0).name : "";
                
                var unitAmount = result.rows.item(i).unit_amount;
                var spentHoursDecimal = unitAmount ? unitAmount : "0";
                
                timesheetListobject.push({
                    'id': result.rows.item(i).id,  
                    'project_id': projectName,          
                    'task_id': taskName,
                    'color_pallet': color_pallet,
                    'name': result.rows.item(i).name || "",  
                    'spent_hours': spentHoursDecimal,   
                    'date': result.rows.item(i).record_date || ""  
                });

            }
        });
        for (var j = 0; j < timesheetListobject.length; j++) {
                    filteredTimesheetList.append({
                        id: timesheetListobject[j].id,
                        project_id: timesheetListobject[j].project_id,
                        task_id: timesheetListobject[j].task_id,
                        name: timesheetListobject[j].name,
                        color_pallet: timesheetListobject[j].color_pallet,
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
            
            if (entry.name.toLowerCase().includes(query.toLowerCase()) || 
                entry.project_id.toLowerCase().includes(query.toLowerCase()) || 
                entry.spent_hours.toLowerCase().includes(query.toLowerCase()) || 
                entry.task_id.toLowerCase().includes(query.toLowerCase()) ||
                entry.date.toLowerCase().includes(query.toLowerCase())  
                ){ 
                    filteredTimesheetList.append(entry);

            }
        }
    }

    


    function edittimesheetData(data){
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            tx.executeSql('UPDATE account_analytic_line_app SET \
                account_id = ?, record_date = ?, project_id = ?, task_id = ?, sub_project_id = ?, sub_task_id = ?, quadrant_id = ?,  \
                name = ?,  unit_amount = ?, last_modified = ? WHERE id = ?',
                [data.updatedAccount, data.updatedDate, data.updatedProject, 
                data.updatedTask,data.updatedsubProject,data.updatedsubTask, data.updatedquadrant, data.updatedDescription,
                data.updatedSpentHours, new Date().toISOString(), data.rowId]  
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
    
    Rectangle {
        width: parent.width
        height: parent.height
        color: "#ffffff"
        Column {
            spacing: 0
            anchors.fill: parent

            Rectangle {
                id:timesheetHeader
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
                    anchors.leftMargin: isDesktop()? 55 : -10 
                    anchors.right: parent.right
                    anchors.rightMargin: isDesktop()?15 : 20 

                    Rectangle {
                        id: header_tital
                        visible: !issearchHeadermain
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
                            text: "Timesheets"
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
                                    color: "transparent"  
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
                                    color: "transparent"  
                                }
                                contentItem: Ubuntu.Icon {
                                    name: "back"
                                }
                                onClicked: {
                                    issearchHeadermain = false
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
                                    filterTimesheetList(searchField.text)  
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
                                                    selectedId = model.id  
                                                    timesheetFlickable.edit_id= model.id; 
                                                    rightPanel.loadProjectData();  
                                                    rightPanel.visible = true  
                                                    isTimesheetEdit = false
                                                    isEditTimesheetClicked = false
                                            }
                                        }

                                        Column {
                                            spacing: 0
                                            anchors.fill: parent

                                            Row {
                                                width: parent.width
                                                height: isDesktop() ? 50 : 50
                                                spacing: 0  
                                                    Rectangle {
                                                        width: 10  
                                                        height: isDesktop()?79:97
                                                        anchors.top: parent.top
                                                        anchors.topMargin: 1
                                                        color: model.color_pallet
                                                    }
                                                Column {
                                                    spacing: 0
                                                    width: parent.width - 10  

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
                                                        Text {
                                                            text:  model.name.trim().split(/\s+/).join(" ")
                                                            id: name_id
                                                            font.pixelSize: isDesktop() ? 18 : 30
                                                            color: "#000000"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: date_id.right
                                                            anchors.leftMargin: 10
                                                            width: parent.width * 0.4
                                                            elide: Text.ElideRight
                                                        }
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
                                                    Row {
                                                        width: parent.width
                                                        height: isDesktop() ? 40 : 50
                                                        spacing: 20

                                                        
                                                        Text {
                                                            id: project_name
                                                            text:"Project: " + model.project_id
                                                            font.pixelSize: isDesktop() ? 18 : 26
                                                            color: notaddDataPro(model)
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: 10
                                                            width: parent.width * 0.4
                                                            elide: Text.ElideRight
                                                        }
                                                        Text {
                                                            text: "Tasks: " + model.task_id
                                                            font.pixelSize: isDesktop() ? 18 : 26
                                                            color: notaddDatatask(model)
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: project_name.right
                                                            anchors.leftMargin: 10
                                                            width: parent.width * 0.6
                                                            elide: Text.ElideRight
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
                                        var result = tx.executeSql('SELECT * FROM account_analytic_line_app WHERE account_id != 0 AND id = ?', [rowId]);
                                    }else{
                                        var result = tx.executeSql('SELECT * FROM account_analytic_line_app where account_id = 0 AND id = ?', [rowId] );
                                    }
                                    if (result.rows.length > 0) {
                                        var rowData = result.rows.item(0);
                                        var projectId = rowData.project_id || "";  
                                        var taskId = rowData.task_id || "";        
                                        var accountId = rowData.account_id || "";  
                                        var sub_pro_Id = rowData.sub_project_id != null ? rowData.sub_project_id || "":"";

                                        if(sub_pro_Id != 0){
                                        edithasSubProject = true
                                        var sub_project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?', [sub_pro_Id]);
                                        editsubProjectInput.text = sub_project.rows.length > 0 ? sub_project.rows.item(0).name || "" : "";
                                        selectededitSubProjectId = sub_pro_Id
                                        }else{
                                        edithasSubProject = false
                                        }

                                        var sub_taskId = rowData.sub_task_id != null ? rowData.sub_task_id || "":"";
                                        if(sub_taskId != 0){
                                        edithasSubTask = true
                                        var sub_task = tx.executeSql('SELECT name FROM project_task_app WHERE id = ?', [sub_taskId]);
                                        editsubTaskInput.text = sub_task.rows.length > 0 ? sub_task.rows.item(0).name || "" : "";
                                        selectededitSubTaskId = sub_taskId
                                        }else{
                                        edithasSubTask = false
                                        }

                                        var rowDate = new Date(rowData.record_date || new Date());  

                                        var project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?', [projectId]);
                                        var task = tx.executeSql('SELECT name FROM project_task_app WHERE id = ?', [taskId]);
                                        if(workpersonaSwitchState){
                                            var account = tx.executeSql('SELECT name FROM users WHERE id = ?', [accountId]);
                                        }
                                        
                                        
                                        editprojectInput.text = project.rows.length > 0 ? project.rows.item(0).name || "" : "";
                                        editselectedProjectId = projectId;
                                        if(workpersonaSwitchState){
                                            editaccountInput.text = account.rows.length > 0 ? account.rows.item(0).name || "" : "";
                                            selectedAccountUserId = accountId;
                                        }
                                        var formattedDate = formatDate(rowDate);  
                                        datetimeInput.text = formattedDate;

                                        editdescriptionInput.text = rowData.name || "";  
                                        edittaskInput.text = task.rows.length > 0 ? task.rows.item(0).name || "" : "";
                                        editselectedTaskId = taskId;

                                        editspenthoursManualInput.text = rowData.unit_amount || "";  
                                        selectededitquadrantId = rowData.quadrant_id
                                    }
                                });

                                function formatDate(date) {
                                    var month = date.getMonth() + 1;  
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
                                            selectedId = -1
                                            
                                        }
                                    }
                                    Button {
                                        id: rightButton
                                        
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.topMargin: 10
                                        width: isDesktop() ? 20 : 50
                                        height: isDesktop() ? 20 : 50
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
                                        var rowId = timesheetFlickable.edit_id;
                                            const editData = {
                                                updatedProject: editselectedProjectId ,
                                                updatedTask: editselectedTaskId,
                                                updatedAccount: selectedAccountUserId,
                                                updatedDescription: editdescriptionInput.text,
                                                updatedSpentHours: editspenthoursManualInput.text,
                                                updatedDate: datetimeInput.text,
                                                updatedsubProject: selectededitSubProjectId,
                                                updatedsubTask: selectededitSubTaskId,
                                                updatedquadrant: selectededitquadrantId,
                                                
                                                subtask: 0,
                                                rowId: rowId
                                            }
                                            if(editprojectInput.text && edittaskInput.text && workpersonaSwitchState?editaccountInput.text : true  && editspenthoursManualInput.text && editdescriptionInput.text){
                                                isTimesheetEdit = true
                                                isEditTimesheetClicked = true
                                                edittimesheetData(editData)
                                                filterTimesheetList(searchField.text)
                                                

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
                                    
                                    height: parent.height  
                                    contentHeight: timesheetedit.childrenRect.height + (isDesktop()?0:100)  
                                    anchors.fill: parent
                                    flickableDirection: Flickable.VerticalFlick  
                                    anchors.top: parent.top
                                    anchors.topMargin: isDesktop() ? 85 : phoneLarg()? 100 : 120
                                    
                                    clip: true
                                    Item {
                                        id: timesheetedit
                                        height: timesheetedit.childrenRect.height + 100
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.topMargin: isDesktop() ? 0 : phoneLarg()? 0 : 120
                                        Row {
                                            id: field_all_edit
                                            spacing: isDesktop() ? 100 : phoneLarg()? 260 :220
                                            anchors.verticalCenterOffset: -height * 1.5
                                            anchors.left: parent.left
                                            anchors.leftMargin: 23
                                            
                                            Component.onCompleted: {
                                                if (!isDesktop()) {
                                                    anchors.horizontalCenter = parent.horizontalCenter; 
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

                                                visible: edithasSubProject}
                                                Label { text: "Task" 
                                                width: 150
                                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                                font.pixelSize: isDesktop() ? 18 : 40}
                                                Label { text: "Sub Task" 
                                                width: 150
                                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                                font.pixelSize: isDesktop() ? 18 : 40
                                                visible: edithasSubTask}
                                                Label { text: "Description" 
                                                width: 150
                                                height: editdescriptionInput.height
                                                font.pixelSize: isDesktop() ? 18 : 40}
                                                // Label { text: "Quadrant" 
                                                // width: 150
                                                // height: isDesktop() ? 150 : phoneLarg()?320:300
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

                                                    
                                                    Rectangle {
                                                        width: parent.width
                                                        height: isDesktop() ? 1 : 2
                                                        color: "black"  
                                                        anchors.bottom: parent.bottom
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                    }

                                                    ListModel {
                                                        id: editaccountList
                                                        
                                                    }
                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        anchors.fill: parent
                                                        
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
                                                            width: editaccountInput.width  


                                                            Repeater {
                                                                model: editaccountList

                                                                MenuItem {
                                                                    width: parent.width
                                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                                                    property int editaccountId: model.id  
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
                                                                        edithasSubTask = false
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
                                                            var month = date.getMonth() + 1; 
                                                            var day = date.getDate();
                                                            var year = date.getFullYear();
                                                            return month + '/' + day + '/' + year;
                                                        }

                                                        
                                                        Component.onCompleted: {
                                                            var currentDate = new Date();
                                                            datetimeInput.text = formatDate(currentDate);
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
                                                        id: editprojectsListModel
                                                        
                                                    }

                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        anchors.fill: parent
                                                        
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
                                                                
                                                                editprojectsListModel.clear();
                                                                var result = fetch_projects(selectedAccountUserId);
                                                                for (var i = 0; i < result.length; i++) {
                                                                    editprojectsListModel.append({'id': result[i].id, 'name': result[i].name, 'projectkHasSubProject': result[i].projectkHasSubProject})
                                                                }
                                                                menu.open();

                                                            }
                                                        }

                                                        Menu {
                                                            id: menu
                                                            x: editprojectInput.x
                                                            y: editprojectInput.y + editprojectInput.height
                                                            width: editprojectInput.width  


                                                            Repeater {
                                                                model: editprojectsListModel

                                                                MenuItem {
                                                                    width: parent.width
                                                                    height: isDesktop() ? 40 : phoneLarg()?50:80
                                                                    property int editprojectId: model.id  
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
                                                                        editselectedTaskId = 0
                                                                        editsubTaskInput.text = ''
                                                                        selectededitSubTaskId = 0
                                                                        edithasSubTask = false
                                                                        editprojectInput.text = editprojectName
                                                                        editselectedProjectId = editprojectId
                                                                        selectedSubProjectId = 0
                                                                        edithasSubProject = model.projectkHasSubProject
                                                                        editsubProjectInput.text = ''
                                                                        selectededitSubProjectId = 0
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
                                                    visible: edithasSubProject
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
                                                        id: editsubProjectsListModel
                                                        
                                                    }

                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 :40
                                                        anchors.fill: parent
                                                        //anchors.margins: 5                                
                                                        id: editsubProjectInput
                                                        Text {
                                                            id: editsubProjectplaceholder
                                                            text: "Sub Project"                                            
                                                            font.pixelSize:isDesktop() ? 18 :40
                                                            color: "#aaa"
                                                            anchors.fill: parent
                                                            verticalAlignment: Text.AlignVCenter
                                                            
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                var sub_project_list = fetch_sub_project(editselectedProjectId);
                                                                editsubProjectsListModel.clear();
                                                                for (var i = 0; i < sub_project_list.length; i++) {
                                                                    editsubProjectsListModel.append({'id': sub_project_list[i].id, 'name': sub_project_list[i].name});
                                                                }
                                                                editsubProjectmenu.open();

                                                            }
                                                        }

                                                        Menu {
                                                            id: editsubProjectmenu
                                                            x: editsubProjectInput.x
                                                            y: editsubProjectInput.y + editsubProjectInput.height
                                                            width: editsubProjectInput.width  


                                                            Repeater {
                                                                model: editsubProjectsListModel

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
                                                                        edithasSubTask = false
                                                                        editsubProjectInput.text = projectName
                                                                        selectededitSubProjectId = projectId
                                                                        editsubProjectmenu.close()
                                                                    }
                                                                }
                                                            }
                                                        }

                                                        onTextChanged: {
                                                            if (editsubProjectInput.text.length > 0) {
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
                                                        
                                                    }
                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        anchors.fill: parent
                                                        
                                                        id: edittaskInput
                                                        
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
                                                                var tasks_list = fetch_tasks_list(editselectedProjectId, selectededitSubProjectId)
                                                                for (var i = 0; i < tasks_list.length; i++) {
                                                                    if(tasks_list[i].parent_id == 0){
                                                                        edittasksListModel.append({'id': tasks_list[i].id, 'name': tasks_list[i].name, 'taskHasSubTask': tasks_list[i].taskHasSubTask})
                                                                    }
                                                                }
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
                                                                    property int taskId: model.id  
                                                                    property string taskName: model.name || ''
                                                                    
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
                                                                        editselectedTaskId = taskId
                                                                        editsubTaskInput.text = ''
                                                                        selectededitSubTaskId = 0
                                                                        edithasSubTask = model.taskHasSubTask
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
                                                    visible: edithasSubTask

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
                                                        
                                                    }

                                                    TextInput {
                                                        width: parent.width
                                                        height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        anchors.fill: parent
                                                        
                                                        id: editsubTaskInput
                                                        visible: edithasSubTask
                                                        
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
                                                                var sub_tasks_list = fetch_sub_tasks(editselectedTaskId);
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
                                                                    property int subTaskId: model.id  
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
                                                                        selectededitSubTaskId = subTaskId
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
                                                    height: editdescriptionInput.height
                                                    color: "transparent"

                                                    
                                                    Rectangle {
                                                        width: parent.width
                                                        height: isDesktop() ? 1 : 2
                                                        color: "black"
                                                        anchors.bottom: parent.bottom
                                                    }

                                                    TextArea {
                                                        background: null 
                                                        padding: 0
                                                        color: "black"
                                                        wrapMode: TextArea.Wrap
                                                        id: editdescriptionInput
                                                        width: parent.width
                                                        // height: parent.height
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        clip: true   
                                                        anchors.left: parent.left
                                                        anchors.leftMargin: (!editdescriptionplaceholder.visible && !isDesktop()) ? -30 : 0               

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
                                                            editdescriptionplaceholder.visible = !focus && editdescriptionInput.text.length === 0;
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
                                                        font.pixelSize: isDesktop() ? 20 : 40
                                                        anchors.fill: parent
                                                        
                                                        id: editspenthoursManualInput
                                                        
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
                                                
                                            }
                                        }
                                        Column {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: field_all_edit.bottom
                                            anchors.topMargin: isDesktop() ? 20 : phoneLarg() ? 30 : 40
                                            spacing: isDesktop() ? 10 : phoneLarg() ? 15 : 20
                                            width: field_all_edit.width

                                            Label {
                                                text: "Select Priority Quadrant"
                                                font.pixelSize: isDesktop() ? 18 : phoneLarg() ? 40 : 40
                                                // anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            // Row for RadioButton 1 and RadioButton 2
                                            Row {
                                                spacing: isDesktop() ? 20 : phoneLarg() ? 5 : 10
                                                width: parent.width

                                                Column {
                                                    width: parent.width * 0.46 // Set dynamic width
                                                    Row {
                                                        spacing: 2  // Close spacing between RadioButton and text
                                                        RadioButton {
                                                            checked: selectededitquadrantId === 1
                                                            onClicked: selectededitquadrantId = 1
                                                        }
                                                        Text {
                                                            text: "Important, Urgent (1)"
                                                            font.pixelSize: isDesktop() ? 18 : phoneLarg() ? 30 : 30
                                                            anchors.verticalCenter: parent.verticalCenter
                                                        }
                                                    }
                                                }

                                                Column {
                                                    width: parent.width * 0.5
                                                    Row {
                                                        spacing: 2
                                                        RadioButton {
                                                            checked: selectededitquadrantId === 2
                                                            onClicked: selectededitquadrantId = 2
                                                        }
                                                        Text {
                                                            text: "Important, Not Urgent (2)"
                                                            font.pixelSize: isDesktop() ? 18 : phoneLarg() ? 30 : 30
                                                            anchors.verticalCenter: parent.verticalCenter
                                                        }
                                                    }
                                                }
                                            }

                                            // Row for RadioButton 3 and RadioButton 4
                                            Row {
                                                spacing: isDesktop() ? 20 : phoneLarg() ? 5 : 10
                                                width: parent.width

                                                Column {
                                                    width: parent.width * 0.46
                                                    Row {
                                                        spacing: 2
                                                        RadioButton {
                                                            checked: selectededitquadrantId === 3
                                                            onClicked: selectededitquadrantId = 3
                                                        }
                                                        Text {
                                                            text: "Not Important, Urgent (3)"
                                                            font.pixelSize: isDesktop() ? 18 : phoneLarg() ? 30 : 30
                                                            anchors.verticalCenter: parent.verticalCenter
                                                        }
                                                    }
                                                }

                                                Column {
                                                    width: parent.width * 0.5
                                                    Row {
                                                        spacing: 2
                                                        RadioButton {
                                                            checked: selectededitquadrantId === 4
                                                            onClicked: selectededitquadrantId = 4
                                                        }
                                                        Text {
                                                            text: "Not Important, Not Urgent (4)"
                                                            font.pixelSize: isDesktop() ? 18 : phoneLarg() ? 30 : 30
                                                            anchors.verticalCenter: parent.verticalCenter
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
                                                        horizontalAlignment: Text.AlignHCenter 
                                                        anchors.centerIn: parent

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
    }
    Component.onCompleted: {
        timesheetlistData();
    }
}

import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.7
import Ubuntu.Components 1.3 as Ubuntu

    

Item {
    width: parent.width
    height: parent.height
    property var filterprojectlistData: []
    property var listData: []
    property int currentRecordId: 0
    property bool issearchHeader: false


    function fetch_projects_list() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        filterprojectlistData = []
        
        db.transaction(function(tx) {
            if (workpersonaSwitchState) {
                var result = tx.executeSql('SELECT * FROM project_project_app where parent_id = 0 order by last_modified desc');
            } else {
                var result = tx.executeSql('SELECT * FROM project_project_app where account_id IS NULL');
            }
            for (var i = 0; i < result.rows.length; i++) {
                var task_total = tx.executeSql('SELECT id, COUNT(*) AS count FROM project_task_app WHERE account_id = ? AND project_id = ?', [result.rows.item(i).account_id, result.rows.item(i).id]);
                var plannedEndDate = result.rows.item(i).planned_end_date;
                if (typeof plannedEndDate !== 'string') {
                    plannedEndDate = String(plannedEndDate);
                }

                var children_list = [];
                var child_projects = tx.executeSql('select * from project_project_app where parent_id = ?', [result.rows.item(i).id]);

                for (var child = 0; child < child_projects.rows.length; child++) {

                    var childtask_total = tx.executeSql('SELECT id, COUNT(*) AS count FROM project_task_app WHERE account_id = ? AND project_id = ?', [child_projects.rows.item(child).account_id, child_projects.rows.item(child).id]);

                    var parent_project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?', [child_projects.rows.item(child).parent_id]);
                    var parentProject = parent_project.rows.length > 0 ? parent_project.rows.item(0).name || "" : "";
                    var childplannedEndDate = child_projects.rows.item(child).planned_end_date;
                    if (typeof childplannedEndDate !== 'string') {
                        childplannedEndDate = String(childplannedEndDate);
                    }

                    children_list.push({
                        id: child_projects.rows.item(child).id,
                        total_tasks: childtask_total.rows.item(0).count,
                        name: child_projects.rows.item(child).name,
                        favorites: child_projects.rows.item(child).favorites,
                        status: child_projects.rows.item(child).last_update_status,
                        allocated_hours: child_projects.rows.item(child).allocated_hours,
                        planned_end_date: childplannedEndDate,
                        parentProject: result.rows.item(i).name
                    });
                }

                listData.push({
                    id: result.rows.item(i).id,
                    total_tasks: task_total.rows.item(0).count,
                    name: result.rows.item(i).name,
                    favorites: result.rows.item(i).favorites,
                    status: result.rows.item(i).last_update_status,
                    allocated_hours: result.rows.item(i).allocated_hours,
                    planned_end_date: plannedEndDate,
                    children: children_list
                    
                });

                
                filterprojectlistData.push({
                    id: result.rows.item(i).id,
                    total_tasks: task_total.rows.item(0).count,
                    name: result.rows.item(i).name,
                    favorites: result.rows.item(i).favorites,
                    status: result.rows.item(i).last_update_status,
                    allocated_hours: result.rows.item(i).allocated_hours,
                    planned_end_date: plannedEndDate,
                    children: children_list
                    
                });

                projectListView.model = listData;  
            }
        });
    }
    
    function filterProjectList(query) {
        listData=[] 

            for (var i = 0; i < filterprojectlistData.length; i++) {
                var entry = filterprojectlistData[i];
                
                if (entry.name.toLowerCase().includes(query.toLowerCase()) ||
                    entry.status.toLowerCase().includes(query.toLowerCase()) ||
                    
                    (entry.allocated_hours.toString().includes(query)) ||
                    entry.planned_end_date.toLowerCase().includes(query.toLowerCase())
                    ) {
                    listData.push(entry);
                    projectListView.model = listData;

                }
            }
    }

    Rectangle {
        id:projectHeader
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
                    text: "Projects"
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
                        filterProjectList(searchField.text);  
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
                                id: projectListView
                                model: listData
                                delegate: Column {
                                    width: parent.width
                                    Rectangle{
                                        id: menRow
                                        width: parent.width
                                        height: isDesktop()?80:100 
                                        color: currentRecordId === modelData.id ? "#F5F5F5" : "#FFFFFF"  
                                        border.color: "#CCCCCC"
                                        border.width:isDesktop()? 1 : 2

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                currentRecordId = modelData.id;
                                                rightPanel.visible = true
                                                projectFlickable.edit_id= modelData.id; 
                                                rightPanel.loadprojectData();
                                            }
                                        }

                                        Row {
                                            width: parent.width
                                            height: isDesktop() ? 50 : 50
                                            spacing: 0  

                                            ToolButton {
                                                id: down_next
                                                width: isDesktop() ? 40 :70
                                                height: isDesktop() ? 78 : 97
                                                anchors.top: parent.top
                                                anchors.topMargin: 1
                                                background: Rectangle {
                                                    color: "transparent"  
                                                }
                                                contentItem: Ubuntu.Icon {
                                                    name: dataId.shown ? "down" : "next"
                                                }
                                                onClicked: {
                                                    onClicked:{
                                                        dataId.shown = !dataId.shown
                                                        
                                                        
                                                        
                                                        }
                                                }
                                            }
                                            Rectangle {
                                                width: 10  
                                                height: isDesktop() ? 78 : 97
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
                                                width: parent.width - (isDesktop() ? 50 :80)  
                                                spacing: 0

                                                Row {
                                                    width: parent.width
                                                    height: isDesktop() ? 40 : 50
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
                                                            source: modelData.favorites > 0 ? "images/star-active.svg" : "images/starinactive.svg" 
                                                            width: isDesktop() ? 20 : 30
                                                            height: isDesktop() ? 20 : 30
                                                            smooth: true  
                                                        }

                                                        Text {
                                                            text: "Project: " + modelData.name
                                                            
                                                            font.pixelSize: isDesktop() ? 20 : 30
                                                            color: "#000000"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            width: parent.width * 0.8  
                                                            elide: Text.ElideRight
                                                        }
                                                    }

                                                    Text {
                                                        text: " "
                                                        font.pixelSize: isDesktop() ? 18 : 26
                                                        color: "#000000"  
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.left: left_row.right
                                                        anchors.leftMargin: 10
                                                        width: parent.width * 0.4
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    Text {
                                                        text: modelData.status
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
                                                    height: isDesktop() ? 40 : 50  
                                                    spacing: 20

                                                    
                                                    Text {
                                                        id: enddate_id
                                                        text: "End Date: " + modelData.planned_end_date
                                                        font.pixelSize: isDesktop() ? 18 : 26
                                                        color: "#000000"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.left: parent.left
                                                        anchors.leftMargin: 10
                                                        width: parent.width * 0.4

                                                    }

                                                    
                                                    Text {
                                                        text: "Allocated Hours: " + modelData.allocated_hours
                                                        font.pixelSize: isDesktop() ? 18 : 26
                                                        color: "#000000"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.left: enddate_id.right
                                                        anchors.leftMargin: 10
                                                        width: parent.width * 0.4
                                                    }

                                                    
                                                    Text {
                                                        text: "(" + modelData.total_tasks + ") Tasks"
                                                        font.pixelSize: isDesktop() ? 18 : 26
                                                        color: "#000000"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.right: parent.right
                                                        horizontalAlignment: Text.AlignRight 
                                                        anchors.rightMargin: 10
                                                        width: parent.width * 0.3
                                                    }
                                                }
                                            }
                                        }

                                    }
                                    Repeater {
                                        model: modelData.children
                                        id: dataId
                                        property bool shown: false
                                        delegate:Rectangle{
                                            width: parent.width - (isDesktop() ?40 : 70)
                                            height: dataId.shown ?  isDesktop()?80:100 : 0
                                            color: currentRecordId === modelData.id ? "#F5F5F5" : "#FFFFFF"  
                                            border.color: "#CCCCCC"
                                            border.width:isDesktop()? 1 : 2
                                            id: paneSettingsList
                                            visible: height > 0
                                            anchors.left: parent.left
                                            anchors.leftMargin: isDesktop() ?40 : 70

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    currentRecordId = modelData.id;
                                                    rightPanel.visible = true
                                                    projectFlickable.edit_id= modelData.id; 
                                                    rightPanel.loadprojectData();
                                                }
                                            }

                                            Row {
                                                height: 50
                                                width: parent.width
                                                
                                                spacing: 0  
                                                
                                                Rectangle {
                                                    width: 10  
                                                    height: isDesktop() ? 78 : 97
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
                                                        height: isDesktop() ? 40 : 50
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
                                                                source: modelData.favorites > 0 ? "images/star-active.svg" : "images/starinactive.svg" 
                                                                width: isDesktop() ? 20 : 30
                                                                height: isDesktop() ? 20 : 30
                                                                smooth: true  
                                                            }

                                                            Text {
                                                                text: "Project: " + modelData.name
                                                                
                                                                font.pixelSize: isDesktop() ? 20 : 30
                                                                color: "#000000"
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                width: parent.width * 0.8  
                                                                elide: Text.ElideRight
                                                            }
                                                        }

                                                        
                                                        Text {
                                                            text: modelData.parentProject
                                                            font.pixelSize: isDesktop() ? 18 : 26
                                                            color: "#000000"  
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: left_row.right
                                                            anchors.leftMargin: 10
                                                            width: parent.width * 0.4
                                                            elide: Text.ElideRight
                                                        }

                                                        
                                                        Text {
                                                            text: modelData.status
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
                                                        height: isDesktop() ? 40 : 50  
                                                        spacing: 20

                                                        
                                                        Text {
                                                            id: enddate_id
                                                            text: "End Date: " + modelData.planned_end_date
                                                            font.pixelSize: isDesktop() ? 18 : 26
                                                            color: "#000000"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: 10
                                                            width: parent.width * 0.4

                                                        }

                                                        
                                                        Text {
                                                            text: "Allocated Hours: " + modelData.allocated_hours
                                                            font.pixelSize: isDesktop() ? 18 : 26
                                                            color: "#000000"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.left: enddate_id.right
                                                            anchors.leftMargin: 10
                                                            width: parent.width * 0.4
                                                        }

                                                        
                                                        Text {
                                                            text: "(" + modelData.total_tasks + ") Tasks"
                                                            font.pixelSize: isDesktop() ? 18 : 26
                                                            color: "#000000"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.right: parent.right
                                                            horizontalAlignment: Text.AlignRight 
                                                            anchors.rightMargin: 10
                                                            width: parent.width * 0.3
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
                                        
                                        if(workpersonaSwitchState){
                                            var account = tx.executeSql('SELECT name FROM users WHERE id = ?', [accountId]);
                                        }
                                        
                                        if(workpersonaSwitchState){
                                            accountInput.text = account.rows.length > 0 ? account.rows.item(0).name || "" : "";
                                        }
                                        nameInput.text = rowData.name
                                        allocatedhoursInput.text = rowData.allocated_hours
                                        parentProjectInput.text = parent_project.rows.length > 0 ? parent_project.rows.item(0).name || "" : "";
                                        img_star.selectedPriority = rowData.favorites || 0; 
                                        descriptionProject.text = rowData.description
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
                            }

                            Flickable {
                                id: flickableContainerProject
                                width: parent.width
                                
                                height: parent.height  
                                contentHeight: projectItemedit.childrenRect.height + (isDesktop()?0:100)  
                                anchors.fill: parent
                                flickableDirection: Flickable.VerticalFlick  
                                anchors.top: parent.top
                                anchors.topMargin: isDesktop() ? 85 : phoneLarg()? 100 : 120
                                
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
                                                anchors.horizontalCenter = parent.horizontalCenter; 
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
                                            Label { text: "Description" 
                                            width: 150
                                            height: descriptionProject.height
                                            font.pixelSize: isDesktop() ? 18 : 40
                                            }
                                        }
                                        Column {
                                            spacing: isDesktop() ? 20 : 40
                                            
                                            Rectangle {
                                                width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
                                                height: isDesktop() ? 25 : phoneLarg()?50:80
                                                color: "transparent"

                                                
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

                                                    onTextChanged: {
                                                        if (startDateInput.text.length > 0) {
                                                            startDateplaceholder.visible = false
                                                        } else {
                                                            startDateplaceholder.visible = true
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
                                                    onTextChanged: {
                                                        if (endDateInput.text.length > 0) {
                                                            endDateplaceholder.visible = false
                                                        } else {
                                                            endDateplaceholder.visible = true
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
                                                        endDateInput.text = formatDate(currentDate);
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
                                                    width:  parent.width
                                                    height: isDesktop() ? 1 : 2
                                                    color: "black"  
                                                    anchors.bottom: parent.bottom
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                }

                                                ListModel {
                                                    id: parentProject
                                                    
                                                }

                                                TextInput {
                                                    width: parent.width
                                                    height: parent.height
                                                    font.pixelSize: isDesktop() ? 18 : 40
                                                    anchors.fill: parent
                                                    
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
                                                    }

                                                    Menu {
                                                        id: parentProjectmenu
                                                        x: parentProjectInput.x
                                                        y: parentProjectInput.y + parentProjectInput.height
                                                        width: parentProjectInput.width  


                                                        Repeater {
                                                            model: parentProject

                                                            MenuItem {
                                                                width: parent.width
                                                                height: isDesktop() ? 40 : phoneLarg()?50:80
                                                                property int parentProjectId: model.id  
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
                                                                    parentProjectInput.text = parentProjectName
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
                                                    
                                                    id: allocatedhoursInput
                                                    
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
                                                spacing: 5  
                                                property int selectedPriority: 0  

                                                Repeater {
                                                    model: 1  
                                                    delegate: Item {
                                                        width: isDesktop() ? 30 : 50  
                                                        height: isDesktop() ? 30 : 50

                                                        Image {
                                                            id: starImage
                                                            source: (index < img_star.selectedPriority) ? "images/star-active.svg" : "images/starinactive.svg"  
                                                            anchors.fill: parent
                                                            smooth: true  
                                                        }
                                                    }
                                                }
                                            }
                                            Rectangle {
                                                width:  parent.width - (!isDesktop()? phoneLarg()? 0:50:0)
                                                height: descriptionProject.height
                                                color: "transparent"

                                                
                                                Rectangle {
                                                    width:  parent.width
                                                    height: isDesktop() ? 1 : 2
                                                    color: "black"
                                                    anchors.bottom: parent.bottom
                                                }

                                                TextArea {
                                                    background: null 
                                                    padding: 0
                                                    color: "black"
                                                    wrapMode: TextArea.Wrap 
                                                    id: descriptionProject
                                                    width: parent.width
                                                    
                                                    font.pixelSize: isDesktop() ? 18 : 40
                                                    readOnly: true
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: (!descriptionProjectPlaceholder.visible && !isDesktop()) ? -30 : 0

                                                    Text {
                                                        id: descriptionProjectPlaceholder
                                                        text: "Description"
                                                        font.pixelSize: isDesktop() ? 18 : 40
                                                        color: "#aaa"
                                                        anchors.fill: parent
                                                        verticalAlignment: Text.AlignVCenter
                                                        visible: descriptionProject.text.length === 0

                                                    }

                                                    onTextChanged: {
                                                        descriptionProjectPlaceholder.visible = !focus &&  descriptionProject.text.length === 0;
                                                    }
                                                    onFocusChanged: {
                                                            descriptionProjectPlaceholder.visible = !focus && descriptionProject.text.length === 0;
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
        fetch_projects_list()
        issearchHeader = false
    }
}

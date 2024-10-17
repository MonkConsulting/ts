import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.7
    

Item {
    width: parent.width
    height: parent.height
    property var filterprojectlistData: []
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

                projectsListModel.append({'id': result.rows.item(i).id, 'total_tasks': task_total.rows.item(0).count, 'name': result.rows.item(i).name, 'allocated_hours': result.rows.item(i).allocated_hours, 'planned_end_date': result.rows.item(i).planned_end_date})
                filterprojectlistData.push({'id': result.rows.item(i).id, 'total_tasks': task_total.rows.item(0).count, 'name': result.rows.item(i).name, 'allocated_hours': result.rows.item(i).allocated_hours, 'planned_end_date': result.rows.item(i).planned_end_date})
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

    function isDesktop() {
        if(Screen.width > 1200){
            return true;
        }else{
            return false;
        }
    }

    ListModel {
        id: projectsListModel
    }

    Rectangle {
        anchors.fill: parent
        anchors.top: parent.top
        anchors.topMargin: isDesktop() ? 80 : 120
        anchors.left: parent.left
        anchors.leftMargin: isDesktop()?70 : 20
        anchors.rightMargin: 20
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
            anchors.leftMargin: isDesktop() ? 20 : 10
            anchors.right: parent.right  // Float the search field to the right
            width: parent.width

            // Label on the left side
            Label {
                text: "Projects"
                font.pixelSize: isDesktop() ? 20 : 40   
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                font.bold: true
                color:"#121944"
                width: parent.width * (isDesktop() ? 0.8 :0.5)
            }

            // Search field on the right side
            TextField {
                id: searchField
                placeholderText: "Search..."
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: parent.width * (isDesktop() ? 0.2 :0.5)
                onTextChanged: {
                    filterProjectList(searchField.text);  // Call the filter function when the text changes
                }
            }
        }

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
                id: flickableArea
                anchors.fill: parent
                contentHeight: column.height 
                clip: true 

                Column {
                    id: column
                    width: parent.width
                    spacing: 0
                    
                    Repeater {
                        model: projectsListModel
                        delegate: Rectangle {
                            width: parent.width
                            height: isDesktop()?80:100 
                            color: "#FFFFFF"
                            border.color: "#CCCCCC"
                            border.width:isDesktop()? 1 : 2
                            
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
                                    
                                    Rectangle {
                                        width: 40
                                        height: 40
                                        color: "transparent"
                                        anchors.right: parent.right

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                console.log("More options clicked for Project " + (index + 1));
                                            }
                                            
                                            Text {
                                                text: "⋮"
                                                font.pixelSize: isDesktop()? 24:35
                                                color: "#000000"
                                                anchors.centerIn: parent
                                            }
                                        }
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
                                        text: model.allocated_hours // Dynamic allocated status
                                        font.pixelSize: isDesktop()? 18 :26
                                        color: "#4CAF50" // Green for allocated status
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter // Center in this row
                                    }

                                    // Separator Status
                                    Text {
                                        text: model.planned_end_date // Dynamic separator
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
        }}
    }

    Component.onCompleted: {
        // Initialization code if needed
        console.log(workpersonaSwitchState,"/////////////++++++++")
        fetch_projects_list()
    }
}

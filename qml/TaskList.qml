import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.7

Item {
    width: parent.width
    height: parent.height
    property var filtertasklistData: []


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
    function isDesktop() {
        if(Screen.width > 1200){
            return true;
        }else{
            return false;
        }
    }

    ListModel {
        id: tasksListModel
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
            anchors.top: parent.top  
            anchors.topMargin: isDesktop() ? 20 : 80
            anchors.left: parent.left
            anchors.leftMargin: isDesktop() ? 20 : 10
            anchors.right: parent.right  
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
                id: flickableArea
                anchors.fill: parent
                contentHeight: column.height 
                clip: true 

                Column {
                    id: column
                    width: parent.width
                    spacing: 0
                    Repeater {
                        model: tasksListModel
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

                                    Text {
                                        text: "Sep " + (index + 1)
                                        font.pixelSize: isDesktop()? 18:26
                                        color: "#4CAF50"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter
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
        fetch_tasks_list()
    }
}

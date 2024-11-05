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
import io.thp.pyotherside 1.4
import Ubuntu.Components 1.3 as Ubuntu


Item {
    width: parent.width
    height: parent.height
    property var optionList: []
    property bool isTextInputVisible: false
    property bool isTextMenuVisible: false
    property bool isValidUrl: true
    property bool isValidLogin: true
    property bool isValidAccount: true
    property bool isPasswordVisible: false
    property var accountsList: []
    property bool loading: false
    property string loadingMessage: ""
    property bool issearchHeader: false


    // Python {
    //     id: python

    //     Component.onCompleted: {
    //         addImportPath(Qt.resolvedUrl('../src/'));
    //         importModule_sync("backend");
    //     }

    //     onError: {
    //         console.log('Python error: ' + traceback);
    //     }
    // }



 


    function queryData() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM users');
            console.log("Database Query Results:");
            accountsList = [];
            for (var i = 0; i < result.rows.length; i++) {
                accountsList.push({'user_id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'link': result.rows.item(i).link, 'database': result.rows.item(i).database, 'username': result.rows.item(i).username})
            }
            recordModel.clear();
            for (var i = 0; i < accountsList.length; i++) {
                recordModel.append(accountsList[i]);
            }
        });
    }
    function filtersynList(query) {
        recordModel.clear(); // Clear existing data in the model

            for (var i = 0; i < accountsList.length; i++) {
                var entry = accountsList[i];
                if (entry.name.toLowerCase().includes(query.toLowerCase()) 
                    ) {
                    recordModel.append(entry);

                }
            }
    }



    function deleteData(recordId) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            var users = tx.executeSql('DELETE FROM users where id =' + parseInt(recordId));


            queryData()
        });
    }

    // function deteleAllData(id){
    //     var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

    //     db.transaction(function(tx) {
    //     var users = tx.executeSql('DELETE FROM users where id =' + parseInt(id));
    //         tx.executeSql('DELETE FROM project_project_app WHERE account_id = ?', [parseInt(id)]);
    //         tx.executeSql('DELETE FROM project_task_app WHERE account_id = ?', [parseInt(id)]);
    //         tx.executeSql('DELETE FROM account_analytic_line_app WHERE account_id = ?', [parseInt(id)]);
    //         tx.executeSql('DELETE FROM mail_activity_type_app WHERE account_id = ?', [parseInt(id)]);
    //         tx.executeSql('DELETE FROM res_users_app WHERE account_id = ?', [parseInt(id)]);
    //         tx.executeSql('DELETE FROM mail_activity_app WHERE account_id = ?', [parseInt(id)]);
    //            queryData()
    //            timesheetlistData()
    //     });
        
    // }
    // function moveDataPersonal(id){
    //     var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

    //     db.transaction(function(tx) {
    //         tx.executeSql('UPDATE project_project_app SET account_id = ? WHERE account_id = ?', [false, parseInt(id)]);


    //         queryData()
    //     });
    // }
    ListModel {
        id: recordModel
    }
    Rectangle {
        id:setting_header
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
            anchors.leftMargin: isDesktop()? issearchHeader? 55 : 70 :issearchHeader ? -10 : 15
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

                Label {
                    text: "Accounts"
                    font.pixelSize: isDesktop() ? 20 : 40
                    anchors.verticalCenter: parent.verticalCenter
                    // anchors.right: ToolButton.right
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
                        width: isDesktop() ? 40 : 80
                        height: isDesktop() ? 35 : 80
                        background: Rectangle {
                            color: "transparent"  // Transparent button background
                        }
                        contentItem: Ubuntu.Icon {
                            name: "add" 
                        }
                        onClicked: {
                            goToLogin()  // Call function to create new activity
                        }
                    }
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
                            filtersynList(searchField.text);  
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

        // Search Row
        // Row {
        //     id: searchId
        //     width: parent.width
        //     anchors.top: parent.top
        //     anchors.topMargin: isDesktop() ? 10 : 80
        //     spacing: isDesktop() ? 20 : 30  
        //     anchors.horizontalCenter: parent.horizontalCenter  
            
        //     Label {
        //         text: "Accounts"
        //         font.pixelSize: isDesktop() ? 20 : 40   
        //         anchors.verticalCenter: parent.verticalCenter
        //         font.bold: true
        //         color: "#121944"
        //     }
            
            
        //     TextField {
        //         id: searchField
        //         placeholderText: "Search..."
        //         anchors.verticalCenter: parent.verticalCenter
        //         anchors.right: parent.right
        //         anchors.rightMargin: btn_id.width + 10
        //         width: parent.width * (isDesktop() ? 0.2 : 0.4)  
        //         onTextChanged: {
        //             filtersynList(searchField.text);  
        //         }
        //     }
            
        //     Button {
        //         id: btn_id
        //         width: isDesktop() ? 120 : 220
        //         height: isDesktop() ? 40 : 80
        //         anchors.verticalCenter: parent.verticalCenter
        //         anchors.right: parent.right
        //         background: Rectangle {
        //             color: "#121944"
        //             radius: isDesktop() ? 5 : 10
        //             border.color: "#87ceeb"
        //             border.width: 2
        //             anchors.fill: parent
        //         }
        //         contentItem: Text {
        //             text: " + "
        //             color: "#ffffff"
        //             font.pixelSize: isDesktop() ? 20 : 40
        //             horizontalAlignment: Text.AlignHCenter
        //             verticalAlignment: Text.AlignVCenter
        //         }
        //         onClicked: {
        //             goToLogin()  // Call function to create new activity
        //         }
        //     }
        // }
        Rectangle {
            // spacing: 0
            anchors.fill: parent
            anchors.top: searchId.bottom  
            anchors.topMargin: isDesktop() ? 68 : 170
            border.color: "#CCCCCC"
            border.width: isDesktop() ? 1 : 2

            Flickable {
                id: listView
                anchors.fill: parent
                width: parent.width
                contentHeight: column.height
                clip: true


                Column {
                    id: column
                    width: parent.width
                    spacing: 0

                    Repeater {
                        model: recordModel
                        delegate: Rectangle {
                            width:  parent.width
                            height: isDesktop() ? 80 : 130
                            // border.color: "#000000"87ceeb
                            color: "#FFFFFF"  // Change color only for selected row
                            border.color: "#CCCCCC"
                            border.width: isDesktop()? 1 : 2
                            // radius: 10
                           
                            Column {
                                spacing: 0
                                anchors.fill: parent 

                                Row {
                                    width: parent.width
                                    height: isDesktop()? 80 :130 
                                    spacing: 20 
                                    
                                     Rectangle {
                                        id: imgmodulename
                                        width: isDesktop() ? 50 : 90
                                        height: isDesktop() ? 50 : 90
                                        color: "#0078d4"
                                        radius: 80
                                        border.color: "#0056a0"
                                        border.width: 2
                                        anchors.rightMargin: 10
                                        
                                        anchors.verticalCenter:  parent.verticalCenter 
                                        anchors.left: parent.left 
                                        anchors.leftMargin:  10 // Optional, to add some space from the right edge

                                        
                                        Text {
                                            text: model.name.charAt(0).toUpperCase() // Capitalize the first letter
                                            color: "#fff"
                                            anchors.centerIn: parent
                                            font.pixelSize: isDesktop() ? 20 : 40
                                        }
                                    }

                                    // Vertical layout for text and delete icon
                                    Column {
                                        spacing: 5 
                                        width: parent.width - 280 // Adjust width to account for the circle and spacing
                                        anchors.centerIn:  parent  // Apply centerIn only for desktop



                                        // Name
                                        Text {
                                            text: model.name
                                            font.pixelSize: isDesktop() ? 20 : 40
                                            color: "#000"
                                            elide: Text.ElideRight
                                        }

                                        // Link
                                        Text {
                                            text: (model.link.length > 40) ? model.link.substring(0, 40) + "..." : model.link
                                            font.pixelSize: isDesktop() ? 18 : 30
                                            color: "#0078d4"
                                            elide: Text.ElideNone  // Disable default elide since we're handling it manually
                                        }
                                    }

                                    Button {
                                        
                                        width: isDesktop() ? 40 : 90
                                        height: isDesktop() ? 40 : 90
                                        // anchors.centerIn: isDesktop() ? parent : undefined  // Apply centerIn only for desktop

                                        background: Rectangle {
                                            color: "transparent"
                                            radius: 10
                                            border.color: "transparent"
                                        }
                                        Image {
                                            source: "images/delete.png"
                                            anchors.fill: parent
                                            smooth: true
                                        }
                                        anchors.right:  parent.right  // This anchors the button to the right
                                        anchors.rightMargin:  20  // Optional, to add some space from the right edge
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: {
                                            // deleteDialog.open()
                                            logInPage(model.user_id)
                                            // passwordDialog.open()
                                            deleteData(model.user_id)
                                            recordModel.remove(index)
                                        }
                                    }
                                    // Dialog {
                                    //     id: deleteDialog
                                    //     title: "Confirmation"
                                    //      x: (parent.width - width) / 2
                                    //      y: -150
                                    //     //  height: isDesktop()?260:500
                                    //     standardButtons: Dialog.Ok | Dialog.Cancel

                                    //     contentItem: Column {
                                    //         spacing: isDesktop() ? 10 : 10  // Increase spacing for desktop
                                    //         padding: isDesktop() ? 10 : 20  // Increase padding for desktop
                                    //             Text {
                                    //                 text: "Are you sure you want to delete this data?"  // Confirmation message
                                    //                 font.pixelSize: isDesktop() ? 16 : 20
                                    //                 horizontalAlignment: Text.AlignHCenter
                                    //                 wrapMode: Text.WordWrap
                                    //             }
                                    //     }

                                    //     onAccepted: {
                                    //         // deteleAllData(model.user_id)
                                    //         logInPage(model.user_id)
                                    //         // passwordDialog.open()
                                    //         deleteData(model.user_id)
                                    //         recordModel.remove(index) // Remove the record
                                    //         deleteDialog.close()  // Close the dialog
                                    //     }

                                    //     onRejected: {
                                    //         console.log("Dialog cancelled")
                                    //     }
                                    // }
                                }
                            }
                        }
                    }
                }
            }
            Item {
                id: loader
                visible: loading // Show loader based on loading state
                // anchors.centerIn: parent

                Rectangle {
                    width: Screen.width
                    height: Screen.height
                    color: "lightgray"
                    radius: 10
                    opacity: 0.8
                    Text {
                        anchors.centerIn: parent
                        text: loadingMessage
                        font.pixelSize: 50
                    }
                }
            }

        }
    }

    Component.onCompleted: {
        queryData();
        issearchHeader = false
    }

    signal logInPage(string Accountuser_id)
    signal goToLogin()
    signal backPage()
}

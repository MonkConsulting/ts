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

Item {
    width: Screen.width
    height: Screen.height
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



    function deleteData(recordId) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            var result = tx.executeSql('DELETE FROM users where id =' + parseInt(recordId));
        });
    }
    function isDesktop() {
        if(Screen.width > 1200){
            return true;
        }else{
            return false;
        }
    }

    Rectangle {
        width: Screen.width
        height: Screen.height
        color: "#121944"
        anchors.centerIn: parent

        Image {
            id: logo
            source: "images/timesheets_large_logo.png" // Path to your logo image
            width: isDesktop() ? 200 : 300
            height: isDesktop() ? 200 : 300
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 20
        }
        Label {
            anchors.top: logo.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: 'Choose an Account'
            font.pixelSize: isDesktop() ? 30 : 60
            color: "#fff"
            id: chooseAccountLabel
            anchors.topMargin: 20
        }

        Rectangle {
            // width: parent.width
            Component.onCompleted: {
                if (!isDesktop()) {
                    height: 80
                }
            }
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: isDesktop() ? 60 : 100
            anchors.leftMargin: isDesktop() ? 60 : 30
            // anchors.right: parent.right
            Button {
                id: backButton
                // width: 150
                // height: 130
                Component.onCompleted: {
                if (!isDesktop()) {
                        height: 130
                    }
                }
                anchors.verticalCenter: parent.verticalCenter

                background: Rectangle {
                    color: "#121944"
                    border.color: "#121944"
                }
                // Hamburger Icon
                Label {
                    text: ""
                    font.pixelSize: isDesktop() ? 20 : 40
                    color: "#fff"
                    anchors.centerIn: parent
                }
                // onClicked: backPage()
            }
            
        }

        Rectangle {
            // width: parent.width
            Component.onCompleted: {
                if (!isDesktop()) {
                    height: 80
                }
            }
            // height: 80
            anchors.top: parent.top
            // anchors.left: parent.left
            anchors.topMargin: isDesktop() ? 60 : 100
            anchors.rightMargin: isDesktop() ? 180 : 250
            anchors.right: parent.right
            Button {
                id: addNewAccountButton
                width: isDesktop() ? 150 : 220  // Set proper width based on device
                height: isDesktop() ? 20 : 45
                anchors.verticalCenter: parent.verticalCenter

                background: Rectangle {
                    color: "#121944"
                    border.color: "#121944"
                }
                // Hamburger Icon
                Label {
                    text: "Add Account"
                    font.pixelSize: isDesktop() ? 20 : 40
                    color: "#fff"
                    anchors.centerIn: parent
                }
                onClicked: goToLogin()
            }
        }

        ListModel {
            id: recordModel
        }

        ListView {
            id: listView
            anchors.fill: parent
            // anchors.margins: 20
            anchors.topMargin: isDesktop() ? 350 : 450
            anchors.centerIn: parent
            anchors.top: chooseAccountLabel.bottom
            model: recordModel
            spacing: 10
            bottomMargin: isDesktop() ? 50 : 0

            delegate: Item {
                width: parent.width
                height: isDesktop() ? 70 : 200
                Rectangle {
                    width: parent.width - isDesktop() ? 700 : 400 // Adjust width for margins
                    height: isDesktop() ? 70 : 190
                    anchors.centerIn: parent
                    color: "#fff"
                    border.color: "#ccc"
                    radius: 5
                    border.width: 1

                    Row {
                        spacing: 10
                        anchors.fill: parent
                        anchors.margins: isDesktop() ? 2 : 20

                        // Circle with the first character
                        Rectangle {
                            id: imgmodulename
                            width: isDesktop() ? 50 : 150
                            height: isDesktop() ? 50 : 150
                            color: "#0078d4"
                            radius: 80
                            border.color: "#0056a0"
                            border.width: 2
                            anchors.rightMargin: 10
                            
                            anchors.verticalCenter: isDesktop() ? parent.verticalCenter : 0
                            anchors.left: isDesktop() ? parent.left : 0
                            anchors.leftMargin: isDesktop() ? 10 : 0 // Optional, to add some space from the right edge

                            
                            Text {
                                text: model.name[0]
                                color: "#fff"
                                anchors.centerIn: parent
                                font.pixelSize: isDesktop() ? 20 : 40
                            }
                        }

                        // Vertical layout for text and delete icon
                        Column {
                            spacing: isDesktop() ? 5 : 20
                            width: parent.width - 280 // Adjust width to account for the circle and spacing
                            anchors.centerIn: isDesktop() ? parent : 0  // Apply centerIn only for desktop



                            // Name
                            Text {
                                text: model.name
                                font.pixelSize: isDesktop() ? 20 : 40
                                color: "#000"
                                elide: Text.ElideRight
                            }

                            // Link
                           Text {
                                text: (model.link.length > 20) ? model.link.substring(0, 20) + "..." : model.link
                                font.pixelSize: isDesktop() ? 18 : 30
                                color: "#0078d4"
                                elide: Text.ElideNone  // Disable default elide since we're handling it manually
                            }
                        }

                        // Delete icon
                        Button {
                            
                            width: isDesktop() ? 40 : 100
                            height: isDesktop() ? 40 : 100
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
                            anchors.right: isDesktop() ? parent.right : 0 // This anchors the button to the right
                            anchors.rightMargin: isDesktop() ? 10 : 0 // Optional, to add some space from the right edge
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                logInPage(model.user_id)
                                // passwordDialog.open()
                                deleteData(model.user_id)
                                recordModel.remove(index)
                            }
                        }
                        // Dialog {
                        //     id: passwordDialog
                        //     title: "Enter Password"
                        //     standardButtons: Dialog.Ok | Dialog.Cancel

                        //     contentItem: Column {
                        //         spacing: 10
                        //         padding: 20

                        //         TextField {
                        //             id: passwordInput
                        //             placeholderText: "Password"
                        //             echoMode: TextInput.Password // This hides the input
                        //         }
                        //     }

                        //     onAccepted: {
                        //         loading = true; // Start loading
                        //         loadingMessage = 'Synchronization for ' + model.name + '!' 
                        //         // timer.start()
                        //         python.call("backend.fetch_projects", [model.link, model.username, passwordInput.text, {'isTextInputVisible': true, 'input_text': model.database}] , function(projects) {
                        //             create_projects(projects, model.user_id);
                        //             python.call("backend.fetch_tasks", [model.link, model.username, passwordInput.text, {'isTextInputVisible': true, 'input_text': model.database}], function(tasks) {
                        //                 create_tasks(tasks, model.user_id);
                        //                 loading = false; // Stop loading
                        //                 passwordInput.text = ""
                        //                 passwordDialog.close();
                        //             })
                        //         })
                        //     }

                        //     onRejected: {
                        //         console.log("Dialog cancelled")
                        //     }
                        // }
                        // Timer {
                        //     id: timer
                        //     interval: 2000  // 2 seconds delay
                        //     running: false
                        //     repeat: false

                        //     onTriggered: {
                        //         // Here you can check the password validity
                        //         console.log("Password entered: " + passwordInput.text);
                        //         loading = false; // Stop loading
                        //         passwordInput.text = ""
                        //         passwordDialog.close(); // Close the dialog after processing
                        //     }
                        // }
                        
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

    Component.onCompleted: {
        queryData();
    }

    signal logInPage(string Accountuser_id)
    signal goToLogin()
    signal backPage()
}

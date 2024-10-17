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
// import Qt.labs.platform 1.0

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
    property string user_name: ""
    property string account_name: ""
    property string selected_database: ""
    property string selected_link: ""
    property int courant_userid: 0

    function initializeDatabase() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            // Create a table if it doesn't exist
            tx.executeSql('CREATE TABLE IF NOT EXISTS users (\
                id INTEGER PRIMARY KEY AUTOINCREMENT,\
                name TEXT NOT NULL,\
                link TEXT NOT NULL,\
                database TEXT NOT NULL,\
                username TEXT NOT NULL\
            )');
            
            tx.executeSql('CREATE TABLE IF NOT EXISTS tasksLists (\
                id INTEGER PRIMARY KEY AUTOINCREMENT,\
                description TEXT NOT NULL,\
                project_id INTEGER NOT NULL,\
                task_id INTEGER NOT NULL,\
                date TEXT NOT NULL,\
                spenthours TEXT NOT NULL,\
                user_id INTEGER NOT NULL,\
                user_name TEXT NOT NULL,\
                FOREIGN KEY (user_id) REFERENCES users(id)\
            )');
            tx.executeSql('delete from tasksLists');
            tx.executeSql('drop table tasksLists');

        });
    }

    function insertData(name, link, database, username) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT id, COUNT(*) AS count FROM users WHERE link = ? AND database = ? AND username = ?', [link, database, username]);

            if (result.rows.item(0).count === 0) {
                tx.executeSql('INSERT INTO users (name, link, database, username) VALUES (?, ?, ?, ?)', [name, link, database, username]);
                var newResult = tx.executeSql('SELECT id FROM users WHERE link = ? AND database = ? AND username = ?', [link, database, username]);
                courant_userid = newResult.rows.item(0).id;
            } else {
                courant_userid = result.rows.item(0).id;
            }
        });
    }

    function queryData() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM users');
            console.log("Database Query Results:");
            accountsList = [];
            for (var i = 0; i < result.rows.length; i++) {
                accountsList.push({'user_id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'link': result.rows.item(i).link, 'database': result.rows.item(i).database, 'username': result.rows.item(i).username})
            }
        });
    }
    function isDesktop() {
        if(Screen.width > 1200){
            return true;
        }else{
            return false;
        }
    }
   
    // Login form components
    Rectangle {
        width: Screen.width
        height: Screen.height
        color: "#121944"
        anchors.centerIn: parent

        Image {
            id: logo
            source: "images/timesheets_large_logo.png" // Path to your logo image
            width: isDesktop() ? 200 : 500
            height: isDesktop() ? 200 : 500
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 20
        }

        Column {
            spacing: 10
            anchors.top: logo.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 20

            ListModel {
                id: accountsListModel
                // Example data
            }


            TextField {
                id: manageAccountInput
                placeholderText: "Select Account"
                anchors.horizontalCenter: parent.horizontalCenter
                width: isDesktop() ? 500 : 1000
                visible: accountsList.length == 0
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        queryData();
                        accountsListModel.clear();
                        for (var i = 0; i < accountsList.length; i++) {
                            accountsListModel.append(accountsList[i]);
                        }
                        accountsListModel.append({'name': 'Add New account', 'user_id': false})
                        menuManageAccounts.open(); // Open the menu after fetching options
                    }
                }
                Menu {
                    id: menuManageAccounts
                    x: manageAccountInput.x
                    y: manageAccountInput.y
                    width: manageAccountInput.width

                    Repeater {
                        model: accountsListModel

                        MenuItem {
                            width: parent.width
                            height: isDesktop() ? 50 : 80
                            property string itemId: model.user_id  // Custom property for ID
                            property string itemName: model.name || ''
                            Text {
                                text: itemName
                                font.pixelSize: isDesktop() ? 20 : 40
                                color: "#000" ? itemId != false : "#121944"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10                                
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 2
                            }
                            onClicked: {
                                if (itemId != false) {
                                    manageAccountInput.text = model.name || ''
                                    linkInput.forceActiveFocus();
                                    linkInput.text = model.link
                                    linkInput.focus = false;
                                    linkInput.forceActiveFocus();
                                    dbInput.text = model.database
                                    dbInputMenu.text = model.database
                                    usernameInput.text = model.username
                                } else {
                                    manageAccountInput.text = ''
                                    linkInput.text = ''
                                    dbInput.text = ''
                                    dbInputMenu.text = ''
                                    usernameInput.text = ''
                                }
                                menuManageAccounts.close()
                            }
                        }
                    }
                }
            }

            TextField {
                id: accountNameInput
                placeholderText: "Account Name"
                anchors.horizontalCenter: parent.horizontalCenter
                width: isDesktop() ? 500 : 1000
            }

            TextField {
                id: linkInput
                placeholderText: "Link"
                anchors.horizontalCenter: parent.horizontalCenter
                width: isDesktop() ? 500 : 1000

                onEditingFinished: {
                    text = text.toLowerCase();
                    if(isValidURL(linkInput.text)) {
                        isValidUrl = true;
                        python.call("backend.fetch_databases", [linkInput.text], function(result) {
                            isTextInputVisible = result.text_field
                            isTextMenuVisible = result.menu_items
                            if (isTextMenuVisible) {
                                optionList = result.menu_items
                            }
                        });
                    } else {
                        isValidUrl = false;
                    }
                }

                onTextChanged: {
                    text = text.toLowerCase();
                }

                function isValidURL(url) {
                    var pattern = new RegExp('^(https?:\\/\\/)?' + // protocol
                        '(([a-zA-Z0-9\\-\\.]+)\\.([a-zA-Z]{2,4})|' + // domain name
                        '(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})|' + // OR ipv4
                        '\\[([a-fA-F0-9:\\.]+)\\])' + // OR ipv6
                        '(\\:\\d+)?(\\/[-a-zA-Z0-9@:%_\\+.~#?&//=]*)*$', 'i');
                    return pattern.test(url);
                }
            }

            Text {
                id: errorMessage
                text: isValidUrl ? "" : "Please enter a valid URL"
                color: "red"
                visible: !isValidUrl
                font.pixelSize: isDesktop() ? 20 : 40
            }

            TextField {
                id: dbInput
                placeholderText: "Database"
                anchors.horizontalCenter: parent.horizontalCenter
                width: isDesktop() ? 500 : 1000
                visible: isTextInputVisible
            }

            TextField {
                id: dbInputMenu
                placeholderText: "Database"
                anchors.horizontalCenter: parent.horizontalCenter
                width: isDesktop() ? 500 : 1000
                visible: isTextMenuVisible
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // python.call("backend.fetch_options_tasks", [projectInput.text] , function(result) {
                        //     tasksList = result;
                        menuTasks.open(); // Open the menu after fetching options
                        // });

                    }
                }
                Menu {
                    id: menuTasks
                    x: dbInputMenu.x
                    y: dbInputMenu.y
                    width: dbInputMenu.width

                    Repeater {  
                        model: optionList

                        MenuItem {
                            width: parent.width
                            height: isDesktop() ? 50 : 40
                            Text {
                                text: modelData
                                font.pixelSize: isDesktop() ? 20 : 40   
                                color: "#000"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight   
                                maximumLineCount: 2 
                            }
                            onClicked: {
                                dbInputMenu.text = modelData
                                menuTasks.close()
                            }
                        }
                    }
                }
            }

            TextField {
                id: usernameInput
                placeholderText: "Username"
                anchors.horizontalCenter: parent.horizontalCenter
                width: isDesktop() ? 500 : 1000
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                TextField {
                    id: passwordInput
                    placeholderText: "Password"
                    width: isDesktop() ? 452 : 900
                    echoMode: isPasswordVisible ? TextInput.Normal : TextInput.Password
                }

                Button {
                    width: isDesktop() ? 40 : 100
                    height: passwordInput.height
                    Image {
                        source: isPasswordVisible ? "images/show.png" : "images/hide.png"
                        anchors.fill: parent
                        smooth: true
                    }
                    onClicked: {
                        isPasswordVisible = !isPasswordVisible
                    }
                }

            }

            Button {
                anchors.topMargin: 20
                width: isDesktop() ? 500 : 1000
                // color: "#FB634E"
                background: Rectangle {
                    color: "#FB634E"
                    radius: isDesktop() ? 5 : 10
                    border.color: "#FB634E"
                    // border.width: 2
                }

                contentItem: Text {
                    text: "Login"
                    color: "#ffffff"
                    font.pixelSize: isDesktop() ? 20 : 30

                }
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    if (!accountNameInput.text && !manageAccountInput.text) {
                        isValidAccount = false;
                    } else {
                        python.call("backend.login_odoo", [linkInput.text, usernameInput.text, passwordInput.text, {'input_text': dbInput.text, 'selected_db': dbInputMenu.text, 'isTextInputVisible': isTextInputVisible, 'isTextMenuVisible': isTextMenuVisible}], function (result) {
                            if (result && result['result'] == 'pass') {
                                insertData(accountNameInput.text, linkInput.text, result['database'], usernameInput.text)
                                isValidLogin = true;
                                loggedIn(result['name_of_user'],courant_userid);
                            }
                            else {
                                isValidLogin = false;
                               console.log("Invalid credentials");
                            }
                        })
                    }
                }
                
            }

            Text {
                id: errorMessageAccount
                text: isValidAccount ? "" : "Please enter Account Name to save!"
                color: "red"
                visible: !isValidAccount
                font.pixelSize: isDesktop() ? 20 : 40
               }

            Text {
                id: errorMessageLogin
                text: isValidLogin ? "" : "Please enter valid Credentials!"
                color: "red"
                visible: !isValidLogin
                font.pixelSize: isDesktop() ? 20 : 40
            }
        }
    }

    Component.onCompleted: {
        initializeDatabase();
        queryData();
        // if (stackView.currentItem && stackView.currentItem.data) {
        //     usernameInput.text = user_name || ''
        //     manageAccountInput.text = account_name || ''
        //     dbInput.text = selected_database || ''
        //     linkInput.text = selected_link || ''
        // }
    }


    // Signal emitted upon successful login
    signal loggedIn(string username,int courant_userid)
}

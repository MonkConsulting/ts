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
// import com.example.databasepathprovider 1.0

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

    function initializeDatabase() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        // db.transaction(function(tx) {
        //     tx.executeSql('DELETE from users')
        //     tx.executeSql('DROP table users')
        //     tx.executeSql('DELETE from project_project_app')
        //     tx.executeSql('DROP table project_project_app')
        //     tx.executeSql('DELETE from project_task_app')
        //     tx.executeSql('DROP table project_task_app')
        //     tx.executeSql('DELETE from account_analytic_line_app')
        //     tx.executeSql('DROP table account_analytic_line_app')
        //     tx.executeSql('DELETE from mail_activity_type_app')
        //     tx.executeSql('DROP table mail_activity_type_app')
        //     tx.executeSql('DELETE from res_partner_app')
        //     tx.executeSql('DROP table res_partner_app')
        //     tx.executeSql('DELETE from mail_activity_app')
        //     tx.executeSql('DROP table mail_activity_app')
        // });
        // Create users table if it doesn't exist
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS users (\
                id INTEGER PRIMARY KEY AUTOINCREMENT,\
                name TEXT NOT NULL,\
                link TEXT NOT NULL,\
                last_modified datetime,\
                database TEXT NOT NULL,\
                username TEXT NOT NULL\
            )');
        });

        // Add last_modified column if it doesn't exist
        // db.transaction(function(tx) {
        //     tx.executeSql('PRAGMA table_info(users)', [], function(tx, results) {
        //         var columnExists = false;
        //         for (var i = 0; i < results.rows.length; i++) {
        //             if (results.rows.item(i).name === "last_modified") {
        //                 columnExists = true;
        //                 break;
        //             }
        //         }
        //         if (!columnExists) {
        //             tx.executeSql('ALTER TABLE users ADD COLUMN last_modified datetime');
        //         }
        //     });
        // });

        // Create project_project_app table if it doesn't exist
        db.transaction(function(tx) {
            
            tx.executeSql('CREATE TABLE IF NOT EXISTS project_project_app (\
                id INTEGER PRIMARY KEY AUTOINCREMENT,\
                name TEXT NOT NULL,\
                account_id INTEGER,\
                parent_id INTEGER,\
                planned_start_date date,\
                planned_end_date date,\
                allocated_hours FLOAT,\
                favorites INTEGER,\
                last_modified datetime,\
                odoo_record_id INTEGER,\
                FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,\
                FOREIGN KEY (parent_id) REFERENCES project_project_app(id) ON DELETE CASCADE\
            )');
        });

        db.transaction(function(tx) {
            
            tx.executeSql('CREATE TABLE IF NOT EXISTS project_task_app (\
                id INTEGER PRIMARY KEY AUTOINCREMENT,\
                name TEXT NOT NULL,\
                account_id INTEGER,\
                project_id INTEGER,\
                parent_id INTEGER,\
                scheduled_date date,\
                deadline date,\
                initial_planned_hours FLOAT,\
                favorites INTEGER,\
                state TEXT,\
                last_modified datetime,\
                odoo_record_id INTEGER,\
                FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,\
                FOREIGN KEY (project_id) REFERENCES project_project_app(id) ON DELETE CASCADE,\
                FOREIGN KEY (parent_id) REFERENCES project_task_app(id) ON DELETE CASCADE\
            )');
        });

        db.transaction(function(tx) {
            
            tx.executeSql('CREATE TABLE IF NOT EXISTS account_analytic_line_app (\
                id INTEGER PRIMARY KEY AUTOINCREMENT,\
                account_id INTEGER,\
                project_id INTEGER,\
                task_id INTEGER,\
                name TEXT,\
                unit_amount FLOAT,\
                last_modified datetime,\
                record_date date,\
                odoo_record_id INTEGER,\
                FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,\
                FOREIGN KEY (project_id) REFERENCES project_project_app(id) ON DELETE CASCADE,\
                FOREIGN KEY (task_id) REFERENCES project_task_app(id) ON DELETE CASCADE\
            )');
        });

        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS mail_activity_type_app (\
                id INTEGER PRIMARY KEY AUTOINCREMENT,\
                account_id INTEGER,\
                name TEXT,\
                odoo_record_id INTEGER,\
                FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE\
            )');
        });

        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS res_users_app (\
                id INTEGER PRIMARY KEY AUTOINCREMENT,\
                account_id INTEGER,\
                name Text,\
                odoo_record_id INTEGER,\
                FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE\
            )');
        });

        db.transaction(function(tx) {
            
            tx.executeSql('CREATE TABLE IF NOT EXISTS mail_activity_app (\
                id INTEGER PRIMARY KEY AUTOINCREMENT,\
                account_id INTEGER,\
                activity_type_id INTEGER,\
                summary TEXT,\
                due_date DATE,\
                user_id INTEGER,\
                notes TEXT,\
                odoo_record_id INTEGER,\
                last_modified datetime,\
                FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,\
                FOREIGN KEY (user_id) REFERENCES res_users_app(id) ON DELETE CASCADE,\
                FOREIGN KEY (activity_type_id) REFERENCES mail_activity_type_app(id) ON DELETE CASCADE\
            )');
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
            recordModel.clear();
            for (var i = 0; i < accountsList.length; i++) {
                recordModel.append(accountsList[i]);
            }
        });
    }

    function fetchTimesheets(instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var timesheetEntries = [];
        db.transaction(function (tx) {
            var result = tx.executeSql('select id, last_modified from users where id = ?', [instance_id]);
            var last_modified = false;
            if (result.rows.length) {
                last_modified = result.rows.item(0).last_modified;
            }
            var fetchedEntries = tx.executeSql('select * from account_analytic_line_app where account_id = ? AND (last_modified < ? OR odoo_record_id IS NULL)', [instance_id, last_modified])
            // , last_modified
             // 
            for (var record = 0; record < fetchedEntries.rows.length; record++) {
                var projectId = tx.executeSql('select odoo_record_id from project_project_app where account_id = ? AND id >= ?', [instance_id, fetchedEntries.rows.item(record).project_id]);
                var taskId = tx.executeSql('select odoo_record_id from project_task_app where account_id = ? AND id >= ?', [instance_id, fetchedEntries.rows.item(record).task_id]);
                timesheetEntries.push({'local_record_id': fetchedEntries.rows.item(record).id,
                                 'record_date': fetchedEntries.rows.item(record).record_date,
                                 'name': fetchedEntries.rows.item(record).name,
                                 'project_id': projectId.rows.item(0).odoo_record_id, 
                                 'task_id': taskId.rows.item(0).odoo_record_id, 
                                 'unit_amount': fetchedEntries.rows.item(record).unit_amount, 
                                 'odoo_record_id': fetchedEntries.rows.item(record).odoo_record_id});
            }
        });
        return timesheetEntries;
    }

    function fetchActivities(instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var timesheetEntries = [];
        db.transaction(function (tx) {
            var result = tx.executeSql('select id, last_modified from users where id = ?', [instance_id]);
            // , last_modified
            var last_modified = false;
            if (result.rows.length) {
                last_modified = result.rows.item(0).last_modified;
            }
            var fetchedEntries = tx.executeSql('select * from mail_activity_app where account_id = ? AND (last_modified < ? OR odoo_record_id IS NULL)', [instance_id, last_modified])
            for (var record = 0; record < fetchedEntries.rows.length; record++) {
                var activityTypeId = tx.executeSql('select odoo_record_id from mail_activity_type_app where account_id = ? AND id >= ?', [instance_id, fetchedEntries.rows.item(record).activity_type_id]);
                var activity_user = tx.executeSql('SELECT id, odoo_record_id FROM res_users_app WHERE id = ?', [fetchedEntries.rows.item(record).user_id]);
                timesheetEntries.push({'local_record_id': fetchedEntries.rows.item(record).id, 'user_id': activity_user.rows.item(record).odoo_record_id, 'due_date': fetchedEntries.rows.item(record).due_date, 'activity_type_id': activityTypeId.rows.item(0).odoo_record_id, 'summary': fetchedEntries.rows.item(record).summary, 'notes': fetchedEntries.rows.item(record).notes, 'odoo_record_id': parseInt(fetchedEntries.rows.item(record).odoo_record_id)});
            }
        });
        return timesheetEntries;
    }

    function update_instance_date(instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var timesheetEntries = [];
        db.transaction(function (tx) {
            tx.executeSql('update users set last_modified = ? where id = ?', [new Date(), instance_id]);
        });
    }

    function update_timesheet_entries(timesheet_entries) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function (tx) {
            for (var record = 0; record < timesheet_entries.length; record++) {
                tx.executeSql('update account_analytic_line_app set odoo_record_id = ?,last_modified = ? where id = ?', [timesheet_entries[record].odoo_record_id, new Date(), timesheet_entries[record].local_record_id])
            }
        });
    }

    function update_activity_entries(activity_entries) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function (tx) {
            for (var record = 0; record < activity_entries.length; record++) {
                tx.executeSql('update mail_activity_app set odoo_record_id = ? where id = ?', [activity_entries[record].odoo_record_id, activity_entries[record].local_record_id])
            }
        });
    }

    function create_contacts(contacts, instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function (tx) {
            for (var contact = 0; contact < contacts.length; contact++) {
                var result = tx.executeSql('SELECT id, COUNT(*) AS count FROM res_users_app WHERE odoo_record_id = ? AND account_id = ?', [contacts[contact].id, parseInt(instance_id)]);
                print('\n\n result.rows.length >>>>>>>>>>>>>', result.rows.length)
                var length = result.rows.length
                if (result.rows.length == 1 && result.rows.item(0).id == null) {
                    length = 0
                }
                if (length > 0) {
                    print('\n\n iffffffffffffffff result.rows.length >>>>>>>>>>>>>', result.rows.item(0).id)
                    tx.executeSql('update res_users_app set name = ? where id = ?', [contacts[contact].name, result.rows.item(0).id])
                } else {
                    print('\n\n elseeeeeeeeeeeeee result.rows.length >>>>>>>>>>>>>')
                    tx.executeSql('INSERT INTO res_users_app (account_id, name, odoo_record_id) VALUES (?, ?, ?)', [instance_id, contacts[contact].name, contacts[contact].id])
                }
            }
        })
    }

    function create_projects(projects, instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            console.log("Database Query Results:");
            for (var project = 0; project < projects.length; project++) {
                var result = tx.executeSql('SELECT id, COUNT(*) AS count FROM project_project_app WHERE odoo_record_id = ? AND account_id = ?', [projects[project].id, parseInt(instance_id)]);
                var parent_project_id = false
                if (projects[project].parent_id.length) {
                    var parent_query = tx.executeSql('SELECT id, COUNT(*) AS count FROM project_project_app WHERE odoo_record_id = ? AND account_id = ?', [projects[project].parent_id[0], parseInt(instance_id)]);
                    if (parent_query.rows.length !== 0) {
                        parent_project_id = parent_query.rows.item(0).id
                    }
                }
                if (result.rows.item(0).count === 0) {
                    tx.executeSql('INSERT INTO project_project_app \
                        (name, account_id, parent_id, planned_start_date, \
                        planned_end_date, allocated_hours, favorites, last_modified, \
                        odoo_record_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', 
                        [projects[project].name, parseInt(instance_id), parent_project_id,
                        projects[project].date_start, projects[project].date, projects[project].allocated_hours,
                        projects[project].is_favorite, new Date(), projects[project].id]);
                } else {
                    
                }

            }
        });
    }

    function create_tasks(tasks, instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);


        db.transaction(function(tx) {
            console.log("Database Query Results:");
            for (var task = 0; task < tasks.length; task++) {
                var result = tx.executeSql('SELECT id, COUNT(*) AS count FROM project_task_app WHERE odoo_record_id = ? AND account_id = ?', [tasks[task].id, parseInt(instance_id)]);
                var parent_task_id = false;
                if (tasks[task].parent_id.length) {
                    var parent_query = tx.executeSql('SELECT id, COUNT(*) AS count FROM project_task_app WHERE odoo_record_id = ? AND account_id = ?', [tasks[task].parent_id[0], parseInt(instance_id)]);
                    if (parent_query.rows.length !== 0) {
                        parent_task_id = parent_query.rows.item(0).id
                    }
                }
                var project_id = false;
                if (tasks[task].project_id.length) {
                    var parent_query = tx.executeSql('SELECT id, COUNT(*) AS count FROM project_project_app WHERE odoo_record_id = ? AND account_id = ?', [tasks[task].project_id[0], parseInt(instance_id)]);
                    if (parent_query.rows.length !== 0) {
                        project_id = parent_query.rows.item(0).id
                    }
                }
                if (result.rows.item(0).count === 0) {
                    tx.executeSql('INSERT INTO project_task_app \
                        (name, account_id, project_id, parent_id, \
                        scheduled_date, deadline, initial_planned_hours, favorites, \
                        state, last_modified, odoo_record_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', 
                        [tasks[task].name, parseInt(instance_id), project_id, parent_task_id,
                        tasks[task].date_deadline, tasks[task].date_deadline, tasks[task].planned_hours,
                        tasks[task].priority, tasks[task].stage_id, new Date(), tasks[task].id]);
                } else {
                    
                }

            }
        });
    }

    function create_activity_types(activities, instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function(tx) {
            for (var activity = 0; activity < activities.length; activity++) {
                var existing_activity = tx.executeSql('select count(*) from mail_activity_type_app where account_id = ? AND odoo_record_id = ?', [instance_id, activities[activity].id])
                if (existing_activity.rows.item(0).count !== 0) {
                    tx.executeSql('INSERT INTO mail_activity_type_app \
                        (account_id, name, odoo_record_id) VALUES \
                        (?, ?, ?)', [instance_id, activities[activity].name, activities[activity].id])
                }
            }
        })
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

        // Rectangle {
        //     // width: parent.width
        //     Component.onCompleted: {
        //         if (!isDesktop()) {
        //             height: 80
        //         }
        //     }
        //     anchors.top: parent.top
        //     anchors.left: parent.left
        //     anchors.topMargin: isDesktop() ? 60 : 100
        //     anchors.leftMargin: isDesktop() ? 60 : 30
        //     // anchors.right: parent.right
        //     Button {
        //         id: backButton
        //         // width: 150
        //         // height: 130
        //         Component.onCompleted: {
        //         if (!isDesktop()) {
        //                 height: 130
        //             }
        //         }
        //         anchors.verticalCenter: parent.verticalCenter

        //         background: Rectangle {
        //             color: "#121944"
        //             border.color: "#121944"
        //         }
        //         // Hamburger Icon
        //         Label {
        //             text: ""
        //             font.pixelSize: isDesktop() ? 20 : 40
        //             color: "#fff"
        //             anchors.centerIn: parent
        //         }
        //         // onClicked: backPage()
        //     }
            
        // }

        // Rectangle {
        //     // width: parent.width
        //     Component.onCompleted: {
        //         if (!isDesktop()) {
        //             height: 80
        //         }
        //     }
        //     // height: 80
        //     anchors.top: parent.top
        //     // anchors.left: parent.left
        //     anchors.topMargin: isDesktop() ? 60 : 100
        //     anchors.rightMargin: isDesktop() ? 180 : 200
        //     anchors.right: parent.right
        //     Button {
        //         id: addNewAccountButton
        //         width: isDesktop() ? 150 : undefined
        //         height: 130
        //         anchors.verticalCenter: parent.verticalCenter

        //         background: Rectangle {
        //             color: "#121944"
        //             border.color: "#121944"
        //         }
        //         // Hamburger Icon
        //         Label {
        //             text: "Add Account"
        //             font.pixelSize: isDesktop() ? 20 : 40
        //             color: "#fff"
        //             anchors.centerIn: parent
        //         }
        //         onClicked: goToLogin()
        //     }
        // }

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
                                source: "images/reload.png"
                                anchors.fill: parent
                                smooth: true
                            }
                            anchors.right: isDesktop() ? parent.right : 0 // This anchors the button to the right
                            anchors.rightMargin: isDesktop() ? 10 : 0 // Optional, to add some space from the right edge
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                    // logInPage(model.user_id)
                                // passwordDialog.y = listView.contentY + (index - 2) * (isDesktop() ? 70 : 200);  // Adjust based on row height
                                passwordDialog.open()
                                // deleteData(model.user_id)
                                // recordModel.remove(index)
                            }
                        }
                        Dialog {
                            id: passwordDialog
                            title: "Enter Password"
                            // width: parent.width * 0.8  // Adjust dialog width
                            x: (parent.width - width) / 2  // Center horizontally // Center horizontally relative to the Row
                            y: -110
                            standardButtons: Dialog.Ok | Dialog.Cancel
                            

                            contentItem: Column {
                                spacing: 10
                                padding: 20

                                TextField {
                                    id: passwordInput
                                    placeholderText: "Password"
                                    echoMode: TextInput.Password // This hides the input
                                }
                            }

                            onAccepted: {
                                loading = true; // Start loading
                                loadingMessage = 'Synchronization for ' + model.name + '!' 
                                // timer.start()
                                python.call('backend.fetch_activity_type', [model.link, model.username, passwordInput.text, {'isTextInputVisible': true, 'input_text': model.database}], function(activities) {
                                    create_activity_types(activities, model.user_id)
                                })
                                python.call("backend.fetch_projects", [model.link, model.username, passwordInput.text, {'isTextInputVisible': true, 'input_text': model.database}] , function(projects) {
                                    create_projects(projects, model.user_id);
                                    python.call("backend.fetch_tasks", [model.link, model.username, passwordInput.text, {'isTextInputVisible': true, 'input_text': model.database}], function(tasks) {
                                        create_tasks(tasks, model.user_id);
                                        loading = false; // Stop loading
                                        passwordInput.text = ""
                                        passwordDialog.close();
                                    })
                                })
                                python.call("backend.fetch_contacts", [model.link, model.username, passwordInput.text, {'isTextInputVisible': true, 'input_text': model.database}] , function(contacts) {
                                    create_contacts(contacts, model.user_id)
                                })
                                var timesheets = fetchTimesheets(model.user_id)
                                python.call("backend.create_timesheets", [model.link, model.username, passwordInput.text, {'isTextInputVisible': true, 'input_text': model.database}, timesheets], function (res) {
                                    update_timesheet_entries(res)
                                })

                                var activities = fetchActivities(model.user_id)
                                python.call("backend.create_activities", [model.link, model.username, passwordInput.text, {'isTextInputVisible': true, 'input_text': model.database}, activities], function (res) {
                                    update_activity_entries(res)
                                })
                                update_instance_date(model.user_id)
                            }

                            onRejected: {
                                console.log("Dialog cancelled")
                            }
                        }
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
        initializeDatabase();
        queryData();
    }

    signal logInPage(string Accountuser_id)
    signal goToLogin()
    signal backPage()
}

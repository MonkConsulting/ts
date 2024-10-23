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


    function initializeDatabase() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        // db.transaction(function(tx) {
            // tx.executeSql('DELETE from users')
            // tx.executeSql('DROP table users')
            // tx.executeSql('DELETE from project_project_app')
            // tx.executeSql('DROP table project_project_app')
            // tx.executeSql('DELETE from project_task_app')
            // tx.executeSql('DROP table project_task_app')
            // tx.executeSql('DELETE from account_analytic_line_app')
            // tx.executeSql('DROP table account_analytic_line_app')
            // tx.executeSql('DELETE from mail_activity_type_app')
            // tx.executeSql('DROP table mail_activity_type_app')
            // tx.executeSql('DELETE from res_partner_app')
            // tx.executeSql('DROP table res_partner_app')
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
                link_id INTEGER,\
                project_id INTEGER,\
                task_id INTEGER,\
                resId INTEGER,\
                resModel TEXT,\
                FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,\
                FOREIGN KEY (user_id) REFERENCES res_users_app(id) ON DELETE CASCADE,\
                FOREIGN KEY (activity_type_id) REFERENCES mail_activity_type_app(id) ON DELETE CASCADE\
                FOREIGN KEY (project_id) REFERENCES project_project_app(id) ON DELETE CASCADE,\
                FOREIGN KEY (task_id) REFERENCES project_task_app(id) ON DELETE CASCADE\
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
                accountsList.push({'user_id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'link': result.rows.item(i).link, 'database': result.rows.item(i).database, 'username': result.rows.item(i).username, 'last_modified': result.rows.item(i).last_modified})
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

    function fetchTimesheets(instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var timesheetEntries = [];
        db.transaction(function (tx) {
            var result = tx.executeSql('select id, last_modified from users where id = ?', [instance_id]);
            var last_modified = false;
            if (result.rows.length) {
                last_modified = result.rows.item(0).last_modified;
            }
            var fetchedEntries = tx.executeSql('select * from account_analytic_line_app where account_id = ? AND (last_modified > ? OR odoo_record_id IS NULL)', [instance_id, last_modified])
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
            var fetchedEntries = tx.executeSql('select * from mail_activity_app where account_id = ? AND (last_modified > ? OR odoo_record_id IS NULL)', [instance_id, last_modified])
            for (var record = 0; record < fetchedEntries.rows.length; record++) {
                var activityTypeId = tx.executeSql('select odoo_record_id from mail_activity_type_app where account_id = ? AND id >= ?', [instance_id, fetchedEntries.rows.item(record).activity_type_id]);
                var activity_user = tx.executeSql('SELECT id, odoo_record_id FROM res_users_app WHERE id = ?', [fetchedEntries.rows.item(record).user_id]);
                var project_id = false;
                var task_id = false;
                if (fetchedEntries.rows.item(record).project_id) {
                    var fetchProject = tx.executeSql('select id, odoo_record_id from project_project_app where id = ?', [fetchedEntries.rows.item(record).project_id])
                    if (fetchProject.rows.length !== 0) {
                        project_id = fetchProject.rows.item(0).odoo_record_id
                    }
                }
                if (fetchedEntries.rows.item(record).task_id) {
                    var fetchTask = tx.executeSql('select id, odoo_record_id from project_task_app where id = ?', [fetchedEntries.rows.item(record).task_id])
                    if (fetchTask.rows.length !== 0) {
                        task_id = fetchTask.rows.item(0).odoo_record_id
                    }
                }
                timesheetEntries.push({'local_record_id': fetchedEntries.rows.item(record).id, 
                    'user_id': activity_user.rows.item(0).odoo_record_id, 
                    'due_date': fetchedEntries.rows.item(record).due_date, 
                    'activity_type_id': activityTypeId.rows.item(0).odoo_record_id, 
                    'summary': fetchedEntries.rows.item(record).summary, 
                    'notes': fetchedEntries.rows.item(record).notes, 
                    'odoo_record_id': fetchedEntries.rows.item(record).odoo_record_id,
                    'link_id': fetchedEntries.rows.item(record).link_id,
                    'project_id': project_id,
                    'task_id': task_id,
                    'res_model': fetchedEntries.rows.item(record).resModel,
                    'res_id': fetchedEntries.rows.item(record).resId});
            }
        });
        return timesheetEntries;
    }

    function update_instance_date(instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        var timesheetEntries = [];
        db.transaction(function (tx) {
            tx.executeSql('update users set last_modified = ? where id = ?', [new Date().toISOString(), instance_id]);
        });
    }

    function update_timesheet_entries(timesheet_entries) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function (tx) {
            for (var record = 0; record < timesheet_entries.length; record++) {
                tx.executeSql('update account_analytic_line_app set odoo_record_id = ?,last_modified = ? where id = ?', [timesheet_entries[record].odoo_record_id, new Date().toISOString(), timesheet_entries[record].local_record_id])
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
                var length = result.rows.length
                if (result.rows.length == 1 && result.rows.item(0).id == null) {
                    length = 0
                }
                if (length > 0) {
                    tx.executeSql('update res_users_app set name = ? where id = ?', [contacts[contact].name, result.rows.item(0).id])
                } else {
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
                        projects[project].is_favorite, new Date().toISOString(), projects[project].id]);
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
                        tasks[task].priority, tasks[task].stage_id, new Date().toISOString(), tasks[task].id]);
                } else {
                    
                }

            }
        });
    }

    function create_activity_types(activities, instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function(tx) {
            for (var activity = 0; activity < activities.length; activity++) {
                var existing_activity = tx.executeSql('select count(*) AS count from mail_activity_type_app where account_id = ? AND odoo_record_id = ?', [instance_id, activities[activity].id])
                if (existing_activity.rows.item(0).count == 0) {
                    tx.executeSql('INSERT INTO mail_activity_type_app \
                        (account_id, name, odoo_record_id) VALUES \
                        (?, ?, ?)', [instance_id, activities[activity].name, activities[activity].id])
                }
            }
        })
    }

    function create_activities(activities, instance_id) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function (tx) {
            for (var activity = 0; activity < activities.length; activity++) {
                var existing_activity = tx.executeSql('select id, count(*) AS count from mail_activity_app where account_id = ? AND odoo_record_id = ?', [instance_id, activities[activity].id])
                var activity_type_id = tx.executeSql('select id from mail_activity_type_app where account_id = ? AND odoo_record_id = ?', [instance_id, activities[activity].activity_type_id[0]])
                var user_id = tx.executeSql('select id from res_users_app where account_id = ? AND odoo_record_id = ?', [instance_id, activities[activity].user_id[0]])
                if (existing_activity.rows.item(0).count == 0) {
                    if (activities[activity].res_model == 'project.project') {
                        var project_id = tx.executeSql('select id from project_project_app where account_id = ? AND odoo_record_id = ?', [instance_id, activities[activity].res_id])
                        tx.executeSql('INSERT INTO mail_activity_app \
                            (account_id, activity_type_id, summary, due_date, user_id, notes, odoo_record_id, last_modified, project_id, link_id)\
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [instance_id, activity_type_id.rows.item(0).id, 
                                activities[activity].summary, activities[activity].date_deadline, user_id.rows.item(0).id,
                                activities[activity].note, activities[activity].id, new Date().toISOString(), project_id.rows.item(0).id, 1])
                    } else if (activities[activity].res_model == 'project.task') {
                        var task_id = tx.executeSql('select id from project_task_app where account_id = ? AND odoo_record_id = ?', [instance_id, parseInt(activities[activity].res_id)])
                        tx.executeSql('INSERT INTO mail_activity_app \
                            (account_id, activity_type_id, summary, due_date, user_id, notes, odoo_record_id, last_modified, task_id, link_id)\
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [instance_id, activity_type_id.rows.item(0).id, 
                                activities[activity].summary, activities[activity].date_deadline, user_id.rows.item(0).id,
                                activities[activity].note, activities[activity].id, new Date().toISOString(), task_id.rows.item(0).id, 2])
                    } else {
                        tx.executeSql('INSERT INTO mail_activity_app \
                            (account_id, activity_type_id, summary, due_date, user_id, notes, odoo_record_id, last_modified, resModel, resId, link_id)\
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [instance_id, activity_type_id.rows.item(0).id, 
                                activities[activity].summary, activities[activity].date_deadline, user_id.rows.item(0).id,
                                activities[activity].note, activities[activity].id, new Date().toISOString(), activities[activity].res_model, activities[activity].res_id, 3])
                    }
                } else {
                    tx.executeSql('update mail_activity_app set activity_type_id = ?, summary = ?, due_date = ?, user_id = ?, notes = ?, last_modified = ?\
                        where id = ?', [activity_type_id.rows.item(0).id, 
                            activities[activity].summary, activities[activity].date_deadline, user_id.rows.item(0).id,
                            activities[activity].note, new Date().toISOString(), existing_activity.rows.item(0).id])
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

    ListModel {
        id: recordModel
    }
    Rectangle {
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: isDesktop()?80:120
        anchors.left: parent.left
        anchors.leftMargin: isDesktop()?70 : 20
        anchors.right: parent.right
        anchors.rightMargin: isDesktop()?10 : 20
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
            anchors.leftMargin: isDesktop() ? 0 : 10
            anchors.right: parent.right  // Float the search field to the right
            width: parent.width

            // Label on the left side
            Label {
                text: "Synchronization"
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
                    filtersynList(searchField.text);  // Call the filter function when the text changes
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
                                            source: "images/reload.png"
                                            anchors.fill: parent
                                            smooth: true
                                        }
                                        anchors.right:  parent.right  // This anchors the button to the right
                                        anchors.rightMargin:  20  // Optional, to add some space from the right edge
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
                                        y: -150
                                        standardButtons: Dialog.Ok | Dialog.Cancel
                                        

                                        contentItem: Column {
                                            spacing: 10
                                            padding: 20

                                            // TextField {
                                            //     id: passwordInput
                                            //     placeholderText: "Password"
                                            //     echoMode: TextInput.Password // This hides the input
                                            // }
                                            Row {
                                                spacing: 5  // Space between the TextField and Button

                                                TextField {
                                                    id: passwordInput
                                                    placeholderText: "Password"
                                                    echoMode: isPasswordVisible ? TextInput.Normal : TextInput.Password  // Toggle between showing and hiding password
                                                    // Layout.fillWidth: true  // Make the TextField take up all available space
                                                }

                                                // Show/Hide password button
                                                Button {
                                                    height: passwordInput.height
                                                    width:passwordInput.height
                                                    // Layout.preferredWidth: passwordInput.height  // Set button width based on TextField height
                                                    Image {
                                                        source: isPasswordVisible ? "images/show.png" : "images/hide.png"  // Icon for show/hide
                                                        anchors.fill: parent
                                                        smooth: true
                                                    }
                                                    onClicked: {
                                                        isPasswordVisible = !isPasswordVisible  // Toggle password visibility
                                                    }
                                                }
                                            }
                                        }

                                        onAccepted: {
                                            loading = true; // Start loading
                                            loadingMessage = 'Synchronization for ' + model.name + '!' 
                                            var filled_password = passwordInput.text
                                            python.call("backend.fetch_projects", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, model.last_modified] , function(projects) {
                                                create_projects(projects, model.user_id);
                                                python.call("backend.fetch_tasks", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, model.last_modified], function(tasks) {
                                                    create_tasks(tasks, model.user_id);
                                                     // Stop loading
                                                    python.call('backend.fetch_activity_type', [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, model.last_modified], function(activity_types) {
                                                        create_activity_types(activity_types, model.user_id)
                                                        python.call("backend.fetch_contacts", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, model.last_modified] , function(contacts) {
                                                            create_contacts(contacts, model.user_id)
                                                            python.call('backend.fetch_activities', [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, model.last_modified], function(activities) {
                                                                create_activities(activities, model.user_id)
                                                                loading = false;
                                                            })
                                                        })
                                                        var activities = fetchActivities(model.user_id)
                                                        python.call("backend.create_activities", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, activities], function (res) {
                                                            update_activity_entries(res)
                                                        })
                                                    })
                                                    var timesheets = fetchTimesheets(model.user_id)
                                                    python.call("backend.create_timesheets", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, timesheets], function (res) {
                                                        update_timesheet_entries(res)
                                                    })
                                                    passwordInput.text = ""
                                                    passwordDialog.close();
                                                })
                                            })

                                            update_instance_date(model.user_id)
                                        }

                                        onRejected: {
                                            console.log("Dialog cancelled")
                                        }
                                    }
                                       
                                    
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
        initializeDatabase();
        queryData();
    }

    signal logInPage(string Accountuser_id)
    signal goToLogin()
    signal backPage()
}

.import QtQuick.LocalStorage 2.7 as Sql

/* Name: get_accounts_list
* This function will return accounts which are linked to Odoo
*/

function get_accounts_list() {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var accountlist = [];
    db.transaction(function(tx) {
        var accounts = tx.executeSql('SELECT * FROM users');
        for (var account = 0; account < accounts.rows.length; account++) {
            accountlist.push({'id': accounts.rows.item(account).id,
                             'name': accounts.rows.item(account).name});
        }
    });
    return accountlist;
}

function convertFloatToTime(value) {
    var hours = Math.floor(value);
    var minutes = Math.round((value - hours) * 60);
    return hours.toString().padStart(2, '0') + ':' + minutes.toString().padStart(2, '0');
}

/* Name: fetch_timesheets
* This function will return timesheets based on work state, this function is returning
* for timesheet list view
* is_work_state -> in case of work mode is enable
*/

function fetch_timesheets(is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var timesheetList = [];
    db.transaction(function(tx) {
        if (is_work_state) {
            var timesheets = tx.executeSql('SELECT * FROM account_analytic_line_app where account_id IS NOT NULL order by id desc');
        } else {
            var timesheets = tx.executeSql('SELECT * FROM account_analytic_line_app where parent_id = 0 AND account_id IS NULL');
        }
        for (var timesheet = 0; timesheet < timesheets.rows.length; timesheet++) {
            var quadrantObj = {0: "Urgent and Important",
                            1: "Important but not Urgent",
                            2: "Not Important but Urgent",
                            3: "Not Important and Not Urgent"};
            var project = tx.executeSql('select name from project_project_app where id = ?', [timesheets.rows.item(timesheet).project_id])
            var instance = tx.executeSql('select name from users where id = ?', [timesheets.rows.item(timesheet).account_id])
            timesheetList.push({'id': timesheets.rows.item(timesheet).id,
                             'instance': instance.rows.length != 0 ? instance.rows.item(0).name : '',
                             'spentHours': convertFloatToTime(timesheets.rows.item(timesheet).unit_amount),
                             'project': project.rows.length != 0 ? project.rows.item(0).name : '',
                             'quadrant': quadrantObj[timesheets.rows.item(timesheet).quadrant_id] || "Urgent and Important",
                             'date': timesheets.rows.item(timesheet).record_date});
        }
    });
    return timesheetList;
}

/* Name: get_timesheet_details
* This function will return timesheets details in form of object to fill in detail view of timesheet
* -> record_id -> for which timesheet details needs to be fetched
*/

function get_timesheet_details(record_id) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var timesheet_detail = {};
    db.transaction(function (tx) {
        var timesheet = tx.executeSql('SELECT * FROM account_analytic_line_app\
                                    WHERE id = ?', [record_id]);
        if (timesheet.rows.length) {
            timesheet_detail = {'instance_id': timesheet.rows.item(0).account_id,
                                'project_id': timesheet.rows.item(0).project_id,
                                'sub_project_id': timesheet.rows.item(0).sub_project_id,
                                'task_id': timesheet.rows.item(0).task_id,
                                'sub_task_id': timesheet.rows.item(0).sub_task_id,
                                'description': timesheet.rows.item(0).name,
                                'spentHours': convertFloatToTime(timesheet.rows.item(0).unit_amount),
                                'quadrant_id': timesheet.rows.item(0).quadrant_id,
                                'record_date': formatDate(new Date(timesheet.rows.item(0).record_date))};
        }
    });
    function formatDate(date) {
        var month = date.getMonth() + 1; 
        var day = date.getDate();
        var year = date.getFullYear();
        return month + '/' + day + '/' + year;
    }
    return timesheet_detail;
}

/* Name: createUpdateTimesheet
* This function will return whether record is saved successfully or not
* -> timesheet_data -> Object of latest data
* -> record_id -> to update record
*/

function createUpdateTimesheet(timesheet_data, record_id) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var timesheetObj = {};
    db.transaction(function (tx) {
        try {
            if (recordid == 0) {
                tx.executeSql('INSERT INTO account_analytic_line_app \
                            (account_id, name, project_id, sub_project_id, task_id, \
                            sub_task_id, unit_amount, quadrant_id, last_modified)\
                            Values (?, ?, ?, ?, ?, ?, ?, ?, ?)', 
                            [timesheet_data.account_id, timesheet_data.name, timesheet_data.project_id,
                            timesheet_data.sub_project_id, timesheet_data.task_id, timesheet_data.sub_task_id, convertDurationToFloat(timesheet_data.unit_amount),
                            timesheet_data.quadrant_id, new Date().toISOString()])
            } else {
                tx.executeSql('UPDATE account_analytic_line_app SET \
                            account_id = ?, name = ?, project_id = ?, sub_project_id = ?, task_id = ?, \
                            sub_task_id = ?, unit_amount = ?, quadrant_id = ?, last_modified = ?\
                            where id = ?', 
                            [timesheet_data.account_id, timesheet_data.name, timesheet_data.project_id,
                            timesheet_data.sub_project_id, timesheet_data.task_id, timesheet_data.sub_task_id, convertDurationToFloat(timesheet_data.unit_amount),
                            timesheet_data.quadrant_id, new Date().toISOString(), recordid])
            }
            timesheetObj['is_success'] = true;
            timesheetObj['message'] = 'Record is saved Successfully!';
        } catch (error) {
            timesheetObj['is_success'] = false;
            timesheetObj['message'] = 'Record could not be saved!\n' + error;
        }
    });
    return timesheetObj;
}

/* Name: convertFloatToTime
* This function will return HH:MM format time based on float value
* -> value -> float value to convert HH:MM
*/

function convertFloatToTime(value) {
    var hours = Math.floor(value);
    var minutes = Math.round((value - hours) * 60);
    return hours.toString().padStart(2, '0') + ':' + minutes.toString().padStart(2, '0');
}

/* Name: convertDurationToFloat
* This function will return float value from HH:MM format
* -> value -> HH:MM format to convert float value
*/

function convertDurationToFloat(value) {
    let vals = value.split(":");
    let hours = parseFloat(vals[0]);
    let minutes = parseFloat(vals[1]);
    let days = Math.floor(hours / 24);
    hours = hours % 24;
    let convertedMinutes = minutes / 60.0;
    return hours + convertedMinutes;
}

/* Name: fetch_projects
* This function will return projects based on Odoo account and work state
* instance_id -> id of users table
* is_work_state -> in case of work mode is enable
*/

function fetch_projects(instance_id, is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var projectList = [];
    db.transaction(function(tx) {
        if (is_work_state) {
            var projects = tx.executeSql('SELECT * FROM project_project_app\
             WHERE account_id = ? AND parent_id IS 0', [instance_id]);
        } else {
            var projects = tx.executeSql('SELECT * FROM project_project_app\
             WHERE account_id IS NULL');
        }
        for (var project = 0; project < projects.rows.length; project++) {
            var child_projects = tx.executeSql('SELECT count(*) as count FROM project_project_app\
             where parent_id = ?', [projects.rows.item(project).id]);
            projectList.push({'id': projects.rows.item(project).id,
                             'name': projects.rows.item(project).name,
                             'projectHasSubProject': true ? child_projects.rows.item(0).count > 0 : false});
        }
    });
    return projectList;
}

/* Name: fetch_sub_project
* This function will return sub projects based on given project's id
* project_id -> id from project_project_app table
* is_work_state -> in case of work mode is enable
*/

function fetch_sub_project(project_id, is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var subProjectsList = [];
    db.transaction(function(tx) {
        if (is_work_state) {
            var sub_projects = tx.executeSql('SELECT * FROM project_project_app\
                                where parent_id = ?', [project_id]);
        } else {
            var sub_projects = tx.executeSql('SELECT * FROM project_project_app\
                                where account_id IS NULL AND parent_id = ?', [project_id]);
        }
        for (var sub_project = 0; sub_project < sub_projects.rows.length; sub_project++) {
            subProjectsList.push({'id': sub_projects.rows.item(sub_project).id,
                                 'name': sub_projects.rows.item(sub_project).name});
        }
    });
    return subProjectsList;
}

/* Name: fetch_tasks_list
* This function will return tasks list
* project_id -> id from project_project_app table
* sub_project_id -> id from project_project_app table
* is_work_state -> in case of work mode is enable
*/

function fetch_tasks_list(project_id, sub_project_id, is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var tasks_list = [];
    db.transaction(function(tx) {
        if (is_work_state) {
            var tasks = tx.executeSql('SELECT * FROM project_task_app\
                                 where project_id = ? AND account_id != 0 AND sub_project_id = ?',
                                [project_id, sub_project_id != 0 ? sub_project_id : null]);
            if (sub_project_id == 0) {
                tasks = tx.executeSql('SELECT * FROM project_task_app\
                                     where project_id = ? AND account_id != 0',
                                    [project_id]);
            }
        } else {
            var tasks = tx.executeSql('SELECT * FROM project_task_app\
                                     where account_id is NULL \
                                     AND project_id = ? \
                                     ',
                                     [project_id]);
        }
        for (var task = 0; task < tasks.rows.length; task++) {
            var child_tasks = tx.executeSql('SELECT count(*) as count FROM project_task_app\
                                             where parent_id = ?',
                                             [tasks.rows.item(task).id]);
            tasks_list.push({'id': tasks.rows.item(task).id,
                         'name': tasks.rows.item(task).name,
                         'taskHasSubTask': true ? child_tasks.rows.item(0).count > 0 : false,
                         'parent_id':tasks.rows.item(task).parent_id});
        }
    });
    return tasks_list;
}

/* Name: fetch_sub_tasks
* This function will return sub tasks list based on given id of the task
* task_id -> id of project_task_app table
* is_work_state -> in case of work mode is enable
*/

function fetch_sub_tasks(task_id, is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var sub_tasks_list = [];
    db.transaction(function(tx) {
        if (is_work_state) {
            var sub_tasks = tx.executeSql('SELECT * FROM project_task_app\
                                         where parent_id = ?', [task_id]);
        } else {
            var sub_tasks = tx.executeSql('SELECT * FROM project_task_app\
                                         where account_id IS NULL AND parent_id = ?',
                                         [task_id]);
        }
        for (var sub_task = 0; sub_task < sub_tasks.rows.length; sub_task++) {
            sub_tasks_list.push({'id': sub_tasks.rows.item(sub_task).id,
                             'name': sub_tasks.rows.item(sub_task).name});
        }
    });
    return sub_tasks_list;
}

/* Name: convert_time
* This function will return formatted time HH:MM
* value -> string
*/

function convert_time(value) {
    var vals = value.split(':');
    var hours = parseInt(vals[0], 10);
    var minutes = parseInt(vals[1], 10);
    hours += Math.floor(minutes / 60);
    minutes = minutes % 60;
    return hours.toString().padStart(2, '0') + ':' + minutes.toString().padStart(2, '0');
}

/* Name: create_timesheet
* This function will create timesheet based on passed data
* data -> object of details related to timesheet entry
*/

function create_timesheet(data) {
    console.log("In create_timesheet");
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    try{
        db.transaction(function(tx) {
            var unitAmount = 0;
            if (data.isManualTimeRecord) {
                unitAmount = convertDurationToFloat(data.manualSpentHours);
            } else {
                unitAmount = convertDurationToFloat(data.spenthours);
            }
            tx.executeSql('INSERT INTO account_analytic_line_app \
                (account_id, record_date, project_id, task_id, name, sub_project_id, sub_task_id, quadrant_id,  \
                unit_amount, last_modified) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [data.instance_id, data.dateTime, data.project, data.task, data.description, data.subprojectId,
                data.subTask, data.quadrant, unitAmount, new Date().toISOString()]);
        });
    }
    catch (err) {
        console.log("create_timesheet: Error saving data in database: " + err)
    };
}

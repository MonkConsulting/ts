.import QtQuick.LocalStorage 2.7 as Sql




    function savetaskData(data) {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
        db.transaction(function (tx) {
            var result = tx.executeSql('INSERT INTO project_task_app (account_id, name, project_id, parent_id, start_date, end_date, deadline, favorites, initial_planned_hours, description, user_id,sub_project_id, last_modified) \
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [data.selectedAccountUserId, data.nameInput, data.selectedProjectId, 
                    data.selectedparentTaskId, data.startdateInput,data.enddateInput, data.deadlineInput, data.img_star, 
                    data.initialInput, data.descriptionInput, data.selectedassigneesUserId, data.selectedSubProjectId, new Date().toISOString()]);
            tx.executeSql('commit')
       });
    }

function edittaskData(data){
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

    db.transaction(function(tx) {
        tx.executeSql('UPDATE project_task_app SET \
            account_id = ?, name = ?, project_id = ?, parent_id = ?, initial_planned_hours = ?, favorites = ?, description = ?, user_id = ?, sub_project_id = ?, \
            start_date = ?, end_date = ?, deadline = ?, last_modified = ? WHERE id = ?',
            [data.selectedAccountUserId, data.nameInput, data.selectedProjectId,data.selectedparentId, data.initialInput,data.img_star,data.editdescription, data.selectedassigneesUserId, data.editselectedSubProjectId,
            data.startdateInput, data.enddateInput,data.deadlineInput, new Date().toISOString(), data.rowId]  
        );
        tx.executeSql('commit');
        fetch_tasks_lists()
    });
}
function fetch_tasks_lists(recordid) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var workpersonaSwitchState = true;
    var filtertasklistData = []
    var tasklist = []
    db.transaction(function(tx) {
        if (!recordid){
            console.log("Gets all records!");
            if(workpersonaSwitchState){
                var result = tx.executeSql('SELECT * FROM project_task_app where account_id != 0 order by last_modified desc');
            }else{
                var result = tx.executeSql('SELECT * FROM project_task_app where account_id = 0');
            }
        }
        else{
            console.log("Gets one record!");
            var result = tx.executeSql('SELECT * FROM project_task_app where id = ? order by last_modified desc', [recordid]);
        }
        for (var i = 0; i < result.rows.length; i++) {
            var parent_task = tx.executeSql('SELECT name FROM project_task_app WHERE id = ?',[result.rows.item(i).parent_id]);
            var parentTask = parent_task.rows.length > 0 ? parent_task.rows.item(0).name || "" : "";

            var accunt_id = tx.executeSql('SELECT name FROM users WHERE id = ?',[result.rows.item(i).account_id]);
            var accountName = accunt_id.rows.length > 0 ? accunt_id.rows.item(0).name || "" : "";

            var id = result.rows.item(i).id
            var spentHoursQuery = tx.executeSql('SELECT unit_amount FROM account_analytic_line_app WHERE task_id = ?', [id]);

            var color_pallet = ''
            if (result.rows.item(i).sub_project_id != 0) {
                var project_color = tx.executeSql('select color_pallet from project_project_app where id = ?', [result.rows.item(i).sub_project_id])
                if (project_color.rows.length) {
                    color_pallet = project_color.rows.item(0).color_pallet;
                }
            } else {
                var project_color = tx.executeSql('select color_pallet from project_project_app where id = ?', [result.rows.item(i).project_id])
                if (project_color.rows.length) {
                    color_pallet = project_color.rows.item(0).color_pallet;
                }
            }

            var totalMinutes = 0;
            for (var j = 0; j < spentHoursQuery.rows.length; j++) {
                var timeString = spentHoursQuery.rows.item(j).unit_amount || "00:00";
                var parts = timeString.split(":");
                var hours = parseInt(parts[0], 10) || 0;
                var minutes = parseInt(parts[1], 10) || 0;

                totalMinutes += hours * 60 + minutes;  
            }

            var totalHours = Math.floor(totalMinutes / 60);
            var remainingMinutes = totalMinutes % 60;
            var spentHours =  totalHours + ":" + (remainingMinutes < 10 ? "0" : "") + remainingMinutes;
//            console.log("IN Tasks.js Account ID: " + result.rows.item(i).account_id);

            tasklist.push({'id': result.rows.item(i).id, 'color_pallet': color_pallet, 
                'name': result.rows.item(i).name, 'allocated_hours': result.rows.item(i).initial_planned_hours, 
                'state': result.rows.item(i).state, 'parentTask': parentTask, 'accountName':accountName,
                'favorites':result.rows.item(i).favorites,'spentHours':spentHours, 'timerRunning': false, 
                'account_id': result.rows.item(i).account_id, 'parent_id': result.rows.item(i).parent_id, 
                'description': result.rows.item(i).description, 'start_date':result.rows.item(i).start_date,
                'end_date':result.rows.item(i).end_date, 'deadline':result.rows.item(i).deadline})
            filtertasklistData.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'allocated_hours': result.rows.item(i).initial_planned_hours, 'state': result.rows.item(i).state,'parentTask': parentTask, 'accountName':accountName,'favorites':result.rows.item(i).favorites,'spentHours':spentHours, 'timerRunning': false})
        }
    })
    return tasklist
}

function filterTaskList(query) {
    tasksListModel.clear(); 

    for (var i = 0; i < filtertasklistData.length; i++) {
        var entry = filtertasklistData[i];
        
        if (entry.name.toLowerCase().includes(query.toLowerCase()) ||
            entry.parentTask.toLowerCase().includes(query.toLowerCase()) || 
            entry.state.toLowerCase().includes(query.toLowerCase()) ||
            entry.accountName.toLowerCase().includes(query.toLowerCase()) ||
            (entry.spentHours.toString().includes(query)) ||  
            (entry.allocated_hours.toString().includes(query))
            ) {
            tasksListModel.append(entry);
        }
    }
}

function fetch_current_users_task(selectedAccountUserId) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var activity_type_list = []
    db.transaction(function (tx) {
        var instance_users = tx.executeSql('select * from res_users_app where account_id = ? AND share = ? AND active = ?', [selectedAccountUserId, 0, 1])
        var all_users = tx.executeSql('select * from res_users_app')
        for (var user = 0; user < all_users.rows.length; user++) {
        } //GM: What is this for? 
        for (var instance_user = 0; instance_user < instance_users.rows.length; instance_user++) {
            activity_type_list.push({'id': instance_users.rows.item(instance_user).id, 'name': instance_users.rows.item(instance_user).name});
        }
    })
    return activity_type_list;
}

function edittaskData(data){
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    console.log("From edittaskData changed data: " + data.initialInput + " " + data.rowId)

    db.transaction(function(tx) {
        tx.executeSql('UPDATE project_task_app SET \
            account_id = ?, name = ?, project_id = ?, parent_id = ?, initial_planned_hours = ?, favorites = ?, description = ?, user_id = ?, sub_project_id = ?, \
            start_date = ?, end_date = ?, deadline = ?, last_modified = ? WHERE id = ?',
            [data.selectedAccountUserId, data.nameInput, data.selectedProjectId,data.selectedparentId, data.initialInput,data.img_star,data.editdescription, data.selectedassigneesUserId, data.editselectedSubProjectId,
            data.startdateInput, data.enddateInput,data.deadlineInput, new Date().toISOString(), data.rowId]  
        );
        tx.executeSql('commit');
//        fetch_tasks_lists()
    });
}

function getAssigneeList(){
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var assigneelist = [];

    db.transaction(function(tx) {
            var result1 = tx.executeSql('SELECT * FROM users');
            for (var i = 0; i < result1.rows.length; i++) {
                console.log("getAssigneeList: " + result1.rows.item(i).name)
                assigneelist.push({'id': result1.rows.item(i).id, 'name': result1.rows.item(i).name})
            }
        })
    return assigneelist

}
import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Components.Pickers 1.3
import QtCharts 2.0
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import "../models/Timesheet.js" as Timesheet
import "../models/Utils.js" as Utils


Page {
    id: timesheetsDetails
    title: "Timesheet Details"
    header: PageHeader {
        title: timesheetsDetails.title
        ActionBar {
            numberOfSlots: 2
            anchors.right: parent.right
            actions: [
                Action {
                    iconName: "edit"
                    text: "Edit"
                    visible: isReadOnly
                    onTriggered:{
                        console.log("Edit Timesheet clicked");
                        // console.log("Account ID: " + currentProject.account_id)
                        isReadOnly = !isReadOnly

                    }
                },
                Action {
                    iconName: "save"
                    text: "Save"
                    visible: !isReadOnly
                    onTriggered: {
                        var timesheet_data = {'account_id': selectedInstanceId,
                                            'name': description_text.text,
                                            'record_date': record_date_text,text,
                                            'project_id': selectedProjectId,
                                            'sub_project_id': selectedSubProjectId,
                                            'task_id': selectedTaskId,
                                            'sub_task_id': selectedSubTaskId,
                                            'unit_amount': hours_text.text,
                                            'quadrant_id': parseInt(prioritySlider.value) - 1}
                        var response = Timesheet.createUpdateTimesheet(timesheet_data, recordid);
                        if (response) {
                            isVisibleMessage = true;
                            isSaved = response.is_success;
                            saveMessage = response.message;
                            if (isSaved) {
                                isReadOnly = !isReadOnly;
                            }
                        }
                        // console.log("Save Project clicked", planned_start_date_text.text);
                    }
                }
            ]
        }
    }

    property var recordid: 0
    property bool isSaved: true
    property string saveMessage: ''
    property bool isVisibleMessage: false
    property bool workpersonaSwitchState: true
    property bool isReadOnly: true
    property var currentTimesheet: {}
    property int favorites: 0
    property int selectedInstanceId: 0
    property int selectedProjectId: 0
    property int selectedSubProjectId: 0
    property int selectedTaskId: 0
    property int selectedSubTaskId: 0

    ListModel {
        id: instanceModel
    }

    ListModel {
        id: projectModel
    }

    ListModel {
        id: subProjectModel
    }

    ListModel {
        id: taskModel
    }

    ListModel {
        id: subTaskModel
    }

    function setInstanceList() {
        var instances = Utils.accountlistDataGet();
        instanceModel.clear();
        for (var instance = 0; instance < instances.length; instance++) {
            instanceModel.append({'id': instances[instance].id, 'name': instances[instance].name});
        }
    }

    function setProjectList() {
        var projects = Timesheet.fetch_projects(selectedInstanceId, workpersonaSwitchState);
        projectModel.clear();
        for (var project = 0; project < projects.length; project++) {
            projectModel.append({'id': projects[project].id,
                                 'name': projects[project].name,
                                 'projectHasSubProject': projects[project].projectHasSubProject});
        }
    }

    function setSubProjectList() {
        var subProjects = Timesheet.fetch_sub_project(selectedProjectId, workpersonaSwitchState);
        subProjectModel.clear();
        for (var subProject = 0; subProject < subProjects.length; subProject++) {
            subProjectModel.append({'id': subProjects[subProject].id,
                                 'name': subProjects[subProject].name});
        }
    }

    function setTasksList() {
        var tasks = Timesheet.fetch_tasks_list(selectedProjectId, selectedSubProjectId, workpersonaSwitchState)
        taskModel.clear();
        for (var task = 0; task < tasks.length; task++) {
            taskModel.append({'id': tasks[task].id,
                                 'name': tasks[task].name});
        }
    }

    function setSubTasksList() {
        var subtasks = Timesheet.fetch_sub_tasks(selectedTaskId, workpersonaSwitchState)
        subTaskModel.clear();
        for (var subtask = 0; subtask < subtasks.length; subtask++) {
            subTaskModel.append({'id': subtasks[subtask].id,
                                 'name': subtasks[subtask].name});
        }
    }

    function floattoint(value) {
        return Number.parseFloat(value).toFixed(0);
    }

    Text {
        id: saveMessageTimesheetText
        text: saveMessage
        color: isSaved ? "green": "red"
        anchors.top: header.bottom
        anchors.topMargin: 10
        leftPadding: units.gu(2)
        visible: isVisibleMessage
    }

    Flickable {
        id: timesheetsDetailsPageFlickable
        anchors.fill: parent
        contentHeight: timesheetsDetailsLomiriShape.height + 1000
        flickableDirection: Flickable.VerticalFlick
        anchors.top: saveMessageTimesheetText.bottom
        anchors.topMargin: header.height + units.gu(4)
        width: parent.width

        LomiriShape {
            id: timesheetsDetailsLomiriShape
            anchors.top: saveMessageTimesheetText.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            radius: "large"
            width: parent.width
            height: parent.height

            Row{
                id: instanceRow
                anchors.left: parent.left
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                         Label {
                            id: instance_label
                            text: "Instance"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                   leftPadding: units.gu(3)
                    ComboBox {
                        id: instance_combo
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: units.gu(5)
                        anchors.centerIn: parent.centerIn
                        flat: true
                        clip: true
                        textRole: "name"
                        model: instanceModel
                        onAccepted: {
                            selectedInstanceId = instanceModel.get(currentIndex).id;
                            project_combo.currentIndex = -1
                            subproject_combo.currentIndex = -1;
                            subproject_combo.editText = ''
                            selectedSubProjectId = 0
                            task_combo.currentIndex = -1;
                            task_combo.editText = ''
                            selectedTaskId = 0
                            sub_task_combo.currentIndex = -1;
                            sub_task_combo.editText = ''
                            selectedSubTaskId = 0
                            setProjectList();
                            setSubProjectList();
                            setTasksList();
                            setSubTasksList();

                        }

                        onCurrentIndexChanged: {
                            if (currentIndex >= 0) {
                                selectedInstanceId = instanceModel.get(currentIndex).id;
                                project_combo.currentIndex = -1;
                                subproject_combo.currentIndex = -1;
                                subproject_combo.editText = ''
                                selectedSubProjectId = 0
                                task_combo.currentIndex = -1;
                                task_combo.editText = ''
                                selectedTaskId = 0
                                sub_task_combo.currentIndex = -1;
                                sub_task_combo.editText = ''
                                selectedSubTaskId = 0
                                setProjectList();
                                setSubProjectList();
                                setTasksList();
                                setSubTasksList();
                            }
                        }
                    }
                }
            }

            Row {
                id: recordDateRow
                anchors.top: instanceRow.bottom
                anchors.left: parent.left
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: recorddate_label                             
                            text: "Date"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column{
                   leftPadding: units.gu(3)
                    TextField {
                        id: record_date_text
                        readOnly: isReadOnly
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        anchors.centerIn: parent.centerIn
                        text: currentTimesheet.record_date
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (record_date_field.visible === false) {
                                    if (!isReadOnly) {
                                        record_date_field.visible = !record_date_field.visible 
                                        record_date_text.text = ""
                                    }
                                }
                                else {
                                    record_date_field.visible = !record_date_field.visible 
                                    record_date_text.text = Qt.formatDate(record_date_field.date, "MM/dd/yyyy")
                                }
                            }
                        }
                    }
                    DatePicker {
                        id: record_date_field
                        visible: false
                        z: 1
                        minimum: {
                            var d = new Date();
                            d.setFullYear(d.getFullYear() - 1);
                            return d;
                        }
                        maximum: Date.prototype.getInvalidDate.call()
                    }
                }       
            }

            Row {
                id: projectRow
                anchors.top: recordDateRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                         Label {
                            id: project_label
                            text: "Project"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                   leftPadding: units.gu(3)
                    ComboBox {
                        id: project_combo
                        editable: true
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: units.gu(5)
                        anchors.centerIn: parent.centerIn
                        flat: true
                        clip: true
                        textRole: "name"
                        model: projectModel
                        onCurrentIndexChanged: {
                            selectedProjectId = 0
                            if (currentIndex >= 0) {
                                selectedProjectId = projectModel.get(currentIndex).id;
                            }
                            subproject_combo.currentIndex = -1;
                            subproject_combo.editText = ''
                            selectedSubProjectId = 0
                            task_combo.currentIndex = -1;
                            task_combo.editText = ''
                            selectedTaskId = 0
                            sub_task_combo.currentIndex = -1;
                            sub_task_combo.editText = ''
                            selectedSubTaskId = 0
                            setSubProjectList();
                            setTasksList();
                            setSubTasksList();
                        }

                        onDisplayTextChanged: {
                            projectDebounceTimer.restart();
                        }

                        Timer {
                            id: projectDebounceTimer
                            interval: 300
                            onTriggered: {
                                var enteredText = project_combo.displayText;
                                var foundIndex = -1;
                                for (var i = 0; i < projectModel.count; i++) {
                                    if (projectModel.get(i).name === enteredText) {
                                        foundIndex = i;
                                        break;
                                    }
                                }

                                if (foundIndex !== -1) {
                                    project_combo.currentIndex = foundIndex;
                                    selectedProjectId = projectModel.get(foundIndex).id;
                                } else {
                                    project_combo.currentIndex = -1;
                                    selectedProjectId = 0;
                                }
                                subproject_combo.currentIndex = -1;
                                subproject_combo.editText = ''
                                selectedSubProjectId = 0
                                task_combo.currentIndex = -1;
                                task_combo.editText = ''
                                selectedTaskId = 0
                                sub_task_combo.currentIndex = -1;
                                sub_task_combo.editText = ''
                                selectedSubTaskId = 0
                                setSubProjectList();
                                setTasksList();
                                setSubTasksList();
                            }
                        }
                    }
                }
            }


            Row {
                id: subProjectRow
                anchors.top: projectRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                         Label {
                            id: subproject_label
                            text: "Sub Project"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                   leftPadding: units.gu(3)
                    ComboBox {
                        id: subproject_combo
                        editable: true
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: units.gu(5)
                        anchors.centerIn: parent.centerIn
                        flat: true
                        clip: true
                        textRole: "name"
                        model: subProjectModel
                        onCurrentIndexChanged: {
                            selectedSubProjectId = 0
                            if (currentIndex >= 0) {
                                selectedSubProjectId = subProjectModel.get(currentIndex).id;
                            }
                            task_combo.currentIndex = -1;
                            task_combo.editText = ''
                            selectedTaskId = 0
                            sub_task_combo.currentIndex = -1;
                            sub_task_combo.editText = ''
                            selectedSubTaskId = 0
                            setTasksList();
                            setSubTasksList();
                        }

                        onDisplayTextChanged: {
                            subProjectDebounceTimer.restart();
                        }

                        Timer {
                            id: subProjectDebounceTimer
                            interval: 300
                            onTriggered: {
                                var enteredText = subproject_combo.displayText;
                                var foundIndex = -1;
                                for (var i = 0; i < subProjectModel.count; i++) {
                                    if (subProjectModel.get(i).name === enteredText) {
                                        foundIndex = i;
                                        break;
                                    }
                                }

                                if (foundIndex !== -1) {
                                    subproject_combo.currentIndex = foundIndex;
                                    selectedSubProjectId = subProjectModel.get(foundIndex).id;
                                } else {
                                    subproject_combo.currentIndex = -1;
                                    selectedSubProjectId = 0;
                                }
                                task_combo.currentIndex = -1;
                                task_combo.editText = ''
                                selectedTaskId = 0
                                sub_task_combo.currentIndex = -1;
                                sub_task_combo.editText = ''
                                selectedSubTaskId = 0
                                setTasksList();
                                setSubTasksList();
                            }
                        }
                    }
                }
            }

            Row {
                id: taskRow
                anchors.top: subProjectRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                         Label {
                            id: task_label
                            text: "Task"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                   leftPadding: units.gu(3)
                    ComboBox {
                        id: task_combo
                        editable: true
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: units.gu(5)
                        anchors.centerIn: parent.centerIn
                        flat: true
                        clip: true
                        textRole: "name"
                        model: taskModel
                        onCurrentIndexChanged: {
                            selectedTaskId = 0
                            if (currentIndex >= 0) {
                                selectedTaskId = taskModel.get(currentIndex).id;
                            }
                            sub_task_combo.currentIndex = -1;
                            sub_task_combo.editText = ''
                            selectedSubTaskId = 0
                            setSubTasksList();
                        }

                        onDisplayTextChanged: {
                            taskDebounceTimer.restart();
                        }

                        Timer {
                            id: taskDebounceTimer
                            interval: 300
                            onTriggered: {
                                var enteredText = task_combo.displayText;
                                var foundIndex = -1;
                                for (var i = 0; i < taskModel.count; i++) {
                                    if (taskModel.get(i).name === enteredText) {
                                        foundIndex = i;
                                        break;
                                    }
                                }

                                if (foundIndex !== -1) {
                                    task_combo.currentIndex = foundIndex;
                                    selectedTaskId = taskModel.get(foundIndex).id;
                                } else {
                                    task_combo.currentIndex = -1;
                                    selectedTaskId = 0;
                                }
                                sub_task_combo.currentIndex = -1;
                                sub_task_combo.editText = ''
                                selectedSubTaskId = 0
                                setSubTasksList();
                            }
                        }
                    }
                }
            }

            Row {
                id: subTaskRow
                anchors.top: taskRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                         Label {
                            id: sub_task_label
                            text: "Sub Task"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                   leftPadding: units.gu(3)
                    ComboBox {
                        id: sub_task_combo
                        editable: true
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: units.gu(5)
                        anchors.centerIn: parent.centerIn
                        flat: true
                        clip: true
                        textRole: "name"
                        model: subTaskModel
                        onCurrentIndexChanged: {
                            selectedSubTaskId = 0
                            if (currentIndex >= 0) {
                                selectedSubTaskId = subTaskModel.get(currentIndex).id;
                            }
                        }

                        onDisplayTextChanged: {
                            subTaskDebounceTimer.restart();
                        }

                        Timer {
                            id: subTaskDebounceTimer
                            interval: 300
                            onTriggered: {
                                var enteredText = sub_task_combo.displayText;
                                var foundIndex = -1;
                                for (var i = 0; i < subTaskModel.count; i++) {
                                    if (subTaskModel.get(i).name === enteredText) {
                                        foundIndex = i;
                                        break;
                                    }
                                }

                                if (foundIndex !== -1) {
                                    sub_task_combo.currentIndex = foundIndex;
                                    selectedSubTaskId = subTaskModel.get(foundIndex).id;
                                } else {
                                    sub_task_combo.currentIndex = -1;
                                    selectedSubTaskId = 0;
                                }
                            }
                        }
                    }
                }
            }

            Row{
                id: descriptionRow
                anchors.top: subTaskRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: description_label                             
                            text: "Description"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column{
                   leftPadding: units.gu(3)
                    TextField {
                        id: description_text
                        // autoSize: true
                        // maximumLineCount: 0
                        readOnly: isReadOnly
                        text: currentTimesheet.description
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                    }
                }
            }

            Row {
                id: spentHoursRow
                anchors.top: descriptionRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: hours_label                             
                            text: "Spent Hours"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column{
                   leftPadding: units.gu(3)
                    TextField {
                        id: hours_text
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        text: currentTimesheet.spentHours
                        readOnly: isReadOnly
                    }
                }       
            }

            Row{
                id: priorityRow
                anchors.top: spentHoursRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                         Label {
                            id: priority_label
                            text: "Priority"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column{
                   leftPadding: units.gu(12)
                    Slider {
                        id: prioritySlider
                        minimumValue: 1
                        maximumValue: 4
                        stepSize: 100
                        width: units.gu(20)
                        // value: 0
                        live: true
                        onValueChanged: {
                            var selection = floattoint(value)
                            if (selection === "1")
                            {
                                priority_label.text = "Important, Urgent"
                            }
                            if (selection === "2")
                            {
                                priority_label.text = "Important, Not Urgent"
                            }
                            if (selection === "3")
                            {
                                priority_label.text = "Not Important, Urgent"
                            }
                            if (selection === "4")
                            {
                                priority_label.text = "Not Important, Not Urgent"
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (recordid != 0) {
            currentTimesheet = Timesheet.get_timesheet_details(recordid);
        //     favorites = currentProject.favorites;
            setInstanceList();
            selectedInstanceId = currentTimesheet.instance_id;
            for (var instance = 0; instance < instanceModel.count; instance++) {
                if (instanceModel.get(instance).id === selectedInstanceId) {
                    instance_combo.currentIndex = instance;
                    instance_combo.editText = instanceModel.get(instance).name
                }
            }

            setProjectList();
            selectedProjectId = currentTimesheet.project_id;
            for (var project = 0; project < projectModel.count; project++) {
                if (projectModel.get(project).id === selectedProjectId) {
                    project_combo.currentIndex = project;
                    project_combo.editText = projectModel.get(project).name
                }
            }

            setSubProjectList();
            selectedSubProjectId = currentTimesheet.sub_project_id;
            for (var sub_project = 0; sub_project < subProjectModel.count; sub_project++) {
                if (subProjectModel.get(sub_project).id === selectedSubProjectId) {
                    subproject_combo.currentIndex = sub_project;
                    subproject_combo.editText = subProjectModel.get(sub_project).name
                }
            }

            setTasksList();
            selectedTaskId = currentTimesheet.task_id;
            for (var task = 0; task < taskModel.count; task++) {
                if (taskModel.get(task).id === selectedTaskId) {
                    task_combo.currentIndex = task;
                    task_combo.editText = taskModel.get(task).name
                }
            }

            setSubTasksList();
            selectedSubTaskId = currentTimesheet.sub_task_id;
            for (var sub_task = 0; sub_task < subTaskModel.count; sub_task++) {
                if (subTaskModel.get(task).id === selectedSubTaskId) {
                    sub_task_combo.currentIndex = task;
                    sub_task_combo.editText = subTaskModel.get(task).name
                }
            }
            prioritySlider.value = parseInt(currentTimesheet.quadrant_id || 0) + 1
        } else {
            setInstanceList();
            selectedInstanceId = instanceModel.get(0).id;
            setProjectList();
            instance_combo.currentIndex = instanceModel.get(0).id;
            instance_combo.editText = instanceModel.get(0).id;
            isReadOnly = false;
            currentTimesheet = {'record_date': Qt.formatDate(new Date(), "MM/dd/yyyy")}
        }
    }
}

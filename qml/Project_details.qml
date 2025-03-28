/*
 * Copyright (C) 2025  Monk Consulting
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * scrollbarex is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Components.Pickers 1.3
import QtCharts 2.0
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import "../models/Project.js" as Project
import "../models/Utils.js" as Utils


Page {
    id: projectDetails
    title: "Project Details"
    header: PageHeader {
        title: projectDetails.title
        ActionBar {
            numberOfSlots: 2
            anchors.right: parent.right
            actions: [
                Action {
                    iconName: "edit"
                    text: "Edit"
                    visible: isReadOnly
                    onTriggered:{
                        isReadOnly = !isReadOnly

                    }
                },
                Action {
                    iconName: "save"
                    text: "Save"
                    visible: !isReadOnly
                    onTriggered: {
                        // isReadOnly = !isReadOnly
                        var project_data = {'account_id': selectedInstanceId,
                                            'name': project_text.text,
                                            'planned_start_date': planned_start_date_text.text == 'mm/dd/yy' ? 0 : planned_start_date_text.text,
                                            'planned_end_date': planned_end_date_text.text == 'mm/dd/yy' ? 0 : planned_end_date_text.text,
                                            'parent_id': selectedParentId,
                                            'allocated_hours': allocated_hours_text.text,
                                            'description': description_text.text,
                                            'favorites': favorites,
                                            'color': colorComboBox.editText}
                        var response = Project.createUpdateProject(project_data, recordid);
                        if (response) {
                            isVisibleMessage = true;
                            isSaved = response.is_success;
                            saveMessage = response.message;
                            if (isSaved) {
                                isReadOnly = !isReadOnly;                                
                            }
                        }
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
    property var currentProject: {}
    property int favorites: 0
    property int selectedInstanceId: 0
    property int selectedParentId: 0
    property var color_indexes: ["#ffffff","#111111","#960334","#FB3778", "#7C0396","#D937FB", "#030396","#3737FB", "#008585","#33FFFF", "#038203","#37FB37", "#787802","#FBFB37", "#964D03","#FB9937"]

    ListModel {
        id: instanceModel
    }

    ListModel {
        id: projectModel
    }

    function setInstanceList() {
        var instances = Utils.accountlistDataGet();
        instanceModel.clear();
        for (var instance = 0; instance < instances.length; instance++) {
            instanceModel.append({'id': instances[instance].id, 'name': instances[instance].name});
        }
    }

    function setParentProjectList() {
        var parentProjects = Project.fetch_parent_project_list(selectedInstanceId, workpersonaSwitchState);
        projectModel.clear();
        for (var parent = 0; parent < parentProjects.length; parent++) {
            projectModel.append({'id': parentProjects[parent].id, 'name': parentProjects[parent].name});
        }
    }

    Text {
        id: saveMessageText
        text: saveMessage
        color: isSaved ? "green": "red"
        anchors.top: header.bottom
        anchors.topMargin: 10
        leftPadding: units.gu(2)
        visible: isVisibleMessage
    }

    Flickable {
        id: projectDetailPageFlickable
        anchors.fill: parent
        contentHeight: projectDetailLomiriShape.height + 1000
        flickableDirection: Flickable.VerticalFlick
        anchors.top: saveMessageText.bottom
        anchors.topMargin: header.height + units.gu(4)
        width: parent.width

        LomiriShape {
            id: projectDetailLomiriShape
            anchors.top: saveMessageText.bottom
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
                            setParentProjectList()
                            parent_project_combo.currentIndex = -1

                        }

                        onCurrentIndexChanged: {
                            if (currentIndex >= 0) {
                                selectedInstanceId = instanceModel.get(currentIndex).id;
                                setParentProjectList()
                                parent_project_combo.currentIndex = -1;
                            }
                        }
                    }
                }
            }

            Row {
                id: projectNameRow
                anchors.top: instanceRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                         Label {
                            id: project_label
                            text: "Name"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                   leftPadding: units.gu(3)
                    TextField {
                        id: project_text
                        readOnly: isReadOnly
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        text: currentProject.name
                    }
                }
            }

            Row {
                id: plannedStartDateRow
                anchors.top: projectNameRow.bottom
                anchors.left: parent.left
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: plannedstartdate_label                             
                            text: "Start Date"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column{
                   leftPadding: units.gu(3)
                    TextField {
                        id: planned_start_date_text
                        readOnly: isReadOnly
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        anchors.centerIn: parent.centerIn
                        text: currentProject.start_date
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (planned_start_date_field.visible === false) {
                                    if (!isReadOnly) {
                                        planned_start_date_field.visible = !planned_start_date_field.visible 
                                        planned_start_date_text.text = ""
                                    }
                                }
                                else {
                                    planned_start_date_field.visible = !planned_start_date_field.visible 
                                    planned_start_date_text.text = Qt.formatDate(planned_start_date_field.date, "MM/dd/yyyy")
                                }
                            }
                        }
                    }
                    DatePicker {
                        id: planned_start_date_field
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
                id: plannedEndDateRow
                anchors.top: plannedStartDateRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: plannedenddate_label
                            text: "End Date"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                   leftPadding: units.gu(3)
                    TextField {
                        id: planned_end_date_text
                        readOnly: isReadOnly
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        anchors.centerIn: parent.centerIn
                        text: currentProject.end_date
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (planned_end_date_field.visible === false) {
                                    if (!isReadOnly) {
                                        planned_end_date_field.visible = !planned_end_date_field.visible
                                        planned_end_date_text.text = ""
                                    }
                                }
                                else {
                                    planned_end_date_field.visible = !planned_end_date_field.visible 
                                    planned_end_date_text.text = Qt.formatDate(planned_end_date_field.date, "MM/dd/yyyy")
                                }
                            }
                        }
                    }
                    DatePicker {
                        id: planned_end_date_field
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
                id: parentProjectRow
                anchors.top: plannedEndDateRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                         Label {
                            id: projectparent_label                            
                            text: "Parent"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                   leftPadding: units.gu(3)
                    ComboBox {
                        id: parent_project_combo
                        editable: true
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: units.gu(5)
                        anchors.centerIn: parent.centerIn
                        flat: true
                        clip: true
                        textRole: "name"
                        model: projectModel
                        onCurrentIndexChanged: {
                            selectedParentId = 0
                            if (currentIndex >= 0) {
                                selectedParentId = projectModel.get(currentIndex).id;
                            }
                        }

                        onDisplayTextChanged: {
                            inputDebounceTimer.restart();
                        }

                        Timer {
                            id: inputDebounceTimer
                            interval: 300
                            onTriggered: {
                                var enteredText = parent_project_combo.displayText;
                                var foundIndex = -1;
                                for (var i = 0; i < projectModel.count; i++) {
                                    if (projectModel.get(i).name === enteredText) {
                                        foundIndex = i;
                                        break;
                                    }
                                }

                                if (foundIndex !== -1) {
                                    parent_project_combo.currentIndex = foundIndex;
                                    selectedParentId = projectModel.get(foundIndex).id;
                                } else {
                                    parent_project_combo.currentIndex = -1;
                                    selectedParentId = 0;
                                }
                            }
                        }
                    }
                }
            }

            Row{
                id: allocatedHoursRow
                anchors.top: parentProjectRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column{
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                         Label {
                            id: allocatedhours_label
                            text: "Allocated Hours"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                   leftPadding: units.gu(3)
                    TextField {
                        id: allocated_hours_text
                        readOnly: isReadOnly
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        text: currentProject.allocated_hours
                    }
                }
            }

            Row {
                id: descriptionRow
                anchors.top: allocatedHoursRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column {
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
                Column {
                   leftPadding: units.gu(3)
                    TextField {
                        id: description_text
                        readOnly: isReadOnly
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        text: currentProject.description
                    }
                }
            }

            Row{
                id: colorSelectionRow
                anchors.top: descriptionRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(10)
                        height: units.gu(5)
                        Label {
                            id: color_label                             
                            text: "Color"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                   leftPadding: units.gu(3)
                    ComboBox {
                        id: colorComboBox
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        model: color_indexes
                        editable: false

                        delegate: Item {
                            width: parent.width
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                color: modelData
                                border.color: "#ccc"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    colorComboBox.currentIndex = index;
                                    colorComboBox.popup.visible = false;
                                }
                            }
                        }

                        contentItem: Rectangle {
                            width: 100
                            height: 30
                            color: colorComboBox.model[colorComboBox.currentIndex]
                            border.color: "#ccc"
                        }
                        currentIndex: 0
                    }


                }
            }

            Row{
                id: priorityRow
                anchors.top: colorSelectionRow.bottom
                anchors.left: parent.left 
                topPadding: 10
                Column {
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
                Column {
                   leftPadding: units.gu(3)
                    Row {
                        width: units.gu(20)
                        height: units.gu(20)
                        id: img_star
                        spacing: 5
                        property int selectedPriority: 0

                        Repeater {
                            model: 1  
                            delegate: Item {
                                width: units.gu(5)  
                                height: units.gu(5)

                                Image {
                                    id: starImage
                                    source: (index < favorites) ? "images/star-active.svg" : "images/starinactive.svg"  
                                    anchors.fill: parent
                                    smooth: true  

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (index + 1 === favorites) {
                                                favorites = !favorites
                                            } else {
                                                favorites = !favorites
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }


        }
    }

    Component.onCompleted: {
        if (recordid != 0) {
            currentProject = Project.get_project_detail(recordid, workpersonaSwitchState);
            favorites = currentProject.favorites;
            setInstanceList();
            selectedInstanceId = currentProject.account_id;
            setParentProjectList();
            selectedParentId = currentProject.parent_id || 0;
            for (var i = 0; i < instanceModel.count; i++) {
                if (instanceModel.get(i).id === selectedInstanceId) {
                    instance_combo.currentIndex = i;
                    instance_combo.editText = instanceModel.get(i).name
                }
            }

            for (var i = 0; i < projectModel.count; i++) {
                if (projectModel.get(i).id === selectedParentId) {
                    parent_project_combo.currentIndex = i;
                    parent_project_combo.editText = projectModel.get(i).name
                }
            }
            for (var colorIndex = 0; colorIndex < color_indexes.length; colorIndex++) {
                if (currentProject.selected_color == color_indexes[colorIndex]) {
                    colorComboBox.currentIndex = colorIndex;
                }
            }
            currentProject.description = currentProject.description.replace(/<[^>]+>/g, " ") 
                        .replace(/<p>;/g,"")
                        .replace(/&nbsp;/g, "")
                        .replace(/&lt;/g, "<")
                        .replace(/&gt;/g, ">")
                        .replace(/&amp;/g, "&")
                        .replace(/&quot;/g, "\"")
                        .replace(/&#39;/g, "'")
                        .trim() || "";
        } else {
            setInstanceList();
            selectedInstanceId = instanceModel.get(0).id;
            setParentProjectList();
            instance_combo.currentIndex = instanceModel.get(0).id;
            instance_combo.editText = instanceModel.get(0).id;
            isReadOnly = false;
            currentProject = {"allocated_hours": "00:00"}
        }
    }
}

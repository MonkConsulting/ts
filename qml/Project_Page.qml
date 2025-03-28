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
import QtQuick.Window 2.2
import Ubuntu.Components 1.3 as Ubuntu
import QtQuick.LocalStorage 2.7
import "../models/Timesheet.js" as Model
import "../models/Project.js" as Project

Page{
    id: project
    title: "Project"
    header: PageHeader {
        id: projectheader
        title: project.title
        ActionBar {
            numberOfSlots: 1
            anchors.right: parent.right
            actions: [
                Action {
                    iconName: "add"
                    text: "New"
                    onTriggered:{
                        console.log("Create Project clicked");
                        // apLayout.addPageToCurrentColumn(project, Qt.resolvedUrl("Project_Create.qml"))
                        apLayout.addPageToNextColumn(project, Qt.resolvedUrl("Project_details.qml"),{"recordid":0});
                    }
                }
            ]
        }
    }

    property var workpersonaSwitchState: true;

    function fetch_projects_list() {
        var projectsList = Project.fetch_projects_list(workpersonaSwitchState);
        projectModel.clear();
        for (var project_record = 0; project_record < projectsList.length; project_record++) {
            projectModel.append({'id': projectsList[project_record].id,
                                'name': projectsList[project_record].name,
                                'deadline': projectsList[project_record].planned_end_date,
                                'allocatedHours': projectsList[project_record].allocated_hours,
                                'favorites': projectsList[project_record].favorites,
                                'color_pallet': projectsList[project_record].color_pallet || '#FFFFFF'})
        }
        // listData = projectsList;
        // projectListView.model = projectsList;
    }

    ListModel {
        id: projectModel
    }

    LomiriShape {
        anchors.top: projectheader.bottom
        height: parent.height
        width: parent.width
        Component {
            id: projectDelegate
            LomiriShape{
                width: parent.width
                height: units.gu(10)
                Row {
                    height: units.gu(10)
                    spacing: 10
                    Column{
                        leftPadding: units.gu(3)
                        width: units.gu(35)
                        height: units.gu(10)
                        Row {
                            spacing: 5
                            Rectangle {
                                width: units.gu(2)
                                height: units.gu(2)
                                color: color_pallet
                            }
                            Text { 
                                id: projecttext
                                width: units.gu(20)
                                text: name
                                clip: true
                            }
                        }
                        Text {
                            anchors.left:projecttext.left
                            text: allocatedHours
                            leftPadding: units.gu(3)
                        }
                    }
                    Column{
                        width: units.gu(10)
                        height: units.gu(10)
                        Text {
                            id: deadlinetext
                            text: deadline
                         }
                        Image {
                            id: starImageList
                            anchors.right: parent.right
                           source: favorites > 0 ? "images/star-active.svg" : "images/starinactive.svg" 
                            width: units.gu(3)
                            height: units.gu(3)
                            smooth: true  
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        projectlist.currentIndex = index
                        apLayout.addPageToNextColumn(project, Qt.resolvedUrl("Project_details.qml"),{"recordid":id});
                    }
                }   
            }
        }

        LomiriListView {
            id: projectlist
            anchors.fill: parent
            model: projectModel
            delegate: projectDelegate
            highlight: Rectangle { anchors.left: parent.left; anchors.right: parent.right; color: "lightsteelblue"; radius: 5 }
            highlightFollowsCurrentItem: true
            currentIndex: 0
            onCurrentIndexChanged: {
                console.log("currentIndex changed")
            }

           Component.onCompleted: {
                // get_project_list(0)
                fetch_projects_list()
            }
        }
    }
}

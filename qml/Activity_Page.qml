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
import "../models/Timesheet.js" as Model
import "../models/Project.js" as Project
import "../models/Activity.js" as Activity
import "../models/Utils.js" as Utils


Page{
    id: activity
    title: "Activities"
        header: PageHeader {
            id: taskheader
            title: activity.title
                ActionBar {
                numberOfSlots: 1
                anchors.right: parent.right
            //    enable: true
                    actions: [
                        Action {
                            iconName: "add"
                            text: "New"
                            onTriggered:{
                                console.log("Create Activity clicked");
                                apLayout.addPageToCurrentColumn(activity, Qt.resolvedUrl("Activity_Create.qml"))

                            }
                        }
                    ]
                }
        }

    
    function get_activity_list(recordid){
            var activities = Activity.queryActivityData(recordid)
            activityListModel.clear();
            for (var activity = 0; activity < activities.length; activity++) {
                activityListModel.append({'id': activities[activity].id, 'summary': activities[activity].summary, 
                'due_date': activities[activity].due_date})
            } 
        }



    ListModel {
        id: activityListModel
    }

    LomiriShape {
        anchors.top: taskheader.bottom
        height: parent.height
        width: parent.width

    
        Component {
            id: activityDelegate
            LomiriShape{
                width: parent.width
                height: units.gu(10)
                Row {
                    height: units.gu(10)
                    spacing: 10
                    Column{
                        width: 200
                        height: units.gu(10)
                        Label{ 
                           id: tasklabel 
                            text: "Activity: "}
                        Text { 
                            width: units.gu(20)
                            anchors.left: tasklabel.left
                            text: summary 
                            clip: true
                            }
                        Label{ 
                            id: idlabel
                            text: "ID: "}
                        Text { 
                            anchors.left:idlabel.left
                            text: id }
                    }
                    Column{
                        width: 150
                        height: units.gu(10)
                        Label{ text: "Due Date: "}
                        Text { text: due_date }
/*                        Label{ text: "Planned: "}
                        Text { text: allocated_hours }*/
                    }

                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
    					activitylist.currentIndex = index
                        apLayout.addPageToNextColumn(activity, Qt.resolvedUrl("Activity_details.qml"),{"recordid":id});
                    }
                }   
            }

        }

        LomiriListView {
            id: activitylist
            anchors.fill: parent
//            anchors.top: taskheader.bottom
            model: activityListModel
            delegate: activityDelegate
            highlight: Rectangle { anchors.left: parent.left; anchors.right: parent.right; color: "lightsteelblue"; radius: 5 }
            highlightFollowsCurrentItem: true
            currentIndex: 0
            onCurrentIndexChanged: {
                    console.log("currentIndex changed")
                }            

           Component.onCompleted: {
                      get_activity_list(0)


            }
        }
    }
}
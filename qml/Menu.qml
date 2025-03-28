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
import Lomiri.Components 1.3
import QtCharts 2.0
import QtQuick.Layouts 1.11
import Qt.labs.settings 1.0
import "../models/Main.js" as Model
import "../models/DbInit.js" as DbInit
import "../models/DemoData.js" as DemoData



Page {
    id: listpage
    title: "Menu"
    anchors.fill: parent
    header: PageHeader {
        id: header
        title: listpage.title
            ActionBar {
                id: actionbar
                numberOfSlots: 1
                anchors.right: parent.right
                actions: [
                   Action {
                        iconName: "appointment-new"
                        text: "Theme"
                        onTriggered:{
                            apLayout.addPageToNextColumn(listpage, Qt.resolvedUrl("Timesheet.qml"))
                            page = 1
                            apLayout.setCurrentPage(page)

                        }
                   }
                ]
            }
    }

    property var page: 0
    LomiriShape{
        anchors.top: header.bottom
        width: parent.width
        height: parent.height
    
        Column {
            anchors.fill: parent
            ListItem {
                height: units.gu(5)
                Rectangle{
                    width: 20
                    height: units.gu(5)
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        name: "home"
                    }
                }
                Label {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "Dashboard"
                }
                onClicked: {
                    page = 0;
                    apLayout.setCurrentPage(page)
                    var incubator = apLayout.addPageToNextColumn(listpage, Qt.resolvedUrl("Dashboard.qml"));

                } 
            }                
            ListItem {
                height: units.gu(5)
                Rectangle{
                    width: 20
                    height: units.gu(5)
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        name: "alarm-clock"
                    }
                }
                Label {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "Timesheet"
                }
                onClicked: {
                    apLayout.addPageToNextColumn(listpage, Qt.resolvedUrl("Timesheet_Page.qml"));
                    page = 1;
                    apLayout.setCurrentPage(page)
                } 
            }
            ListItem {
                height: units.gu(5)
                Rectangle{
                    width: 20
                    height: units.gu(5)
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        name: "calendar"
                    }
                }                    
                Label {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "Activities"
                }
                onClicked: {
                    apLayout.addPageToNextColumn(listpage, Qt.resolvedUrl("Activity_Page.qml"))
                    page = 2;
                    apLayout.setCurrentPage(page)
                }
            }
            ListItem {
                height: units.gu(5)
                Rectangle{
                    width: 20
                    height: units.gu(5)
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        name: "view-list-symbolic"
                    }
                }                    
                Label {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "Tasks"
                }
                onClicked: {
                    apLayout.addPageToNextColumn(listpage, Qt.resolvedUrl("Task_Page.qml"))
                    page = 3;
                    apLayout.setCurrentPage(page)
                }
                }   
            ListItem {
                height: units.gu(5)
                Rectangle{
                    width: 20
                    height: units.gu(5)
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        name: "folder-symbolic"
                    }
                }
                Label {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "Projects"
                }
                onClicked: {
                    apLayout.addPageToNextColumn(listpage, Qt.resolvedUrl("Project_Page.qml"))
                    page = 4;
                    apLayout.setCurrentPage(page)
                }                
            }
            ListItem {
                height: units.gu(5)
                Rectangle{
                    width: 20
                    height: units.gu(5)
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        name: "sync"
                    }
                }
                Label {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "Sync"
                }
                onClicked: {
                    apLayout.addPageToNextColumn(listpage, Qt.resolvedUrl("Sync_Page.qml"))
                    page = 5;
                    apLayout.setCurrentPage(page)
                }                
            }
            ListItem {
                height: units.gu(5)
                Rectangle{
                    width: 20
                    height: units.gu(5)
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        name: "settings"
                    }
                }
                Label {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "Settings"
                }
                onClicked: {
                    apLayout.addPageToNextColumn(listpage, Qt.resolvedUrl("Settings_Page.qml"))
                    page = 6;
                    apLayout.setCurrentPage(page)
                }                
            }
        }
    }
}
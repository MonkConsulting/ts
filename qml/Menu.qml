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
    }

    property var page: 0
    LomiriShape{
        anchors.top: header.bottom
        width: parent.width
        height: parent.height
    
        Column {
            anchors.fill: parent
            ListItem {
                Rectangle{
                    width: 40
                    height: 40
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: 40
                        name: "home"
                    }
                }
                Label {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "Dashboard"
                }
                onClicked: {
                    apLayout.addPageToNextColumn(listpage, Qt.resolvedUrl("Dashboard.qml"));
                    page = 0;
                    apLayout.setCurrentPage(page)
                } 
            }                
            ListItem {
                Rectangle{
                    width: 40
                    height: 40
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: 40
                        name: "alarm-clock"
                    }
                }
                Label {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "Timesheet"
                }
                onClicked: {
                    apLayout.addPageToNextColumn(listpage, Qt.resolvedUrl("Timesheet.qml"),{"textval":"Hahaha"});
                    page = 1;
                    apLayout.setCurrentPage(page)
                } 
            }
            ListItem {
                Rectangle{
                    width: 40
                    height: 40
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: 40
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
                Rectangle{
                    width: 40
                    height: 40
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: 40
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
                Rectangle{
                    width: 40
                    height: 40
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: 40
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
                Rectangle{
                    width: 40
                    height: 40
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: 40
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
                Rectangle{
                    width: 40
                    height: 40
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: 40
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
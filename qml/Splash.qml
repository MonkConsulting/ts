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
    id: splashPage
    title: "Timesheet"
    anchors.fill: parent

    header: PageHeader{
        id: header
        visible: false
        title: "Splash"   
    } 
        
    Rectangle{
        id: splashrect
        visible: true
        anchors.fill: parent
        width: units.gu(45)
        height: units.gu(75)
        color: "#ffffff"
        border.color: "black"
        border.width: 1
        Image {
            id: image
            anchors.centerIn: parent
            width: units.gu(45)
            height: units.gu(40)
            source: "time_management_logo_4_3.jpg"
        }
        Timer {
            interval: 2000; 
            running: true
            repeat: false
            onTriggered: {
                splashrect.visible = false
                apLayout.setFirstScreen();
            }
        }

    }

}

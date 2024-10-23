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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Window 2.2


ListView {
    id: root
    property int selectedYear:      2024

    signal clicked(date date);  // onClicked: print('onClicked', date.toDateString())

 // private
    property date selectedDate: new Date()
    function isDesktop() {
        if(Screen.width > 1300){
            return true;
        }else{
            return false;
        }
    }
    width: isDesktop() ? 450 : 600;  height: isDesktop() ? 450 : 600 // default size
    snapMode:    ListView.SnapOneItem
    orientation: Qt.Horizontal
    clip:        true
    anchors.margins: 0

    model: 500 * 12 // index == months since January of the year 0

    function set(year, month) {
        selectedYear = year
        selectedDate = new Date(year, month, selectedDate.getDate())
        var index = year * 12 + month
        listView.currentIndex = index
        // positionViewAtIndex(index, ListView.Center)
    }

    Item {
        width: isDesktop() ? 400 : 600 // Adjust width as needed
        height: isDesktop() ? 345 : 600 // Adjust height as needed
        anchors.centerIn: parent
        Row {
            spacing: 10
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: isDesktop() ? 0 : 80
                // margins.top: 80 // Add top margin to separate from previous item
            }

            ComboBox {
                id: yearSelector
                // width: 50
                width: isDesktop() ? 200 : 300
                height: isDesktop() ? 30 : 57
                // model: 10 // Example: show 10 years
                textRole: "yearText"
                model: ListModel {
                    Component.onCompleted: {
                        var currentYear = new Date().getFullYear();
                        for (var i = currentYear; i < currentYear + 10; ++i) {
                            append({ "yearText": i.toString() });
                        }
                    }
                }

                onCurrentTextChanged: {
                    selectedYear = parseInt(currentText)
                }
                // Populate the years, or dynamically populate based on your needs
                // Example: you might populate years from current year to current year + 10
            }

            Button {
                width: isDesktop() ? 80 : 100
                height: isDesktop() ? 30 : 50

                background: Rectangle {
                    color: "#FB634E"
                    radius: 10
                    border.color: "#FB634E"
                    border.width: 2
                    anchors.fill: parent
                }
                contentItem: Text {
                    anchors.fill: parent
                    text: "Go"
                    color: "#fff"
                    font.pixelSize: isDesktop() ? 20 : 30
                    horizontalAlignment: Text.AlignHCenter // Align text horizontally (redundant here but useful for multi-line)
                    verticalAlignment: Text.AlignVCenter


                }

                onClicked: {
                    var selectedYear = parseInt(yearSelector.currentText)
                    root.set(selectedYear, root.selectedDate.getMonth())
                }
            }
        }
    }

    delegate: Item {
        // property int year:      Math.floor(index / 12)
        property int month:     index % 12 // 0 January
        property int firstDay:  new Date(selectedYear, month, 1).getDay() // 0 Sunday to 6 Saturday

        width: root.width;  height: root.height

        Rectangle {
            width: parent.width
            height: isDesktop() ? 390 : 600
            color: "#121944"
            border.color: "#121944"
        }

        // Add top margin by adjusting the y position
        y: 10

        Column {
            spacing: isDesktop() ? 40 : 60

            Item { // month year header
                width: root.width;  
                height: isDesktop() ? root.height - grid.height - 100 : root.height - grid.height - 70;


                Text { // month year
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        // topMargin: 500 // Add top margin to create space above the Text
                        centerIn: parent
                    }

                    // anchors.centerIn: parent
                    color: "#fff"
                    text: ['January', 'February', 'March', 'April', 'May', 'June',
                           'July', 'August', 'September', 'October', 'November', 'December'][month] + ' ' + selectedYear
                    font {pixelSize: 0.5 * grid.cellHeight}
                }

            }

            Grid { // 1 month calender
                id: grid

                width: root.width;  height: (isDesktop() ? 0.675 : 0.745) * root.height
                property real cellWidth:  width  / columns;
                property real cellHeight: height / rows // width and height of each cell in the grid.

                columns: 7 // days
                rows:    7

                Repeater {
                    model: grid.columns * grid.rows // 49 cells per month

                    delegate: Rectangle { // index is 0 to 48
                        property int day:  index - 7 // 0 = top left below Sunday (-7 to 41)
                        property int date: day - firstDay + 1 // 1-31

                        width: grid.cellWidth;  height: grid.cellHeight
                        border.width: 0.3 * radius
                        border.color: new Date(selectedYear, month, date).toDateString() == selectedDate.toDateString()  &&  text.text  &&  day >= 0?
                                      'black': 'transparent' // selected
                        radius: 0.02 * root.height
                        opacity: !mouseArea.pressed? 1: 0.3  //  pressed state

                        Text {
                            id: text

                            anchors.centerIn: parent
                            font.pixelSize: 0.5 * parent.height
                            font.bold:      new Date(selectedYear, month, date).toDateString() == new Date().toDateString() // today
                            text: {
                                if(day < 0)                                               ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index] // Su-Sa
                                else if(new Date(selectedYear, month, date).getMonth() == month)  date // 1-31
                                else                                                      ''
                            }
                        }

                        MouseArea {
                            id: mouseArea

                            anchors.fill: parent
                            enabled:    text.text  &&  day >= 0

                            onClicked: {
                                selectedDate = new Date(selectedYear, month, date)
                                root.clicked(selectedDate)
                            }
                        }
                    }
                }
            }
        }
    }

}

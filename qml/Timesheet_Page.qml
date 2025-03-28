import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import QtQuick.Window 2.2
import Ubuntu.Components 1.3 as Ubuntu
import QtQuick.LocalStorage 2.7
import "../models/Timesheet.js" as Model
import "../models/Project.js" as Project

Page{
    id: timesheets
    title: "Timesheets"
    header: PageHeader {
        id: timesheetsheader
        title: timesheets.title
        ActionBar {
            numberOfSlots: 1
            anchors.right: parent.right
            actions: [
                Action {
                    iconName: "add"
                    text: "New"
                    onTriggered:{
                        console.log("Create Timesheet clicked");
                        apLayout.addPageToNextColumn(timesheets, Qt.resolvedUrl("Timesheet.qml"));
                    }
                }
            ]
        }
    }

    property var workpersonaSwitchState: true;

    function fetch_timesheets_list() {
        var timesheets_list = Model.fetch_timesheets(workpersonaSwitchState);
        timesheetModel.clear();
        for(var timesheet = 0; timesheet < timesheets_list.length; timesheet++) {
            timesheetModel.append({'id': timesheets_list[timesheet].id,
                                'instance': timesheets_list[timesheet].instance,
                                'project': timesheets_list[timesheet].project,
                                'spentHours': timesheets_list[timesheet].spentHours,
                                'quadrant': timesheets_list[timesheet].quadrant || 0,
                                'date': timesheets_list[timesheet].date});
        }
    }

    ListModel {
        id: timesheetModel
    }

    LomiriShape {
        anchors.top: timesheetsheader.bottom
        height: parent.height
        width: parent.width
        Component {
            id: timesheetDelegate
            LomiriShape{
                width: parent.width
                height: units.gu(10)
                Row {
                    height: units.gu(10)
                    spacing: 10
                    Column{
                       leftPadding: units.gu(3)
                        width: units.gu(30)
                        height: units.gu(10)
                        Text { 
                            id: instancetext
                            width: units.gu(20)
                            text: instance
                            clip: true
                        }
                        Text { 
                            id: projecttext
                            width: units.gu(20)
                            text: project
                            clip: true
                        }
                        Text { 
                            anchors.left:projecttext.left
                            text: spentHours 
                        }
                    }
                    Column{
                        width: units.gu(10)
                        height: units.gu(10)
                        Text {
                            id: datetext
                            text: date
                        }
                        Text {
                            id: quadranttext
                            text: quadrant
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        timesheetlist.currentIndex = index
                        apLayout.addPageToNextColumn(timesheets, Qt.resolvedUrl("Timesheet_details.qml"),{"recordid":id});
                    }
                }   
            }

        }

        LomiriListView {
            id: timesheetlist
            anchors.fill: parent
            model: timesheetModel
            delegate: timesheetDelegate
            highlight: Rectangle { anchors.left: parent.left; anchors.right: parent.right; color: "lightsteelblue"; radius: 5 }
            highlightFollowsCurrentItem: true
            currentIndex: 0
            onCurrentIndexChanged: {
                console.log("currentIndex changed")
            }

           Component.onCompleted: {
                // get_project_list(0)
                fetch_timesheets_list()
            }
        }
    }
}

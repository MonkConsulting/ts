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

import QtQuick 2.6
import Lomiri.Components 1.3
import QtQuick.Window 2.2
import QtQuick.Layouts 1.11
import "../models/DbInit.js" as DbInit

MainView {

    id: mainView
    
    objectName: "TS"  
    applicationName: "tsapp.monk"
    property bool init: true

//  width: Screen.desktopAvailableWidth < units.gu(130) ? units.gu(40) : units.gu(130)
    width: units.gu(50) //GM: for testing with only one column
    height: units.gu(95)
  

    AdaptivePageLayout {
        id: apLayout
        anchors.fill: parent
        property bool isMultiColumn: true       
        property Page currentPage: splash_page
        property Page thirdPage: dashboard_page2
        primaryPage: splash_page

        layouts: [
            PageColumnsLayout {
                when: width > units.gu(80) && width < units.gu(130)
                // column #0
                PageColumn {
                    minimumWidth: units.gu(20)
                    maximumWidth: units.gu(30)
                    preferredWidth: width > units.gu(90) ? units.gu(20) : units.gu(15)
                }
                // column #1
                PageColumn {
                    minimumWidth: units.gu(50)
                    maximumWidth: units.gu(80)
                    preferredWidth: width > units.gu(90) ? units.gu(60) : units.gu(45)
                }
             
            },
            PageColumnsLayout {
                when: width >= units.gu(130) 
                // column #0
                PageColumn {
                    minimumWidth: units.gu(20)
                    maximumWidth: units.gu(30)
                    preferredWidth: units.gu(20)
                }
                // column #1
                PageColumn {
                    minimumWidth: units.gu(65)
                    maximumWidth: units.gu(80)
                    preferredWidth: units.gu(50)
                }
                // column #2
                PageColumn {
                    fillWidth: true
                }
            }
        ]
 
        Splash{
            id:splash_page
        }
        Menu{
            id:menu_page
        }
        Dashboard{
            id:dashboard_page
        }                
        Dashboard2{
            id:dashboard_page2
        }         
        Timesheet{
            id:timesheet_page
        }        
        Activity_Page{
            id:activity_page
        }
        Task_Page{
            id:task_page
        }
        Project_Page{
            id:project_page
        }
        Sync_Page{
            id:sync_page
        }
        Settings_Page{
            id:settings_page
        }
        Timesheet_Page{
            id:timesheet_list
        }  

        function setFirstScreen()
        {
            console.log("First Screen " + columns);
            switch (columns){
                case 1: 
                    primaryPage = dashboard_page;
                    currentPage = dashboard_page
                    break
                case 2:  
                    primaryPage = menu_page;
                    currentPage = dashboard_page
                    addPageToNextColumn(primaryPage,currentPage);
                    break
                case 3:
                    primaryPage = menu_page;
                    currentPage = dashboard_page
                    addPageToNextColumn(primaryPage,currentPage);
                    addPageToNextColumn(currentPage,thirdPage);
                    break
            }
            init = false; 
        }


        function setCurrentPage(page){
            console.log("In setCurrentPage Page is :" + page + " Current Page" + currentPage)
            switch(page){
                case 0:
                    currentPage = dashboard_page
                    thirdPage = dashboard_page2
                    if(apLayout.columns === 3){
//                        addPageToNextColumn(currentPage,thirdPage);
                    }
                    break
                case 1:
                    currentPage = timesheet_page
                    thirdPage = null
                    break
                case 2:
                    currentPage = activity_page
                    thirdPage = null
                    break
                case 3:
                    currentPage = task_page
                    thirdPage = null
                    break
                case 4:
                    currentPage = project_page
                    thirdPage = null
                    break
                case 5:
                    currentPage = sync_page
                    thirdPage = null
                    break
                case 6:
                    currentPage = settings_page
                    thirdPage = null
                    break                                                                             
                case 7:
                    currentPage = timesheet_list
                    thirdPage = null
                    break               }
        }


        onColumnsChanged: {
            console.log("onColumnsChanged: "+ columns + " width " + units.gu(width));
            if(init === false){ 
                console.log("currentPage: " + currentPage + "Primarypage: " + primaryPage + " column changed " + columns + " width " + units.gu(width));
                switch (columns){
                    case 1: primaryPage = dashboard_page;                            
                            addPageToCurrentColumn(primaryPage,currentPage);
                        break
                    case 2:  primaryPage = menu_page;
                             addPageToNextColumn(primaryPage,currentPage);
                        break
                    case 3:  primaryPage = menu_page;
                             addPageToNextColumn(primaryPage,currentPage);
                             if (thirdPage != "")
                                 addPageToNextColumn(currentPage,thirdPage);

                        break
                }

            }
        }
    
        Component.onCompleted: {
            console.log("From OnComplete " + columns); 
            DbInit.initializeDatabase();
        }
        
    }
}
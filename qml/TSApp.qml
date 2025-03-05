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

MainView {

    id: mainView
    
    objectName: "TS"  
    applicationName: "tsapp.monk"

//    width: Screen.desktopAvailableWidth < units.gu(130) ? units.gu(40) : units.gu(130)
    width: units.gu(50) //GM: for testing with only one column
    height: units.gu(95)
  
    

    AdaptivePageLayout {
        id: apLayout
        anchors.fill: parent
        property bool isMultiColumn: true
        property Page currentPage: page2
        primaryPage: page2
        layouts: [
            PageColumnsLayout {
                when: width > units.gu(80) && width < units.gu(130)
                // column #0
                PageColumn {
                    minimumWidth: units.gu(50)
                    maximumWidth: units.gu(65)
                    preferredWidth: width > units.gu(90) ? units.gu(60) : units.gu(50)
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
                    minimumWidth: units.gu(25)
                    maximumWidth: units.gu(35)
                    preferredWidth: units.gu(35)
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
 
        Menu{
            id:page1
        }
        Dashboard{
            id:page2
        }

                
        Timesheet{
            id:page3
        }        
        Activity_Page{
            id:page4
        }
        Task_Page{
            id:page5
        }
        Project_Page{
            id:page6
        }
        Sync_Page{
            id:page7
        }
        Settings_Page{
            id:page8
        }


        function setCurrentPage(page){
            console.log("In setCurrentPage Page is :" + page)
            switch(page){
                case 1:
                    currentPage = page3
                    break
                case 2:
                    currentPage = page4
                    break
                case 3:
                    currentPage = page5
                    break
                case 4:
                    currentPage = page6
                    break
                case 5:
                    currentPage = page7
                    break
                case 6:
                    currentPage = page8
                    break                                                                             
            }
        }


        onColumnsChanged: {
          

       


           console.log("currentPage: " + currentPage + "Primarypage: " + primaryPage + " column changed " + columns + " width " + units.gu(width));

            switch (columns){
                case 1:  primaryPage = page2;
                         addPageToCurrentColumn(primaryPage,currentPage);

                    break
                case 2:  primaryPage = page1;
                         addPageToNextColumn(primaryPage,currentPage);
                    break
                case 3:primaryPage = page1;
                         addPageToNextColumn(primaryPage,currentPage);
                    break

            }
/*
           if(columns > 1){
            currentPage = primaryPage
            primaryPage = page1     
            addPageToNextColumn(primaryPage,currentPage);
           }
           else{
            if(currentPage != null)
            {
                primaryPage = currentPage     

            }


           }*/
/*
           if (columns > 1 ){
            addPageToNextColumn(page1, page2);
            addPageToNextColumn(page2, page4);
           }
            else
            {
              removePages(page2)
              removePages(page4)

            }*/
        }
    
        Component.onCompleted: {
           console.log("From OnComplete " + columns);
/*           if (apLayout.columns > 1){
                apLayout.addPageToNextColumn(page1, page2);
                apLayout.addPageToNextColumn(page2, page4);
            }*/
            currentPage = primaryPage;
        }
        
    }
}
import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import QtQuick.Window 2.2
import io.thp.pyotherside 1.4
import "../models/Sync.js" as SyncData

Page {
	id: createAccountPage
    title: "Create Account"

    header: PageHeader {
        id: pageHeader
        title: createAccountPage.title
        trailingActionBar.actions: [
            Action {
                iconName: "document-save"
                onTriggered: {
                    if (!accountNameInput.text) {
                        isValidAccount = false;
                    } else {
                        isValidAccount = true;
                        isValidLogin = true;
                        connectionSuccess = false;
                        python.call("backend.login_odoo", [linkInput.text, usernameInput.text, passwordInput.text, {'input_text': dbInput.text || single_db, 'selected_db': database_combo.currentText, 'isTextInputVisible': isTextInputVisible, 'isTextMenuVisible': isTextMenuVisible}], function (result) {
                            if (result && result['result'] == 'pass') {
                                let apikey = ""
                                if(selectedconnectwithId == 1) {
                                    apikey = passwordInput.text
                                }
                                var isDuplicate = SyncData.createAccount(accountNameInput.text, linkInput.text, result['database'], usernameInput.text,selectedconnectwithId,apikey)
                                if (isDuplicate) {
                                    alreadyExistAccount = true;
                                } else {
                                    isValidLogin = true;
                                    connectionSuccess = true;
                                    alreadyExistAccount = false;
                                }
                            } else {
                                isValidLogin = false;
                                connectionSuccess = false;
                                alreadyExistAccount = false;
                            }
                        })
                    }
                }
            }
        ]
    }

    property bool isTextInputVisible: false
    property bool isTextMenuVisible: false
    property bool connectionSuccess: false
    property bool isValidUrl: true
    property bool isValidLogin: true
    property bool isValidAccount: true
    property bool isPasswordVisible: false
    property int selectedconnectwithId: 1
    property bool alreadyExistAccount: false
    property string single_db: ""

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            importModule_sync("backend");
        }

        onError: {
        }
    }

    ListModel {
        id: databaseListModel
    }

    ListModel {
        id: menuconnectwithModel
        ListElement { modelData: "Connect With Api Key"; itemid:0  }
        ListElement { modelData: "Connect With Password"; itemid:1 }
    }

    Flickable {
        id: accountPageFlickable
        anchors.fill: parent
        contentHeight: signup_shape.height + 1500
        flickableDirection: Flickable.VerticalFlick
        anchors.top: pageHeader.bottom
        anchors.topMargin: pageHeader.height + units.gu(4)
        width: parent.width
        LomiriShape {
            id: signup_shape
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            radius: "large"
            width: parent.width
            height: parent.height
            Row {
                id: accountRow
                anchors.topMargin: 5
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(12)
                        height: units.gu(4)
                        Label {
                            id: account_name_label
                            text: "Account Name"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                    leftPadding: units.gu(1)
                    Rectangle {
                        width: units.gu(28)
                        height: units.gu(5)
                        TextField {
                            id: accountNameInput
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: "Account Name"
                            width: parent.width
                        }
                    }
                }
            }

            Row {
                id: linkRow
                anchors.top: accountRow.bottom
                // anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: units.gu(2)
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(12)
                        height: units.gu(4)
                        Label {
                            id: link_label
                            text: "Link"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                    leftPadding: units.gu(1)
                    Rectangle {
                        width: units.gu(28)
                        height: units.gu(4)
                        
                        TextField {
                            id: linkInput
                            placeholderText: "Link"
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            height: parent.height

                            onTextChanged: {
                                text = text.toLowerCase();
                            }

                            onAccepted: {
                                text = text.toLowerCase();
                                if (isValidURL(linkInput.text)) {
                                    isValidUrl = true;
                                    python.call("backend.fetch_databases", [linkInput.text], function(result) {
                                        isTextInputVisible = result.text_field
                                        isTextMenuVisible = result.menu_items
                                        if (isTextMenuVisible) {
                                            for (var db = 0; db < result.menu_items.length; db++) {
                                                databaseListModel.append({'name': result.menu_items[db]})
                                            }
                                        } else if (result.single_db) {
                                            single_db = result.single_db;
                                        }
                                    });
                                } else {
                                    isValidUrl = false;
                                }
                            }

                            function isValidURL(url) {
                                var pattern = new RegExp('^(https?:\\/\\/)?' + 
                                    '(([a-zA-Z0-9\\-\\.]+)\\.([a-zA-Z]{2,4})|' + 
                                    '(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})|' + 
                                    '\\[([a-fA-F0-9:\\.]+)\\])' + 
                                    '(\\:\\d+)?(\\/[-a-zA-Z0-9@:%_\\+.~#?&//=]*)*$', 'i');
                                return pattern.test(url);
                            }
                        }
                    }
                }
            }

            Text {
                id: errorMessage
                text: isValidUrl ? "" : "Please enter a valid URL"
                color: "red"
                visible: !isValidUrl
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: linkRow.bottom
            }

            Row {
                id: databaseRow
                anchors.top: isValidUrl ? linkRow.bottom : errorMessage.bottom
                anchors.topMargin: units.gu(3)
                visible: isTextInputVisible
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(12)
                        height: units.gu(3)
                        Label {
                            id: database_name_label
                            text: "Database"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                    leftPadding: units.gu(1)
                    Rectangle {
                        width: units.gu(28)
                        height: units.gu(5)
                        TextField {
                            id: dbInput
                            placeholderText: "Database"
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                        }
                    }
                }
            }

            Row {
                id: databaseListRow
                anchors.top: isValidUrl ? linkRow.bottom : errorMessage.bottom
                anchors.topMargin: units.gu(3)
                visible: isTextMenuVisible
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(12)
                        height: units.gu(3)
                        Label {
                            id: database_list_label
                            text: "Database"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                    leftPadding: units.gu(1)
                    Rectangle {
                        width: units.gu(28)
                        height: units.gu(5)
                        ComboBox {
                            id: database_combo
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model:  databaseListModel

                            onActivated: {
                            }
                            onHighlighted: {
                            }
                            onAccepted: {
                            }
                        }
                    }
                }
            }

            Row {
                id: usernameRow
                anchors.top: isTextMenuVisible ? databaseListRow.bottom :
                            (isTextInputVisible ? databaseRow.bottom :
                            (isValidUrl ? linkRow.bottom : errorMessageBottom))
                anchors.topMargin: units.gu(3)
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(12)
                        height: units.gu(4)
                         Label {
                            id: username_label
                            text: "Username"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                    leftPadding: units.gu(1)
                    Rectangle {
                        width: units.gu(28)
                        height: units.gu(5)
                        TextField {
                            id: usernameInput
                            placeholderText: "Username"
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                        }
                    }
                }
            }

            Row {
                id: connectWithRow
                anchors.top: usernameRow.bottom
                anchors.topMargin: units.gu(2)
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(12)
                        height: units.gu(5)
                         Label {
                            id: connectwith_label
                            text: "Connect With"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                    leftPadding: units.gu(1)
                    Rectangle {
                        width: units.gu(28)
                        height: units.gu(5)
                        LomiriShape {
                            width: parent.width
                            height: parent.height
                            ComboBox {
                                id: connectWith_combo
                                width: parent.width
                                height: parent.height
                                anchors.centerIn: parent.centerIn
                                flat: true
                                model: menuconnectwithModel

                                onActivated: {
                                    if (connectWith_combo.currentIndex == 0) {
                                        selectedconnectwithId = 1
                                    } else {
                                        selectedconnectwithId = 0
                                    }
                                }
                                onHighlighted: {
                                }
                                onAccepted: {
                                    if (find(editText) != -1)
                                    {
                                        if (connectWith_combo.currentIndex == 0) {
                                            selectedconnectwithId = 1
                                        } else {
                                            selectedconnectwithId = 0
                                        }
                                    }
                                } 

                            }
                        }
                    }
                }
            }

            Row {
                id: passwordRow
                anchors.top: connectWithRow.bottom
                anchors.topMargin: units.gu(3)
                Column {
                    leftPadding: units.gu(2)
                    Rectangle {
                        width: units.gu(12)
                        height: units.gu(4)
                        Label {
                            id: password_label
                            text: connectWith_combo.currentIndex == 1 ? "Password" : "API Key"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Column {
                    leftPadding: units.gu(1)
                    Rectangle {
                        width: units.gu(23)
                        height: units.gu(5)
                        TextField {
                            id: passwordInput
                            echoMode: isPasswordVisible ? TextInput.Normal : TextInput.Password
                            placeholderText: connectWith_combo.currentIndex == 1 ? "Password" : "API Key"
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                        }
                    }
                }
                Column {
                    Button {
                        width: units.gu(5)
                        height: passwordInput.height
                        color: "#fff"
                        iconName: isPasswordVisible ? "view-on" : "view-off"
                        onClicked: {
                            isPasswordVisible = !isPasswordVisible
                        }
                    }
                }
            }

            Text {
                id: errorMessageAccount
                text: isValidAccount ? "" : "Please enter Account Name to save!"
                color: "red"
                anchors.top: passwordRow.bottom
                anchors.topMargin: 10
                visible: !isValidAccount
            }

            Text {
                id: errorMessageLogin
                text: isValidLogin ? "" : "Please enter valid Credentials!"
                color: "red"
                visible: !isValidLogin
                anchors.top: passwordRow.bottom
                anchors.topMargin: 10
            }

            Text {
                id: connectionSuccessMessage
                text: connectionSuccess ? "Connection Successful! Please navigate to Sync page!" : ""
                color: "green"
                visible: connectionSuccess
                anchors.top: passwordRow.bottom
                anchors.topMargin: 10
            }

            Text {
                id: errorMessageDuplicate
                text: !alreadyExistAccount ? "" : "Account Already exist!"
                color: "red"
                anchors.top: passwordRow.bottom
                anchors.topMargin: 10
                visible: alreadyExistAccount
            }

            Label {
                text: selectedconnectwithId == 1 ? "<br/>Connect with API Key: Your API key will be stored on your device, enabling synchronization without requiring a password.<br/><br/>In Odoo, you can generate your API key in the <b>My Profile</b> page under the <b>Account Security</b> tab." : "<br/>Connect with Password: You will be prompted to enter your password each time synchronization is performed."
                textFormat: Text.RichText
                anchors.left: parent.left
                anchors.top: errorMessageDuplicate.bottom
                anchors.topMargin: 10
                anchors.leftMargin: units.gu(2)
                anchors.right: parent.right
                verticalAlignment: Label.AlignVCenter
                wrapMode: Label.Wrap
            }
        }
    }
}

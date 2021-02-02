/*
 * Copyright (C) 2021  Pavel Prosto
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * uVideo is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.5
import Morph.Web 0.1
import QtWebEngine 1.7
import QtSystemInfo 5.0
import QtQuick.Window 2.2
import Ubuntu.Content 1.3

Window {
    id: root
    visible: true
    visibility: Window.Windowed
    width: units.gu(45)
    height: units.gu(75)

    property string filename: ""
    property string path: "/home/phablet/Videos/"

ScreenSaver {
id: screenSaver
screenSaverEnabled: true
}

 StackView {
        id: stack
        initialItem: mainView
        anchors.fill: parent
    }
Item {
    id: mainView
ListView {
        id: grig
        clip: true
        anchors{
            top: parent.top;
            bottom: openButton.top;
            left: parent.left;
            right: parent.right;
            margins : units.gu(1);
        }
        spacing: units.gu(0.5)
        model: listModel
        delegate: ImgItem {
            text: txt
            image: img
            adress: adr
            onClicked: {
                if (img=="video-x-generic"){
                    root.playV(adr);
                }
            }
        }
    }
    ListModel{
        id:listModel
    }
    OpenButton{
        id: openButton
        anchors{
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins : units.gu(1);
        }
        text: "Open new file";
        onClicked: {
            contentPicker.visible=true
        }
    }
    ContentPeerPicker {
        id: contentPicker
        anchors.fill: parent
        visible: false
        contentType: ContentType.Videos
        handler: ContentHandler.Source

        onPeerSelected: {
            peer.selectionType = ContentTransfer.Single
            var activeTransfer = peer.request()
            activeTransfer.stateChanged.connect(function() {
                if (picker.activeTransfer.state === ContentTransfer.Charged) {
                    picker.activeTransfer.items[0].url
                }
            })
            contentPicker.visible = false
        }
       
        onCancelPressed: {
            contentPicker.visible = false
        }
    }

    Connections {
        id: videoimport
        property ContentTransfer vtr: null
        target: ContentHub
        onImportRequested: {
            const adr = String(transfer.items[0].url).replace('file://', '');
            root.playV(adr);
            //vtr=transfer
            //transfer.finalize();
        }
        function finalVideo()
        {
            //vtr.finalize();
        }
    }
    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            setHandler('progress', function(returnValue) {
                var newItem = {}
                    newItem.adr = returnValue[2]
                    newItem.img = returnValue[1]
                    newItem.txt = returnValue[0]
                    listModel.append(newItem)
            });
            setHandler('finished', function() {
        
            });
            importModule('main', function () {
                loadVideo();
            });
        }
        onError: {
            console.log('python error: ' + traceback);
        }
        function loadVideo(){
            listModel.clear();
            call('main.explorer.seach', [], function() {});
        }
    }
}
function playV(adr)
    {
        root.filename=adr
        console.log("play:"+root.filename)
        screenSaver.screenSaverEnabled=false
        root.visibility = Window.FullScreen
        webView.reload()
        stack.push(videoplayer)
    }
Item {
    id: videoplayer 
    visible: false  

    WebEngineView {
    id: webView
    anchors.fill: parent
    url: "../src/index.html"

    onJavaScriptDialogRequested: function(request) {
        request.accepted = true;
        if (request.message=="url_file"){
            request.dialogAccept(root.filename);
        }else if (request.message=="end_video") {
            request.dialogAccept();
            screenSaver.screenSaverEnabled=true
            root.visibility = Window.Windowed;
            python.loadVideo();
            stack.pop();
        }else{
            label1.text = qsTr(request.message)
            myDialog.visible = true;
            request.dialogAccept();
        }
    }
    }
}

Item {
      id: myDialog
      visible: false
      anchors.fill: parent
        Rectangle {
            width: units.gu(30)
            height: units.gu(20)
            anchors{
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            radius: units.gu(1)
            border.width: units.gu(0.25)
            border.color: "#77777720"

        Text {
            id: label1
            text: qsTr("")
            anchors.fill: parent
            horizontalAlignment: Label.AlignHCenter
            font.pixelSize: units.gu(2)
            padding: units.gu(1)
            wrapMode : Text.WordWrap
        }
        Button {
        id: closebut
        text: "Close"
        anchors{
            right: parent.right
            rightMargin: units.gu(1)
            bottom: parent.bottom
            bottomMargin: units.gu(1)
        }
        onClicked: {
            myDialog.visible = false;
        }
        }
        }
    }
}

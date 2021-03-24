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

import QtQuick.Controls.Suru 2.2
import "./constants.js" as Constants

Window {
    id: root
    Item {
    id: locale
    readonly property string txt1: i18n.tr("Video playlist is emty.\nClick \"+\" to add new videos")
    readonly property string txt2: i18n.tr("Add new files")
    readonly property string title: i18n.tr("Video")
    readonly property string faq: i18n.tr("../src/faq/en.html")
    }

    Component.onCompleted: {
    i18n.domain = "uvideo.pavelprosto"
    }

    visible: true
    visibility: Window.Windowed
    width: units.gu(45)
    height: units.gu(75)
    color: theme.palette.normal.background

    property string filename: ""
    property int activeTheme: parseInt(settings.theme)
    Settings {
    id: settings
    property string theme: Constants.Theme.System
    property bool fullscreen_enbl: true
    }

ScreenSaver {
    id: screenSaver
    screenSaverEnabled: true
}

StackView {
    id: stack
    initialItem: complimentView
    anchors.fill: parent
}

ComplimentScreen
    {
        id: complimentView
    }

Item {
    id: mainView
    visible:false
    property bool ready: true

    ListView {
        id: grig
        clip: true
        anchors{
            top: headwin.bottom;
            bottom: parent.bottom;
            left: parent.left;
            right: parent.right;
            margins : units.gu(1);
        }
        property bool enablScroll: true
        interactive: enablScroll
        spacing: units.gu(0.5)
        model: listModel
        delegate: ImgItem {
            text: txt
            image: img
            adress: adr
            onClicked: {
                if (img=="video-x-generic"){
                    videoplayer.play(adr);
                }
            }
            onSubup: {
              grig.enablScroll=false
            }
            onSubdown: {
              grig.enablScroll=true
            }
            onSubclick:{
                python.call('main.addignore', [adr], function() {});
                python.loadVideo();
            }
        }
    }
    ListModel{
        id:listModel
    }
    Text {
            id: clearlabel
            text: locale.txt1;
            color: theme.palette.normal.backgroundText;
            visible: false;
            anchors{
            top: parent.top;
            bottom: parent.bottom;
            left: parent.left;
            right: parent.right;
            margins : units.gu(1);
            }
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignHCenter
            font.pixelSize: units.gu(2)
            padding: units.gu(1)
            wrapMode : Text.WordWrap
    }
    Rectangle {
        id: headwin
        anchors{
        top: parent.top;
        left: parent.left;
        right: parent.right;
        }
        color: theme.palette.normal.background    
        height: units.gu(6);
        Text {
            text: locale.title
            anchors{
                margins: units.gu(1)
                top: parent.top
                left: parent.left
                }
            verticalAlignment: Label.AlignVCenter
            font.pixelSize: units.gu(2.5)
            padding: units.gu(1)
            wrapMode : Text.WordWrap
            color: theme.palette.normal.backgroundText
        }
            Rectangle {
                height: units.gu(0.1)
                color: theme.palette.normal.base
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }
            MenuProg {
                id: programmenu
                anchors{
                right: parent.right
                rightMargin: units.gu(2)
                top: parent.top
                //topMargin: units.gu(1.5)
                }  
            }
            OpenButton{
                id: openButton
                anchors{
                    top: parent.top
                    topMargin : units.gu(0.5);
                    right: parent.right
                    rightMargin: units.gu(6.5)
                    margins : units.gu(1);
                }
                iconName: "add"
                width: units.gu(6)
                colorBut: theme.palette.normal.background
                aspectBorder: UbuntuShape.Flat
                colorButText: theme.palette.normal.backgroundText
                onClicked: {
                    stack.push(importPage)
                }
            }
    }
    // OpenButton{
    //     id: openButton
    //     anchors{
    //         bottom: parent.bottom
    //         left: parent.left
    //         right: parent.right
    //         margins : units.gu(1);
    //     }
    //     text: locale.txt2;
    //     onClicked: {
    //         contentPicker.visible=true
    //     }
    // }
    // ContentPeerPicker {
    //     id: contentPicker
    //     anchors.fill: parent
    //     visible: false
    //     contentType: ContentType.Videos
    //     handler: ContentHandler.Source

    //     onPeerSelected: {
    //         contentPicker.visible = false
    //         peer.selectionType = ContentTransfer.Single
    //         peer.request()
    //     }
       
    //     onCancelPressed: {
    //         contentPicker.visible = false
    //     }
    // }

    // property var activeTransfer
    // ContentTransferHint {
    //     id: importHint
    //     anchors.fill: parent
    //     activeTransfer: mainView.activeTransfer
    // }
    Connections {
        id: videoimport
        target: ContentHub
        onImportRequested: {
            const adr = String(transfer.items[0].url).replace('file://', '');
            if (complimentView.ready==false)
            {
            mainView.ready=false
            stack.push(mainView)
            }
            videoplayer.play(adr);
        }
    }
    
    Python {
        id: python
        property string tmpn: "";
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            setHandler('progress', function(returnValue) {
                var newItem = {}
                    newItem.adr = returnValue[2]
                    tmpn = returnValue[2]
                    newItem.img = returnValue[1]
                    newItem.txt = returnValue[0]
                    listModel.append(newItem)
            });
            setHandler('finished', function() {
                if (listModel==null){
                    clearlabel.visible=true
                } else
                if (listModel.count==0){
                    clearlabel.visible=true
                }
            });
            setHandler('error', function(returnValue) {
                myDialog.text = returnValue
                myDialog.visible = true;
            });
            importModule('main', function () {
                loadVideo();
            });
        }
        onError: {
            myDialog.text = 'python error: ' + traceback
            myDialog.visible = true;
            console.log('python error: ' + traceback);
        }
        function loadVideo(){
            clearlabel.visible=false;
            listModel.clear();
            call('main.explorer.seach', [], function() {});
        }
    }
}

Item {
    id: videoplayer 
    visible: false  
    property bool enblcon: false
    property int timepoint: 0

    Connections {
            enabled: videoplayer.enblcon
            target: myDialog
            onClicked: { 
            videoplayer.enblcon=false
            var js = "$('#videoID')[0].currentTime="+videoplayer.timepoint
            webView.runJavaScript(js, function() {});
            }
        }

    function play(adr)
    {
        root.filename=adr
        screenSaver.screenSaverEnabled=false
        if (settings.fullscreen_enbl) {root.visibility = Window.FullScreen}
        if (webView.url=="../src/index.html"){
            webView.reload()
        }else{
            webView.url="../src/index.html"
        }
        stack.push(videoplayer)
        python.call('main.gettimemark', [root.filename], function(ret) {
            if (ret>-1){
                videoplayer.timepoint=ret
                myDialog.text = i18n.tr("Do you want to continue playing the video from the previous point?")
                myDialog.okbutton = true;
                myDialog.oktext = i18n.tr("Yes")
                myDialog.button = i18n.tr("No")
                myDialog.visible = true;
                videoplayer.enblcon=true
            }
        });
    }

    WebEngineView {
    id: webView
    anchors.fill: parent
    url: "../src/index.html"
    onJavaScriptDialogRequested: function(request) {
        request.accepted = true;
        var txt=request.message
        if (txt=="url_file"){
            request.dialogAccept(root.filename);
        }else if (txt=="end_video") {
            request.dialogAccept();
            screenSaver.screenSaverEnabled=true
            root.visibility = Window.Windowed;
            python.loadVideo();
            stack.pop();
        }else if(txt.indexOf("#timemark")>-1){
            request.dialogAccept();
            python.call('main.addtimemark', [root.filename,txt], function() {});
        }else if(txt=="LiberaPay"){
            Qt.openUrlExternally("https://liberapay.com/pavelprosto/")
        }else{
            request.dialogAccept();
            myDialog.text = txt
            myDialog.visible = true;
        }
    }
    onJavaScriptConsoleMessage: function(lvl, msg, lnum, msgid) {
        console.log(msg);
        myDialog.text = i18n.tr(msg)
        myDialog.visible = true;
    }
    }
}

ImportPage {
    id: importPage
    visible: false
    }

VideoSettings{
    id: settingsPage
    visible: false
}

MyDialog {
      id: myDialog
      visible: false
      anchors.fill: parent
    }

function setCurrentTheme() {
    switch (activeTheme) {
      case Constants.Theme.System:
        theme.name = "";
        Suru.theme = undefined;
        break;
      case Constants.Theme.SuruLight:
        theme.name = "Ubuntu.Components.Themes.Ambiance";
        Suru.theme = Suru.Light;
        break;
      case Constants.Theme.SuruDark:
        theme.name = "Ubuntu.Components.Themes.SuruDark";
        Suru.theme = Suru.Dark;
        break;
    }
  }

  onActiveThemeChanged: setCurrentTheme()
}

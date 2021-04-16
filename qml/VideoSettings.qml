import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
import io.thp.pyotherside 1.3
import "./constants.js" as Constants

Page { 
  id: root
    signal settingsshow
    property int oldpos1: 0
    property int oldpos2: 0
    onSettingsshow:{
      root.oldpos1=themeSelect.selectedIndex
      root.oldpos2=sections1.selectedIndex
    }
header: PageHeader {
        title: i18n.tr("Settings")
    }
Flickable {
    clip: true
    anchors{
          top: root.header.bottom
          left: parent.left
          right: parent.right
          bottom: okButton.top
        }
      contentWidth: rectRoot.width
      contentHeight: rectRoot.height
  
  Rectangle {
    id :rectRoot
        width: root.width
        height: {childrenRect.height+units.gu(4)}
        color: theme.palette.normal.background
        
    Text {
        id: label1
        text: i18n.tr("Programm theme:")
        color: theme.palette.normal.backgroundText
        font.pixelSize: units.gu(2)
        anchors{
          top: parent.top
          topMargin: units.gu(2)
          left: parent.left
          leftMargin: units.gu(2)
        }
    }
    property var thememodel: [
        i18n.tr("System"),
        "Suru Light" ,
        "Suru Dark"
        ]
    property var themeval: [
      Constants.Theme.System ,
      Constants.Theme.SuruLight,
      Constants.Theme.SuruDark 
    ]
    OptionSelector {
      id: themeSelect
        anchors{
          top: label1.bottom
          topMargin: units.gu(1)
          left: parent.left
          leftMargin: units.gu(2)
          right: parent.right
          rightMargin: units.gu(2)
        }
            model: parent.thememodel
              Component.onCompleted: {
                themeSelect.selectedIndex = _getIndexByTheme(settings.theme)
                root.oldpos1=themeSelect.selectedIndex
              }
              function _getIndexByTheme(themeId) {
                return themeId
              }
            //textRole: "text"
            onSelectedIndexChanged: {
              settings.theme = parent.themeval[selectedIndex]
            }
    }

Text {
        id: label2
        text: i18n.tr("Video play mode:")
        color: theme.palette.normal.backgroundText
        font.pixelSize: units.gu(2)
        anchors{
          top: themeSelect.bottom
          topMargin: units.gu(2)
          left: parent.left
          leftMargin: units.gu(2)
        }
    }
property var videoWinMode: [
        i18n.tr("Windowed"), 
        i18n.tr("FullScreen")
    ]
Sections {
        id: sections1
        selectedIndex: 0
        anchors{
          top: label2.bottom
          //left: parent.left
          leftMargin: units.gu(2)
          right: parent.right
          rightMargin: units.gu(2)
          }
        model: parent.videoWinMode
        //width: parent.width
        Component.onCompleted: {
          if (settings.fullscreen_enbl) {
                sections1.selectedIndex=1
              }else{
                sections1.selectedIndex=0
              }
          root.oldpos2=sections1.selectedIndex
      }
      onSelectedIndexChanged: {
        if (sections1.selectedIndex==1){
              settings.fullscreen_enbl=true
            }else{
              settings.fullscreen_enbl=false
            }
      }
    }
Text {
        id: label3
        text: i18n.tr("Clear all timemarks for videos:")
        color: theme.palette.normal.backgroundText
        font.pixelSize: units.gu(2)
        anchors{
          top: sections1.bottom
          topMargin: units.gu(2)
          left: parent.left
          leftMargin: units.gu(2)
        }
    }
Text {
        id: label4
        text: i18n.tr("When you watch a video, the program creates timemarks so that you can continue watching the video next time.")
        color: theme.palette.normal.backgroundText
        font.pixelSize: units.gu(1)
        anchors{
          top: label3.bottom
          right: parent.right
          rightMargin: units.gu(2)
          left: parent.left
          leftMargin: units.gu(2)
        }
        wrapMode: Text.WordWrap
    }
OpenButton{
  id: remButton
  anchors{
          top: label4.bottom
          leftMargin: units.gu(2)
          right: parent.right
          rightMargin: units.gu(2)
  }
  width: units.gu(16)
  colorBut: UbuntuColors.red
  colorButText: "white"
  iconOffset: true
  iconName: "delete"
  text: i18n.tr("Clear")
    onClicked: {
      python.call('main.removeAlltimemark', [], function() {
        myDialog.text = i18n.tr("All timemarks removed")
        myDialog.visible = true;
      });
    }
  }
OpenButton{
  id: linkButton
  anchors{
          top: remButton.bottom
          topMargin: units.gu(2)
          leftMargin: units.gu(2)
          right: parent.right
          rightMargin: units.gu(2)
  }
  width: units.gu(26)
  iconName: "home"
  text: i18n.tr("Create uHome link")
    onClicked: {
      Qt.openUrlExternally("uhome://createlink/?name=VideoPlayer&url=uvideo://&backgroundcolor=#00000000&icon=img/uVideo.svg")
    }
  }
//"Remove all timemarks for videos"
}}
OpenButton{
  id: okButton
  anchors{
    left: parent.left
    leftMargin: units.gu(2)
    bottom: parent.bottom
    bottomMargin: units.gu(1.5)
  }
  width: units.gu(16)
  colorBut: UbuntuColors.green
  colorButText: "white"
  iconOffset: true
  iconName: "document-save"
  text: i18n.tr("Save")
    onClicked: {
      stack.pop()
    }
  }
OpenButton{
  id: cancelButton
  anchors{
    right: parent.right
    rightMargin: units.gu(2)
    bottom: parent.bottom
    bottomMargin: units.gu(1.5)
  }
  width: units.gu(16)
  iconOffset: true
  iconName: "close"
  text: i18n.tr("Cancel")
    onClicked: {
      themeSelect.selectedIndex=root.oldpos1
      sections1.selectedIndex=root.oldpos2
      stack.pop()
    }
  }
}
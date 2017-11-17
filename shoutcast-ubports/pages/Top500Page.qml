import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0
import QtMultimedia 5.6

import "../components"
import "../components/shoutcast.js" as Shoutcast
import "../components/Util.js" as Util

Page {
    id: top500Page

    property int currentItem: -1
    property bool showBusy: false

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Top 500 Stations")
        StyleHints {
            foregroundColor: UbuntuColors.orange
            backgroundColor: UbuntuColors.porcelain
            dividerColor: UbuntuColors.slate
        }

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: pageStack.pop();
            }
        ]
        flickable: stationsListView
    }

    ActivityIndicator {
        id: activity
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        running: showBusy
        visible: running
        z: 1
    }

    Column {
        spacing: units.gu(1)
        id: pageLayout
        anchors {
            top: top500Page.header.bottom
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
            fill: parent
        }

        ListView {
            id: stationsListView
            width: parent.width - scrollBar.width
            height: parent.height

            anchors {
                horizontalCenter: parent.horizontalCenter
                topMargin: units.gu(2)
            }
            delegate: ListItem {
                id: delegate
                width: parent.width //- 2*Theme.paddingMedium
                height: stationListItemView.height
                //x: Theme.paddingMedium
                //contentHeight: childrenRect.height

                StationListItemView {
                    id: stationListItemView
                }

                onClicked: loadStation(model.id, Shoutcast.createInfo(model), tuneinBase)
            }

            model: top500Model

        }

        Scrollbar {
            id: scrollBar
            flickableItem: stationsListView
            anchors.right: parent.right
        }

        XmlListModel {
            id: top500Model
            query: "/stationlist/station"
            XmlRole { name: "name"; query: "string(@name)" }
            XmlRole { name: "mt"; query: "string(@mt)" }
            XmlRole { name: "id"; query: "@id/number()" }
            XmlRole { name: "br"; query: "@br/number()" }
            XmlRole { name: "genre"; query: "string(@genre)" }
            XmlRole { name: "ct"; query: "string(@ct)" }
            XmlRole { name: "lc"; query: "@lc/number()" }
            XmlRole { name: "logo"; query: "string(@logo)" }
            XmlRole { name: "genre2"; query: "string(@genre2)" }
            XmlRole { name: "genre3"; query: "string(@genre3)" }
            XmlRole { name: "genre4"; query: "string(@genre4)" }
            XmlRole { name: "genre5"; query: "string(@genre5)" }
            onStatusChanged: {
                if(status === XmlListModel.Ready) {
                    console.log("XmlListModel.Ready")
                    showBusy = false
                    /*if(top500Model.count === 0)
                        app.showErrorDialog(qsTr("SHOUTcast server returned no Stations"))
                    else
                        currentItem = app.findStation(app.stationId, top500Model)
                    */
                }
            }
        }

        XmlListModel {
            id: tuneinModel
            query: "/stationlist/tunein"
            XmlRole{ name: "base"; query: "@base/string()" }
            XmlRole{ name: "base-m3u"; query: "@base-m3u/string()" }
            XmlRole{ name: "base-xspf"; query: "@base-xspf/string()" }
            onStatusChanged: {
                if (status !== XmlListModel.Ready)
                    return
                tuneinBase = {}
                if(tuneinModel.count > 0) {
                    var b = tuneinModel.get(0)["base"]
                    if(b)
                        tuneinBase["base"] = b
                    b = tuneinModel.get(0)["base-m3u"]
                    if(b)
                        tuneinBase["base-m3u"] = b
                    b = tuneinModel.get(0)["base-xspf"]
                    if(b)
                        tuneinBase["base-xspf"] = b
                }
            }
        }
    }

    function reload() {
        showBusy = true
        currentItem = -1
        loadTop500(function(xml) {
            //console.log(xml)
            top500Model.xml = xml
            top500Model.reload()
            tuneinModel.xml = xml
            tuneinModel.reload()
        }, function() {
            // timeout
            showBusy = false
            //app.showErrorDialog(qsTr("SHOUTcast server did not respond"))
            console.log("SHOUTcast server did not respond")
        })
    }

    Component.onCompleted: {
        reload()
    }

}



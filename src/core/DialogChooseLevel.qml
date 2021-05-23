/* GCompris - DialogChooseLevel.qml
 *
 * SPDX-FileCopyrightText: 2018 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Johnny Jazeix <jazeix@gmail.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.9
import GCompris 1.0

/**
 * todo
 * @ingroup components
 *
 * todo
 *
 * @sa ApplicationSettings
 * @inherit QtQuick.Item
 */
Rectangle {
    id: dialogChooseLevel
    visible: false
    focus: visible

    /* Public interface: */

    /**
     * type:string
     * The name of the activity in case of per-activity config.
     *
     * Will be autogenerated unless set by the caller.
     */
    property string activityName: currentActivity.name.split('/')[0]

    /// @cond INTERNAL_DOCS

    property bool isDialog: true

    /**
     * type:string
     * Title of the configuration dialog.
    */
    readonly property string title: currentActivity ? qsTr("%1 settings").arg(currentActivity.title) : ""

    property var difficultiesModel: []
    property QtObject currentActivity

    property var chosenLevels: []

    property var activityData
    onActivityDataChanged: loadData()
    /// @endcond

    /**
     * By default, we display configuration (this avoids to add code in each 
     * activity to set it by default).
     */
    property bool displayDatasetAtStart: !hasConfig

    /**
     * Emitted when the config dialog has been closed.
     */
    signal close

    /**
     * Emitted when the config dialog has been started.
     */
    signal start

    onStart: initialize()

    signal stop

    /**
     * Emitted when the settings are to be saved.
     *
     * The actual persisting of the settings in the settings file is done by
     * DialogActivityConfig. The activity has to take care to update its
     * internal state.
     */
    signal saveData

    signal startActivity

    /**
     * Emitted when the config settings have been loaded.
     */
    signal loadData

    property bool datasetButtonVisible: true
    property bool hasConfigOrDataset: hasConfig || hasDataset
    property bool hasConfig: currentActivity && currentActivity.hasConfig
    property bool hasDataset: currentActivity && currentActivity.hasDataset && datasetButtonVisible

    color: "#696da3"
    border.color: "black"
    border.width: 1

    property bool inMenu: false

    onVisibleChanged: {
        if(visible) {
            configLoader.initializePanel()
        }
    }

    Keys.onPressed: {
        if(event.key === Qt.Key_Down) {
            scrollItem.down();
        } else if(event.key === Qt.Key_Up) {
            scrollItem.up();
        } else if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if(saveAndStartButton.visible) {
                saveAndStartButton.clicked();
            } else {
                saveButton.clicked();
            }
        } else if(datasetVisibleButton.enabled && optionsVisibleButton.enabled &&
                (event.key === Qt.Key_Left || event.key === Qt.Key_Right)) {
            if(datasetVisibleButton.selected) {
                optionsVisibleButton.clicked();
            } else {
                datasetVisibleButton.clicked();
            }
        }
    }

    Keys.onEscapePressed: {
        cancelButton.clicked();
    }

    Keys.onReleased: {
        if(event.key === Qt.Key_Back) {
            cancelButton.clicked();
            event.accepted = true;
        }
    }

    onClose: activity.forceActiveFocus();

    function initialize() {
        // dataset information
        chosenLevels = currentActivity.currentLevels.slice()
        difficultiesModel = []
        for(var level in currentActivity.levels) {
            var data = currentActivity.getDataset(currentActivity.levels[level])
            difficultiesModel.push({
                "level": currentActivity.levels[level],
                "enabled": data.enabled,
                "objective": data.objective,
                "difficulty": data.difficulty,
                "selectedInConfig": (chosenLevels.indexOf(currentActivity.levels[level]) != -1)
            })
        }
        difficultiesRepeater.model = difficultiesModel

        // Defaults to config if in an activity else to dataset if in menu
        if(displayDatasetAtStart) {
            datasetVisibleButton.clicked()
        }
        else {
            optionsVisibleButton.clicked()
        }
    }

    Column {
        id: titleColumn
        spacing: 10
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: dialogChooseLevel.width - 30
        Rectangle {
            id: titleRectangle
            color: "#e6e6e6"
            radius: 10 * ApplicationInfo.ratio
            width: parent.width
            height: title.height * 1.2
            border.color: "black"
            border.width: 0

                GCText {
                    id: title
                    text: dialogChooseLevel.title
                    width: titleColumn.width - 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "black"
                    fontSize: 20
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                }
        }

        // Header buttons
        Row {
            id: datasetOptionsRow
            height: dialogChooseLevel.height / 12
            width: titleRectangle.width
            spacing: titleRectangle.width * 0.1
            GCButton {
                id: datasetVisibleButton
                text: qsTr("Dataset")
                enabled: hasDataset
                height: parent.height
                width: titleRectangle.width * 0.45
                opacity: enabled ? 1 : 0
                theme: "settingsButton"
                selected: datasetVisibleButton.selected
                onClicked: { selected = true; }
                // reset the view to original position when changing tab
                onSelectedChanged: { flick.contentY = 0; }
            }
            GCButton {
                id: optionsVisibleButton
                text: qsTr("Options")
                enabled: hasConfig
                height: parent.height
                width: titleRectangle.width * 0.45
                opacity: enabled ? 1 : 0
                theme: "settingsButton"
                selected: !datasetVisibleButton.selected
                onClicked: { datasetVisibleButton.selected = false; } //showOptions()
            }
        }

        // "Dataset"/"Options" content
        Rectangle {
            color: "#bdbed0"
            radius: 10 * ApplicationInfo.ratio
            width: dialogChooseLevel.width - 30
            height: dialogChooseLevel.height - (30 + title.height * 1.2) - saveAndPlayRow.height - datasetOptionsRow.height - 3 * parent.spacing
            border.color: "white"
            border.width: 3 * ApplicationInfo.ratio
            anchors.margins: 100

            Flickable {
                id: flick
                flickDeceleration: 1500
                anchors.margins: 10 * ApplicationInfo.ratio
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                flickableDirection: Flickable.VerticalFlick
                clip: true
                contentHeight: contentItem.childrenRect.height + 40 * ApplicationInfo.ratio

                Loader {
                    id: configLoader
                    visible: !datasetVisibleButton.selected
                    active: optionsVisibleButton.enabled
                    source: active ? "qrc:/gcompris/src/activities/"+activityName+"/ActivityConfig.qml" : ""

                    // Load configuration at start of activity
                    // in the menu, it's done when the visibility property
                    // of the dialog changes
                    onItemChanged: if(!inMenu) { initializePanel(); }

                    function initializePanel() {
                        if(item) {
                            // only connect once the signal to save data
                            if(item.background !== dialogChooseLevel) {
                                item.background = dialogChooseLevel
                                dialogChooseLevel.saveData.connect(save)
                            }
                            getInitialConfiguration()
                        }
                    }
                    function getInitialConfiguration() {
                        activityData = Qt.binding(function() { return item.dataToSave })
                        if(item) {
                            item.dataToSave = ApplicationSettings.loadActivityConfiguration(activityName)
                            item.setDefaultValues()
                        }
                    }
                    function save() {
                        item.saveValues()
                        ApplicationSettings.saveActivityConfiguration(activityName, item.dataToSave)
                    }
                }

                Column {
                    visible: datasetVisibleButton.selected
                    spacing: 10

                    Repeater {
                        id: difficultiesRepeater
                        delegate: Row {
                            height: objective.height
                            visible: modelData.enabled
                            Image {
                                id: difficultyIcon
                                source: "qrc:/gcompris/src/core/resource/difficulty" +
                                modelData.difficulty + ".svg";
                                sourceSize.height: objective.indicatorImageHeight
                                sourceSize.width: height
                                anchors.verticalCenter: objective.verticalCenter
                            }
                            GCDialogCheckBox {
                                id: objective
                                width: dialogChooseLevel.width - 30 - difficultyIcon.width - 2 * flick.anchors.margins
                                text: modelData.objective
                                checked: chosenLevels.indexOf(modelData.level) != -1
                                onVisibleChanged: {
                                    if(visible) checked = (chosenLevels.indexOf(modelData.level) != -1)
                                }
                                onClicked: {
                                    if(checked) {
                                        chosenLevels.push(modelData.level)
                                    }
                                    else if(chosenLevels.length > 1) {
                                        chosenLevels.splice(chosenLevels.indexOf(modelData.level), 1)
                                    }
                                    else {
                                        // At least one must be selected
                                        checked = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // The scroll buttons
            GCButtonScroll {
                id: scrollItem
                anchors.right: parent.right
                anchors.rightMargin: 5 * ApplicationInfo.ratio
                anchors.bottom: flick.bottom
                anchors.bottomMargin: 5 * ApplicationInfo.ratio
                onUp: flick.flick(0, 1000)
                onDown: flick.flick(0, -1000)
                upVisible: flick.visibleArea.yPosition <= 0 ? false : true
                downVisible: flick.visibleArea.yPosition + flick.visibleArea.heightRatio >= 1 ? false : true
            }
        }
        // Footer buttons
        Row {
            id: saveAndPlayRow
            height: dialogChooseLevel.height / 12
            width: titleRectangle.width
            spacing: titleRectangle.width * 0.05
            GCButton {
                id: cancelButton
                text: qsTr("Cancel")
                height: parent.height
                width: titleRectangle.width * 0.25
                theme: "settingsButton"
                onClicked: close();
            }
            GCButton {
                id: saveButton
                text: qsTr("Save")
                height: parent.height
                width: titleRectangle.width * 0.25
                theme: "settingsButton"
                onClicked: {
                    saveData();
                    if (inMenu === false) {
                        startActivity();
                    }
                    close();
                }
            }
            GCButton {
                id: saveAndStartButton
                text: qsTr("Save and start")
                height: parent.height
                width: titleRectangle.width * 0.4
                visible: inMenu === true
                theme: "settingsButton"
                onClicked: {
                    saveData();
                    startActivity();
                }
            }
        }
    }
}

/* GCompris - algebra.js
 *
 * SPDX-FileCopyrightText: 2014 Aruna Sankaranarayanan and Bruno Coudoin
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */

.pragma library
.import QtQuick 2.9 as Quick
.import "qrc:/gcompris/src/core/core.js" as Core

var currentLevel
var maxLevel
var items
var dataset
var operand
var secondOperandVal
var firstOperandVal
var subLevelData = []
var speedSetting
var operandText
var OperandsEnum = {
    TIMES_SIGN : "\u00D7",
    PLUS_SIGN : "\u002B",
    MINUS_SIGN : "\u2212",
    DIVIDE_SIGN : "\u2215"
}


function start(items_, operand_, speedSetting_) {
    operand   = operand_
    items = items_
    speedSetting = speedSetting_
    currentLevel = 0
    dataset = items.levels
    maxLevel = dataset.length
    initLevel()
}

function stop() {
    items.balloon.stopMoving()
    items.timer.stop()
}

function initLevel() {
    items.bar.level = currentLevel + 1
    items.score.visible = false
    items.okButton.visible = false
    items.score.currentSubLevel = 1
    subLevelData = []
    if(currentLevel === maxLevel)
        initLastLevel();
    else {
        items.score.numberOfSubLevels = dataset[currentLevel].operands.length;
        for(var i = 0; i < items.score.numberOfSubLevels; i++)
            subLevelData.push([dataset[currentLevel].operands[i].first, dataset[currentLevel].operands[i].second])
    }
    subLevelData = Core.shuffle(subLevelData)
    calculateOperands()
    items.iAmReady.visible = true
    items.firstOp.visible = false
    items.secondOp.visible = false
    items.balloon.stopMoving()
}

function circularShiftElements() {
    if(!validateAnswer(parseInt(items.numpad.answer)))
        subLevelData.push(subLevelData.shift())
    else
        subLevelData.shift()
}

function nextLevel() {
    if(maxLevel  < ++currentLevel) {
        currentLevel = 0
    }
    initLevel();
}

function previousLevel() {
    if(--currentLevel < 0) {
        currentLevel = maxLevel
    }
    initLevel();
}

/* last level will be generated by this function,it will always contain randomly picked questions from previous levels*/
function initLastLevel() {
    items.score.numberOfSubLevels = maxLevel  * 5;
    for (var i = 0; i < items.score.numberOfSubLevels; i++) {
        //randomly choose a level
        var randomLevel = Math.floor(Math.random() * maxLevel)
        // randomly choose question from level
        var randomIndex = Math.floor(Math.random() * dataset[randomLevel].operands.length)
        subLevelData.push([dataset[randomLevel].operands[randomIndex].first, dataset[randomLevel].operands[randomIndex].second])
    }
}

function calculateOperands()
{

        firstOperandVal = subLevelData[0][0]
        secondOperandVal = subLevelData[0][1]

    items.firstOp.text = firstOperandVal
    items.secondOp.text = secondOperandVal
}

// Return the expected answer
function getAnswer() {
    switch(operand.text)
    {
    case OperandsEnum.TIMES_SIGN:
        return (firstOperandVal * secondOperandVal)

    case OperandsEnum.PLUS_SIGN:
        return (firstOperandVal + secondOperandVal)

    case OperandsEnum.MINUS_SIGN:
        return (firstOperandVal - secondOperandVal)

    case OperandsEnum.DIVIDE_SIGN:
        return (firstOperandVal / secondOperandVal)
    }
}

function validateAnswer(screenAnswer)
{
    return (getAnswer() === screenAnswer)
}

function run() {
    calculateOperands()
    items.numpad.resetText()
    items.score.visible = true
    items.iAmReady.visible = false
    items.firstOp.visible = true
    items.secondOp.visible = true
    items.okButton.visible = true
    items.numpad.answerFlag = false
    items.result = getAnswer()
    items.balloon.startMoving(100000 / speedSetting)
}

function questionsLeft() {
    items.okButton.enabled = false
    items.balloon.startMoving(100000 / speedSetting)
    circularShiftElements()
    if(validateAnswer(parseInt(items.numpad.answer))) {
        items.numpad.answerFlag = true

        if(items.score.currentSubLevel < items.score.numberOfSubLevels) {
            items.audioEffects.play("qrc:/gcompris/src/core/resource/sounds/win.wav")
            items.score.currentSubLevel++
            items.timer.start()
        } else {
            items.score.currentSubLevel = 1
            items.balloon.stopMoving()
            items.bonus.good("smiley");
        }
    }
    else
        items.bonus.bad("smiley");
}

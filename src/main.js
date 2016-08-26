import 'babel-polyfill'
import { curry, is } from 'ramda'
import { createStore } from 'redux'
import * as actions from './actions'
import * as Progress from './services/Progress'
import * as Painter from './services/Painter'
import sokoban from './reducers'
import level0 from './levels/0'
import level1 from './levels/1'
import level2 from './levels/2'
import level3 from './levels/3'
import level4 from './levels/4'
import level5 from './levels/5'
import level6 from './levels/6'
import level7 from './levels/7'
import level8 from './levels/8'
import level9 from './levels/9'
import level10 from './levels/10'
import level11 from './levels/11'
import level12 from './levels/12'
import level13 from './levels/13'


const LEVELS = [level0, level1, level2, level3, level4, level5, level6, level7, level8, level9,level10, level11, level12, level13];
const BLOCK_SIZE = 16;

// Buttons
let arrowUpButton = document.getElementById('up-arrow');
let arrowDownButton = document.getElementById('down-arrow');
let arrowLeftButton = document.getElementById('left-arrow');
let arrowRightButton = document.getElementById('right-arrow');
let undoMoveButton = document.getElementById('undo-move');
let undoLevelButton = document.getElementById('undo-level');
let startOverButton = document.querySelector('[start-over]');

// Popup
let blur = document.querySelector('[blur]');
let popup = document.querySelector('[popup]');
let dismissPopup = document.querySelector('[dismiss-popup]');
let popupLevel = document.querySelector('[popup-level]')
let popupMoves = document.querySelector('[popup-moves]')
let popupPushes = document.querySelector('[popup-pushes]')

// Game state elements
let levelIndicator = document.querySelector('[level]')
let movesIndicator = document.querySelector('[moves]')
let pushesIndicator = document.querySelector('[pushes]')
let messageIndicator = document.querySelector('[message]')

let store = createStore(sokoban, window.devToolsExtension && window.devToolsExtension());

var canvas = document.getElementById('game');
canvas.width = 608;
canvas.height = 544;
var context = canvas.getContext('2d');
context.scale(2, 2);

// Animate Soko
var interval = setInterval(() => {
    Painter.paintNextSoko(context, store.getState())
}, 300);

store.subscribe(function() {
    const state = store.getState()

    // Draw the game
    Painter.paint(context, state)

    levelIndicator.innerHTML = `Level ${state.levelNumber}`
    movesIndicator.innerHTML = `${state.movesCount} moves`
    pushesIndicator.innerHTML = `${state.pushesCount} pushes`
    messageIndicator.innerHTML = `${state.message}`

    popupLevel.innerHTML = `You completed level ${state.levelNumber}`
    popupMoves.innerHTML = `with ${state.movesCount} moves`
    popupPushes.innerHTML = `and ${state.pushesCount} pushes`

    if(state.levelCompleted) {
        removeEventListeners();

        // Timeout, to show the player that all the boxes are all in place
        setTimeout(showPopup, 100);
    } else {
        hidePopup();
    }
});

function loadNextLevel() {
    const state = store.getState()

    const nextLevel = state.levelNumber + 1;

    // reset sokos sprite to the first
    Painter.resetSoko()

    // save the reached level
    Progress.save(nextLevel);

    addEventListeners();

    store.dispatch(actions.loadLevel(LEVELS[nextLevel]));
}

const moveUp = () => { store.dispatch(actions.move('up')) }
const moveDown = () => { store.dispatch(actions.move('down')) }
const moveLeft = () => { store.dispatch(actions.move('left')) }
const moveRight = () => { store.dispatch(actions.move('right')) }
const undoMove = () => { store.dispatch(actions.undoMove()) }
const undoLevel = () => {
    const levelNumber = store.getState().levelNumber
    store.dispatch(actions.undoLevel(LEVELS[levelNumber]))
}
const startOver = (event) => {
    event.preventDefault();

    let startOver = confirm('Start from level 0 again?');

    if (!startOver) {
        return;
    }

    Progress.clear();
    store.dispatch(actions.loadLevel(LEVELS[0]));
}

function showPopup() {
    blur.classList.add('visible');
    popup.classList.add('visible');
    dismissPopup.focus();
}

function hidePopup() {
    blur.classList.remove('visible');
    popup.classList.remove('visible');
}

function addEventListeners() {
    // Add button listeners
    arrowUpButton.addEventListener('click', moveUp)
    arrowDownButton.addEventListener('click', moveDown)
    arrowLeftButton.addEventListener('click', moveLeft)
    arrowRightButton.addEventListener('click', moveRight)
    undoMoveButton.addEventListener('click', undoMove)
    undoLevelButton.addEventListener('click', undoLevel)
    startOverButton.addEventListener('click', startOver);

    // Popup OK button
    dismissPopup.addEventListener('click', loadNextLevel);

    // Add keyboard listeners
    document.addEventListener('keydown', onKeyDown);
    document.addEventListener('keyup', onKeyUp);
}

function removeEventListeners() {
    // Remove button listeners
    arrowUpButton.removeEventListener('click', moveUp)
    arrowDownButton.removeEventListener('click', moveDown)
    arrowLeftButton.removeEventListener('click', moveLeft)
    arrowRightButton.removeEventListener('click', moveRight)
    undoMoveButton.removeEventListener('click', undoMove)
    undoLevelButton.removeEventListener('click', undoLevel)
    startOverButton.removeEventListener('click', startOver);

    // Remove keyboard listeners
    document.removeEventListener('keydown', onKeyDown);
}

function onKeyDown(e) {
    switch (e.keyCode) {
        case 37:
            moveLeft()
            arrowLeftButton.classList.add('active')
            break;
        case 38:
            moveUp()
            arrowUpButton.classList.add('active')
            break;
        case 39:
            moveRight()
            arrowRightButton.classList.add('active')
            break;
        case 40:
            moveDown()
            arrowDownButton.classList.add('active')
            break;
        case 77:
            undoMove()
            break;
        case 76:
            undoLevel()
            break;
    }
}

function onKeyUp(e) {
    switch (e.keyCode) {
        case 37:
            arrowLeftButton.classList.remove('active')
            break;
        case 38:
            arrowUpButton.classList.remove('active')
            break;
        case 39:
            arrowRightButton.classList.remove('active')
            break;
        case 40:
            arrowDownButton.classList.remove('active')
            break;
    }
}

addEventListeners();
dismissPopup.addEventListener('click', loadNextLevel);
var startingLevel = parseInt(Progress.get()) || 0;
store.dispatch(actions.loadLevel(LEVELS[startingLevel]));

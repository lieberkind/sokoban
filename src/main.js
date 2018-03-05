import * as Progress from './services/Progress';
const app = window.Elm.Main.embed(document.getElementById('elm-app'));

app.ports.saveProgress.subscribe(levelNumber => {
	Progress.save(levelNumber);
});

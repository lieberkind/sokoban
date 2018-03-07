import * as Progress from './services/Progress';

Progress.get().then(startAtLevel => {
	const app = window.Elm.Main.embed(document.getElementById('elm-app'), { startAtLevel });

	app.ports.saveProgress.subscribe(levelNumber => {
		Progress.save(levelNumber);
	});
});

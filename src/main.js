import * as Progress from './services/Progress';

Progress.get().then(progress => {
	const app = window.Elm.Main.embed(document.getElementById('elm-app'), { progress });

	app.ports.saveProgress.subscribe(levelNumber => {
		Progress.save(levelNumber);
	});

	app.ports.clearProgress.subscribe(levelNumber => {
		Progress.clear();
	});
});

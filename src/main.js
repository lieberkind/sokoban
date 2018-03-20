import * as Progress from './services/Progress';
import { request } from 'https';

Progress.get().then(progress => {
	const app = window.Elm.Main.embed(document.getElementById('elm-app'), { progress });

	app.ports.saveProgress.subscribe(levelNumber => {
		Progress.save(levelNumber);
	});

	app.ports.clearProgress.subscribe(levelNumber => {
		Progress.clear();
	});

	// Animate soko. Am actually not sure if there's a *worse* way of doing this?
	// Should ideally be handled by Elm.
	const ceiling = 3;
	const floor = 0;
	let step = 1;
	let sokoSprite = 0;
	let sokoClass = 'soko-' + sokoSprite;

	setInterval(function() {
		const soko = document.getElementById('soko');

		if (soko) {
			soko.classList.remove('soko-' + sokoSprite);

			sokoSprite += step;
			sokoClass = 'soko-' + sokoSprite;

			if (sokoSprite === ceiling || sokoSprite === floor) {
				step = -step;
			}
		}
	}, 300);

	const paintNextSoko = () => {
		const soko = document.getElementById('soko');
		if (soko) {
			soko.classList.add(sokoClass);
		}
		requestAnimationFrame(paintNextSoko);
	};

	requestAnimationFrame(paintNextSoko);
});

const PROGRESS_KEY = 'p';

const isNumeric = val => Number(parseFloat(val)) === val;

const isProgressValid = ({ levelNumber, totalMoves, totalPushes }) =>
	isNumeric(levelNumber) && isNumeric(totalMoves) && isNumeric(totalPushes);

export const get = () => {
	const progressHash = localStorage.getItem(PROGRESS_KEY);

	return new Promise((resolve, reject) => {
		debugger;

		if (!progressHash) {
			console.debug('### No progress saved');
			resolve(null);
			return;
		}

		try {
			const progressString = atob(progressHash);
			const progressObject = JSON.parse(progressString);
			const res = isProgressValid(progressObject) ? progressObject : null;
			resolve(res);
		} catch (e) {
			console.error(e);
			resolve(null);
		}
	});
};

export const save = ({ levelNumber = 0, totalMoves = 0, totalPushes = 0 }) => {
	const progress = { levelNumber, totalMoves, totalPushes };
	const jsonProgress = JSON.stringify(progress);
	const hashedProgress = btoa(jsonProgress);

	localStorage.setItem(PROGRESS_KEY, hashedProgress);
};

export const clear = () => {
	localStorage.removeItem(PROGRESS_KEY);
};

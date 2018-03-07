export const get = () => {
	var savedAt = localStorage.getItem('savedAt');
	var levelHash = localStorage.getItem('levelHash');

	return new Promise((resolve, reject) => {
		if (!savedAt || !levelHash) {
			console.debug('### No progress saved');
			resolve(0);
		}

		// Wow, this is horrible. Gief refactoring.
		try {
			var levelPlainText = atob(levelHash);
			var parts = (levelPlainText = levelPlainText.split('-'));
			var maybeLevelNumber = parts[1] === savedAt ? parseInt(parts[0]) : 0;
			var levelNumber = isNaN(maybeLevelNumber) ? 0 : maybeLevelNumber;

			resolve(levelNumber);
		} catch (e) {
			resolve(0);
		}
	});
};

export const save = level => {
	var savedAt = Date.now();
	var levelHash = btoa(level + '-' + savedAt);

	localStorage.setItem('savedAt', savedAt);
	localStorage.setItem('levelHash', levelHash);
};

export const clear = () => {
	localStorage.removeItem('savedAt');
	localStorage.removeItem('levelHash');
};

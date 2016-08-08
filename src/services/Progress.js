export const get = () => {
    var savedAt = localStorage.getItem('savedAt');
    var levelHash = localStorage.getItem('levelHash');

    if(!savedAt || !levelHash) {
        console.debug('### No progress saved');
        return 0;
    }

    var levelPlainText = atob(levelHash);
    var parts = levelPlainText = levelPlainText.split('-');

    return parts[1] === savedAt ? parts[0] : 0;
}

export const save = (level) => {
    var savedAt = Date.now();
    var levelHash = btoa(level + '-' +  savedAt);

    localStorage.setItem('savedAt', savedAt);
    localStorage.setItem('levelHash', levelHash);
}

export const clear = () => {
    localStorage.removeItem('savedAt');
    localStorage.removeItem('levelHash');
}

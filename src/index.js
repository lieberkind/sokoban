import "./main.css";
import { Elm } from "./Main.elm";
import registerServiceWorker from "./registerServiceWorker";
import * as Progress from "./services/Progress";

// Elm.Main.init({
//   node: document.getElementById('root')
// });

Progress.get().then(progress => {
  const app = Elm.Main.init({
    node: document.getElementById("root"),
    flags: { progress }
  });

  app.ports.saveProgress.subscribe(levelNumber => {
    Progress.save(levelNumber);
  });

  app.ports.clearProgress.subscribe(levelNumber => {
    Progress.clear();
  });

  // Animate soko. This is not nice. Should ideally be handled by Elm.
  const sokoSprites = [
    "soko-0",
    "soko-1",
    "soko-2",
    "soko-3",
    "soko-2",
    "soko-1"
  ];
  let sokoSpriteIndex = 0;

  setInterval(function() {
    const soko = document.getElementById("soko");

    if (soko) {
      soko.classList.remove(sokoSprites[sokoSpriteIndex]);

      sokoSpriteIndex = (sokoSpriteIndex + 1) % 5;
    }
  }, 300);

  const paintNextSoko = () => {
    const soko = document.getElementById("soko");
    if (soko) {
      soko.classList.add(sokoSprites[sokoSpriteIndex]);
    }
    requestAnimationFrame(paintNextSoko);
  };

  requestAnimationFrame(paintNextSoko);
});

registerServiceWorker();

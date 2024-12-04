import { HOME } from "./src/shared/constants";

import { App } from "astal/gtk3";
import Bar from "./src/widget/bar";
import Launcher from "./src/widget/launcher";
import NotificationPopups from "./src/widget/notifs/popups";
import Panel from "./src/widget/panel";
import { togglePopupWindow } from "./src/widget/PopupWindow";

import { writeFile } from "astal/file";
import { exec } from "astal/process";

import barStyle from "inline:./scss/bar.scss";
import notifStyle from "inline:./scss/notif.scss";
import launcherStyle from "inline:./scss/launcher.scss";
import panelStyle from "inline:./scss/panel.scss";
import miscStyle from "inline:./scss/misc.scss";

const colorsPath = `${HOME}/.config/ags_res/colors.scss`;
const tmpscss = "/tmp/style.scss";
const target = "/tmp/style.css";

writeFile(
  tmpscss,
  `
  @import "${colorsPath}";

  * {
    all: unset;
    &:not(icon) {
      font-family: "Rubik";
      font-size: 13px;
    }
  }

  ${miscStyle}
  ${barStyle}
  ${panelStyle}
  ${notifStyle}
  ${launcherStyle}
`,
);

exec(`sass ${tmpscss} ${target}`);

App.start({
  icons: `${SRC}/assets/icons`,
  requestHandler(req, res) {
    const [cmd, ...args] = req.split(" ");
    if (cmd == "toggle-popup") {
      togglePopupWindow(args[0]);
      res("");
    }
  },
  css: target,
  main() {
    Bar();
    Launcher();
    NotificationPopups();
    Panel();
  },
});

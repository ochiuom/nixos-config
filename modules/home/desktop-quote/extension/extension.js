import St from 'gi://St';
import GLib from 'gi://GLib';
import Clutter from 'gi://Clutter';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const QUOTE_FILE = GLib.build_filenamev([GLib.get_home_dir(), '.cache', 'desktop-quote', 'quote.txt']);
const REFRESH_INTERVAL = 3600;

let _label = null;
let _timeout = null;

function loadQuote() {
    try {
        let [ok, contents] = GLib.file_get_contents(QUOTE_FILE);
        if (ok) {
            let text = new TextDecoder().decode(contents).trim();
            _label.set_text(text);
        }
    } catch (e) {
        _label.set_text('The obstacle is the way.\n— Marcus Aurelius');
    }
    return GLib.SOURCE_CONTINUE;
}

export default class DesktopQuoteExtension {
    enable() {
        _label = new St.Label({
            style: [
                'font-family: "JetBrains Mono", monospace;',
                'font-size: 13px;',
                'font-style: italic;',
                'color: rgba(255, 255, 255, 0.80);',
                'background-color: rgba(30, 30, 30, 0.45);',
                'border-radius: 12px;',
                'padding: 16px 20px;',
            ].join(''),
            x_align: Clutter.ActorAlign.END,
            y_align: Clutter.ActorAlign.START,
        });

        _label.set_position(
            global.screen_width - 400,   // ← increase this to move left
            global.screen_height - 100   // ← bottom right
        );

       Main.layoutManager._backgroundGroup.add_child(_label);

        loadQuote();
        _timeout = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, REFRESH_INTERVAL, loadQuote);
    }

    disable() {
        if (_timeout) {
            GLib.source_remove(_timeout);
            _timeout = null;
        }
        if (_label) {
            _label.destroy();
            _label = null;
        }
    }
}

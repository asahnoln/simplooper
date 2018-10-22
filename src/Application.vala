// Copyright (C) 2018 Arthur Aslanyan
// 
// This file is part of looper.
// 
// looper is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// looper is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with looper.  If not, see <http://www.gnu.org/licenses/>.
// 

public class Looper : Gtk.Application {
    public Looper () {
        Object(
            application_id: "com.github.asahnoln.elementary-looper",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this);

        main_window.default_width = 200;
        main_window.default_height = 200;
        main_window.title = _("Looper");

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.HORIZONTAL;
        
        var start_button = new Gtk.Button.with_label (_("Start"));
        start_button.clicked.connect(() => {
            start_button.label = start_button.label == _("Start") ? _("Overdub") : _("Start");
        });

        var stop_button = new Gtk.Button.with_label (_("Stop"));

        grid.add (stop_button);
        grid.add (start_button);

        main_window.add (grid);
        main_window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Looper ();
        return app.run (args);
    }
}
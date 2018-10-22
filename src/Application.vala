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

        // TODO: Loops storage

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.HORIZONTAL;
        
        // Button labels mean COMMANDS to do, not STATES
        // Arguable?

        var start_button = new Gtk.Button.with_label (_("Rec"));
        start_button.clicked.connect(() => {
            // Primitive phases
            start_button.label = start_button.label == _("Rec") || start_button.label == _("Overdub")
                ? _("Play") // Record sound
                : _("Overdub"); // Play sound

            // TODO: Record and play sound

            // Limit to 5 minutes
            // Save in memory? On disk? 
            // I think it's better to work with current loop in memory and store other loops on disk
        });

        var stop_button = new Gtk.Button.with_label (_("Stop"));
        stop_button.clicked.connect(() => {
            start_button.label = _("Play");
        });

        // TODO: Add erase button
        // TODO: Add STATUS indicator
        // TODO: Change button labels with icons

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
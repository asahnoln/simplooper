// Copyright (C) 2020 Arthur Aslanyan
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
    private ushort state { get; set; default = 0; }
    private bool has_song { get; set; default = false; }

    enum StateType {
        STATE_STOPPED,
        STATE_RECORDING,
        STATE_PLAYING,
        STATE_OVERDUBBING
    }

    public Looper () {
        Object(
            application_id: "com.github.asahnoln.audiolooper",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        
        // Audio
        
        /* Initialize GStreamer */
        //  Gst.gst_init (/*&argc, &argv*/);
        
        /* Build the pipeline */
        //  var pipeline =
            //  Gst.gst_parse_launch
            //  ("playbin uri=https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm",
            //  NULL);

        /* Start playing */
        //  Gst.gst_element_set_state (pipeline, Gst.GST_STATE_PLAYING);

        /* Wait until error or EOS */
        //  var bus = Gst.gst_element_get_bus (pipeline);
        //  var msg =
            //  Gst.gst_bus_timed_pop_filtered (bus, Gst.GST_CLOCK_TIME_NONE,
            //  Gst.GST_MESSAGE_ERROR | Gst.GST_MESSAGE_EOS);

        /* Free resources */
        //  if (msg != NULL) {
            //  Gst.gst_message_unref (msg);
        //  }
        //  Gst.gst_object_unref (bus);
        //  Gst.gst_element_set_state (pipeline, Gst.GST_STATE_NULL);
        //  Gst.gst_object_unref (pipeline);

        // Grid
        var main_window = new Gtk.ApplicationWindow (this);

        main_window.default_width = 200;
        main_window.default_height = 200;
        main_window.title = _("Looper");

        // TODO: Loops storage

        var layout = new Gtk.Grid ();
        //  grid.orientation = Gtk.Orientation.HORIZONTAL;
        layout.column_spacing = 6;
        layout.row_spacing = 6;
        
        // Button labels mean COMMANDS to do, not STATES
        // Arguable?
        

        var start_button = new Gtk.Button.with_label (_("Rec"));
        start_button.clicked.connect(() => {
            // Primitive phases
            state = state == StateType.STATE_RECORDING || state == StateType.STATE_OVERDUBBING
                ? StateType.STATE_PLAYING // Record sound
                : StateType.STATE_OVERDUBBING // Play sound
            ;

            debug("Button clicked!");

            debug(state.to_string ());


            // TODO: Record and play sound

            // Limit to 5 minutes
            // Save in memory? On disk? 
            // I think it's better to work with current loop in memory and store other loops on disk
        });

        var stop_button = new Gtk.Button.with_label (_("Stop"));
        stop_button.sensitive = false;
        stop_button.clicked.connect(() => {
            //start_button.label = _("Play");
            if (state == StateType.STATE_STOPPED) {
                has_song = false;
            }
        });

        //  notify.connect((s, p) => {
        //      debug("Property changed! %s", p.name);
        //      switch (state) {
        //          case StateType.STATE_STOPPED:
        //              if (has_song) {
        //                  start_button.label = _("Play");
        //                  stop_button.label = _("Erase");
        //              } else {
        //                  start_button.label = _("Rec");
        //                  stop_button.label = _("Stop");
        //                  stop_button.sensitive = false;
        //              }
        //              break;
        //          case StateType.STATE_RECORDING:
        //              start_button.label = _("Play");
        //              stop_button.label = _("Stop");
        //              stop_button.sensitive = true;
        //              has_song = true;
        //              break;
        //          case StateType.STATE_PLAYING:
        //              start_button.label = _("Overdub");
        //              stop_button.sensitive = true;
        //              break;
        //          case StateType.STATE_OVERDUBBING:
        //              start_button.label = _("Play");
        //              break;
        //      }
        //  });

        // TODO: Add STATUS indicator
        // TODO: Change button labels with icons

        //  start_button.margin = 12;
        //  stop_button.margin = 12;

        layout.attach (stop_button, 0, 0, 1, 1);
        layout.attach_next_to (start_button, stop_button, Gtk.PositionType.RIGHT, 1, 1);

        main_window.add (layout);
        main_window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Looper ();
        return app.run (args);
    }
}
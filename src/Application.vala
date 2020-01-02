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
    protected enum StateType {
        NO_SONG,
        STOPPED,
        RECORDING,
        PLAYING,
        OVERDUBBING
    }
    protected StateType[] PrePlayStateType = {
        StateType.STOPPED,
        StateType.RECORDING,
        StateType.OVERDUBBING
    };
    protected StateType state { get; set; default = StateType.NO_SONG; }

    public Looper () {
        Object(
            application_id: "com.github.asahnoln.simplooper",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        
        // Audio
        
        
        
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

        // Build the pipeline:
        // Gst.Element pipeline;
        // try {
        //     pipeline = Gst.parse_launch ("playbin uri=https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm");
        // } catch (Error e) {
        //     stderr.printf ("Error: %s\n", e.message);
        //     return;
        // }

        // // Start playing:
        // pipeline.set_state (Gst.State.PLAYING);

        // // Wait until error or EOS:
        // var bus = pipeline.get_bus ();
        // bus.timed_pop_filtered (Gst.CLOCK_TIME_NONE, Gst.MessageType.ERROR | Gst.MessageType.EOS);

        // // Free resources:
        // pipeline.set_state (Gst.State.NULL);

        // Grid
        var main_window = new Gtk.ApplicationWindow (this);

        main_window.default_width = 200;
        main_window.default_height = 200;
        main_window.title = _("Audio Looper");

        // TODO: Loops storage

        var layout = new Gtk.Grid ();
        //  grid.orientation = Gtk.Orientation.HORIZONTAL;
        layout.column_spacing = 6;
        layout.row_spacing = 6;

        // TODO: Add STATUS indicator
        var statusbar = new Gtk.Statusbar ();
        var status_context_id = statusbar.get_context_id ("all");
        
        // Button labels mean COMMANDS to do, not STATES
        // Arguable?
        

        var start_button = new Gtk.Button.with_label (_("Rec"));
        start_button.clicked.connect(() => {
            // Primitive phases
            state = state in PrePlayStateType
                ? StateType.PLAYING 
                : (state == StateType.NO_SONG 
                    ? StateType.RECORDING 
                    : StateType.OVERDUBBING
                ) 
            ;
            // Limit to 5 minutes
            // Save in memory? On disk? 
            // I think it's better to work with current loop in memory and store other loops on disk
        });

        var stop_button = new Gtk.Button.with_label (_("Stop"));
        stop_button.sensitive = false;
        stop_button.clicked.connect(() => {
            state = state == StateType.STOPPED 
                ? StateType.NO_SONG // Remove song
                : StateType.STOPPED // Stop
            ;
        });

        // TODO: Вынести обработку состояний
        notify["state"].connect((s, p) => {
            switch (state) {
                case StateType.NO_SONG:
                    process_state_no_song (start_button, stop_button);
                    break;
                case StateType.STOPPED:
                    process_state_stopped (start_button, stop_button);
                    break;
                case StateType.RECORDING:
                    process_state_recording (start_button, stop_button);
                    break;
                case StateType.PLAYING:
                    process_state_playing (start_button, stop_button);
                    break;
                case StateType.OVERDUBBING:
                    process_state_overdubbing (start_button, stop_button);
                    break;
            }

            statusbar.push (status_context_id, state.to_string ()); 
        });

        // TODO: Change button labels with icons

        //  start_button.margin = 12;
        //  stop_button.margin = 12;

        layout.attach (stop_button, 0, 0, 1, 1);
        layout.attach_next_to (start_button, stop_button, Gtk.PositionType.RIGHT, 1, 1);

        layout.attach (statusbar, 0, 1, 1, 1);

        main_window.add (layout);
        main_window.show_all ();
    }

    private void process_state_no_song (Gtk.Button start_button, Gtk.Button stop_button) {
        start_button.label = _("Rec");
        stop_button.label = _("Stop");
        stop_button.sensitive = false;
    }

    private void process_state_stopped (Gtk.Button start_button, Gtk.Button stop_button) {
        start_button.label = _("Play");
        stop_button.label = _("Erase");
    }

    private void process_state_recording (Gtk.Button start_button, Gtk.Button stop_button) {
        start_button.label = _("Play");
        stop_button.label = _("Stop");
        stop_button.sensitive = true;
    }

    private void process_state_playing (Gtk.Button start_button, Gtk.Button stop_button) {
        start_button.label = _("Overdub");
        stop_button.label = _("Stop");
        stop_button.sensitive = true;
    }

    private void process_state_overdubbing (Gtk.Button start_button, Gtk.Button stop_button) {
        start_button.label = _("Play");
        stop_button.label = _("Stop");
    }

    public static int main (string[] args) {
        /* Initialize GStreamer */
        Gst.init (ref args);
        var app = new Looper ();
        return app.run (args);
    }
}

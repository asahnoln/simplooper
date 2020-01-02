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
    
    protected Gst.Element source;
    protected Gst.Element sink;
    protected Gst.Pipeline pipeline;
    

    // Thanks to reco
    private string _tmp_filename;
    private string _tmp_full_path;
    protected string tmp_filename { 
        get {
            if (_tmp_filename == null) {
                _tmp_filename = "simplooper_" + new DateTime.now_local ().to_unix ().to_string ();
            }
            return _tmp_filename;
        }
        set {
            _tmp_filename = value;
        }
    }
    protected string tmp_full_path {
        get {
            if (_tmp_full_path == null) {
                _tmp_full_path = Environment.get_tmp_dir () + "/%s%s".printf (tmp_filename, ".wav");
            }
            debug (_tmp_full_path);
            return _tmp_full_path;
        }
        set {
            _tmp_full_path = value;
        }
    }

    public Looper () {
        Object(
            application_id: "com.github.asahnoln.simplooper",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        
        // Grid
        var main_window = new Gtk.ApplicationWindow (this);

        main_window.default_width = 200;
        main_window.default_height = 200;
        main_window.title = _("Simplooper");

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

        stop_recording ();
        // stop_playing ();
    }

    private void process_state_recording (Gtk.Button start_button, Gtk.Button stop_button) {
        start_button.label = _("Play");
        stop_button.label = _("Stop");
        stop_button.sensitive = true;

        start_recording ();
    }

    private void process_state_playing (Gtk.Button start_button, Gtk.Button stop_button) {
        start_button.label = _("Overdub");
        stop_button.label = _("Stop");
        stop_button.sensitive = true;

        stop_recording ();
        start_playing ();
    }

    private void process_state_overdubbing (Gtk.Button start_button, Gtk.Button stop_button) {
        start_button.label = _("Play");
        stop_button.label = _("Stop");

        stop_playing ();
        start_recording ();
    }

    private void start_recording () {
        source = Gst.ElementFactory.make ("autoaudiosrc", "source");
        sink = Gst.ElementFactory.make ("filesink", "sink");
        pipeline = new Gst.Pipeline ("record-pipeline");
        var encoder = Gst.ElementFactory.make ("wavenc", "encoder");

        if (source == null || sink == null || pipeline == null || encoder == null) {
            stderr.puts ("Not all elements could be created.\n");
            return;
        }

        sink.set ("location", tmp_full_path);

        pipeline.add_many (encoder, sink, source);

        if (source.link (encoder) != true) {
            stderr.puts ("Source could not be linked to encoder.\n");
            return;
        }

        if (encoder.link (sink) != true) {
            stderr.puts ("Encoder could not be linked to sink.\n");
            return;
        }

        // Start playing:
        Gst.StateChangeReturn ret = pipeline.set_state (Gst.State.PLAYING);
        if (ret == Gst.StateChangeReturn.FAILURE) {
            stderr.puts ("Unable to set the pipeline to the playing state.\n");
            return;
        }

        // Wait until error or EOS:
        // Gst.Bus bus = pipeline.get_bus ();
        // Gst.Message msg = bus.timed_pop_filtered (Gst.CLOCK_TIME_NONE, Gst.MessageType.ERROR | Gst.MessageType.EOS);

        // // Parse message:
        // if (msg != null) {
        //     switch (msg.type) {
        //     case Gst.MessageType.ERROR:
        //         GLib.Error err;
        //         string debug_info;

        //         msg.parse_error (out err, out debug_info);
        //         stderr.printf ("Error received from element %s: %s\n", msg.src.name, err.message);
        //         stderr.printf ("Debugging information: %s\n", (debug_info != null)? debug_info : "none");
        //         break;

        //     case Gst.MessageType.EOS:
        //         print ("End-Of-Stream reached.\n");
        //         break;

        //     default:
        //         // We should not reach here because we only asked for ERRORs and EOS:
        //         assert_not_reached ();
        //     }
        // }
    }

    private void stop_recording () {
        // Free resources: 
        pipeline.set_state (Gst.State.NULL);
    }

    private void start_playing() {
        source = Gst.ElementFactory.make ("filesrc", "source");
        sink = Gst.ElementFactory.make ("autoaudiosink", "sink");
        pipeline = new Gst.Pipeline ("play-pipeline");

        if (source == null || sink == null || pipeline == null) {
            stderr.puts ("Not all elements could be created.\n");
            return;
        }

        source.set ("location", tmp_full_path);

        pipeline.add_many (source, sink);

        if (source.link (sink) != true) {
            stderr.puts ("Elements could not be linked.\n");
            return;
        }

        // Start playing:
        Gst.StateChangeReturn ret = pipeline.set_state (Gst.State.PLAYING);
        if (ret == Gst.StateChangeReturn.FAILURE) {
            stderr.puts ("Unable to set the pipeline to the playing state.\n");
            return;
        }
    }

    private void stop_playing() {
        pipeline.set_state (Gst.State.NULL);
    }

    public static int main (string[] args) {
        /* Initialize GStreamer */
        Gst.init (ref args);
        var app = new Looper ();
        return app.run (args);
    }
}

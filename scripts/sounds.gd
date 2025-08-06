extends AudioStreamPlayer


enum ID {
	NONE = -1,
}


var sound_resources : Dictionary[ID, String] = {
	
}


const TRANSITION_TIME : float = 2.0;


var current_track : ID = -1;
var remember_position : bool = true;
var play_from : float = 0.0;


func get_stream_by_id(id: ID) -> AudioStream:
	return null;


func play_looped(new_track: ID) -> void:
	if new_track == current_track:
		return;
	
	current_track = new_track;
	
	var new_stream := get_stream_by_id(new_track);
	match new_stream: # set up looping
		_ when new_stream is AudioStreamWAV:
			new_stream.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD;
			new_stream.loop_end = new_stream.get_length() * new_stream.mix_rate;
		_ when new_stream is AudioStreamMP3 or new_stream is AudioStreamOggVorbis:
			new_stream.loop = true;
		_:
			# other cases not implemented
			push_warning(
				"unexpected music stream type for %s, looping won't work"
				% ID.find_key(new_track)
			);
	
	stream = new_stream;
	play();

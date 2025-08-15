extends AudioStreamPlayer


enum ID {
	NONE = -1,
	
	MUSIC_ESCAPE_FROM_TARKOV,
	MUSIC_UPGRADE_SHOP_THEME,
	MUSIC_UPGRADE_SHOP_THEME_COOL,
	MUSIC_MELANCHOLY_TOMATO,
	MUSIC_CITY,
	MUSIC_METAL,
	MUSIC_BACKSTAGE,
	MUSIC_STAGE,
	
	MUSIC_GOOFY_AAH,
	
	SFX_FUCK,
	SFX_AAGH,
	SFX_AGGH,
	SFX_AGHH,
	SFX_ARGH,
	SFX_GRUNT,
	SFX_1KMIC,
	
	SFX_JUMP,
	SFX_FLAP,
	SFX_COIN,
}


var sound_resources : Dictionary[ID, String] = {
	ID.MUSIC_ESCAPE_FROM_TARKOV: "res://assets/music/Menu - Escaping the Tomato Farm v2.ogg",
	ID.MUSIC_UPGRADE_SHOP_THEME: "res://assets/music/Last cup of coffee - lofi bossa.ogg",
	ID.MUSIC_UPGRADE_SHOP_THEME_COOL: "res://assets/music/Last cup of coffee - lofi bossa with quotes.ogg",
	ID.MUSIC_MELANCHOLY_TOMATO: "res://assets/music/Tomato Farm v2.ogg",
	ID.MUSIC_CITY: "res://assets/music/Doki in the City - more tame.ogg",
	ID.MUSIC_METAL: "res://assets/music/A Metal Cup of Coffee.ogg",
	ID.MUSIC_GOOFY_AAH: "res://assets/music/Doki in the City.ogg",
	ID.MUSIC_BACKSTAGE: "res://assets/music/Backstage.ogg",
	ID.MUSIC_STAGE: "res://assets/music/On the Stage - Dokibird Ending Theme Remake.ogg",
	
	ID.SFX_FUCK: "res://assets/sfx/fuck.wav",
	ID.SFX_AAGH: "res://assets/sfx/Scream 1.wav",
	ID.SFX_AGGH: "res://assets/sfx/Scream 2.wav",
	ID.SFX_AGHH: "res://assets/sfx/Scream 3.wav",
	ID.SFX_ARGH: "res://assets/sfx/Scream 4.wav",
	ID.SFX_GRUNT: "res://assets/sfx/grunt 1.wav",
	ID.SFX_1KMIC: "res://assets/sfx/1k mic.ogg",
	
	ID.SFX_JUMP: "res://assets/sfx/Jump 1.ogg",
	ID.SFX_FLAP: "res://assets/sfx/Jump 2.ogg",
	ID.SFX_COIN: "res://assets/sfx/Coin 2.ogg",
}


var current_track : ID = ID.NONE;


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;
	bus = &"music";


func get_stream_by_id(id: ID) -> AudioStream:
	return load(sound_resources.get(id, null));


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

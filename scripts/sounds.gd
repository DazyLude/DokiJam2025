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
	SFX_AAAAH,
	
	SFX_GRUNT,
	SFX_1KMIC,
	
	SFX_JUMP,
	SFX_FLAP,
	SFX_COIN,
	SFX_KETCHUP,
	SFX_IMPACT,
	SFX_IMPACT2,
	
	VOX_UEH,
	VOX_OOH,
	VOX_LAUGH,
	VOX_EH,
	VOX_UGHH,
	VOX_OUF,
	VOX_AAH,
	VOX_AAAH,
	VOX_NYOO,
	VOX_SIGH,
	VOX_WHAT,
	VOX_AIGHT,
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
	
	ID.SFX_FUCK: "res://assets/sfx/fuck.ogg",
	ID.SFX_AAGH: "res://assets/sfx/Scream 1.ogg",
	ID.SFX_AGGH: "res://assets/sfx/Scream 2.ogg",
	ID.SFX_AGHH: "res://assets/sfx/Scream 3.ogg",
	ID.SFX_ARGH: "res://assets/sfx/Scream 4.ogg",
	ID.SFX_AAAAH: "res://assets/sfx/Scream 5 (long).ogg",
	
	ID.SFX_GRUNT: "res://assets/sfx/Grunt 1 v4.ogg",
	ID.SFX_1KMIC: "res://assets/sfx/1k mic.ogg",
	
	ID.SFX_JUMP: "res://assets/sfx/Jump 1-3.ogg",
	ID.SFX_FLAP: "res://assets/sfx/Jump 2.ogg",
	ID.SFX_COIN: "res://assets/sfx/Coin 2.ogg",
	ID.SFX_KETCHUP: "res://assets/sfx/Ketchup 1.ogg",
	ID.SFX_IMPACT: "res://assets/sfx/Impact 1.ogg",
	ID.SFX_IMPACT2: "res://assets/sfx/Impact 2.ogg",
	
	ID.VOX_LAUGH: "res://assets/sfx/Laugh 1.ogg",
	ID.VOX_UEH: "res://assets/sfx/Vox 1 ueh.ogg",
	ID.VOX_OOH: "res://assets/sfx/Vox 2.ogg",
	ID.VOX_EH: "res://assets/sfx/Vox 3.ogg",
	ID.VOX_UGHH: "res://assets/sfx/Vox 4.ogg",
	ID.VOX_OUF: "res://assets/sfx/Vox 5.ogg",
	ID.VOX_AAH: "res://assets/sfx/Vox 6.ogg",
	ID.VOX_AAAH: "res://assets/sfx/Vox 7.ogg",
	ID.VOX_NYOO: "res://assets/sfx/Vox 8 noo.ogg",
	ID.VOX_SIGH: "res://assets/sfx/Vox 9 sigh.ogg",
	ID.VOX_WHAT: "res://assets/sfx/Vox 10 what.ogg",
	ID.VOX_AIGHT: "res://assets/sfx/Vox 11 um alright.ogg",
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

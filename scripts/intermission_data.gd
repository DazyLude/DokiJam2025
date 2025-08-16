class_name IntermissionData

enum {
	TYPE_YONKOMA,
	TYPE_DIALOGUE,
}


enum {
	CHARACTER_TOMATO,
	CHARACTER_CROWKI,
	CHARACTER_RETRO,
	CHARACTER_BOUNTY,
	CHARACTER_DRAGOON,
}

enum {
	EMOTE_NORMAL,
	EMOTE_TIRED,
	EMOTE_HURT,
}


static var character_data : Dictionary[int, Dictionary] = {
	CHARACTER_TOMATO: {
		"base": "res://assets/intermissions/tomato_sprite.png",
		"name": "Doki",
		"emotions": {
			EMOTE_NORMAL: "",
		},
		"speech": Sounds.ID.SFX_OOH,
	},
	CHARACTER_CROWKI: {
		"base": "res://assets/intermissions/crow_sprite.png",
		"name": "Doki",
		"emotions": {
			EMOTE_NORMAL: "",
		},
	},
	CHARACTER_RETRO: {
		"base": "res://assets/intermissions/retro_sprite.png",
		"name": "Doki",
		"emotions": {
			EMOTE_NORMAL: "",
		},
	},
	CHARACTER_BOUNTY: {
		"base": "res://assets/intermissions/bounty_sprite.png",
		"name": "Doki",
		"emotions": {
			EMOTE_NORMAL: "",
		},
	},
	CHARACTER_DRAGOON: {
		"base": "res://assets/intermissions/goons_sprite.png",
		"name": "Dragoon",
		"emotions": {
			EMOTE_NORMAL: "",
		},
		"speech": Sounds.ID.SFX_UEH,
	},
}


static var intermission_data : Dictionary[String, Dictionary] = {
	"intro": {
		"type": TYPE_YONKOMA,
		"images": [
			"res://assets/intermissions/actual_intro/intro_1.png",
			"res://assets/intermissions/actual_intro/intro_2.png",
			"res://assets/intermissions/actual_intro/intro_3.png",
			"res://assets/intermissions/actual_intro/intro_4.png"
		],
		"background": "res://assets/intermissions/actual_intro/bg.png",
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
	},
	"outro": {
		"type": TYPE_YONKOMA,
		"images": [
			"res://assets/intermissions/outro/end_1.png",
			"res://assets/intermissions/outro/end_2.png",
			"res://assets/intermissions/outro/end_3.png",
			"res://assets/intermissions/outro/end_4.png"
		],
		"background": "res://assets/intermissions/actual_intro/bg.png",
		"bgm": Sounds.ID.MUSIC_STAGE,
	},
	"vn1-2": {
		"type": TYPE_DIALOGUE,
		"background": "res://assets/stages/farm/tomato_farm.png",
		"characters": [CHARACTER_TOMATO, CHARACTER_DRAGOON],
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
		"dialogue": [
			[CHARACTER_TOMATO, "hey", {"sfx": Sounds.ID.SFX_OOH}],
			[CHARACTER_DRAGOON, "caw!", {"sfx": Sounds.ID.SFX_OOH}],
			[CHARACTER_TOMATO, "hey", {"swap": CHARACTER_CROWKI, "sfx": Sounds.ID.SFX_LAUGH}],
			[CHARACTER_DRAGOON, "hey", {"sfx": Sounds.ID.SFX_LAUGH}],
		],
	},
	"vn2-3": {
		"type": TYPE_DIALOGUE,
		"background": "res://assets/stages/farm/tomato_farm.png",
		"characters": [CHARACTER_TOMATO, CHARACTER_DRAGOON],
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
		"dialogue": [
			[CHARACTER_TOMATO, "hey"],
			[CHARACTER_DRAGOON, "caw!"],
		],
	},
	"vn3-4": {
		"type": TYPE_DIALOGUE,
		"background": "res://assets/stages/farm/tomato_farm.png",
		"characters": [CHARACTER_TOMATO, CHARACTER_DRAGOON],
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
		"dialogue": [
			[CHARACTER_TOMATO, "hey"],
			[CHARACTER_DRAGOON, "caw!"],
		],
	},
	"vn4-5": {
		"type": TYPE_DIALOGUE,
		"background": "res://assets/stages/farm/tomato_farm.png",
		"characters": [CHARACTER_TOMATO, CHARACTER_DRAGOON],
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
		"dialogue": [
			[CHARACTER_TOMATO, "hey"],
			[CHARACTER_DRAGOON, "caw!"],
		],
	},
}

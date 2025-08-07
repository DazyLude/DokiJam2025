class_name IntermissionData

enum {
	TYPE_YONKOMA,
	TYPE_DIALOGUE,
}


enum {
	CHARACTER_TOMATO,
	CHARACTER_CROWKI,
}

enum {
	EMOTE_NORMAL,
	EMOTE_TIRED,
	EMOTE_HURT,
}


static var character_data : Dictionary[int, Dictionary] = {
	CHARACTER_TOMATO: {
		"base": "res://assets/skinsuits/tomato/tomato_base.png",
		"name": "Tomato",
		"emotions": {
			EMOTE_NORMAL: "res://assets/skinsuits/tomato/tomato_neutral.png",
			EMOTE_TIRED: "res://assets/skinsuits/tomato/tomato_tired.png",
			EMOTE_HURT: "res://assets/skinsuits/tomato/tomato_hurt.png",
		},
		"speech": Sounds.ID.SFX_FUCK,
	},
	CHARACTER_CROWKI: {
		"base": "res://assets/skinsuits/crowki/crowki_base.png",
		"name": "Crowki",
		"emotions": {
			EMOTE_NORMAL: "res://assets/skinsuits/crowki/crowki_neutral.png",
			EMOTE_TIRED: "res://assets/skinsuits/crowki/crowki_tired.png",
			EMOTE_HURT: "res://assets/skinsuits/crowki/crowki_hurt.png",
		},
		"speech": [Sounds.ID.SFX_AAGH, Sounds.ID.SFX_AGGH, Sounds.ID.SFX_AGHH, Sounds.ID.SFX_ARGH, Sounds.ID.SFX_UUGH],
	}
}


static var intermission_data : Dictionary[String, Dictionary] = {
	"intro": {
		"type": TYPE_YONKOMA,
		"images": [
			"res://assets/intermissions/intro/loss_f1.tres",
			"res://assets/intermissions/intro/loss_f2.tres",
			"res://assets/intermissions/intro/loss_f3.tres",
			"res://assets/intermissions/intro/loss_f4.tres"
		],
		"background": "res://assets/stages/farm/tomato_farm.png",
	},
	"tomato field massacre": {
		"type": TYPE_DIALOGUE,
		"background": "res://assets/stages/farm/tomato_farm.png",
		"characters": [CHARACTER_TOMATO, CHARACTER_CROWKI],
		"dialogue": [
			[CHARACTER_TOMATO, EMOTE_NORMAL, "hey"],
			[CHARACTER_CROWKI, EMOTE_NORMAL, "caw!"],
		],
	}
}

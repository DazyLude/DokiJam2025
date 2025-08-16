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
		"speech": Sounds.ID.VOX_OOH,
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
		"speech": Sounds.ID.VOX_OOH,
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
			[
				CHARACTER_DRAGOON,
				"Welcome to our Cafe, what would you like?",
				{"sfx": Sounds.ID.VOX_EH}
			],
			[
				CHARACTER_TOMATO,
				"I wanna fly. Do you have anything that can make me fly?",
				{"sfx": Sounds.ID.VOX_UGHH}
			],
			[
				CHARACTER_DRAGOON,
				"Sorry, we don’t have any R*d B*ll. We don’t have the rights to that.",
				{"sfx": Sounds.ID.VOX_UEH}
			],
			[
				CHARACTER_DRAGOON,
				"We have some coffee left though!",
				{"sfx": Sounds.ID.VOX_UGHH}
			],
			[
				CHARACTER_TOMATO,
				"R*d B*ll? Coffee? I don’t know what that is. I picked up some coins outside though, so I’ll take whatever you have.",
				{"sfx": Sounds.ID.VOX_SIGH}
			],
			[
				CHARACTER_DRAGOON,
				"Ok, here you go. Your Last Cup of Coffee.",
				{"sfx": Sounds.ID.VOX_AIGHT}
			],
			[
				CHARACTER_TOMATO,
				"Wowwww, how the heck did that happen?",
				{"sfx": Sounds.ID.VOX_WHAT, "swap": CHARACTER_CROWKI}
			],
			[
				CHARACTER_TOMATO,
				"Can I get more of that?",
				{"sfx": Sounds.ID.VOX_OOH}
			],
			[
				CHARACTER_DRAGOON,
				"Sorry we’re completely out of coffee now.",
				{"sfx": Sounds.ID.VOX_SIGH}
			],
			[
				CHARACTER_DRAGOON,
				"If you’re just looking for caffeine, there’s a DokiSupps™ dispensary in town you could try.",
				{"sfx": Sounds.ID.VOX_AAAH}
			],
			[
				CHARACTER_TOMATO,
				"Hey wait, [i]I’m[/i] Doki!",
				{"sfx": Sounds.ID.VOX_OUF}
			],
			[
				CHARACTER_TOMATO,
				"This must be a sign. DokiSupps™ here I come!",
				{"sfx": Sounds.ID.VOX_AAH}
			],
			[
				CHARACTER_DRAGOON,
				"Hey wait, before you go, be careful out there. After the old lady at the farm had a heart attack tomato juice production has reached an all time low.",
				{"sfx": Sounds.ID.VOX_SIGH}
			],
			[
				CHARACTER_DRAGOON,
				"None of the cars are running these days. I can’t even buy any more coffee beans.",
				{"sfx": Sounds.ID.VOX_NYOO}
			],
			[
				CHARACTER_TOMATO,
				"Oh, that sucks. Anyways, Byeeeeeeeeee~~~",
				{"sfx": Sounds.ID.VOX_LAUGH}
			],
		],
	},
	"vn2-3": {
		"type": TYPE_DIALOGUE,
		"background": "res://assets/stages/farm/tomato_farm.png",
		"characters": [CHARACTER_CROWKI, CHARACTER_DRAGOON],
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
		"dialogue": [
			[CHARACTER_TOMATO, "hey"],
			[CHARACTER_DRAGOON, "caw!"],
		],
	},
	"vn3-4": {
		"type": TYPE_DIALOGUE,
		"background": "res://assets/stages/farm/tomato_farm.png",
		"characters": [CHARACTER_RETRO, CHARACTER_DRAGOON],
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
		"dialogue": [
			[CHARACTER_TOMATO, "hey"],
			[CHARACTER_DRAGOON, "caw!"],
		],
	},
	"vn4-5": {
		"type": TYPE_DIALOGUE,
		"background": "res://assets/stages/farm/tomato_farm.png",
		"characters": [CHARACTER_BOUNTY, CHARACTER_DRAGOON],
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
		"dialogue": [
			[CHARACTER_TOMATO, "hey"],
			[CHARACTER_DRAGOON, "caw!"],
		],
	},
}

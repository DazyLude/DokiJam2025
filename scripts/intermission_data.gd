class_name IntermissionData


const tm_string = '[font_size=24][b][i]™[/i][/b][/font_size]';


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
	CHARACTER_DRAGOON_FLIPPED,
	
	CHARACTER_EMPTY,
	CHARACTER_EMPTY2,
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
	CHARACTER_DRAGOON_FLIPPED: {
		"base": "res://assets/intermissions/goons_sprite_f.png",
		"name": "Other Dragoon",
		"emotions": {
			EMOTE_NORMAL: "",
		},
		"speech": Sounds.ID.VOX_OOH,
	},
	CHARACTER_EMPTY: {
		"base": "",
		"name": "Dragoon",
		"emotions": {
			EMOTE_NORMAL: "",
		},
		"speech": Sounds.ID.VOX_OOH,
	},
	CHARACTER_EMPTY2: {
		"base": "",
		"name": "Other Dragoon",
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
				"If you’re just looking for caffeine, there’s a DokiSupps%s dispensary in town you could try." % tm_string,
				{"sfx": Sounds.ID.VOX_AAAH}
			],
			[
				CHARACTER_TOMATO,
				"Hey wait, [i]I’m[/i] Doki!",
				{"sfx": Sounds.ID.VOX_OUF}
			],
			[
				CHARACTER_TOMATO,
				"This must be a sign. DokiSupps%s here I come!" % tm_string,
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
		"background": "res://assets/stages/city/shopping_street.png",
		"characters": [CHARACTER_CROWKI, CHARACTER_DRAGOON],
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
		"dialogue": [
			[
				CHARACTER_DRAGOON,
				"Hello, welcome to the DokiSupps%s dispensary, what can I help you with?" % tm_string,
				{"sfx": Sounds.ID.VOX_SIGH}
			],
			[
				CHARACTER_CROWKI,
				"Give me everything you have.",
				{"sfx": Sounds.ID.VOX_OOH}
			],
			[
				CHARACTER_DRAGOON,
				"Are you robbing me??",
				{"sfx": Sounds.ID.SFX_AGGH}
			],
			[
				CHARACTER_CROWKI,
				"Of course not! See, I have money.",
				{"sfx": Sounds.ID.VOX_UGHH}
			],
			[
				CHARACTER_DRAGOON,
				"Oh, ok, here you are!",
				{"sfx": Sounds.ID.VOX_UEH}
			],
			[
				CHARACTER_CROWKI,
				"Yes, I need more! Do you have any more?",
				{"swap": CHARACTER_RETRO, "sfx": Sounds.ID.VOX_LAUGH}
			],
			[
				CHARACTER_DRAGOON,
				"Nope, I sold you all I have. I didn’t even have that much left after I sold a bunch to Miss Fantome.",
				{"sfx": Sounds.ID.VOX_NYOO}
			],
			[
				CHARACTER_CROWKI,
				"Who’s that?",
				{"sfx": Sounds.ID.VOX_WHAT}
			],
			[
				CHARACTER_DRAGOON,
				"Oh she’s a local idol who has dreams of making it big. She’s performing today to try to keep everyone awake.",
				{"sfx": Sounds.ID.VOX_AAH}
			],
			[
				CHARACTER_DRAGOON,
				"People’s coffee around town has been mysteriously disappearing recently and they’re making a big fuss.",
				{"sfx": Sounds.ID.VOX_AAAH}
			],
			[
				CHARACTER_DRAGOON,
				"There’s only so much the energy drinks we supply can do for them.",
				{"sfx": Sounds.ID.VOX_SIGH}
			],
			[
				CHARACTER_DRAGOON,
				"The only thing that can calm them down is Miss Fantome’s dulcet tones.",
				{"sfx": Sounds.ID.VOX_SIGH}
			],
			[
				CHARACTER_CROWKI,
				"Cool story bro. Where is this performance happening?",
				{"sfx": Sounds.ID.VOX_AIGHT}
			],
			[
				CHARACTER_DRAGOON,
				"Oh, it’s at the Arena in the middle of the city. About that way.",
				{"sfx": Sounds.ID.VOX_OOH}
			],
			[
				CHARACTER_CROWKI,
				"Kay, thanks, byeee~",
				{"sfx": Sounds.ID.VOX_LAUGH}
			],
		],
	},
	"vn3-4": {
		"type": TYPE_DIALOGUE,
		"background": "res://assets/stages/backstage/backstage.png",
		"characters": [CHARACTER_RETRO, CHARACTER_EMPTY, CHARACTER_EMPTY2],
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
		"dialogue": [
			[
				CHARACTER_RETRO,
				"This must be the arena. Let’s see what we have here…",
				{"sfx": Sounds.ID.VOX_UGHH}
			],
			[
				CHARACTER_RETRO,
				"Oh boy, I must have hit the jackpot! There’s so much DokiSupps%s here." % tm_string,
				{"sfx": Sounds.ID.VOX_LAUGH}
			],
			[
				CHARACTER_RETRO,
				"Yum yum.",
				{"sfx": Sounds.ID.VOX_OOH}
			],
			[
				CHARACTER_RETRO,
				"I think I’ve reached my final form!",
				{"swap": CHARACTER_BOUNTY, "sfx": Sounds.ID.VOX_LAUGH}
			],
			[
				CHARACTER_RETRO,
				"Wait, someone’s coming. I gotta hide.",
				{"sfx": Sounds.ID.VOX_AAAH}
			],
			[
				CHARACTER_RETRO,
				"",
				{"hide": true, "skip": true}
			],
			[
				CHARACTER_EMPTY,
				"I know Miss Fantome gets cranky when she hasn’t had caffeine in a while, but did we really have to keep it so far away?",
				{"walk in": {"side": 1, "character": CHARACTER_DRAGOON}, "sfx": Sounds.ID.VOX_SIGH}
			],
			[CHARACTER_RETRO, "", {"skip": true, "flip": true}],
			[
				CHARACTER_EMPTY2,
				"And saying she won’t perform if she doesn’t get any soon? How needy can one person get?",
				{"walk in": {"side": 0, "character": CHARACTER_DRAGOON_FLIPPED}, "sfx": Sounds.ID.VOX_UGHH}
			],
			[
				CHARACTER_RETRO,
				"Heh heh, what a sucker.",
				{"sfx": Sounds.ID.VOX_EH}
			],
			[CHARACTER_RETRO, "", {"skip": true, "flip": true}],
			[
				CHARACTER_EMPTY,
				"Oh nonononononononono.",
				{"sfx": Sounds.ID.VOX_NYOO}
			],
			[
				CHARACTER_EMPTY,
				"How can we possibly be out of DokiSupps%s already? We just bought some more." % tm_string,
				{"sfx": Sounds.ID.VOX_NYOO}
			],
			[
				CHARACTER_EMPTY,
				"Now Miss Fantome is going to kill me, the wisps are going to riot!",
				{"sfx": Sounds.ID.VOX_EH}
			],
			[CHARACTER_RETRO, "", {"skip": true, "flip": true}],
			[
				CHARACTER_EMPTY2,
				"And more importantly, this concert is going to be cancelled!",
				{"sfx": Sounds.ID.VOX_NYOO}
			],
			[
				CHARACTER_EMPTY2,
				"Where are we supposed to find a replacement?",
				{"sfx": Sounds.ID.VOX_SIGH}
			],
			[
				CHARACTER_EMPTY2,
				"We can’t even pay anyone with anything other than a dog.",
				{"sfx": Sounds.ID.VOX_SIGH}
			],
			[
				CHARACTER_RETRO,
				"Wait, I can sing and I get a dog too?",
				{"hide": false, "sfx": Sounds.ID.VOX_WHAT}
			],
			[
				CHARACTER_EMPTY2,
				"Ahhhhhhh! Who are you?!",
				{"sfx": Sounds.ID.SFX_AGGH}
			],
			[
				CHARACTER_RETRO,
				"Don’t worry about it, show me where the stage is. And get me that dog!",
				{"flip": true, "sfx": Sounds.ID.VOX_LAUGH}
			],
		],
	},
	"vn4-5": {
		"type": TYPE_DIALOGUE,
		"background": "res://assets/stages/stage/stage.png",
		"characters": [CHARACTER_BOUNTY, CHARACTER_DRAGOON],
		"bgm": Sounds.ID.MUSIC_GOOFY_AAH,
		"dialogue": [
			[
				CHARACTER_DRAGOON,
				"Here we are then. Hopefully you can actually sing, miss.",
				{"sfx": Sounds.ID.VOX_AAH}
			],
			[
				CHARACTER_BOUNTY,
				"Don’t worry about it.",
				{"sfx": Sounds.ID.VOX_EH}
			],
			[
				CHARACTER_DRAGOON,
				"Before you go on, we were planning on sending Miss Fantome on tour.",
				{"sfx": Sounds.ID.VOX_AAH}
			],
			[
				CHARACTER_DRAGOON,
				"If this goes well, we can send you instead.",
				{"sfx": Sounds.ID.VOX_AAAH}
			],
			[
				CHARACTER_BOUNTY,
				"Alright bet. Make sure you prepare some Doki World Tour posters!",
				{"sfx": Sounds.ID.VOX_LAUGH}
			],
			[
				CHARACTER_DRAGOON,
				"Break a leg. Or, well, we’d really prefer if you didn’t.",
				{"sfx": Sounds.ID.VOX_SIGH}
			],
		],
	},
}

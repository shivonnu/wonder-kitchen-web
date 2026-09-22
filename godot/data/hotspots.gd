class_name Hotspots
extends Object

const ITEM_META := {
	"memo": {"name": "ルナのメモ", "icon": "res://assets/art/icon-memo.png"},
	"potato": {"name": "星いも", "icon": "res://assets/art/potato.png"},
	"onion": {"name": "月たまねぎ", "icon": "res://assets/art/onion.png"},
	"moonMilk": {"name": "月牛乳", "icon": "res://assets/art/icon-milk.png"},
	"starSalt": {"name": "星しお", "icon": "res://assets/art/icon-salt.png"},
}

const HAND_NAMES := {
	"": "素手",
	"knife": "包丁",
	"potato": "星いも",
	"onion": "月たまねぎ",
	"chopped_potato": "切った星いも",
	"chopped_onion": "切った月たまねぎ",
	"moonMilk": "月牛乳",
	"starSalt": "星しお",
}

const BACK := {
	"starRoad": "kitchen",
	"moonField": "starRoad",
	"moonCave": "moonField",
	"cooking": "kitchen",
}

const ART := {
	"kitchen": "res://assets/art/kitchen.png",
	"starRoad": "res://assets/art/star-road.png",
	"moonField": "res://assets/art/moon-field.png",
	"moonCave": "res://assets/art/moon-cave.png",
}

const TITLES := {
	"kitchen": "夜のキッチン",
	"starRoad": "星の道",
	"moonField": "月のうら側の畑",
	"moonCave": "月の洞窟",
	"cooking": "料理",
}

const SCENES := {
	"kitchen": {
		"title": "夜のキッチン",
		"art": "kitchen",
		"hotspots": [
			{
				"id": "table",
				"label": "木のテーブル",
				"x": 56, "y": 62, "w": 16, "h": 16,
				"fx": "table",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "まな板は、料理をはじめてから出てくるよ。いまはメモと、おなかの準備。"},
				],
			},
			{
				"id": "wallStars",
				"label": "壁の星くず",
				"x": 38, "y": 8, "w": 14, "h": 18,
				"fx": "wallStars",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "壁に落ちた星くず。なめると、ほんの少し塩味。"},
				],
			},
			{
				"id": "bench",
				"label": "石のベンチ",
				"x": 64, "y": 42, "w": 16, "h": 16,
				"fx": "bench",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "ルナがよくここで、足をぶらぶらしてた。"},
				],
			},
			{
				"id": "shion",
				"label": "しおん",
				"x": 32, "y": 54, "w": 8, "h": 18,
				"actions": [
					{
						"type": "flag",
						"flag": "metShion",
						"speaker": "しおん",
						"text": "ようこそ、ほししおの島へ。今夜は月あかりポタージュをつくりたいの。ルナがメモを置いていったよ。",
					},
				],
			},
			{
				"id": "luna",
				"label": "うさぎのルナ",
				"x": 46, "y": 52, "w": 10, "h": 18,
				"hideWhen": ["lunaLeft"],
				"actions": [
					{
						"type": "give",
						"item": "memo",
						"speaker": "ルナ",
						"text": "ぴょん。メモ、置いてく。月あかりポタージュ：星いも、月たまねぎ、月牛乳、星しお。窓から月のうら側へいけるよ。",
					},
					{"type": "flag", "flag": "gotMemo", "speaker": "ルナ", "text": "足跡をたどってきて。先にいっちゃう。"},
					{"type": "flag", "flag": "lunaLeft", "speaker": "ルナ", "text": "窓の向こうで待ってる。ぴょんっ。"},
				],
			},
			{
				"id": "memoSpot",
				"label": "テーブルのメモ",
				"x": 46, "y": 56, "w": 10, "h": 16,
				"showWhen": ["lunaLeft"],
				"fx": "memoSpot",
				"actions": [
					{
						"type": "say",
						"speaker": "メモ",
						"text": "月あかりポタージュ：星いも、月たまねぎ、月牛乳、仕上げに星しお。",
					},
				],
			},
			{
				"id": "window",
				"label": "丸い窓",
				"x": 52, "y": 4, "w": 28, "h": 38,
				"actions": [
					{
						"type": "flag",
						"flag": "windowOpen",
						"speaker": "しおん",
						"text": "窓の向こうは星の道。月のうら側の畑につながっているよ。",
					},
					{"type": "go", "scene": "starRoad"},
				],
			},
			{
				"id": "saltJar",
				"label": "星しおの壺",
				"x": 80, "y": 32, "w": 12, "h": 20,
				"hideWhen": ["saltTaken"],
				"actions": [
					{
						"type": "give",
						"item": "starSalt",
						"speaker": "しおん",
						"text": "島の特製、星しお。天の川の粒が少し混ざっているの。マヨネーズとはちがう、塩の魔法だよ。",
					},
					{"type": "flag", "flag": "saltTaken", "speaker": "しおん", "text": "ひとふりで星空の味。"},
				],
			},
			{
				"id": "emptySalt",
				"label": "空の壺",
				"x": 80, "y": 32, "w": 12, "h": 20,
				"showWhen": ["saltTaken"],
				"fx": "emptySalt",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "星しおはもうカバンのなか。大切にね。"},
				],
			},
			{
				"id": "pot",
				"label": "お鍋",
				"x": 18, "y": 32, "w": 16, "h": 28,
				"fx": "pot",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "まだ何も入っていない。材料がそろったら、ここで煮よう。"},
				],
			},
			{
				"id": "clock",
				"label": "星座時計",
				"x": 18, "y": 6, "w": 16, "h": 22,
				"fx": "clock",
				"actions": [
					{"type": "say", "speaker": "時計", "text": "どこまでも回ると思った？　ぽん。鳩時計だよ。この島の夜は、まだ終わらない。"},
				],
			},
			{
				"id": "lamp",
				"label": "塩のランプ",
				"x": 86, "y": 8, "w": 12, "h": 24,
				"fx": "lamp",
				"actions": [
					{"type": "say", "speaker": "ランプ", "text": "結晶がきらきらと、金の光をこぼしている。"},
				],
			},
			{
				"id": "sink",
				"label": "流し",
				"x": 0, "y": 40, "w": 18, "h": 32,
				"fx": "sink",
				"actions": [],
			},
			{
				"id": "shelf",
				"label": "調味料棚",
				"x": 1, "y": 8, "w": 22, "h": 22,
				"fx": "shelf",
				"actions": [
					{"type": "say", "speaker": "棚", "text": "こしょうも砂糖もない。この島の味つけは、ほとんど星しおだけ。"},
				],
			},
			{
				"id": "floorCrystal",
				"label": "床の結晶",
				"x": 82, "y": 68, "w": 14, "h": 16,
				"fx": "floorCrystal",
				"actions": [
					{"type": "say", "speaker": "結晶", "text": "チリン。踏むたび、遠い星の音がする。"},
				],
			},
			{
				"id": "cookStart",
				"label": "料理をはじめる",
				"x": 36, "y": 68, "w": 22, "h": 12,
				"requireItems": ["memo", "potato", "onion", "moonMilk", "starSalt"],
				"missingText": "まだ材料が足りないみたい。メモと、星いも、月たまねぎ、月牛乳、星しおがいるよ。",
				"actions": [{"type": "go", "scene": "cooking", "speaker": "しおん", "text": "そろったね。つくってみよう。"}],
			},
		],
	},
	"starRoad": {
		"title": "星の道",
		"art": "starRoad",
		"hotspots": [
			{
				"id": "clouds",
				"label": "夜の雲",
				"x": 32, "y": 10, "w": 28, "h": 18,
				"fx": "clouds",
				"actions": [
					{"type": "say", "speaker": "雲", "text": "わた雲のなかに、塩の粒がまぶしてある。"},
				],
			},
			{
				"id": "nearStars",
				"label": "ちかい星",
				"x": 6, "y": 30, "w": 16, "h": 18,
				"fx": "nearStars",
				"actions": [
					{"type": "say", "speaker": "星", "text": "てをのばすと、つめたい。まだ遠い。"},
				],
			},
			{
				"id": "road",
				"label": "星の道",
				"x": 20, "y": 30, "w": 40, "h": 42,
				"fx": "road",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "踏むたび、靴の裏がきらきらする。ルナの足跡をたどろう。"},
				],
			},
			{
				"id": "meteor",
				"label": "ながれ星",
				"x": 4, "y": 4, "w": 28, "h": 28,
				"fx": "meteor",
				"actions": [{"type": "say", "speaker": "ながれ星", "text": "きゅいん。願いごとは塩味だと叶いやすい、らしい。"}],
			},
			{
				"id": "footprints",
				"label": "ルナの足跡",
				"x": 28, "y": 52, "w": 28, "h": 28,
				"fx": "footprints",
				"actions": [{"type": "say", "speaker": "足跡", "text": "うさぎの足跡が、月のうら側へ続いている。"}],
			},
			{
				"id": "toField",
				"label": "月のうら側へ",
				"x": 62, "y": 8, "w": 28, "h": 48,
				"actions": [{"type": "go", "scene": "moonField", "speaker": "しおん", "text": "空気が、塩っぽくなった。"}],
			},
			{
				"id": "backKitchen",
				"label": "キッチンへ戻る",
				"x": 4, "y": 78, "w": 22, "h": 14,
				"actions": [{"type": "go", "scene": "kitchen"}],
			},
		],
	},
	"moonField": {
		"title": "月のうら側の畑",
		"art": "moonField",
		"hotspots": [
			{
				"id": "furrows",
				"label": "星いもの畑",
				"x": 2, "y": 38, "w": 34, "h": 28,
				"fx": "furrows",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "畝のあいだに、星くずがまいてある。いもは左、たまねぎは手前だよ。"},
				],
			},
			{
				"id": "hills",
				"label": "遠い丘",
				"x": 18, "y": 22, "w": 36, "h": 16,
				"fx": "hills",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "丘の向こうは、もっと塩っぽい風。"},
				],
			},
			{
				"id": "rocks",
				"label": "月の石",
				"x": 56, "y": 58, "w": 22, "h": 18,
				"fx": "rocks",
				"actions": [
					{"type": "say", "speaker": "石", "text": "軽い。持ち帰ることもできるけど、今夜はいらないかな。"},
				],
			},
			{
				"id": "littleCrater",
				"label": "ちいさな穴",
				"x": 26, "y": 64, "w": 12, "h": 12,
				"fx": "littleCrater",
				"actions": [
					{"type": "say", "speaker": "穴", "text": "うさぎが掘ったあと、かも。"},
				],
			},
			{
				"id": "potato",
				"label": "星いも",
				"x": 10, "y": 42, "w": 16, "h": 22,
				"hideWhenItem": ["potato"],
				"actions": [
					{"type": "give", "item": "potato", "speaker": "星いも", "text": "土のなかで光っていたいも。ほくほくの星のかたち。"},
				],
			},
			{
				"id": "onion",
				"label": "月たまねぎ",
				"x": 32, "y": 40, "w": 14, "h": 20,
				"hideWhenItem": ["onion"],
				"actions": [
					{"type": "give", "item": "onion", "speaker": "月たまねぎ", "text": "層が三日月みたいに重なっている。切ると、塩の涙が出るらしい。"},
				],
			},
			{
				"id": "earth",
				"label": "遠くの青い星",
				"x": 80, "y": 4, "w": 12, "h": 14,
				"fx": "earth",
				"actions": [{"type": "say", "speaker": "しおん", "text": "あれが地球。ここでは豆つぶみたい。"}],
			},
			{
				"id": "crater",
				"label": "クレーター",
				"x": 42, "y": 52, "w": 22, "h": 24,
				"fx": "crater",
				"actions": [{"type": "say", "speaker": "クレーター", "text": "なかはからっぽ。牛乳はもっと奥の洞窟だよ。"}],
			},
			{
				"id": "toCave",
				"label": "月の洞窟へ",
				"x": 80, "y": 26, "w": 18, "h": 26,
				"actions": [{"type": "go", "scene": "moonCave"}],
			},
			{
				"id": "backRoad",
				"label": "星の道へ戻る",
				"x": 4, "y": 78, "w": 22, "h": 14,
				"actions": [{"type": "go", "scene": "starRoad"}],
			},
		],
	},
	"moonCave": {
		"title": "月の洞窟",
		"art": "moonCave",
		"hotspots": [
			{
				"id": "well",
				"label": "月の井戸",
				"x": 36, "y": 46, "w": 26, "h": 32,
				"hideWhenItem": ["moonMilk"],
				"actions": [
					{"type": "give", "item": "moonMilk", "speaker": "月の井戸", "text": "静かな白い液体。飲むと、夢のなかで潮の音がする。"},
				],
			},
			{
				"id": "leaveAfterMilk",
				"label": "畑へもどる",
				"x": 16, "y": 28, "w": 68, "h": 52,
				"showWhenItem": ["moonMilk"],
				"actions": [
					{"type": "go", "scene": "moonField", "speaker": "しおん", "text": "月牛乳はカバンへ。星しおはキッチンの壺だよ。もどってそろえよう。"},
				],
			},
			{
				"id": "stalactite",
				"label": "塩の鍾乳石",
				"x": 8, "y": 0, "w": 50, "h": 22,
				"fx": "stalactite",
				"actions": [{"type": "say", "speaker": "鍾乳石", "text": "なめると、ほんの少しだけしょっぱい。"}],
			},
			{
				"id": "echo",
				"label": "こだま",
				"x": 78, "y": 18, "w": 18, "h": 24,
				"fx": "echo",
				"actions": [{"type": "say", "speaker": "こだま", "text": "……しお。……しお。"}],
			},
			{
				"id": "backField",
				"label": "畑へ戻る",
				"x": 4, "y": 78, "w": 22, "h": 14,
				"actions": [{"type": "go", "scene": "moonField"}],
			},
			{
				"id": "caveClock",
				"label": "星座時計",
				"x": 18, "y": 6, "w": 16, "h": 22,
				"fx": "caveClock",
				"actions": [
					{"type": "say", "speaker": "時計", "text": "針は、井戸の水面と同じ速さで止まっている。"},
				],
			},
			{
				"id": "caveShelf",
				"label": "調味料棚",
				"x": 1, "y": 8, "w": 22, "h": 22,
				"fx": "caveShelf",
				"actions": [
					{"type": "say", "speaker": "棚", "text": "ここにある壺は飾り。星しおはキッチンだよ。"},
				],
			},
			{
				"id": "caveSink",
				"label": "流し",
				"x": 0, "y": 40, "w": 18, "h": 32,
				"fx": "caveSink",
				"actions": [
					{"type": "say", "speaker": "流し", "text": "星くずの水。飲むのは、井戸の月牛乳のほうがいいかな。"},
				],
			},
			{
				"id": "cavePot",
				"label": "お鍋",
				"x": 18, "y": 32, "w": 16, "h": 28,
				"fx": "cavePot",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "ここでは煮ないよ。材料をそろえて、キッチンに帰ろう。"},
				],
			},
			{
				"id": "caveWindow",
				"label": "丸い窓",
				"x": 52, "y": 4, "w": 28, "h": 22,
				"fx": "caveWindow",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "月が、井戸の縁に落ちているみたい。"},
				],
			},
			{
				"id": "caveLamp",
				"label": "塩のランプ",
				"x": 86, "y": 8, "w": 12, "h": 24,
				"fx": "caveLamp",
				"actions": [
					{"type": "say", "speaker": "ランプ", "text": "結晶が、井戸の蒸気で少しにじんでいる。"},
				],
			},
			{
				"id": "caveJar",
				"label": "まぼろしの壺",
				"x": 80, "y": 32, "w": 12, "h": 20,
				"fx": "caveJar",
				"actions": [
					{"type": "say", "speaker": "しおん", "text": "星しおは、こっちの壺じゃなくてキッチンだよ。"},
				],
			},
			{
				"id": "caveCrystals",
				"label": "床の結晶",
				"x": 4, "y": 68, "w": 18, "h": 16,
				"fx": "caveCrystals",
				"actions": [
					{"type": "say", "speaker": "結晶", "text": "チリン。月の井戸が、遠くで答える。"},
				],
			},
		],
	},
}


static func visible(scene_id: String) -> Array:
	if scene_id not in SCENES:
		return []
	var spots: Array = SCENES[scene_id]["hotspots"]
	var out: Array = []
	for spot in spots:
		var ok := true
		if spot.has("showWhen"):
			for f in spot["showWhen"]:
				if not GameState.has_flag(str(f)):
					ok = false
		if spot.has("hideWhen"):
			for f in spot["hideWhen"]:
				if GameState.has_flag(str(f)):
					ok = false
		if spot.has("showWhenItem"):
			for id in spot["showWhenItem"]:
				if not GameState.has_item(str(id)):
					ok = false
		if spot.has("hideWhenItem"):
			for id in spot["hideWhenItem"]:
				if GameState.has_item(str(id)):
					ok = false
		if ok and _give_already_taken(spot):
			ok = false
		if ok:
			out.append(spot)
	return out


static func _give_already_taken(spot: Dictionary) -> bool:
	var actions: Array = spot.get("actions", [])
	if actions.is_empty():
		return false
	var any_give := false
	for a in actions:
		var t := str(a.get("type", ""))
		if t == "go" or t == "say":
			return false
		if t == "give":
			any_give = true
			if not GameState.has_item(str(a.get("item", ""))):
				return false
		if t == "flag":
			if not GameState.has_flag(str(a.get("flag", ""))):
				return false
	return any_give

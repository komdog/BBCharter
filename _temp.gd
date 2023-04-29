extends Control

var players = [
	{"name": "Kom", "hp": 50},
	{"name": "Leks", "hp": 31},
	{"name": "Blue", "hp": 82},
	{"name": "Kawy", "hp": 64}
]

func _ready():
	players.sort_custom(func(a,b): return a['hp'] < b['hp'])
	print(players)


	

class_name Serializer
extends Resource

var player_resource: PlayerResource

func save_game():
	var saved_game: SavedGame = SavedGame.new()
	ResourceSaver.save(saved_game, Global.SAVE_FILE)

func load_game():
	var saved_game: SavedGame = load(Global.SAVE_FILE)

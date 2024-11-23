extends Control

@onready var reading = $MarginContainer/GridContainer/PanelContainer/VBoxContainer/Reading
@onready var phonemic_awareness = $MarginContainer/GridContainer/PanelContainer/VBoxContainer/PhonemicAwareness
@onready var reading_comprehension = $MarginContainer/GridContainer/PanelContainer/VBoxContainer/ReadingComprehension

@onready var PauseMusic = $PauseMusic

@onready var skipped_words_container = $MarginContainer/GridContainer/GridContainer/PanelContainer/VBoxContainer/ScrollContainer/SkippedWordsContainer

@onready var recently_read_word = $MarginContainer/GridContainer/GridContainer/VBoxContainer/PanelContainer/HBoxContainer/RecentlyReadWord
@onready var recently_learned_word = $MarginContainer/GridContainer/GridContainer/VBoxContainer/PanelContainer2/HBoxContainer/RecentlyLearnedWord

var skill_check_stats = []
var saved_data
const NO_DATA = "NO DATA"

# Called when the node enters the scene tree for the first time.
func _ready():
	PauseMusic.stream = load("res://assets/sounds/music/pause_music.mp3")
	PauseMusic.play()
	if FileAccess.file_exists(Global.SAVE_FILE):
		saved_data = load(Global.SAVE_FILE) as SavedGame
	show_stats()

func load_stats():
	if saved_data:
		skill_check_stats = saved_data.skill_check_stats
		group_data()
		get_passed_words()
		get_skipped_words()

func show_stats():
	load_stats()
	print("Passed Words: " + str(passed_words))
	print("Skipped Words: " + str(skipped_words))
	if !skill_check_stats.is_empty():
		reading.text = "%s%%" % calculate_reading()
		phonemic_awareness.text = "%s%%" % calculate_phonemic_awareness()
		if !reading_comprehension_data.is_empty():
			reading_comprehension.text = "%s%%" % calculate_reading_comprehension()
		else:
			reading_comprehension.text = NO_DATA
		show_skipped_words()
		show_recently_read_word()
		show_recently_learned_word()
	else:
		reading.text = NO_DATA
		phonemic_awareness.text = NO_DATA
		reading_comprehension.text = NO_DATA
		recently_learned_word.text = NO_DATA
		recently_read_word.text = NO_DATA
		var label = Label.new()
		skipped_words_container.add_child(label)
		label.text = NO_DATA

"""
word_state[0] = word
word_state[1] = skill
word_state[2] = passed
"""

var phonemic_awareness_data = []
var reading_comprehension_data = []
var passed_words = []
var skipped_words = []

func group_data():
	if !skill_check_stats.is_empty():
		for word_state in skill_check_stats:
			if word_state[1] == "Flash Cards" or word_state[1] == "Identify":
				phonemic_awareness_data.append(word_state)
			elif word_state[1] == "Story Time":
				reading_comprehension.append(word_state)
			else:
				print(word_state[1])

func calculate_reading():
	var passed_word_count: float = 0
	var skipped_word_count: float = 0
	var total_words: float
	for word_state in skill_check_stats:
		if word_state[2]:
			passed_word_count += 1
		else:
			skipped_word_count += 1
	total_words = passed_word_count + skipped_word_count
	
	var reading_percentage: float
	reading_percentage = passed_word_count / total_words * 100
	return reading_percentage

func calculate_phonemic_awareness():
	var passed_word_count: float = 0
	var skipped_word_count: float = 0
	var total_words: float
	for word_state in phonemic_awareness_data:
		if word_state[2]:
			passed_word_count += 1
		else:
			skipped_word_count += 1
	total_words = passed_word_count + skipped_word_count
	var phonemic_awareness_percentage: float
	phonemic_awareness_percentage = passed_word_count / total_words * 100
	return phonemic_awareness_percentage

func calculate_reading_comprehension():
	var passed_word_count: float = 0
	var skipped_word_count: float = 0
	var total_words: float
	for word_state in reading_comprehension_data:
		if word_state[2]:
			passed_word_count += 1
		else:
			skipped_word_count += 1
	total_words = passed_word_count + skipped_word_count
	var reading_comprehension_percentage: float
	reading_comprehension_percentage = passed_word_count / total_words * 100
	return reading_comprehension_percentage


func get_passed_words():
	for word_state in skill_check_stats:
		if word_state[2] == true:
			passed_words.append(word_state[0])

func get_skipped_words():
	for word_state in skill_check_stats:
		if word_state[2] == false:
			skipped_words.append(word_state[0])

func show_skipped_words():
	if skipped_words_container.get_child_count() > 0:
		for i in skipped_words_container.get_child_count():
			skipped_words_container.remove_child(skipped_words_container.get_child(0))
	var filtered_skipped_words = []
	for word in skipped_words:
		if filtered_skipped_words.size() == 0:
			filtered_skipped_words.append(word)
		for i in filtered_skipped_words.size():
			if word != filtered_skipped_words[i]:
				filtered_skipped_words.append(word)
			else:
				continue
	for word in filtered_skipped_words:
		var label = Label.new()
		skipped_words_container.add_child(label)
		label.text = word

func is_word_in_skipped_words(_word: String):
	for word in skipped_words:
		if _word == word:
			return true
		else:
			return false

func is_word_in_passed_words(_word: String):
	for word in passed_words:
		if _word == word:
			return true
		else:
			return false

func show_recently_read_word():
	recently_read_word.text = skill_check_stats[-1][0]

func show_recently_learned_word():
	for index in skipped_words.size():
		if is_word_in_passed_words(skipped_words[index]):
			recently_learned_word.text = skipped_words[index]
			skipped_words.remove_at(index)

var main_menu_scene = load("res://scenes/main_menu.tscn")
func _on_back_button_pressed():
	get_tree().change_scene_to_packed(main_menu_scene)

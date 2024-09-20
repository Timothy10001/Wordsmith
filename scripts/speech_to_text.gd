extends Node
class_name SpeechToText


# Signal used to alert speech recording started
signal STT_speech_recording

# Signal used to alert speech has been recorded
signal STT_speech_recorded(recording_path, recording_name)

# Signal used to alert that Speech to Text (STT) has been requested
signal STT_requested(recording_path, recording_name)

# Signal used to alert of STT response
signal STT_response_generated(response)


#Global Openai variables
@export var api_key: String = "sk-LZP820ldszOEpCc_5hPkzOfojI5KDHRhORbuqVvd10T3BlbkFJM0ljP7yWrfm4ZUtnINfe8JgEN1Gb3vh8NRFCRQOzkA": set = set_api_key
@export var base_openai_url: String = "https://api.openai.com/v1": set = set_base_openai_url

#STT variables
# See https://platform.openai.com/docs/guides/speech-to-text
@export var STT_model: String = "whisper-1":set = set_STT_model
@export var STT_language: String = "en":set = set_STT_language
@export var STT_temperature: float = 0.0:set = set_STT_temperature
var STT_url: String = "/audio/transcriptions"
var STT_headers: Array
var STT_boundary = "boundary"
var STT_audio_file
var STT_http_request
var STT_response_format = "text"
var interface_enabled : bool = false
var save_path : String
var record_effect = null
var micrecordplayer





func _ready():
	# Set all headers for http requests
	# STT header
	STT_headers = ["Content-Type: multipart/form-data; boundary=" + STT_boundary, "Authorization: Bearer " + api_key]
	# set up http request for STT
	STT_http_request = HTTPRequest.new()
	add_child(STT_http_request)
	STT_http_request.timeout = 10.0
	STT_http_request.use_threads = true
	STT_http_request.connect("request_completed", Callable(self, "_on_STT_request_completed"))


	# set up audio nodes for speech recording for STT

	# Make sure audio input is enabled even if program is not set to otherwise to prevent inadvertent errors in use
	ProjectSettings.set_setting("audio/driver/enable_input", true)

	var current_number = 0
	while AudioServer.get_bus_index("STTMicRecorder" + str(current_number)) != -1:
		current_number += 1

	var bus_name = "STTMicRecorder" + str(current_number)
	var record_bus_idx = AudioServer.bus_count

	AudioServer.add_bus(record_bus_idx)
	AudioServer.set_bus_name(record_bus_idx, bus_name)

	record_effect = AudioEffectRecord.new()
	AudioServer.add_bus_effect(record_bus_idx, record_effect)

	AudioServer.set_bus_mute(record_bus_idx, true)

	micrecordplayer = AudioStreamPlayer.new()
	add_child(micrecordplayer)
	micrecordplayer.bus = bus_name

	# Activate voice commands; this could be commented out for better control from another script
	activate_voice_commands(true)


# This is needed to activate the voice commands in the node for STT.
# Sample usage in another script: godot-openai-simple.activate_voice_commands(true)
func activate_voice_commands(value:bool):
	print("WhisperAPI voice commands activated")

	interface_enabled = value
	if value:
		if micrecordplayer.stream == null:
			micrecordplayer.stream = AudioStreamMicrophone.new()
		if !micrecordplayer.playing:
			micrecordplayer.play()
	else:	
		if micrecordplayer.playing:
			micrecordplayer.stop()

		micrecordplayer.stream = null

# Start voice capture for STT, e.g., on a button press or other event
# Sample usage from another script: godot-openai-simple.start_voice_command()		
func start_recording():
	print("Reading sound")
	if !micrecordplayer.playing:
		micrecordplayer.play()
	record_effect.set_recording_active(true)	
	emit_signal("STT_speech_recording")
	#If you wanted to automatically stop after a certain time after starting, the following would work
	#await get_tree().create_timer(20.0).timeout	
	#end_voice_command()

# End voice capture for STT, e.g., on a button press or other event
# Sample usage from another script: godot-openai-simple.end_voice_command()		
func stop_recording():
	print("stop reading sound")
	var recording = record_effect.get_recording()
	await get_tree().create_timer(1.0).timeout
	record_effect.set_recording_active(false)
	micrecordplayer.stop()

	if OS.has_feature("editor"):
		save_path = OS.get_user_data_dir().path_join("whisper_audio.wav")
	elif OS.has_feature("android"):
		save_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS, false).path_join("whisper_audio.wav")
	else:
		save_path = OS.get_executable_path().get_base_dir().path_join("whisper_audio.wav")
	var _check_ok = recording.save_to_wav(save_path)
	#print(check_ok)		
	emit_signal("STT_speech_recorded", save_path, "whisper_audio.wav")
	# This script currently assumes you automatically want to go from recording to transcribing, if you do not want that and want control over the call, comment out the next line
	call_STT_url(save_path, "whisper_audio.wav")

# Call Openai STT (Whisper) API with recorded audio
# Sample usage from another script: godot-openai-simple.call_STT_url(OS.get_user_data_dir().path_join("my_recorded_audio_file.wav"), "my_recorded_audio_file.wav")
func call_STT_url(file_path:String, file_name:String): 
	# Godot doesn't come with built-in multi-part form data support so need to do special work here

	# open file that has recorded speech and get its binary content to use in the request
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_buffer(file.get_length())
	file.close()

	var post_fields = {
		"model": STT_model,
		"language": STT_language,
		"response_format": STT_response_format
	}
	var body1 = "\r\n\r\n"
	for key in post_fields:
		print("key found:" + str(key))
		body1 += "--" + STT_boundary + "\r\n"
		body1 += "Content-Disposition: form-data; name=\"" + key + "\"\r\n\r\n" + post_fields[key] + "\r\n"
	body1 += "--" + STT_boundary + "\r\n"
	body1 += "Content-Disposition: form-data; name=\"" + "file" + "\"; filename=\"" + file_name + "\"\r\nContent-Type: "
	body1 += "audio/wav"
	body1 += "\r\n\r\n"
	var body2 = "\r\n" + "--" + STT_boundary + "--"
	var post_content = body1.to_utf8_buffer() + content + body2.to_utf8_buffer()
	print("making file http request")
	emit_signal("STT_requested", file_path, file_name)
	var err = STT_http_request.request_raw(base_openai_url+STT_url, STT_headers, HTTPClient.METHOD_POST, post_content)
	print("err from request raw from STT http file post request is: " + str(err))

# Function to receive response to STT API call with audio file prompt
func _on_STT_request_completed(result, responseCode, headers, body):
	# Should receive 200 if all is fine; if not print code
	if responseCode != 200:
		print("There was an error with Whisper API's response, response code:" + str(responseCode))
		print(result)
		print(headers)
		print(body.get_string_from_utf8())
		return

	var STT_text_response = body.get_string_from_utf8()
	print("STT text generated: " + STT_text_response)

	emit_signal("STT_response_generated", STT_text_response)

# All setter functions for godot-openai-simple
#Global Openai variables
func set_api_key(new_api_key : String):
	api_key = new_api_key

func set_base_openai_url(new_base_url: String):
	base_openai_url = new_base_url

#STT variables
func set_STT_model(new_STT_model: String):
	STT_model = new_STT_model

func set_STT_language(new_STT_language: String):
	STT_language = new_STT_language

func set_STT_temperature(new_STT_temperature: float):
	STT_temperature = new_STT_temperature

extends Node

const CONFIG_FILE_PATH = "user://settings.cfg"
const SPELL_FILES = {
	"BRD": "res://BRD_spells.json",
	"BER": "res://BER_spells.json",
	"BST": "res://BST_spells.json",
	"CLR": "res://CLR_spells.json",
	"ENC": "res://ENC_spells.json",
	"NEC": "res://NEC_spells.json",
	"MAG": "res://MAG_spells.json",
	"MNK": "res://MNK_spells.json",
	"PAL": "res://PAL_spells.json",
	"RNG": "res://RNG_spells.json",
	"ROG": "res://ROG_spells.json",
	"SHD": "res://SHD_spells.json",
	"SHM": "res://SHM_spells.json",
	"WAR": "res://WAR_spells.json",
	"WIZ": "res://WIZ_spells.json",
	"DRU": "res://DRU_spells.json",
	"EXP": "res://EXP_list.txt"
}

# Expansion order for filtering (index-based comparison)
const EXPANSION_ORDER = [
	"EQ", "KUNARK", "VELIOUS", "LUCLIN", "POP", "LOY", "LDON",
	"GATES", "OMENS", "DON", "DOD", "POR", "TSS", "TBS", "SOF",
	"SOD", "UF", "HOT", "VOA", "ROF", "COTF", "TDS", "TBM",
	"EOK", "ROS", "TBL", "TOV", "COV", "TOL", "NOS", "LS"
]

# Map display names to expansion codes
const EXPANSION_NAMES = {
	"EverQuest": "EQ",
	"The Ruins of Kunark": "KUNARK",
	"The Scars of Velious": "VELIOUS",
	"The Shadows of Luclin": "LUCLIN",
	"The Planes of Power": "POP",
	"The Legacy of Ykesha": "LOY",
	"Lost Dungeons of Norrath": "LDON",
	"Gates of Discord": "GATES",
	"Omens of War": "OMENS",
	"Dragons of Norrath": "DON",
	"Depths of Darkhollow": "DOD",
	"Prophecy of Ro": "POR",
	"The Serpents Spine": "TSS",
	"The Buried Sea": "TBS",
	"Secrets of Faydwer": "SOF",
	"Seeds of Destruction": "SOD",
	"Underfoot": "UF",
	"House of Thule": "HOT",
	"Veil of Alaris": "VOA",
	"Rain of Fear": "ROF",
	"Call of the Forsaken": "COTF",
	"The Darkened Sea": "TDS",
	"The Broken Mirror": "TBM",
	"Empires of Kunark": "EOK",
	"Ring of Scale": "ROS",
	"The Burning Lands": "TBL",
	"Torment of Velious": "TOV",
	"Claws of Veeshan": "COV",
	"Terror of Luclin": "TOL",
	"Night of Shadows": "NOS",
	"Laurions Song": "LS"
}

# Map zone names to the expansion they were introduced in
const ZONE_EXPANSIONS = {
	# Original EQ zones
	"Ak'Anon": "EQ",
	"Butcherblock Mountains": "EQ",
	"Commonlands": "EQ",
	"East Freeport": "EQ",
	"Erudin": "EQ",
	"Erudin Palace": "EQ",
	"Everfrost Peaks": "EQ",
	"Greater Faydark": "EQ",
	"Grobb": "EQ",
	"Halas": "EQ",
	"Innothule Swamp": "EQ",
	"Lavastorm Mountains": "EQ",
	"Lesser Faydark": "EQ",
	"Neriak Commons": "EQ",
	"Neriak Third Gate": "EQ",
	"North Kaladim": "EQ",
	"North Karana": "EQ",
	"North Qeynos": "EQ",
	"North Ro": "EQ",
	"Northern Felwithe": "EQ",
	"Ocean of Tears": "EQ",
	"Oggok": "EQ",
	"Paineel": "EQ",
	"Qeynos Catacombs": "EQ",
	"Rivervale": "EQ",
	"South Qeynos": "EQ",
	"South Ro": "EQ",
	"Southern Felwithe": "EQ",
	"Steamfont Mountains": "EQ",
	"Surefall Glade": "EQ",
	"The Rathe Mountains": "EQ",
	"West Freeport": "EQ",
	# Kunark zones
	"Cabilis East": "KUNARK",
	"West Cabilis": "KUNARK",
	"Firiona Vie": "KUNARK",
	"The Overthere": "KUNARK",
	# Velious zones
	"Iceclad Ocean": "VELIOUS",
	"Skyshrine": "VELIOUS",
	"Thurgadin": "VELIOUS",
	"Wakening Land": "VELIOUS",
	# Luclin zones
	"Katta Castellum": "LUCLIN",
	"Sanctus Seru": "LUCLIN",
	"Shadow Haven": "LUCLIN",
	"Shar Vahl": "LUCLIN",
	"The Bazaar": "LUCLIN",
	# PoP zones
	"The Plane of Knowledge": "POP",
	# Gates of Discord zones
	"Abysmal Sea": "GATES",
	# TSS zones
	"Crescent Reach": "TSS",
	"The Mines of Gloomingdeep": "TSS",
	# Ring of Scale zones
	"The Overthere [RoS]": "ROS",
	# Night of Shadows zones
	"Shar Vahl, Divided (NoS)": "NOS"
}

var game_dir: String = ""
var character: String
var character_inventory: String
var current_spell_class: String
var expansion_set: String = ""
var expansion_save: bool = false
var current_file_name = ""
var http_request: HTTPRequest
const MAX_RETRIES = 3
const RETRY_DELAY = 5.0
const REQUEST_DELAY = 1.5
var current_file_key : String = ""
var tween: Tween

# Spell data storage for JSON
var spell_data: Array = []

var color_column1 = Color("#d79921")
var color_column2 = Color("#ebdbb2")
var color_column3 = Color("#928374")

@onready var label_game_dir: Label = %LabelGameDir
@onready var file_dialog_game_dir: FileDialog = %FileDialogGameDir
@onready var file_list: ItemList = %ItemListFiles
@onready var item_list_spells: ItemList = %ItemListSpells
@onready var label_spells: Label = %LabelSpells
@onready var item_list: ItemList = %ItemList
@onready var button_bard: Button = %ButtonBard
@onready var button_necromancer: Button = %ButtonNecromancer
@onready var button_druid: Button = %ButtonDruid
@onready var panel: Panel = %Panel
@onready var label_missing: Label = %LabelMissing
@onready var label_exp: Label = %LabelExp
@onready var menu_button_exp: MenuButton = %MenuButtonExp
@onready var label_class: Label = %LabelClass
@onready var label: Label = %Label
@onready var label_2: Label = %Label2
@onready var check_button_exp: CheckButton = %CheckButtonExp
@onready var popup_panel: PopupPanel = %PopupPanel
@onready var label_cloud: Label = %LabelCloud
@onready var label_v: Label = %LabelV
@onready var label_pop: Label = %LabelPop

@onready var bard: AnimatedSprite2D = %Bard
@onready var beastlord: AnimatedSprite2D = %Beastlord
@onready var berserker: AnimatedSprite2D = %Berserker
@onready var cleric: AnimatedSprite2D = %Cleric
@onready var druid: AnimatedSprite2D = %Druid
@onready var enchanter: AnimatedSprite2D = %Enchanter
@onready var magician: AnimatedSprite2D = %Magician
@onready var monk: AnimatedSprite2D = %Monk
@onready var necromancer: AnimatedSprite2D = %Necromancer
@onready var paladin: AnimatedSprite2D = %Paladin
@onready var ranger: AnimatedSprite2D = %Ranger
@onready var rogue: AnimatedSprite2D = %Rogue
@onready var shadowknight: AnimatedSprite2D = %Shadowknight
@onready var shaman: AnimatedSprite2D = %Shaman
@onready var warrior: AnimatedSprite2D = %Warrior
@onready var wizard: AnimatedSprite2D = %Wizard

func _ready() -> void:
	# Set solid tooltip background globally
	var tooltip_panel_style = StyleBoxFlat.new()
	tooltip_panel_style.bg_color = Color(0.12, 0.12, 0.12, 1.0)  # Dark gray, fully opaque
	tooltip_panel_style.set_corner_radius_all(4)
	tooltip_panel_style.set_content_margin_all(8)
	tooltip_panel_style.border_color = Color(0.3, 0.3, 0.3, 1.0)
	tooltip_panel_style.set_border_width_all(1)

	# Apply to the theme used by item_list
	var theme = item_list.theme
	if theme:
		theme.set_stylebox("panel", "TooltipPanel", tooltip_panel_style)
		# Also set tooltip label color
		theme.set_color("font_color", "TooltipLabel", Color(0.92, 0.86, 0.70, 1.0))

	load_game_dir()
	if game_dir:
		update_file_list()
	var file = FileAccess.open("res://EXP_list.txt", FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if not line.is_empty():
				menu_button_exp.get_popup().add_item(line)
		file.close()
	button_bard.connect("pressed", Callable(self, "_on_button_bard_pressed"))
	button_necromancer.connect("pressed", Callable(self, "_on_button_necromancer_pressed"))
	button_druid.connect("pressed", Callable(self, "_on_button_druid_pressed"))
	menu_button_exp.get_popup().id_pressed.connect(_on_item_selected)
	check_button_exp.button_pressed = expansion_save
	set_column_colors()
	set_column_colors_spells()
	check_settings_file()
	var version = ProjectSettings.get_setting("application/config/version")
	label_v.text = "v " + str(version) + " "
	label_pop.visible = false
	label_pop.modulate.a = 1.0
	label_pop.mouse_filter = Control.MOUSE_FILTER_IGNORE

func get_expansion_index(exp_code: String) -> int:
	return EXPANSION_ORDER.find(exp_code.to_upper())

func get_expansion_code(display_name: String) -> String:
	if EXPANSION_NAMES.has(display_name):
		return EXPANSION_NAMES[display_name]
	return "LS"  # Default to latest expansion

func load_spells_from_json(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("Failed to open ", file_path)
		spell_data = []
		return
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	if error != OK:
		printerr("JSON parse error: ", json.get_error_message())
		spell_data = []
		return
	spell_data = json.data

func display_spells_for_expansion(max_expansion: String) -> void:
	var max_index = get_expansion_index(max_expansion)
	if max_index == -1:
		max_index = EXPANSION_ORDER.size() - 1  # Show all if unknown

	item_list.clear()
	item_list.max_columns = 3
	label_2.show()
	menu_button_exp.show()

	for i in range(spell_data.size()):
		var spell = spell_data[i]
		var spell_exp_index = get_expansion_index(spell.expansion)
		if spell_exp_index <= max_index:
			var level_str = str(spell.level)
			if level_str.length() == 1:
				level_str = "  " + level_str
			elif level_str.length() == 2:
				level_str = " " + level_str
			item_list.add_item(level_str.rpad(3))
			item_list.add_item(spell.name)
			item_list.add_item(spell.expansion)
			# Store spell index in metadata for the spell name column
			item_list.set_item_metadata(item_list.get_item_count() - 2, i)

	remove_matching_spells()
	set_column_colors()
	update_missing_count()

func display_all_spells() -> void:
	display_spells_for_expansion("LS")

func build_spell_tooltip(spell: Dictionary) -> String:
	var tooltip = "%s (Level %s)\n%s" % [spell.name, str(spell.level), spell.url]

	if spell.has("merchants") and spell.merchants.size() > 0:
		# Get current expansion index for filtering
		var current_exp_code = get_expansion_code(expansion_set) if expansion_set != "" else "LS"
		var max_exp_index = get_expansion_index(current_exp_code)

		# Filter merchants by their expansion field
		var available_merchants = []
		for m in spell.merchants:
			var merchant_exp = m.e.to_upper() if m.has("e") else "EQ"
			var merchant_exp_index = get_expansion_index(merchant_exp)
			if merchant_exp_index <= max_exp_index:
				available_merchants.append(m)

		if available_merchants.size() > 0:
			tooltip += "\n\nSold by:"
			for m in available_merchants:
				var loc = str(m.l) if m.l != null else "unknown"
				var price = m.p if m.p != "" else "?"
				tooltip += "\n  %s - %s (%s) @ %s" % [m.m, m.z, price, loc]

	return tooltip

func _on_item_selected(id: int):
	var item_text = menu_button_exp.get_popup().get_item_text(id)
	var display_text = item_text.split("(")[0].strip_edges()
	label_exp.text = display_text
	expansion_set = display_text

	var exp_code = get_expansion_code(display_text)
	load_spells_from_json(SPELL_FILES[current_spell_class])
	display_spells_for_expansion(exp_code)
	save_game_dir()

func check_settings_file():
	var file = game_dir

	if file == "":
		print("Settings file not found or inaccessible.")
		var timer = Timer.new()
		timer.connect("timeout", show_popup)
		timer.set_wait_time(0.1)
		timer.set_one_shot(true)
		add_child(timer)
		timer.start()
	else:
		popup_panel.hide()

func show_popup():
	if not popup_panel.visible:
		popup_panel.show()
		popup_panel.popup_centered()

func update_file_list() -> void:
	file_list.clear()
	var dir = DirAccess.open(game_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with("-Spellbook.txt"):
				var name_server = file_name.get_slice("-Spellbook.txt", 0)
				var parts = name_server.split("_", false, 1)
				if parts.size() == 2:
					var display_name = "%s - %s" % [parts[1].capitalize(), parts[0].capitalize()]
					file_list.add_item(display_name)
					file_list.set_item_tooltip_enabled(file_list.get_item_count() - 1, false)
					file_list.set_item_metadata(file_list.get_item_count() - 1, file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		label_game_dir.text = game_dir
	else:
		label_game_dir.text = "<-- Please select a game directory!"

func update_character_inventory(file_name: String) -> void:
	var updated_name = file_name.replace("Spellbook", "Inventory")
	character_inventory = updated_name

func populate_spell_list(file_content: String) -> void:
	item_list_spells.clear()
	item_list_spells.max_columns = 2
	label.show()
	for line in file_content.split("\n"):
		if line.strip_edges().is_empty():
			continue
		var parts = line.split("\t", false, 1)
		if parts.size() >= 2:
			var number = parts[0].strip_edges()
			if number.length() == 1:
				number = "  " + number
			elif number.length() == 2:
				number = " " + number
			number = number.rpad(3)

			var spell_name = parts[1].strip_edges()
			item_list_spells.add_item(number)
			item_list_spells.add_item(spell_name)
		else:
			item_list_spells.add_item(line.strip_edges())
			item_list_spells.add_item("")
	set_column_colors_spells()

func remove_matching_spells() -> void:
	var spells_to_remove = []
	var character_spells = {}
	for i in range(0, item_list_spells.get_item_count(), 2):
		var spell_number = item_list_spells.get_item_text(i).strip_edges()
		var spell_name = item_list_spells.get_item_text(i + 1).strip_edges()
		character_spells[spell_name] = spell_number
	for i in range(0, item_list.get_item_count(), 3):
		var spell_number = item_list.get_item_text(i).strip_edges()
		var spell_name = item_list.get_item_text(i + 1).strip_edges()
		if spell_name in character_spells and character_spells[spell_name] == spell_number:
			spells_to_remove.append(i)
	for i in range(spells_to_remove.size() - 1, -1, -1):
		var index_to_remove = spells_to_remove[i]
		item_list.remove_item(index_to_remove + 2)
		item_list.remove_item(index_to_remove + 1)
		item_list.remove_item(index_to_remove)
	update_missing_count()

func set_column_colors():
	var colors = [color_column1, color_column2, color_column3]
	var item_count = item_list.get_item_count()
	for i in range(item_count):
		var color_index = i % 3
		item_list.set_item_custom_fg_color(i, colors[color_index])

		# Enable tooltips only for spell name column (index % 3 == 1)
		if color_index == 1:
			var spell_index = item_list.get_item_metadata(i)
			if spell_index != null and spell_index < spell_data.size():
				var tooltip = build_spell_tooltip(spell_data[spell_index])
				item_list.set_item_tooltip(i, tooltip)
				item_list.set_item_tooltip_enabled(i, true)
			else:
				item_list.set_item_tooltip_enabled(i, false)
		else:
			item_list.set_item_tooltip_enabled(i, false)

func set_column_colors_spells():
	var colors = [color_column1, color_column2, color_column3]
	var item_count = item_list_spells.get_item_count()
	for i in range(item_count):
		var color_index = i % 2
		item_list_spells.set_item_custom_fg_color(i, colors[color_index])
		item_list_spells.set_item_tooltip_enabled(i, false)

func _on_file_dialog_game_dir_dir_selected(dir: String) -> void:
	game_dir = dir
	save_game_dir()
	update_file_list()

func _on_button_set_game_dir_pressed() -> void:
	file_dialog_game_dir.popup_centered(Vector2i(500, 400))

func _on_button_bag_pressed() -> void:
	remove_inventory_from_itemlist()

func _on_item_list_files_item_selected(index: int) -> void:
	var original_filename = file_list.get_item_metadata(index)
	var file_path = game_dir.path_join(original_filename)
	var file_content = FileAccess.get_file_as_string(file_path)
	populate_spell_list(file_content)
	update_spell_count()
	update_character_inventory(original_filename)
	print("Inventory file: " + character_inventory)
	label_exp.hide()
	item_list.hide()
	bard.hide()
	berserker.hide()
	beastlord.hide()
	cleric.hide()
	druid.hide()
	enchanter.hide()
	magician.hide()
	monk.hide()
	necromancer.hide()
	paladin.hide()
	ranger.hide()
	rogue.hide()
	shadowknight.hide()
	shaman.hide()
	warrior.hide()
	wizard.hide()
	item_list_spells.show()
	panel.show()
	label_class.text = ""
	menu_button_exp.hide()
	label_missing.text = ""
	label_exp.text = ""
	label_2.hide()
	$ButtonBag.show()

func _on_check_button_exp_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		expansion_save = true
		save_game_dir()
	else:
		expansion_save = false
		save_game_dir()

func remove_inventory_from_itemlist() -> void:
	var full_file_path = game_dir.path_join(character_inventory)
	if not FileAccess.file_exists(full_file_path):
		print("Error: File not found - ", full_file_path)
		return
	var file = FileAccess.open(full_file_path, FileAccess.READ)
	if file == null:
		print("Error: Unable to open file - ", full_file_path)
		return
	var content = file.get_as_text()
	file.close()
	var lines = content.split("\n")
	var removed_count = 0
	for line in lines:
		if line.contains("Spell:"):
			var spell_start = line.find("Spell:") + 6
			var spell_end = line.find("\t", spell_start)
			var spell_name = line.substr(spell_start, spell_end - spell_start).strip_edges()
			for i in range(item_list.get_item_count() - 1, -1, -1):
				var item_text = item_list.get_item_text(i)
				if spell_name in item_text:
					item_list.remove_item(i + 2)
					item_list.remove_item(i + 1)
					item_list.remove_item(i)
					removed_count += 3
					print("Removed line: ", item_text)
					break
	update_missing_count()
	show_at_mouse("Removed " + str(removed_count/3) + " spells found")

func _on_button_close_cfg_pressed() -> void:
	save_game_dir()
	$PopupPanel.hide()

func update_spell_count() -> void:
	label_spells.text = str(item_list_spells.get_item_count() / 2) if item_list_spells.get_item_count() > 0 else ""

func save_game_dir() -> void:
	var config = ConfigFile.new()
	config.set_value("Settings", "game_dir", game_dir)
	config.set_value("Settings", "expansion_set", expansion_set)
	config.set_value("Settings", "expansion_save", expansion_save)
	var error = config.save(CONFIG_FILE_PATH)
	if error != OK:
		printerr("Failed to save config file. Error code: ", error)

func load_game_dir() -> void:
	var config = ConfigFile.new()
	if config.load(CONFIG_FILE_PATH) == OK:
		game_dir = config.get_value("Settings", "game_dir", "")
		expansion_set = config.get_value("Settings", "expansion_set", "")
		expansion_save = config.get_value("Settings", "expansion_save", false)
	else:
		game_dir = ""
		expansion_set = ""
		expansion_save = false
		popup_panel.show()

func update_missing_count():
	var line_count = item_list.get_item_count() / 3 + 1
	%LabelMissing.text = str(line_count)

func _on_button_update_pressed() -> void:
	update_file_list()

func _on_button_info_pressed() -> void:
	$PopupPanel.show()

func run_stored_selection():
	if expansion_set.is_empty():
		print("No expansion set selected")
		return
	label_exp.text = expansion_set
	var exp_code = get_expansion_code(expansion_set)
	load_spells_from_json(SPELL_FILES[current_spell_class])
	display_spells_for_expansion(exp_code)

func hide_all_class_sprites():
	bard.hide()
	beastlord.hide()
	berserker.hide()
	cleric.hide()
	druid.hide()
	enchanter.hide()
	magician.hide()
	monk.hide()
	necromancer.hide()
	paladin.hide()
	ranger.hide()
	rogue.hide()
	shadowknight.hide()
	shaman.hide()
	warrior.hide()
	wizard.hide()

func select_class(class_code: String, display_name: String, sprite: AnimatedSprite2D) -> void:
	current_spell_class = class_code
	load_spells_from_json(SPELL_FILES[class_code])
	display_all_spells()
	set_column_colors()
	label_class.text = display_name
	hide_all_class_sprites()
	sprite.show()
	item_list.show()
	label_exp.show()
	panel.hide()
	if expansion_save == true:
		run_stored_selection()

func _on_button_bard_pressed() -> void:
	select_class("BRD", "Bard", bard)

func _on_button_necromancer_pressed() -> void:
	select_class("NEC", "Necromancer", necromancer)

func _on_button_druid_pressed() -> void:
	select_class("DRU", "Druid", druid)

func _on_button_beastlord_pressed() -> void:
	select_class("BST", "Beastlord", beastlord)

func _on_button_berserker_pressed() -> void:
	select_class("BER", "Berserker", berserker)

func _on_button_cleric_pressed() -> void:
	select_class("CLR", "Cleric", cleric)

func _on_button_enchanter_pressed() -> void:
	select_class("ENC", "Enchanter", enchanter)

func _on_button_magician_pressed() -> void:
	select_class("MAG", "Magician", magician)

func _on_button_monk_pressed() -> void:
	select_class("MNK", "Monk", monk)

func _on_button_paladin_pressed() -> void:
	select_class("PAL", "Paladin", paladin)

func _on_button_ranger_pressed() -> void:
	select_class("RNG", "Ranger", ranger)

func _on_button_rogue_pressed() -> void:
	select_class("ROG", "Rogue", rogue)

func _on_button_shadowknight_pressed() -> void:
	select_class("SHD", "Shadowknight", shadowknight)

func _on_button_shaman_pressed() -> void:
	select_class("SHM", "Shaman", shaman)

func _on_button_warrior_pressed() -> void:
	select_class("WAR", "Warrior", warrior)

func _on_button_wizard_pressed() -> void:
	select_class("WIZ", "Wizard", wizard)

func update_spell_files():
	var http_request_node = HTTPRequest.new()
	add_child(http_request_node)
	http_request_node.request_completed.connect(_on_request_completed)

	for key in SPELL_FILES:
		current_file_key = key
		var local_path = SPELL_FILES[key]
		var filename = local_path.get_file()
		var url = "https://raw.githubusercontent.com/stianfan/EQSpellTool/main/" + filename

		print("Requesting: ", url)
		label_cloud.text = "Requesting: " + filename
		var error = http_request_node.request(url)
		if error != OK:
			print("An error occurred in the HTTP request for ", filename)
			label_cloud.text = "Error in HTTP request for: " + filename

		await http_request_node.request_completed

	http_request_node.queue_free()

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Error fetching file: ", result)
		return

	var remote_content = body.get_string_from_utf8()
	var local_path = SPELL_FILES[current_file_key]
	var filename = local_path.get_file()

	print("Processing: ", filename)
	label_cloud.text = "Processing: " + filename

	# Read local file content
	var local_content = ""
	if FileAccess.file_exists(local_path):
		var file = FileAccess.open(local_path, FileAccess.READ)
		local_content = file.get_as_text()
		file.close()

	# Compare and update if different
	if local_content != remote_content:
		var file = FileAccess.open(local_path, FileAccess.WRITE)
		file.store_string(remote_content)
		file.close()
		print("Updated: ", filename)
		label_cloud.text = "Updated: " + filename
	else:
		print("No update needed for: ", filename)
		label_cloud.text = "Up to date: " + filename
	label_cloud.text = "Update complete!"


func _on_button_cloud_pressed() -> void:
	update_spell_files()

func _on_item_list_item_activated(index: int) -> void:
	# Only respond to spell name column (index % 3 == 1)
	if index % 3 != 1:
		return

	# Get the spell URL from metadata
	var spell_index = item_list.get_item_metadata(index)
	if spell_index != null and spell_index < spell_data.size():
		var url = spell_data[spell_index].url
		if url and url != "":
			DisplayServer.clipboard_set(url)
			print("Copied URL to clipboard: ", url)
			show_at_mouse("URL copied!")
		else:
			show_at_mouse("No URL available")
	else:
		show_at_mouse("No URL available")

func _on_item_list_spells_item_activated(index: int) -> void:
	var text_to_copy = item_list_spells.get_item_text(index)
	DisplayServer.clipboard_set(text_to_copy)
	print("Copied to clipboard: ", text_to_copy)
	show_at_mouse("Copied to clipboard")

func show_at_mouse(text: String) -> void:
	if tween:
		tween.kill()
	label_pop.text = text
	label_pop.position = get_viewport().get_mouse_position()
	label_pop.visible = true
	label_pop.modulate.a = 1.0
	tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(label_pop, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func(): label_pop.visible = false )

extends Node
## Statistiky pro ověření hypotéz z ideového plánu:
##   H1: kolik pokusů hráč odehraje za jedno spuštění hry (cíl: v průměru aspoň 3),
##   H2: ve kterém pokusu poprvé porazí bosse prvního patra (cíl: nejpozději ve 3.).
## Souhrn se ukládá do user://stats.cfg, každý pokus jako řádek do user://pokusy.csv
## (na Windows: %APPDATA%\SCRAPBOT\). CSV jde otevřít v Excelu.

const CFG_PATH := "user://stats.cfg"
const CSV_PATH := "user://pokusy.csv"

var total_runs := 0            # všechny pokusy na tomhle počítači
var session_runs := 0          # pokusy od spuštění hry
var boss_kills := 0
var first_boss_kill_run := 0   # ve kterém pokusu padl boss poprvé (0 = zatím nikdy)

# právě probíhající pokus
var run_active := false
var run_number := 0
var run_start_ms := 0
var rooms_cleared := 0
var reached_boss := false
var items_taken: Array[String] = []


func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CFG_PATH) == OK:
		total_runs = cfg.get_value("stats", "total_runs", 0)
		boss_kills = cfg.get_value("stats", "boss_kills", 0)
		first_boss_kill_run = cfg.get_value("stats", "first_boss_kill_run", 0)


func start_run() -> void:
	total_runs += 1
	session_runs += 1
	run_number = total_runs
	run_start_ms = Time.get_ticks_msec()
	rooms_cleared = 0
	reached_boss = false
	items_taken.clear()
	run_active = true
	_save()


## result: "vyhra", "smrt" nebo "vzdal" (nový pokus / návrat do menu uprostřed hry)
func end_run(result: String) -> void:
	if not run_active:
		return
	run_active = false
	if result == "vyhra":
		boss_kills += 1
		if first_boss_kill_run == 0:
			first_boss_kill_run = run_number
	_save()
	_append_csv(result)


func run_seconds() -> float:
	return (Time.get_ticks_msec() - run_start_ms) / 1000.0


func format_time(seconds: float) -> String:
	var s := int(seconds)
	return "%d:%02d" % [s / 60, s % 60]


func open_folder() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("stats", "total_runs", total_runs)
	cfg.set_value("stats", "boss_kills", boss_kills)
	cfg.set_value("stats", "first_boss_kill_run", first_boss_kill_run)
	cfg.save(CFG_PATH)


func _append_csv(result: String) -> void:
	var is_new := not FileAccess.file_exists(CSV_PATH)
	var f := FileAccess.open(CSV_PATH, FileAccess.READ_WRITE if not is_new else FileAccess.WRITE)
	if f == null:
		return
	f.seek_end()
	if is_new:
		f.store_line("datum;pokus;pokus_od_spusteni;vysledek;vycistene_mistnosti;dosel_k_bossovi;cas_s;predmety")
	var row := [
		Time.get_datetime_string_from_system(false, true),
		str(run_number),
		str(session_runs),
		result,
		str(rooms_cleared),
		"ano" if reached_boss else "ne",
		str(int(run_seconds())),
		", ".join(items_taken),
	]
	f.store_line(";".join(row))
	f.close()

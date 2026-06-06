extends Node

const PATH:="user://if_save.json"

func save_game()->bool:
	var d={"p1_score":GameManager.player_scores[0],"p2_score":GameManager.player_scores[1],
		   "p1_lives":GameManager.player_lives[0],"p2_lives":GameManager.player_lives[1],
		   "level":GameManager.current_level,"player":GameManager.current_player,
		   "time":Time.get_datetime_string_from_system()}
	var f=FileAccess.open(PATH,FileAccess.WRITE)
	if not f: return false
	f.store_string(JSON.stringify(d,"\t")); f.close()
	print("[Save] Guardado OK"); return true

func load_game()->bool:
	if not FileAccess.file_exists(PATH):
		print("[Save] No hay archivo"); return false
	var f=FileAccess.open(PATH,FileAccess.READ)
	if not f: return false
	var j=JSON.new(); var e=j.parse(f.get_as_text()); f.close()
	if e!=OK: return false
	var d=j.get_data()
	GameManager.player_scores[0]=d.get("p1_score",0)
	GameManager.player_scores[1]=d.get("p2_score",0)
	GameManager.player_lives[0]=d.get("p1_lives",3)
	GameManager.player_lives[1]=d.get("p2_lives",3)
	GameManager.current_level=d.get("level",1)
	GameManager.current_player=d.get("player",0)
	for i in 2:
		GameManager.score_changed.emit(i,GameManager.player_scores[i])
		GameManager.lives_changed.emit(i,GameManager.player_lives[i])
	print("[Save] Cargado OK"); return true

func has_save()->bool: return FileAccess.file_exists(PATH)
func delete_save()->void:
	if has_save(): DirAccess.remove_absolute(PATH)

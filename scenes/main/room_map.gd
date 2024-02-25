extends Node2D

@onready var ExitPathNode: Node = $Route / ExitPath
@onready var BossRoomNode: Node = $Route / BossRoom
@onready var BossRoomVisitedNode: Node = $Route / BossVisited


func room_map_reset() -> void:

	for i in range(6):
		var _i: int = i + 1
		get_node("Route/Room_%02d" % _i).hide()

	BossRoomNode.hide()
	BossRoomVisitedNode.hide()


func _on_change_room(room_array: Array[int]) -> void:

	match room_array[6]:
		Game.ROOMS.NONE:
			ExitPathNode.show()
			BossRoomNode.hide()
			BossRoomVisitedNode.hide()
		Game.ROOMS.NOT_VISIT:
			ExitPathNode.hide()
			BossRoomNode.show()
		Game.ROOMS.VISITED:
			ExitPathNode.hide()
			BossRoomVisitedNode.show()

	var _iterator: int = 1

	for id in room_array:
		if _iterator == 7: return

		var _node: Node = get_node("Route/Room_%02d" % _iterator)

		if id == Game.ROOMS.VISITED:
			_node.show()
		else:
			_node.hide()

		_iterator += 1

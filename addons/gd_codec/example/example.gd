extends Node
class Item:
	var item_id_test : StringName
	var count : int
	var slot : int
	func _init(p_item_id : StringName, p_count : int, p_slot : int) -> void:
		self.item_id_test = p_item_id
		self.count = p_count
		self.slot = p_slot
	func _to_string() -> String:
		return item_id_test as String + "x" + str(count) + " at slot " + str(slot)
class Inventory:
	var items : Array[Item] = []
	func _init(p_items : Array[Item]) -> void:
		self.items = p_items
	func _to_string() -> String:
		return "Inventory with items: " + str(items)
static var item_codec : Codec = Codec.record({
		"item_id":Codec.STRING_NAME,
		"count": Codec.INT,
		"slot": Codec.INT,
		}).xmap(
				func(value:Dictionary) -> Item: return Item.new(value["item_id"], value["count"], value["slot"]),
				func(item:Item) -> Dictionary: return {"item_id": item.item_id_test, "count": item.count, "slot": item.slot}
		)
static var inventory_codec : Codec = Codec.record({
		"items": Codec.arrayof(item_codec),
		}).xmap(
			func(value:Dictionary) -> Inventory:
				var items : Array[Item] = []
				# Unfortunately, Godot will not allow casting this to Array[Item]
				# so we need to proxy it into another array. Sorry!
				items.append_array(value["items"])
				return Inventory.new(items),
			func(inventory:Inventory) -> Dictionary: return {"items": inventory.items}
		)
func _init() -> void:
	var item1 := Item.new("a very cool sword", 1, 16)
	var item2 := Item.new("a very cool shovel", 1, 14)
	var inventory : Inventory = Inventory.new([item1, item2])
	print("Item 1: " + CodecOps.JSON_OPS.encode(item_codec, item1).data_array.get_string_from_utf8())
	print("Item 2: " + CodecOps.JSON_OPS.encode(item_codec, item2).data_array.get_string_from_utf8())
	print("Inventory: " + CodecOps.JSON_OPS.encode(inventory_codec, inventory).data_array.get_string_from_utf8())
	print("Inventory (Parsed): " + str(CodecOps.JSON_OPS.decode_string(inventory_codec, '''{
		"items":[
			{
				"item_id": "a demon's sword",
				"count": 1,
				"slot": 0,
			},
			{
				"item_id": "readable book",
				"count": 1,
				"slot": 1
			}
		]
	}''')))
	pass

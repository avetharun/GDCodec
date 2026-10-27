extends Node


static var item_bicast_codec : Codec = Codec.bicast([
		Codec.STRING_NAME, Codec.field(&"get_item_id", Codec.FieldType.Method),
		Codec.INT, Codec.field(&"count"),
		Codec.INT, Codec.field(&"slot"),
		Codec.optional(Codec.VARIANT, {}), Codec.field(&"data")
		], Item)

static var keyed_record_codec : Codec = Codec.record({
		"count": Codec.INT,
		"name": Codec.STRING
		}, true)

static var item_record_codec : Codec = Codec.record({
		"item_id":Codec.STRING_NAME,
		"count": Codec.INT,
		"slot": Codec.INT,
		"data": Codec.optional(Codec.VARIANT, {})
		})

## Records are a codec type that can be stored as a dictionary.
## However, Codec.mapof(k_codec, v_codec) will create an unformatted
## Dictionary that will be of type Dictionary[KeyType, ValueType], assuming
## xmap/smap/rmap is used. Dictionaries cannot be explicitly typed when used,
## so proxies may need to be used when converting to and from a variable
## such as Inventory.items
static var item_codec : Codec = Codec.record({
		"item_id":Codec.STRING_NAME,
		"count": Codec.INT,
		"slot": Codec.INT,
		"data": Codec.optional(Codec.VARIANT, {})
		}).xmap(
				func(value:Dictionary) -> Item: return Item.new(value["item_id"], value["count"], value["slot"], value["data"]),
				func(item:Item) -> Dictionary: return {"item_id": item.item_id_test, "count": item.count, "slot": item.slot, "data": item.data}
		)

static var inventory_codec : Codec = Codec.record({
		"items": Codec.arrayof(item_codec),
		}).xmap(
				func(value:Dictionary) -> Inventory:
						var items : Array[Item] = []
						for item:Item in value["items"]:
							items.append(item)
						return Inventory.new(items),
				func(inventory:Inventory) -> Dictionary:
					var items:Array = []
					for item:Item in inventory.items:
						items.append(item)
					return {"items": items}
)

## This is to test loading a BMP header, and determining the size of the image.
## [br][url]https://www.ece.ualberta.ca/~elliott/ee552/studentAppNotes/2003_w/misc/bmp_file_format/bmp_file_format.htm[/url]
## [br] The Codec.join function joins together data, such that it can be read
## as a binary blob using CodecOps.BYTE_BUFFER_OPS[br]
## Codec.byte_span will allow you to read the bytes used, 
## however Codec.padding will not. Codec.padding will always return null
static var bmp_test_codec : Codec = Codec.join([
		Codec.byte_span(18), # Header and Size fields
		Codec.INT, # Width (1)
		Codec.INT, # Height (2)
		Codec.byte_span(32), # Remaining part of InfoHeader.
		]).rmap( # Map the result into a bmp header object
			func(value:Array) -> BmpHeader: return BmpHeader.new(value[1], value[2])
			)
func _init() -> void:
	var item1 := Item.new("a very cool sword", 1, 16)
	var item2 := Item.new("a very cool shovel", 1, 14, {"damage": 7})
	var bicast_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
	item_bicast_codec.encode(item2, bicast_buffer)
	bicast_buffer.seek(0)
	var bicast_item:Item = item_bicast_codec.decode(bicast_buffer)
	assert(bicast_item.item_id_test == item2.item_id_test, "Item bicast roundtrip changed item_id.")
	assert(bicast_item.count == item2.count, "Item bicast roundtrip changed count.")
	assert(bicast_item.slot == item2.slot, "Item bicast roundtrip changed slot.")
	assert(bicast_item.data == item2.data, "Item bicast roundtrip changed data.")
	print("Item (bicast roundtrip): " + str(bicast_item))
	var bicast_json:StreamPeerBuffer = CodecOps.JSON_OPS.encode(item_bicast_codec, item2)
	var bicast_json_value:Dictionary = JSON.parse_string(bicast_json.data_array.get_string_from_utf8())
	assert(bicast_json_value["item_id"] == item2.item_id_test, "Bicast JSON used the wrong field name.")
	var bicast_json_item:Item = CodecOps.JSON_OPS.decode_buffer(item_bicast_codec, bicast_json)
	assert(bicast_json_item.item_id_test == item2.item_id_test, "Bicast JSON roundtrip changed item_id.")

	var keyed_value:Dictionary = {"count": 7, "name": "keyed"}
	var keyed_binary:StreamPeerBuffer = StreamPeerBuffer.new()
	keyed_record_codec.encode(keyed_value, keyed_binary)
	keyed_binary.seek(0)
	assert(keyed_record_codec.decode(keyed_binary) == keyed_value, "Keyed binary record roundtrip failed.")
	var keyed_json:StreamPeerBuffer = CodecOps.JSON_OPS.encode(keyed_record_codec, keyed_value)
	assert(CodecOps.JSON_OPS.decode_buffer(keyed_record_codec, keyed_json) == keyed_value, "Keyed JSON record roundtrip failed.")
	var inventory : Inventory = Inventory.new([item1, item2])
	## These will encode the item and inventory into a JSON object, based on
	## their codec.
	print("Item 1: " + CodecOps.JSON_OPS.encode(item_codec, item1).data_array.get_string_from_utf8())
	print("Item 2: " + CodecOps.JSON_OPS.encode(item_codec, item2).data_array.get_string_from_utf8())
	var encoded_inventory:StreamPeerBuffer = CodecOps.JSON_OPS.encode(inventory_codec, inventory)
	print("Inventory: " + encoded_inventory.data_array.get_string_from_utf8())
	var json_roundtrip:Inventory = CodecOps.JSON_OPS.decode_buffer(inventory_codec, encoded_inventory)
	assert(json_roundtrip.items.size() == inventory.items.size(), "Inventory JSON roundtrip changed the item count.")
	for i in range(inventory.items.size()):
		var expected_item:Item = inventory.items[i]
		var actual_item:Item = json_roundtrip.items[i]
		assert(actual_item.item_id_test == expected_item.item_id_test, "Inventory JSON roundtrip changed item_id at index %d." % i)
		assert(actual_item.count == expected_item.count, "Inventory JSON roundtrip changed count at index %d." % i)
		assert(actual_item.slot == expected_item.slot, "Inventory JSON roundtrip changed slot at index %d." % i)
		var expected_json_data:Variant = JSON.parse_string(JSON.stringify(expected_item.data))
		assert(actual_item.data == expected_json_data, "Inventory JSON roundtrip changed data at index %d." % i)
	print("Inventory (JSON Roundtrip): " + str(json_roundtrip))
	
	## This decoded/parses the inventory (and item) from a JSON object. This can
	## be from a file, or represented as a string using decode_string(...)
	## The bicast codec is tested separately; xmap constructs Items from the JSON record.
	var decoded_inventory : Inventory = CodecOps.JSON_OPS.decode_dict(inventory_codec, {
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
	})
	print("Inventory (Parsed): " + str(decoded_inventory))
	var span_codec : Codec = Codec.span(Codec.arrayof(Codec.BYTE).with_length_encoding(Codec.LengthEncoding.INT8), 4, [64,64])
	var span_buf : StreamPeerBuffer = CodecOps.BYTE_BUFFER_OPS.encode(span_codec, [[1,2], [2,3]])
	print("Span (Encoded): " + str(span_buf.data_array))
	var decoded_span : Array = CodecOps.BYTE_BUFFER_OPS.decode_buffer(span_codec, span_buf)
	print("Span (Padded): " + str(decoded_span))
	var _bmp_data : PackedByteArray = FileAccess.get_file_as_bytes("uid://swymxv1dpht8")
	## StreamPeerBuffer is used instead of PackedByteArray because it automatically
	## resizes when modified, if needed
	var _bmp_buf : StreamPeerBuffer = StreamPeerBuffer.new()
	_bmp_buf.data_array = _bmp_data
	print(CodecOps.BYTE_BUFFER_OPS.decode_buffer(bmp_test_codec, _bmp_buf) as BmpHeader)

class Item:
	var item_id_test : StringName
	var count : int
	var slot : int
	var data : Dictionary
	func get_item_id() -> StringName:
		return item_id_test
	func _init(p_item_id : StringName, p_count : int, p_slot : int, p_data : Dictionary = {}) -> void:
		self.item_id_test = p_item_id
		self.count = p_count
		self.slot = p_slot
		self.data = p_data
	func _to_string() -> String:
		return item_id_test as String + "x" + str(count) + " at slot " + str(slot) + " with data "\
				+ str(data)

class Inventory:
	var items : Array[Item] = []
	func _init(p_items : Array[Item]) -> void:
		self.items = p_items
	func _to_string() -> String:
		return "Inventory with items: " + str(items)

class BmpHeader:
	var width:int
	var height:int
	func _init(p_width : int, p_height : int) -> void:
		self.width = p_width
		self.height = p_height
	func _to_string() -> String:
		return "Width: " + str(width) + " Height: " + str(height)

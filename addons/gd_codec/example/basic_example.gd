extends Node

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
		## The xmap function maps the base result (from parsing) into another type
		## codec.smap maps the source result (in this case, Dictionary) from
		## one type to another.
		## codec.rmap maps the result (in this case, Item) into its base type
		## which in this case, is a Dictionary.
		}).xmap(
				func(value:Dictionary) -> Item: return Item.new(value["item_id"], value["count"], value["slot"], value["data"]),
				func(item:Item) -> Dictionary: return {"item_id": item.item_id_test, "count": item.count, "slot": item.slot, "data": item.data}
		)

static var inventory_codec : Codec = Codec.record({
		"items": Codec.arrayof(item_codec),
		}).xmap(
				func(value:Dictionary) -> Inventory:
						var items : Array[Item] = []
						# Unfortunately, Godot will not allow casting this to Array[Item]
						# via a array.map() call, 
						# so we need to proxy it into another array. Sorry!
						items.append_array(value["items"])
						return Inventory.new(items),
				func(inventory:Inventory) -> Dictionary: return {"items": inventory.items}
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
	var inventory : Inventory = Inventory.new([item1, item2])
	## These will encode the item and inventory into a JSON object, based on
	## their codec.
	print("Item 1: " + CodecOps.JSON_OPS.encode(item_codec, item1).data_array.get_string_from_utf8())
	print("Item 2: " + CodecOps.JSON_OPS.encode(item_codec, item2).data_array.get_string_from_utf8())
	print("Inventory: " + CodecOps.JSON_OPS.encode(inventory_codec, inventory).data_array.get_string_from_utf8())
	
	## This decoded/parses the inventory (and item) from a JSON object. This can
	## be from a file, or represented as a string using decode_string(...)
	## Since this example uses xmap on both the item and string, this will 
	## result in both the Inventory and Item(s) to be valid objects to use 
	## elsewhere
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

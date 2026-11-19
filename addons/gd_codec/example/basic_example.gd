## The purpose of this file is two things:
## First, it allows a demonstration of what the GDCodec library can be used for
## Second, it functions as a testing environment for various features of the library
## specifically, codec recursion, record tests, xmaps, bicasts, etc.
##
## If you are looking for networking examples, check the networking_example scene!

extends Node

## The Codec.lazy method can be used to self-reference the codec that is being defined.
## Note: does NOT need to have Codec.optional (or Codec.nullable) however for nesting chained objects,
## such as the DialogRef in this example, it's reccomended.
static var DIALOG_CODEC:Codec = Codec.bicast([
	Codec.STRING_NAME, Codec.field(&"id", Codec.FieldType.Field, "dialog_id"),
	Codec.STRING, Codec.field(&"title", Codec.FieldType.Field, "dialog_title"),
	Codec.STRING, Codec.field(&"body", Codec.FieldType.Field, "dialog_body"),
	Codec.optional(Codec.lazy(func() -> Codec: return DIALOG_CODEC), null), Codec.field(&"next", Codec.FieldType.Field, "next_dialog")
], DialogRef, DialogRef._bicast_import)


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
## Using the record format, inheritance requires you to duplicate the initial formatting.
## In complex chains, this can become expensive. Try using [method Codec.create_bicast_mapping] or [method Codec.get_bicast]
static var sword_item_codec : Codec = Codec.record({
		"item_id":Codec.STRING_NAME,
		"count": Codec.INT,
		"slot": Codec.INT,
		"data": Codec.optional(Codec.VARIANT, {}),
		"damage": Codec.FLOAT,
		}).xmap(
				func(value:Dictionary) -> Item: return SwordItem.new(value["damage"], value["item_id"], value["count"], value["slot"], value["data"]),
				func(item:SwordItem) -> Dictionary: return {"item_id": item.item_id_test, "count": item.count, "slot": item.slot, "data": item.data, "damage": item.damage}
		)


## The [method Codec.bicast] method is used for a more streamlined automation of mapping codecs directly to an object.
## [br] It allows you to represent fields or getter functions as a mapping into a constructor.
## [br] The constructor can either be a static method (use this for classes you do NOT control, ie Godot's classes)
## or the .new constructor (_init). The new method will be default if unspecified.
## [br] For Resource-based classes, use a static method instead of having an _init so Godot can still parse the Resource type.
## [br] For more examples of this method, see [url=https://avetharun.github.io/docs/gdcodec/docs/codecs/#codec-examples-encoding-an-object-using-bicast]GDCodec's Documentation / Encoding an object using Bicast[/url]
static var item_bicast_codec : Codec = Codec.bicast([
		## In Neoforge, this would be formatted as Codec.STRING_NAME.fieldOf("item_id").forGetter(Item::get_item_id)
		Codec.STRING_NAME, Codec.field(&"get_item_id", Codec.FieldType.Method, "item_id"),
		Codec.INT, Codec.field(&"count"),
		Codec.INT, Codec.field(&"slot"),
		Codec.optional(Codec.VARIANT, {}), Codec.field(&"data")
		], Item, Item.codec_new)
## For extending an existing codec, it's recommended to use [method Codec.bicast] with [method Codec.get_bicast_mapping]
## Two methods exist on [Codec.BicastMapping]. [method Codec.BicastMapping.prepend] which puts the "extend" as if you did the following:
## [codeblock]
## class A:
##     func _init(something:bool):
##        ...
## class PrependB extends A:
##     func _init(some_string:String, something:bool):
##         super._init(something)
##         ...
## class ExtendB extends A:
##     func _init(something:bool, some_string:String):
##         super._init(something)
##         ...
## [/codeblock]
## where you would use [method Codec.BicastMapping.prepend] for [code]PrependB[/code] and [method Codec.BicastMapping.extend] for [code]ExtendB[/code]
static var sword_item_bicast_codec : Codec = Codec.bicast(
	item_bicast_codec.get_bicast().prepend(
		[
			Codec.FLOAT, Codec.field(&"damage")
		]
	), SwordItem)
## Identical to the first argument of the [method Codec.bicast] method.
## Allows extending and inheritance
static var item_bicast_mapping : Codec.BicastMapping = Codec.create_bicast_mapping([
	Codec.STRING_NAME, Codec.field(&"get_item_id", Codec.FieldType.Method, "id"),
	Codec.INT, Codec.field(&"count"),
	Codec.INT, Codec.field(&"slot"),
	Codec.optional(Codec.VARIANT, {}), Codec.field(&"data")
])
static var sword_item_bicast_mapping : Codec.BicastMapping = item_bicast_mapping.extend(
	[
		Codec.FLOAT, Codec.field(&"damage")
	]
)

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

## A tagged choice whose payload codec is selected by its StringName identifier.
static var pick_codec:Codec = Codec.pick({
	&"pick_a": Codec.bicast([Codec.INT, &"var_a"], PickA),
	&"pick_b": Codec.bicast([Codec.STRING, &"var_b"], PickB),
	&"pick_c": Codec.bicast([Codec.BOOL, &"var_c"], PickC)
})

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
	var item3 := SwordItem.new(4.0, "a very very cool sword!", 1, 8)
	var i3_bicast_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
	sword_item_bicast_codec.encode(item3, i3_bicast_buffer)
	i3_bicast_buffer.seek(0)
	var i3_bicast_item:SwordItem = sword_item_bicast_codec.decode(i3_bicast_buffer)
	assert(i3_bicast_item.item_id_test == item3.item_id_test, "Item bicast roundtrip changed item_id.")
	assert(i3_bicast_item.count == item3.count, "Item bicast roundtrip changed count.")
	assert(i3_bicast_item.slot == item3.slot, "Item bicast roundtrip changed slot.")
	assert(i3_bicast_item.data == item3.data, "Item bicast roundtrip changed data.")
	print("Item (bicast roundtrip 3): " + str(i3_bicast_item))

	var dialog_leaf := DialogRef.new(&"leaf", "Leaf", "End of dialog")
	var dialog_root := DialogRef.new(&"root", "Root", "Start of dialog", dialog_leaf)
	var dialog_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
	DIALOG_CODEC.encode(dialog_root, dialog_buffer)
	dialog_buffer.seek(0)
	var decoded_dialog:DialogRef = DIALOG_CODEC.decode(dialog_buffer)
	assert(decoded_dialog.id == dialog_root.id, "Recursive bicast roundtrip changed the root id.")
	assert(decoded_dialog.next.id == dialog_leaf.id, "Recursive bicast roundtrip changed the next dialog id.")
	assert(decoded_dialog.next.next == null, "Recursive bicast roundtrip changed the terminal dialog.")
	print("Dialog (bicast roundtrip) "+decoded_dialog._to_string())
	var i2_bicast_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
	item_bicast_codec.encode(item2, i2_bicast_buffer)
	i2_bicast_buffer.seek(0)
	var i2_bicast_item:Item = item_bicast_codec.decode(i2_bicast_buffer)
	assert(i2_bicast_item.item_id_test == item2.item_id_test, "Item bicast roundtrip changed item_id.")
	assert(i2_bicast_item.count == item2.count, "Item bicast roundtrip changed count.")
	assert(i2_bicast_item.slot == item2.slot, "Item bicast roundtrip changed slot.")
	assert(i2_bicast_item.data == item2.data, "Item bicast roundtrip changed data.")
	print("Item (bicast roundtrip 2): " + str(i2_bicast_item))
	
	var i1_bicast_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
	item_bicast_codec.encode(item1, i1_bicast_buffer)
	i1_bicast_buffer.seek(0)
	var i1_bicast_item:Item = item_bicast_codec.decode(i1_bicast_buffer)
	assert(i1_bicast_item.item_id_test == item1.item_id_test, "Item bicast roundtrip changed item_id. Expected %s found %s" % [item1.item_id_test, i1_bicast_item.item_id_test])
	assert(i1_bicast_item.count == item1.count, "Item bicast roundtrip changed count.")
	assert(i1_bicast_item.slot == item1.slot, "Item bicast roundtrip changed slot.")
	assert(i1_bicast_item.data == item1.data, "Item bicast roundtrip changed data.")
	print("Item (bicast roundtrip 1): " + str(i1_bicast_item))
	
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
	var pick_a_value:PickA = PickA.new(0xdb7991)
	var pick_a_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
	pick_codec.encode([&"pick_a", pick_a_value], pick_a_buffer)
	pick_a_buffer.seek(0)
	var decoded_pick_a:Array = pick_codec.decode(pick_a_buffer)
	assert(decoded_pick_a[0] == &"pick_a" and decoded_pick_a[1] is PickA and decoded_pick_a[1].var_a == pick_a_value.var_a, "PickA roundtrip failed.")
	print("Pick (pick_a roundtrip): " + str(decoded_pick_a[1].var_a) + " == " + str(0xdb7991))
	var pick_b_value:PickB = PickB.new("Some String")
	var pick_b_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
	pick_codec.encode([&"pick_b", pick_b_value], pick_b_buffer)
	pick_b_buffer.seek(0)
	var decoded_pick_b:Array = pick_codec.decode(pick_b_buffer)
	assert(decoded_pick_b[0] == &"pick_b" and decoded_pick_b[1] is PickB and decoded_pick_b[1].var_b == pick_b_value.var_b, "PickB roundtrip failed.")
	print("Pick (pick_b roundtrip): \"" + str(decoded_pick_b[1].var_b) + "\" == \"Some String\"")
	var pick_c_value:PickC = PickC.new(true)
	var pick_c_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
	pick_codec.encode([&"pick_c", pick_c_value], pick_c_buffer)
	pick_c_buffer.seek(0)
	var decoded_pick_c:Array = pick_codec.decode(pick_c_buffer)
	assert(decoded_pick_c[0] == &"pick_c" and decoded_pick_c[1] is PickC and decoded_pick_c[1].var_c == pick_c_value.var_c, "PickC roundtrip failed.")
	print("Pick (pick_c roundtrip): " + str(decoded_pick_c[1].var_c) + " == true")

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

class Item extends RefCounted:
	var item_id_test : StringName
	var count : int
	var slot : int
	var data : Dictionary
	func get_item_id() -> StringName:
		return item_id_test
	static func codec_new(p_item_id : StringName, p_count : int, p_slot : int, p_data : Dictionary = {}) -> Item:
		return Item.new(p_item_id, p_count, p_slot, p_data)
	func _init(p_item_id : StringName, p_count : int, p_slot : int, p_data : Dictionary = {}) -> void:
		self.item_id_test = p_item_id
		self.count = p_count
		self.slot = p_slot
		self.data = p_data
	func _to_string() -> String:
		return item_id_test as String + "x" + str(count) + " at slot " + str(slot) + " with data "\
				+ str(data)
class SwordItem extends Item:
	var damage : float
	func _init(p_damage:float, p_item_id : StringName, p_count : int, p_slot : int, p_data : Dictionary = {}) -> void:
		super._init(p_item_id, p_count, p_slot, p_data)
	func _to_string() -> String:
		return "SwordItem@"+super._to_string()
class Inventory extends RefCounted:
	var items : Array[Item] = []
	func _init(p_items : Array[Item]) -> void:
		self.items = p_items
	func _to_string() -> String:
		return "Inventory with items: " + str(items)

class DialogRef extends RefCounted:

	var id:StringName
	var title:String
	var body:String
	var next:DialogRef

	static func _bicast_import(p_id:StringName, p_title:String, p_body:String, p_next:DialogRef) -> DialogRef:
		return DialogRef.new(p_id, p_title, p_body, p_next)

	func _init(p_id:StringName, p_title:String, p_body:String, p_next:DialogRef = null) -> void:
		id = p_id
		title = p_title
		body = p_body
		next = p_next
	func _to_string() -> String:
		var base : String = "$%s | \"%s\" : \"%s\"" %[id, title, body]
		var _current : DialogRef = next
		while _current != null:
			base += " -> "+ _current._to_string()
			_current = _current.next
		return base

class PickA extends RefCounted:
	var var_a:int
	func _init(p_var_a:int) -> void:
		var_a = p_var_a

class PickB extends RefCounted:
	var var_b:String
	func _init(p_var_b:String) -> void:
		var_b = p_var_b

class PickC extends RefCounted:
	var var_c:bool
	func _init(p_var_c:bool) -> void:
		var_c = p_var_c

class BmpHeader extends RefCounted:
	var width:int
	var height:int
	func _init(p_width : int, p_height : int) -> void:
		self.width = p_width
		self.height = p_height
	func _to_string() -> String:
		return "Width: " + str(width) + " Height: " + str(height)

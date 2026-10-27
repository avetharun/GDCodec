@tool
## Serialization / Deserialization format creation
## 
## [br] Allows encoding and decoding with much more control than [method @GlobalScope.var_to_bytes]
class_name Codec
extends RefCounted
var _encoder : Encoder
var _decoder : Decoder
var _wire_encoder : Encoder
var _is_record:bool = false
var _length_encoding : LengthEncoding = LengthEncoding.INT32
var _rmap_f : Callable = Callable()
var _smap_f : Callable = Callable()
var _json_smap_f : Callable = Callable()
var _json_wire_encoder : Encoder
var _cd_name : StringName = _UNNAMED_CODEC
const _UNNAMED_CODEC : StringName = "Unnamed"
## Enum (64-bit unsigned)
## [br] [b]Warning:[/b] make sure to validate the output of this!
static var ENUM : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_u64(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_u64())
).set_name("Enum")
## Long (64-bit unsigned)
static var LONG : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_u64(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_u64())
).set_name("U64")
## Int (32-bit unsigned)
static var INT : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_u32(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_u32())
).set_name("U32")
## Short (16-bit unsigned)
static var SHORT : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_u16(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_u16())
).set_name("U16")
## Byte (8-bit unsigned)
static var BYTE : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_u8(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_u8())
).set_name("U8")
## Long (64-bit signed)
static var SIGNED_LONG : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_64(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_64())
).set_name("S64")
## Int (32-bit signed)
static var SIGNED_INT : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_32(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_32())
).set_name("S32")
## Short (16-bit signed)
static var SIGNED_SHORT : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_16(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_16())
).set_name("S16")
## Byte (8-bit signed)
static var SIGNED_BYTE : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_8(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_8())
).set_name("S8")
## Double
static var DOUBLE : Codec = Codec.new(
		Encoder.new(func(v:float, buf:StreamPeerBuffer): buf.put_double(v)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_double())
).set_name("Double")
## Float
static var FLOAT : Codec = Codec.new(
		Encoder.new(func(v:float, buf:StreamPeerBuffer): buf.put_float(v)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_float())
).set_name("Float")
## Boolean (8-bit unsigned)
## [br] Note: this is not a bitmask
static var BOOL : Codec = Codec.new(
		Encoder.new(func(v:bool, buf:StreamPeerBuffer): buf.put_u8(1 if v else 0)), 
		Decoder.new(func(buf:StreamPeerBuffer): return true if buf.get_u8() == 1 else false)
).set_name("Boolean")
## Length-prefixed String
static var STRING : Codec = _length_prefixed_string().set_name("String")
## Variant of [member Codec.STRING] that will convert into a StringName automatically
static var STRING_NAME: Codec = STRING.xmap(
		func(source: String) -> StringName: return StringName(source),
		func(destination: StringName) -> String: return String(destination)
).set_name("StringName")
## Array of Longs (64-bit unsigned)
static var LONG_ARRAY : Codec = arrayof(LONG).set_name("U64Array")
## Array of Ints (32-bit unsigned)
static var INT_ARRAY : Codec = arrayof(INT).set_name("U32Array")
## Array of Shorts (16-bit unsigned)
static var SHORT_ARRAY : Codec = arrayof(SHORT).set_name("U16Array")
## Array of Longs (64-bit signed)
static var SIGNED_LONG_ARRAY : Codec = arrayof(SIGNED_LONG).set_name("S64Array")
## Array of Ints (32-bit signed)
static var SIGNED_INT_ARRAY : Codec = arrayof(SIGNED_INT).set_name("S32Array")
## Array of Shorts (16-bit signed)
static var SIGNED_SHORT_ARRAY : Codec = arrayof(SIGNED_SHORT).set_name("S16Array")
## Array of Bytes (8-bit signed)
static var SIGNED_BYTE_ARRAY : Codec = arrayof(SIGNED_BYTE).set_name("S8Array")
## Array of Doubles
static var DOUBLE_ARRAY : Codec = arrayof(DOUBLE).set_name("DoubleArray")
## Array of Floats
static var FLOAT_ARRAY : Codec = arrayof(FLOAT).set_name("FloatArray")
## Array of Booleans (8-bit unsigned)
static var BOOL_ARRAY : Codec = arrayof(BOOL).set_name("BoolArray")
## Array of length-prefixed Strings
static var STRING_ARRAY : Codec = arrayof(STRING).set_name("StringArray")
## Array of Bytes (8-bit unsigned)
static var BYTE_ARRAY : Codec = _length_prefixed_bytes().set_name("U8Array")
## Array of Color (RGBA8, Int32 encoded)
static var COLOR_ARRAY : Codec = arrayof(COLOR).set_name("ColorArray")
## Array of Color (RGBA01, HDR format, Float encoded)
static var COLOR_HDR_ARRAY : Codec = arrayof(COLOR).set_name("ColorHDRArray")
## Array of Bytes (mapped to [PackedByteArray])
static var PACKED_BYTE_ARRAY : Codec = BYTE_ARRAY.xmap(
	func(source: PackedByteArray) -> PackedByteArray: return source,
	func(destination: PackedByteArray) -> PackedByteArray: return destination
)
## Array of Colors (RGBA8, mapped to [PackedColorArray])
static var PACKED_COLOR_ARRAY : Codec = COLOR_ARRAY.xmap(
	func(source: Array[Variant]) -> PackedColorArray: return PackedColorArray(source),
	func(destination: PackedColorArray) -> Array[Variant]:
		var values: Array[Variant] = []
		values.assign(destination)
		return values
)
## Array of Colors (RGBA01, HDR format, mapped to [PackedColorArray])
static var PACKED_COLOR_HDR_ARRAY : Codec = COLOR_HDR_ARRAY.xmap(
	func(source: Array[Variant]) -> PackedColorArray: return PackedColorArray(source),
	func(destination: PackedColorArray) -> Array[Variant]:
		var values: Array[Variant] = []
		values.assign(destination)
		return values
)
## Array of Floats (mapped to [PackedFloat32Array])
static var PACKED_FLOAT32_ARRAY : Codec = FLOAT_ARRAY.xmap(
	func(source: Array[Variant]) -> PackedFloat32Array: return PackedFloat32Array(source),
	func(destination: PackedFloat32Array) -> Array[Variant]:
		var values: Array[Variant] = []
		values.assign(destination)
		return values
)
## Array of Floats (mapped to [PackedFloat32Array])
static var PACKED_FLOAT_ARRAY : Codec = PACKED_FLOAT32_ARRAY

## Array of Doubles (mapped to [PackedFloat64Array])
static var PACKED_FLOAT64_ARRAY : Codec = DOUBLE_ARRAY.xmap(
	func(source: Array[Variant]) -> PackedFloat64Array: return PackedFloat64Array(source),
	func(destination: PackedFloat64Array) -> Array[Variant]:
		var values: Array[Variant] = []
		values.assign(destination)
		return values
)
## Array of Doubles (mapped to [PackedFloat64Array])
static var PACKED_DOUBLE_ARRAY : Codec = PACKED_FLOAT64_ARRAY
## Array of Ints (mapped to [PackedInt32Array])
static var PACKED_INT32_ARRAY : Codec = SIGNED_INT_ARRAY.xmap(
	func(source: Array[Variant]) -> PackedInt32Array: return PackedInt32Array(source),
	func(destination: PackedInt32Array) -> Array[Variant]:
		var values: Array[Variant] = []
		values.assign(destination)
		return values
)
## Array of Longs (mapped to [PackedInt64Array])
static var PACKED_INT64_ARRAY : Codec = SIGNED_LONG_ARRAY.xmap(
	func(source: Array[Variant]) -> PackedInt64Array: return PackedInt64Array(source),
	func(destination: PackedInt64Array) -> Array[Variant]:
		var values: Array[Variant] = []
		values.assign(destination)
		return values
)
## Array of Strings (mapped to [PackedStringArray])
static var PACKED_STRING_ARRAY : Codec = STRING_ARRAY.xmap(
	func(source: Array[Variant]) -> PackedStringArray: return PackedStringArray(source),
	func(destination: PackedStringArray) -> Array[Variant]:
		var values: Array[Variant] = []
		values.assign(destination)
		return values
)
## Array of Vector2 (mapped to [PackedVector2Array])
static var PACKED_VECTOR2_ARRAY : Codec = arrayof(VECTOR2).xmap(
	func(source: Array[Variant]) -> PackedVector2Array: return PackedVector2Array(source),
	func(destination: PackedVector2Array) -> Array[Variant]:
		var values: Array[Variant] = []
		values.assign(destination)
		return values
)
## Array of Vector3 (mapped to [PackedVector3Array])
static var PACKED_VECTOR3_ARRAY : Codec = arrayof(VECTOR3).xmap(
	func(source: Array[Variant]) -> PackedVector3Array: return PackedVector3Array(source),
	func(destination: PackedVector3Array) -> Array[Variant]:
		var values: Array[Variant] = []
		values.assign(destination)
		return values
)
## Array of Vector4 (mapped to [PackedVector4Array])
static var PACKED_VECTOR4_ARRAY : Codec = arrayof(VECTOR4).xmap(
	func(source: Array[Variant]) -> PackedVector4Array: return PackedVector4Array(source),
	func(destination: PackedVector4Array) -> Array[Variant]:
		var values: Array[Variant] = []
		values.assign(destination)
		return values
)

## Color (RGBA8, Int32 encoded)
static var COLOR : Codec = Codec.INT.xmap(
	func(source: int) -> Color: return Color.hex(source),
	func(destination: Color) -> int: return destination.to_rgba32()
).set_name("Color8")

## Color (RGBA01, HDR format, Float encoded)
static var COLOR_HDR : Codec = Codec.new(
		Encoder.new(func(v:Color, buf:StreamPeerBuffer): buf.put_float(v.r); buf.put_float(v.g); buf.put_float(v.b); buf.put_float(v.a)), 
		Decoder.new(func(buf:StreamPeerBuffer): return Color(buf.get_float(), buf.get_float(), buf.get_float(), buf.get_float()))
).set_name("ColorHDR")

## Vector2 (64-bit)
static var VECTOR2 : Codec = Codec.new(
		Encoder.new(func(v:Vector2, buf:StreamPeerBuffer): buf.put_float(v.x); buf.put_float(v.y)), 
		Decoder.new(func(buf:StreamPeerBuffer): return Vector2(buf.get_float(), buf.get_float()))
).set_name("Vector2")

## Vector2i (32-bit)
static var VECTOR2I : Codec = Codec.new(
		Encoder.new(func(v:Vector2i, buf:StreamPeerBuffer): buf.put_32(v.x); buf.put_32(v.y)), 
		Decoder.new(func(buf:StreamPeerBuffer): return Vector2i(buf.get_32(), buf.get_32()))
).set_name("Vector2i")

## Vector3 (64-bit)
static var VECTOR3 : Codec = Codec.new(
		Encoder.new(func(v:Vector3, buf:StreamPeerBuffer): buf.put_float(v.x); buf.put_float(v.y); buf.put_float(v.z)), 
		Decoder.new(func(buf:StreamPeerBuffer): return Vector3(buf.get_float(), buf.get_float(), buf.get_float()))
).set_name("Vector3")

## Vector3i (32-bit)
static var VECTOR3I : Codec = Codec.new(
		Encoder.new(func(v:Vector3i, buf:StreamPeerBuffer): buf.put_32(v.x); buf.put_32(v.y); buf.put_32(v.z)), 
		Decoder.new(func(buf:StreamPeerBuffer): return Vector3i(buf.get_32(), buf.get_32(), buf.get_32()))
).set_name("Vector3i")

## Vector4 (64-bit)
static var VECTOR4 : Codec = Codec.new(
		Encoder.new(func(v:Vector4, buf:StreamPeerBuffer): buf.put_float(v.x); buf.put_float(v.y); buf.put_float(v.z); buf.put_float(v.w)), 
		Decoder.new(func(buf:StreamPeerBuffer): return Vector4(buf.get_float(), buf.get_float(), buf.get_float(), buf.get_float()))
).set_name("Vector4")

## Vector4i (32-bit)
static var VECTOR4I : Codec = Codec.new(
		Encoder.new(func(v:Vector4i, buf:StreamPeerBuffer): buf.put_32(v.x); buf.put_32(v.y); buf.put_32(v.z); buf.put_32(v.w)), 
		Decoder.new(func(buf:StreamPeerBuffer): return Vector4i(buf.get_32(), buf.get_32(), buf.get_32(), buf.get_32()))
).set_name("Vector4i")

## Quaternion
static var QUATERNION : Codec = Codec.new(
		Encoder.new(func(v:Quaternion, buf:StreamPeerBuffer): buf.put_float(v.x); buf.put_float(v.y); buf.put_float(v.z); buf.put_float(v.w)), 
		Decoder.new(func(buf:StreamPeerBuffer): return Quaternion(buf.get_float(), buf.get_float(), buf.get_float(), buf.get_float()))
).set_name("Quaternion")

## Native Godot Variant
static var VARIANT : Codec = Codec.new(
		Encoder.new(func(v, buf:StreamPeerBuffer): buf.put_var(v)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_var())
).set_name("Variant")

## Native Godot Variant, full objects and code enabled.[br]
## [b]Warning[/b]: Deserialized objects can contain code which gets executed.
## Do not use this option if the serialized object comes from untrusted sources
## to avoid potential security threats such as remote code execution.
static var VARIANT_WITH_OBJECTS : Codec = Codec.new(
		Encoder.new(func(v, buf:StreamPeerBuffer): buf.put_var(v, true)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_var(true))
).set_name("VariantWithObject")

## Array of booleans that will be packed into a single byte.
static var BITMASK_8 : Codec = Codec.new(
		Encoder.new(func(v: Array, buf:StreamPeerBuffer):
			var mask: int = 0
			for i in range(min(v.size(), 8)):
				if v[i]: mask |= (1 << i)
			buf.put_u8(mask)
			), 
		Decoder.new(func(buf:StreamPeerBuffer) -> Array:
			var mask: int = buf.get_u8()
			var flags: Array = []
			for i in range(8):
				flags.append((mask & (1 << i)) != 0)
			return flags
			)
).set_name("Bitmask8")


static func _length_prefixed_string() -> Codec:
	var _r_codec : Codec = Codec.new()
	_r_codec._set_encoder(Encoder.new(func(v:String, buf:StreamPeerBuffer):
		var data:PackedByteArray = v.to_utf8_buffer()
		_r_codec._encode_length(buf, data.size())
		buf.put_data(data)))
	_r_codec._set_decoder(Decoder.new(func(buf:StreamPeerBuffer):
		var len:int = _r_codec._decode_length(buf)
		var result:Array = buf.get_data(len)
		return result[1].get_string_from_utf8()))
	return _r_codec

static func _length_prefixed_bytes() -> Codec:
	var _r_codec : Codec = Codec.new()
	_r_codec._set_encoder(Encoder.new(func(v:PackedByteArray, buf:StreamPeerBuffer):
		_r_codec._encode_length(buf, v.size())
		buf.put_data(v)))
	_r_codec._set_decoder(Decoder.new(func(buf:StreamPeerBuffer):
		var len:int = _r_codec._decode_length(buf)
		var result:Array = buf.get_data(len)
		return result[1]))
	return _r_codec

## Constant-width codec of an element type. [br]
## The default value must be encodable by this codec.
static func span(codec:Codec, length:int, default:Variant) -> Codec:
	assert(length >= 0)
	var span_codec := Codec.new(
			Encoder.new(func(v:Array[Variant], buf:StreamPeerBuffer):
				assert(v.size() <= length)
				for i in range(length):
					codec.encode(v[i] if i < v.size() else default, buf)
				),
			Decoder.new(func(buf:StreamPeerBuffer):
				var values:Array[Variant] = []
				for i in range(length):
					values.append(codec.decode(buf))
				return values
				)
	)
	span_codec._wire_encoder = Encoder.new(func(v:Array[Variant], buf:StreamPeerBuffer):
			assert(v.size() <= length)
			for i in range(length):
				codec._encode_wire(v[i] if i < v.size() else default, buf)
			)
	return span_codec


## Creates a readable array/span of bytes of a set length
static func byte_span(length:int) -> Codec:
	return Codec.new(
		Encoder.new(func(v:PackedByteArray, buf:StreamPeerBuffer):
				v.resize(length)
				buf.put_data(v)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var result:Array = buf.get_data(length)
				return result[1] as PackedByteArray
				)
	)

## Creates a codec for nullable values. Wrapper for Codec.optional
static func nullable(codec:Codec) -> Codec:
	return optional(codec, null)


## Creates a codec for nullable values.
static func optional(codec:Codec, default:Variant) -> Codec:
	var optional_codec := Codec.new(
		Encoder.new(func(v:Variant, buf:StreamPeerBuffer):
				if v == null or v == default:
					buf.put_u8(0)
					return
				buf.put_u8(1)
				if v == null and v != default:
					v = default
				codec.encode(v, buf)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var marker:int = buf.get_u8()
				assert(marker == 0 or marker == 1)
				if marker == 0:
					return default
				return codec.decode(buf)
				)
	)
	optional_codec._wire_encoder = Encoder.new(func(v:Variant, buf:StreamPeerBuffer):
				if v == null or v == default:
					buf.put_u8(0)
					return
				buf.put_u8(1)
				codec._encode_wire(v, buf)
				)
	return optional_codec


## Creates a zero-width codec that always decodes to value and validates the value during encoding.
static func constant(value:Variant) -> Codec:
	return Codec.new(
		Encoder.new(func(v:Variant, buf:StreamPeerBuffer):assert(v == value)),
		Decoder.new(func(buf:StreamPeerBuffer):return value)
	)


## Creates a codec that will insert [length] bytes into the resulting codec
static func padding(length:int) -> Codec:
	assert(length >= 0)
	return Codec.new(
		Encoder.new(func(v:Variant, buf:StreamPeerBuffer):
				var bytes : PackedByteArray = PackedByteArray()
				bytes.resize(length)
				buf.put_data(bytes)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var result:Array = buf.get_data(length)
				assert(result[0] == OK)
				return null
				)
	)


## Creates a tagged union codec. Values use the form [tag, value], and the tag selects the codec in codecs.
static func either(tag_codec:Codec, codecs:Array) -> Codec:
	assert(not codecs.is_empty())
	return Codec.new(
		Encoder.new(func(v:Array, buf:StreamPeerBuffer):
				var tag:int = v[0]
				assert(tag >= 0 and tag < codecs.size())
				tag_codec.encode(tag, buf)
				codecs[tag].encode(v[1], buf)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var tag:int = tag_codec.decode(buf)
				assert(tag >= 0 and tag < codecs.size())
				return [tag, codecs[tag].decode(buf)]
				)
	)


## Creates a fixed-sequence codec. Values are encoded and decoded as an array matching the codecs order.
static func join(codecs:Array) -> Codec:
	return Codec.new(
		Encoder.new(func(v:Array, buf:StreamPeerBuffer):
				assert(v.size() == codecs.size())
				for i in range(codecs.size()):
					codecs[i].encode(v[i], buf)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var values:Array[Variant] = []
				for codec in codecs:
					values.append(codec.decode(buf))
				return values
				)
	)

## Creates a codec that represents a length-prefixed string with a max length
static func limited_string(max_length:int) -> Codec:
	assert(max_length >= 0)
	var _r_codec : Codec = Codec.new()
	_r_codec._set_encoder(Encoder.new(func(v:String, buf:StreamPeerBuffer):
				var data:PackedByteArray = v.to_utf8_buffer()
				assert(data.size() <= max_length)
				_r_codec._encode_length(buf, data.size())
				buf.put_data(data)))
	_r_codec._set_decoder(Decoder.new(func(buf:StreamPeerBuffer):
				var len:int = _r_codec._decode_length(buf)
				assert(len <= max_length)
				var result:Array = buf.get_data(len)
				return result[1].get_string_from_utf8()
				))
	return _r_codec

## Creates an array of codecs, formatted as NUM32[...]
static func arrayof(codec:Codec) -> Codec:
	var array_codec : Codec = Codec.new()
	array_codec._set_encoder(Encoder.new(func(v:Array[Variant], buf:StreamPeerBuffer):
				var len : int = v.size()
				array_codec._encode_length(buf, len)
				for i in range(len):
					var cv : Variant = v.get(i)
					codec.encode(cv, buf)
				))
	array_codec._set_decoder(Decoder.new(func(buf:StreamPeerBuffer):
				var len:int = array_codec._decode_length(buf)
				var values:Array[Variant] = []
				for i in range(len):
					values.append(codec.decode(buf))
				return values
				))
	array_codec._set_wire_encoder(Encoder.new(func(v:Array[Variant], buf:StreamPeerBuffer):
			array_codec._encode_length(buf, v.size())
			for value in v:
				codec._encode_wire(value, buf)
			))
	array_codec._json_smap_f = func(v:Array) -> Array:
		var values:Array = []
		for value in v:
			if not codec._json_smap_f.is_null():
				values.append(codec._json_smap_f.call(value))
			else:
				var smap:Callable = codec.get_smap()
				values.append(smap.call(value) if not smap.is_null() else value)
		return values
	return array_codec


## Creates an array codec that rejects more than max_length elements during encoding or decoding
static func limited_array(codec:Codec, max_length:int) -> Codec:
	assert(max_length >= 0)
	var _r_codec : Codec = Codec.new()
	_r_codec._set_encoder(Encoder.new(func(v:Array[Variant], buf:StreamPeerBuffer):
			assert(v.size() <= max_length)
			_r_codec._encode_length(buf, v.size())
			for value in v:
				codec.encode(value, buf)
			))
	_r_codec._set_decoder(Decoder.new(func(buf:StreamPeerBuffer):
			var len:int = _r_codec._decode_length(buf)
			assert(len <= max_length)
			var values:Array[Variant] = []
			for i in range(len):
				values.append(codec.decode(buf))
			return values
			))
	return _r_codec


## Creates a length-prefixed map codec using separate codecs for keys and values.[br]Effectively just a Dictionary wrapper for codecs 
static func mapof(key_codec:Codec, value_codec:Codec) -> Codec:
	var _r_codec : Codec = Codec.new()
	_r_codec._set_encoder(Encoder.new(func(v:Dictionary, buf:StreamPeerBuffer):
			_r_codec._encode_length(buf, v.size())
			for key in v:
				key_codec.encode(key, buf)
				value_codec.encode(v[key], buf)))
	_r_codec._set_decoder(Decoder.new(func(buf:StreamPeerBuffer):
			var len:int = _r_codec._decode_length(buf)
			var values:Dictionary = {}
			for i in range(len):
				var key:Variant = key_codec.decode(buf)
				values[key] = value_codec.decode(buf)
			return values))
	return _r_codec


## Creates a record codec that encodes fields in the dictionary's declaration order.[br]This can be used to serialize from and to class objects, similarly to var_to_bytes.
## If [param encode_key] is true, each field name is encoded as a length-prefixed string immediately before its value.
static func record(fields:Dictionary, encode_key:bool = false) -> Codec:
	var field_names:Array = fields.keys()
	var codec : Codec = Codec.new(
		Encoder.new(func(v:Dictionary, buf:StreamPeerBuffer):
				for field_name in field_names:
					var field_codec:Codec = fields[field_name]
					if encode_key:
						STRING.encode(str(field_name), buf)
					field_codec.encode(v.get(field_name), buf)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var value:Dictionary = {}
				for field_name in field_names:
					var field_codec:Codec = fields[field_name]
					if encode_key:
						assert(STRING.decode(buf) == str(field_name), "Record key did not match expected field %s." % field_name)
					value[field_name] = field_codec.decode(buf)
				return value
				)
	)
	codec._is_record = true
	codec._wire_encoder = Encoder.new(func(v:Dictionary, buf:StreamPeerBuffer):
			for field_name in field_names:
				var field_codec:Codec = fields[field_name]
				if encode_key:
					STRING.encode(str(field_name), buf)
				field_codec._encode_wire(v.get(field_name), buf)
			)
	codec._json_smap_f = func(v:Dictionary) -> Dictionary:
		var values:Dictionary = {}
		for field_name in field_names:
			var field_codec:Codec = fields[field_name]
			var field_value:Variant = v.get(field_name)
			if not field_codec._json_smap_f.is_null():
				values[field_name] = field_codec._json_smap_f.call(field_value)
			else:
				var smap:Callable = field_codec.get_smap()
				values[field_name] = smap.call(field_value) if not smap.is_null() else field_value
		return values
	return codec


## Constructs an enum codec that will be represented as a string instead of an
## integer.
## [br] Returns [code]-1[/code] when the element is not found.
## [br][b]Warning:[/b] ensure you modify the default_key param if you
## have an element named "__INVALID__"
## [br][b]Warning:[/b] ensure you do not have two keys that can be converted to
## the same string when [param forced_case] is false,
## eg 'some_key' and 'SOME_KEY'
## [br][i]Reccomendation:[/i] have an "invalid" enum element and set it as
## the default.
static func enum_string(p_enum_type:Variant, default:int = -1, forced_case:bool = false, default_key:String = "__INVALID__"):
	# Allows mapping a lowercase variant of the enum to the actual value
	# forced_case is false
	var tKeyMap : Dictionary[String, int] = {}
	if forced_case:
		tKeyMap = p_enum_type
	else:
		for key:String in p_enum_type.keys():
			tKeyMap.set(key.to_lower(), p_enum_type.get(key))
	return Codec.STRING.xmap(
		func(e_s:String)->int: return tKeyMap.get(e_s if forced_case else e_s.to_lower(), default),
		(func(e_i:int)->String: 
				var _result = tKeyMap.find_key(e_i)
				return _result if _result != null else default_key
				)
	)
static func get_enum_string_value(p_enum_type:Variant, e_key:String, default:int = -1, forced_case:bool = false):
	if forced_case:
		# assume it's safe
		return p_enum_type.get(e_key)
	for key:String in p_enum_type.keys():
		#print(key.to_lower() + "==" + e_key.to_lower() + str(key.to_lower() == e_key.to_lower()))
		if key.to_lower() == e_key.to_lower():
			return p_enum_type.get(key)
	return default
func _init(c_encoder:Encoder = null, c_decoder:Decoder = null) -> void:
	self._encoder = c_encoder
	self._decoder = c_decoder
	self._wire_encoder = c_encoder


func _set_encoder(c_encoder:Encoder):
	self._encoder = c_encoder
	if (self._wire_encoder == null):
		self._wire_encoder = c_encoder


func _set_wire_encoder(c_wire_encoder:Encoder):
	self._wire_encoder = c_wire_encoder


func _set_decoder(c_decoder:Decoder):
	self._decoder = c_decoder


func _encode_wire(v:Variant, buf:StreamPeerBuffer):
	_wire_encoder.encode(v, buf)


## Encodes into the supplied buffer
func encode(v:Variant, buf:StreamPeerBuffer) -> StreamPeerBuffer:
	_encoder.encode(v, buf)
	return buf


## Gets the name of the codec. If not valid, returns "Unnamed_Codec"
func get_name() -> StringName:
	return self._cd_name


## Sets the name of the codec (Returned when calling to_string)
func set_name(name:StringName) -> Codec:
	self._cd_name = name
	return self


## Decodes from the supplied buffer
func decode(buf:StreamPeerBuffer)->Variant:
	return _decoder.decode(buf)


## Converts the result(Decoded) into another type[br]eg: [code]Codec.INT.map(func(result): return str(result))[/code][br]would result in a string represented by an uint32
func rmap(mapper:Callable) -> Codec:
	var source:Codec = self
	var codec = Codec.new(
		source._encoder,
		Decoder.new(func(buf:StreamPeerBuffer):return mapper.call(source.decode(buf)))
	)
	codec._rmap_f = mapper
	return codec


## Returns the mapper supplied in [code]to[/code] in the [code]xmap[/code]
## function, or the mapper in [code]rmap[/code]
func get_rmap() -> Callable:
	return _rmap_f


## Returns the mapper supplied in [code]from[/code] in the [code]xmap[/code]
## function, or the mapper in [code]smap[/code]
func get_smap() -> Callable:
	return _smap_f


## Creates a codec that maps field codecs to and from instances of [param c_type].
## Params require pairs of Codec and a raw [StringName] or [CodecBiRef] in the following format:
## [CODEC_TYPE, &"field_name", ...]
## Raw names are read with [method Object.get]. Use [method Codec.field] to select a different access method.
## Native classes require an explicit constructor callable in [param c_ctor].
## JSON serialization uses field names from [CodecBiRef.json_name].
static func bicast(bi_pairs : Array[Variant], c_type:Variant, c_ctor : Callable = Callable()) -> Codec:
	var c : Codec = Codec.new()
	return c._bicast_map(bi_pairs, c_type, c_ctor)


func _bicast_map(bi_pairs : Array[Variant], c_type:Variant, c_ctor : Callable = Callable()) -> Codec:
	assert(bi_pairs.size() % 2 == 0, "Missing field name for Codec.")
	var field_codecs : Array[Codec] = []
	var field_accessors : Array[Callable] = []
	var json_names:Array[StringName] = []
	for i in range(0, bi_pairs.size(), 2):
		assert(bi_pairs[i] is Codec, "Expected a Codec at index %d." % i)
		assert(bi_pairs[i + 1] is StringName or bi_pairs[i + 1] is CodecBiRef, "Expected a StringName or CodecBiRef at index %d." % (i + 1))
		field_codecs.append(bi_pairs[i] as Codec)
		field_accessors.append(_bicast_field_accessor(bi_pairs[i + 1]))
		var json_name:StringName
		if bi_pairs[i + 1] is CodecBiRef:
			json_name = (bi_pairs[i + 1] as CodecBiRef).json_name
		else:
			json_name = bi_pairs[i + 1] as StringName
		assert(not json_name.is_empty(), "Bicast fields need a JSON name; use Codec.field with a name or an inferable field/method name.")
		assert(not json_names.has(json_name), "Duplicate bicast JSON field name: %s." % json_name)
		json_names.append(json_name)

	var script_type:bool = c_type is Script
	assert(script_type or not c_ctor.is_null(), "A constructor must be provided when c_type is not a Script.")
	var ctor : Callable = c_type.new if c_ctor.is_null() else c_ctor
	var ctor_name : StringName = &"_init" if c_ctor.is_null() else c_ctor.get_method()
	var ctor_arg_count:int = -1
	if script_type:
		for method:Dictionary in c_type.get_script_method_list():
			if method.name == ctor_name:
				ctor_arg_count = method.args.size()
				break
	if ctor_arg_count == -1:
		ctor_arg_count = ctor.get_argument_count()
		if script_type and ctor == c_type.new:
			push_error("Cannot use bicast on constructor [new] when there are custom arguments!")
	var type_name:String = c_type.get_global_name() if script_type else str(c_type)
	assert(ctor_arg_count == field_codecs.size(), "%s %s must have exactly as many arguments as the mapping! Expected: %d, found: %d" % [type_name, ctor_name, field_codecs.size(), ctor_arg_count])

	self._smap_f = func(v:Variant) -> Array[Variant]:
		assert(_bicast_instance_matches(v, c_type), "Value must be an instance of %s." % type_name)
		var values:Array[Variant] = []
		for i in range(field_codecs.size()):
			values.append(field_accessors[i].call(v))
		return values

	self._json_smap_f = func(v:Variant) -> Dictionary:
		var values:Array[Variant] = self._smap_f.call(v)
		var json_fields:Dictionary = {}
		for i in range(json_names.size()):
			json_fields[String(json_names[i])] = values[i]
		return json_fields

	self._rmap_f = func(values:Array[Variant]) -> Variant:
		assert(values.size() == field_codecs.size())
		var value:Variant = ctor.callv(values)
		assert(_bicast_instance_matches(value, c_type), "Constructor must return an instance of %s." % type_name)
		return value

	var encode_fields := func(v:Variant, buf:StreamPeerBuffer, wire:bool = false) -> void:
		var values:Array[Variant] = self._smap_f.call(v)
		for i in range(field_codecs.size()):
			if wire:
				field_codecs[i]._encode_wire(values[i], buf)
			else:
				field_codecs[i].encode(values[i], buf)

	self._encoder = Encoder.new(func(v:Variant, buf:StreamPeerBuffer):
		encode_fields.call(v, buf)
	)
	self._wire_encoder = Encoder.new(func(v:Variant, buf:StreamPeerBuffer):
		encode_fields.call(v, buf, true)
	)
	self._is_record = true
	self._json_wire_encoder = Encoder.new(func(v:Dictionary, buf:StreamPeerBuffer):
		for i in range(field_codecs.size()):
			field_codecs[i]._encode_wire(v.get(String(json_names[i])), buf)
	)
	self._decoder = Decoder.new(func(buf:StreamPeerBuffer) -> Variant:
		var values:Array[Variant] = []
		for codec:Codec in field_codecs:
			values.append(codec.decode(buf))
		return self._rmap_f.call(values)
	)
	return self


func _bicast_instance_matches(value:Variant, c_type:Variant) -> bool:
	if not value is Object:
		return false
	if c_type is Script:
		return _script_inherits_from(value.get_script(), c_type)
	return is_instance_of(value, c_type)


func _bicast_field_accessor(field_ref:Variant) -> Callable:
	if field_ref is StringName:
		var field_name:StringName = field_ref as StringName
		return func(instance:Object) -> Variant:
			return instance.get(field_name)

	var bi_ref:CodecBiRef = field_ref as CodecBiRef
	if bi_ref.ref_type == CodecBiRef.RefType.GETTER_NAME and not bi_ref.field_getter.is_null():
		var getter:Callable = bi_ref.field_getter
		return func(_instance:Object) -> Variant:
			return getter.call()

	match bi_ref.field_type:
		FieldType.Method:
			assert(not bi_ref.field_name.is_empty(), "Method fields require a method name.")
			var method_field_name:StringName = bi_ref.field_name
			return func(instance:Object) -> Variant:
				return instance.call(method_field_name)
		FieldType.Field:
			assert(not bi_ref.field_name.is_empty(), "Field references require a field name.")
			var property_name:StringName = bi_ref.field_name
			return func(instance:Object) -> Variant:
				return instance.get(property_name)
	assert(false, "Invalid CodecBiRef field type.")
	return Callable()


func _script_inherits_from(cs:Script, ts:Script) -> bool:
	var current:Script = cs
	while current != null:
		if current == ts:
			return true
		current = current.get_base_script()
	return false


## Converts the source(Encoded) into another type[br]eg: [Code]Codec.INT.map(func(source): return int(result))[/code][br] would result in the inputs being casted as an uint32 
func smap(mapper:Callable) -> Codec:
	var source:Codec = self
	var codec = Codec.new(
		Encoder.new(func(v:Variant, buf:StreamPeerBuffer):source.encode(mapper.call(v), buf)),
		source._decoder
	)
	codec._smap_f = mapper
	codec._json_smap_f = func(v:Variant) -> Variant:
		var mapped:Variant = mapper.call(v)
		if not source._json_smap_f.is_null():
			return source._json_smap_f.call(mapped)
		return mapped
	return codec


## Converts the result(Decoded) into another type and converts it back before encoding[br]eg: [code]Codec.INT.xmap(func(result): return str(result), func(value): return int(value))[/code][br]would result in a string represented by an uint32
func xmap(to:Callable, from:Callable) -> Codec:
	var source:Codec = self
	var codec := Codec.new(
		Encoder.new(func(v:Variant, buf:StreamPeerBuffer):
				source.encode(from.call(v), buf)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				return to.call(source.decode(buf))
				)
	)
	codec._smap_f = from
	codec._rmap_f = to
	codec._is_record = source._is_record
	codec._wire_encoder = source._wire_encoder
	codec._json_wire_encoder = source._json_wire_encoder
	codec._json_smap_f = func(v:Variant) -> Variant:
		var mapped:Variant = from.call(v)
		if not source._json_smap_f.is_null():
			return source._json_smap_f.call(mapped)
		return mapped
	return codec

## Sets the size of an encoded "length-prefixed" element in bits. [br]
## For example, Codec.arrayof(...).with_length_encoding(Codec.LengthEncoding.INT8) will use a
## single byte for the length of an array. Of course, 
func with_length_encoding(p_length_encoding:LengthEncoding = LengthEncoding.INT32) -> Codec:
	self._length_encoding = p_length_encoding
	return self

## Sets this codec to be optional. Identical to calling Codec.optional(..., default)
func with_optional(default:Variant) -> Codec:
	return optional(self, default)

func with_nullable() -> Codec:
	return nullable(self)

func _decode_length(buf:StreamPeerBuffer) -> int:
	match(self._length_encoding):
		LengthEncoding.INT8: return buf.get_u8()
		LengthEncoding.INT16: return buf.get_u16()
		LengthEncoding.INT32: return buf.get_u32()
		LengthEncoding.INT64: return buf.get_u64()
		_:assert(false, "Length encoding was not valid: " + str(self._length_encoding))
	return 0

const __tostring_lh : String = "<Codec:"
const __tostring_rh : String = ">"
func _to_string() -> String:
	return __tostring_lh + get_name() + __tostring_rh

func _encode_length(buf:StreamPeerBuffer, length:int):
	match(self._length_encoding):
		LengthEncoding.INT8: 
			assert(length <= INT8_MAX, "Length encoding exceeded bounds: " + str(INT8_MAX))
			buf.put_u8(length)
		LengthEncoding.INT16: 
			assert(length <= INT16_MAX, "Length encoding exceeded bounds: " + str(INT16_MAX))
			buf.put_u16(length)
		LengthEncoding.INT32: 
			assert(length <= INT32_MAX, "Length encoding exceeded bounds: " + str(INT32_MAX))
			buf.put_u32(length)
		LengthEncoding.INT64: 
			assert(length <= INT64_MAX, "Length encoding exceeded bounds: " + str(INT64_MAX))
			buf.put_u64(length)
		_:assert(false, "Length encoding was not valid: " + str(self._length_encoding))
## Which field format to prefer
## [br] Method: Will attempt to use the method name using instance.call(field)
## [br] Field: Will attempt to use the field name using instance.get(field)
enum FieldType {
	Method, Field
}
## Creates a field reference for [method Codec.bicast]. If [param name] is empty,
## the JSON name is inferred from [param field]; method names beginning with
## [code]get_[/code], [code]has_[/code], or [code]is_[/code] have that prefix removed.
static func field(field:Variant, type:FieldType=FieldType.Field, name : String = String()) -> CodecBiRef:
	var biref : CodecBiRef = CodecBiRef.new()
	assert(field is Callable or field is StringName or field is String, "Codec.field must be either a StringName or a Callable getter!")
	var field_name:StringName
	if field is Callable:
		assert(field.get_argument_count() == 0, "Getter field for Codec.field cannot have arguments! It must be a getter!")
		biref.ref_type = CodecBiRef.RefType.GETTER_NAME
		biref.field_getter = field
		biref.field_name = field.get_method()
		biref.field_type = type
		field_name = biref.field_name
	elif field is StringName or field is String:
		biref.ref_type = CodecBiRef.RefType.NAME
		biref.field_name = field as StringName
		biref.field_type = type
		field_name = biref.field_name
	biref.json_name = StringName(name) if not name.is_empty() else _json_name_from_field(field_name, field is Callable or type == FieldType.Method)
	return biref


static func _json_name_from_field(field_name:StringName, is_method:bool) -> StringName:
	var name:String = String(field_name)
	if is_method:
		for prefix:String in ["get_", "has_", "is_"]:
			if name.begins_with(prefix) and name.length() > prefix.length():
				name = name.substr(prefix.length())
				break
	return StringName(name)


class CodecBiRef extends RefCounted:
	var field_name : StringName
	var json_name : StringName
	var field_getter : Callable
	var ref_type : RefType
	var field_type : FieldType
	enum RefType{
		NAME, GETTER, GETTER_NAME
	}
class Encoder:
	var _efunc : Callable
	func _init(efunc:Callable) -> void:
		self._efunc = efunc
	
	
	## Encodes into the buffer
	func encode(v:Variant, buf:StreamPeerBuffer):
		_efunc.call(v, buf)
class Decoder:
	var _dfunc : Callable
	func _init(dfunc:Callable) -> void:
		self._dfunc = dfunc
	
	
	## Decodes the buffer
	func decode(buf:StreamPeerBuffer) -> Variant:
		return _dfunc.call(buf)
## Determines how large the length of an array type should be in bits
enum LengthEncoding {
	## Encodes length into 1 byte
	INT8,
	## Encodes length into 2 bytes
	INT16,
	## Encodes length into 4 bytes
	INT32,
	## Encodes length into 8 bytes
	INT64
}

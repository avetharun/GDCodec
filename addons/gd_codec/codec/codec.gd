@tool
## Serialization / Deserialization format creation
class_name Codec
extends RefCounted
var _encoder : Encoder
var _decoder : Decoder
var _wire_encoder : Encoder
var _is_record:bool = false
## Enum (64-bit unsigned)
static var ENUM : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_u64(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_u64())
)
## Long (64-bit unsigned)
static var LONG : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_u64(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_u64())
)
## Int (32-bit unsigned)
static var INT : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_u32(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_u32())
)
## Short (16-bit unsigned)
static var SHORT : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_u16(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_u16())
)
## Byte (8-bit unsigned)
static var BYTE : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_u8(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_u8())
)
## Long (64-bit signed)
static var SIGNED_LONG : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_64(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_64())
)
## Int (32-bit signed)
static var SIGNED_INT : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_32(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_32())
)
## Short (16-bit signed)
static var SIGNED_SHORT : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_16(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_16())
)
## Byte (8-bit signed)
static var SIGNED_BYTE : Codec = Codec.new(
		Encoder.new(func(v:int, buf:StreamPeerBuffer): buf.put_8(v as int)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_8())
)
## Double
static var DOUBLE : Codec = Codec.new(
		Encoder.new(func(v:float, buf:StreamPeerBuffer): buf.put_double(v)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_double())
)
## Float
static var FLOAT : Codec = Codec.new(
		Encoder.new(func(v:float, buf:StreamPeerBuffer): buf.put_float(v)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_float())
)
## Boolean (8-bit unsigned)
## [br] Note: this is not a bitmask
static var BOOL : Codec = Codec.new(
		Encoder.new(func(v:bool, buf:StreamPeerBuffer): buf.put_u8(1 if v else 0)), 
		Decoder.new(func(buf:StreamPeerBuffer): return true if buf.get_u8() == 1 else false)
)
## Length-prefixed String
static var STRING : Codec = Codec.new(
		Encoder.new(func(v:String, buf:StreamPeerBuffer): buf.put_utf8_string(v)), 
		Decoder.new(func(buf:StreamPeerBuffer): return buf.get_utf8_string())
)
## Variant of [member Codec.STRING] that will convert into a StringName automatically
static var STRING_NAME: Codec = STRING.xmap(
		func(source: String) -> StringName: return StringName(source),
		func(destination: StringName) -> String: return String(destination)
)
## Array of Longs (64-bit unsigned)
static var LONG_ARRAY : Codec = arrayof(LONG)
## Array of Ints (32-bit unsigned)
static var INT_ARRAY : Codec = arrayof(INT)
## Array of Shorts (16-bit unsigned)
static var SHORT_ARRAY : Codec = arrayof(SHORT)
## Array of Longs (64-bit signed)
static var SIGNED_LONG_ARRAY : Codec = arrayof(SIGNED_LONG)
## Array of Ints (32-bit signed)
static var SIGNED_INT_ARRAY : Codec = arrayof(SIGNED_INT)
## Array of Shorts (16-bit signed)
static var SIGNED_SHORT_ARRAY : Codec = arrayof(SIGNED_SHORT)
## Array of Bytes (8-bit signed)
static var SIGNED_BYTE_ARRAY : Codec = arrayof(SIGNED_BYTE)
## Array of Doubles
static var DOUBLE_ARRAY : Codec = arrayof(DOUBLE)
## Array of Floats
static var FLOAT_ARRAY : Codec = arrayof(FLOAT)
## Array of Booleans (8-bit unsigned)
static var BOOL_ARRAY : Codec = arrayof(BOOL)
## Array of length-prefixed Strings
static var STRING_ARRAY : Codec = arrayof(STRING)
## Array of Bytes (8-bit unsigned)
static var BYTE_ARRAY : Codec = Codec.new(
	Encoder.new(func(v:PackedByteArray, buf:StreamPeerBuffer):
			buf.put_u32(v.size())
			buf.put_data(v)
			),
	Decoder.new(func(buf:StreamPeerBuffer):
			var len:int = buf.get_u32()
			var result:Array = buf.get_data(len)
			return result[1]
			)
)

## Creates a readable array/span of bytes of a set length
static func byte_span(length:int):
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
	return optional(codec)


## Creates a codec for nullable values.
static func optional(codec:Codec) -> Codec:
	return Codec.new(
		Encoder.new(func(v:Variant, buf:StreamPeerBuffer):
				if v == null:
					buf.put_u8(0)
					return
				buf.put_u8(1)
				codec.encode(v, buf)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var marker:int = buf.get_u8()
				assert(marker == 0 or marker == 1)
				if marker == 0:
					return null
				return codec.decode(buf)
				)
	)


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
	return Codec.new(
		Encoder.new(func(v:String, buf:StreamPeerBuffer):
				var data:PackedByteArray = v.to_utf8_buffer()
				assert(data.size() <= max_length)
				buf.put_u32(data.size())
				buf.put_data(data)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var len:int = buf.get_u32()
				assert(len <= max_length)
				var result:Array = buf.get_data(len)
				return result[1].get_string_from_utf8()
				)
	)

## Creates an array of codecs, formatted as NUM32[...]
static func arrayof(codec:Codec) -> Codec:
	var array_codec := Codec.new(
		Encoder.new(func(v:Array[Variant], buf:StreamPeerBuffer):
				var len : int = v.size()
				buf.put_u32(len)
				for i in range(len):
					var cv : Variant = v.get(i)
					codec.encode(cv, buf)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var len = buf.get_u32()
				var values:Array[Variant] = []
				for i in range(len):
					values.append(codec.decode(buf))
				return values
				)
	)
	array_codec._wire_encoder = Encoder.new(func(v:Array[Variant], buf:StreamPeerBuffer):
			buf.put_u32(v.size())
			for value in v:
				codec._encode_wire(value, buf)
			)
	return array_codec


## Creates an array codec that rejects more than max_length elements during encoding or decoding
static func limited_array(codec:Codec, max_length:int) -> Codec:
	assert(max_length >= 0)
	return Codec.new(
		Encoder.new(func(v:Array[Variant], buf:StreamPeerBuffer):
				assert(v.size() <= max_length)
				buf.put_u32(v.size())
				for value in v:
					codec.encode(value, buf)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var len:int = buf.get_u32()
				assert(len <= max_length)
				var values:Array[Variant] = []
				for i in range(len):
					values.append(codec.decode(buf))
				return values
				)
	)


## Creates a length-prefixed map codec using separate codecs for keys and values.[br]Effectively just a Dictionary wrapper for codecs 
static func mapof(key_codec:Codec, value_codec:Codec) -> Codec:
	return Codec.new(
		Encoder.new(func(v:Dictionary, buf:StreamPeerBuffer):
				buf.put_u32(v.size())
				for key in v:
					key_codec.encode(key, buf)
					value_codec.encode(v[key], buf)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var len:int = buf.get_u32()
				var values:Dictionary = {}
				for i in range(len):
					var key:Variant = key_codec.decode(buf)
					values[key] = value_codec.decode(buf)
				return values
				)
	)


## Creates a record codec that encodes fields in the dictionary's declaration order.[br]This can be used to serialize from and to class objects, similarly to var_to_bytes
static func record(fields:Dictionary) -> Codec:
	var field_names:Array = fields.keys()
	var codec : Codec = Codec.new(
		Encoder.new(func(v:Dictionary, buf:StreamPeerBuffer):
				for field_name in field_names:
					var field_codec:Codec = fields[field_name]
					field_codec.encode(v.get(field_name), buf)
				),
		Decoder.new(func(buf:StreamPeerBuffer):
				var value:Dictionary = {}
				for field_name in field_names:
					var field_codec:Codec = fields[field_name]
					value[field_name] = field_codec.decode(buf)
				return value
				)
	)
	codec._is_record = true
	codec._wire_encoder = Encoder.new(func(v:Dictionary, buf:StreamPeerBuffer):
			for field_name in field_names:
				var field_codec:Codec = fields[field_name]
				field_codec._encode_wire(v.get(field_name), buf)
			)
	return codec


func _init(c_encoder:Encoder, c_decoder:Decoder) -> void:
	self._encoder = c_encoder
	self._decoder = c_decoder
	self._wire_encoder = c_encoder

## Encodes into the supplied buffer
func encode(v:Variant, buf:StreamPeerBuffer):
	_encoder.encode(v, buf)


func _encode_wire(v:Variant, buf:StreamPeerBuffer):
	_wire_encoder.encode(v, buf)

## Decodes from the supplied buffer
func decode(buf:StreamPeerBuffer)->Variant:
	return _decoder.decode(buf)


## Converts the result(Decoded) into another type[br]eg: [code]Codec.INT.map(func(result): return str(result))[/code][br]would result in a string represented by an uint32
func rmap(mapper:Callable) -> Codec:
	var source:Codec = self
	return Codec.new(
		source._encoder,
		Decoder.new(func(buf:StreamPeerBuffer):return mapper.call(source.decode(buf)))
	)


## Converts the source(Encoded) into another type[br]eg: [Code]Codec.INT.map(func(source): return int(result))[/code][br] would result in the inputs being casted as an uint32 
func smap(mapper:Callable) -> Codec:
	var source:Codec = self
	return Codec.new(
		Encoder.new(func(v:Variant, buf:StreamPeerBuffer):source.encode(mapper.call(v), buf)),
		source._decoder
	)


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
	codec._is_record = source._is_record
	codec._wire_encoder = source._wire_encoder
	return codec


class Encoder:
	var _efunc : Callable
	func _init(efunc:Callable) -> void:
		self._efunc = efunc
	func encode(v:Variant, buf:StreamPeerBuffer):
		_efunc.call(v, buf)
class Decoder:
	var _dfunc : Callable
	func _init(dfunc:Callable) -> void:
		self._dfunc = dfunc
	func decode(buf:StreamPeerBuffer) -> Variant:
		return _dfunc.call(buf)

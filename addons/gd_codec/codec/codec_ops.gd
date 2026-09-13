@tool
@abstract
## Base class for codec parsers and encoders
class_name CodecOps
extends Resource
## Operator for encoding and decoding JSON files and Dictionaries
static var JSON_OPS = preload("uid://0ndcitn5ibtt").new()
## Operator for encoding and decoding raw byte blobs
static var BYTE_BUFFER_OPS = preload("uid://y4y8twf4m6kn").new()
## Operator for encoding and decoding [ConfigFile]
static var CONFIG_OPS = preload("uid://blxjbsy3xdi1y").new()

## Encodes using the supplied buffer
@abstract func encode_buffer(codec:Codec, buf:StreamPeerBuffer) -> StreamPeerBuffer

## Decodes using the supplied buffer
@abstract func decode_buffer(codec:Codec, buf:StreamPeerBuffer) -> Variant

## Decodes using the supplied String
func decode_string(codec:Codec, buf:String):
	var b = StreamPeerBuffer.new()
	b.data_array=buf.to_utf8_buffer()
	return decode_buffer(codec, b)

## Encodes using the supplied value
@abstract func encode(codec:Codec, value:Variant) -> StreamPeerBuffer

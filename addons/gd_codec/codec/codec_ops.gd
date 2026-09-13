@tool
@abstract
class_name CodecOps
extends Resource
## Base class for codec parsers and encoders
static var JSON_OPS := CodecOpJson.new()
static var BYTE_BUFFER_OPS := CodecOpsByteBuffer.new()
static var CONFIG_OPS := CodecOpsConfigFile.new()

@abstract func encode_buffer(codec:Codec, buf:StreamPeerBuffer) -> StreamPeerBuffer


@abstract func decode_buffer(codec:Codec, buf:StreamPeerBuffer) -> Variant


func decode_string(codec:Codec, buf:String):
	var b = StreamPeerBuffer.new()
	b.data_array=buf.to_utf8_buffer()
	return decode_buffer(codec, b)


@abstract func encode(codec:Codec, value:Variant) -> StreamPeerBuffer

class_name CodecOpJson extends CodecOps


func encode_buffer(codec:Codec, buf:StreamPeerBuffer) -> StreamPeerBuffer:
	assert(codec._is_record)
	var value : Variant = codec.decode(buf)
	if not codec._json_smap_f.is_null():
		value = codec._json_smap_f.call(value)
	else:
		var smap:Callable = codec.get_smap()
		if not smap.is_null():
			value = smap.call(value)
	var b = StreamPeerBuffer.new()
	b.put_data(JSON.stringify(value).to_utf8_buffer())
	return b


func decode_buffer(codec:Codec, buf:StreamPeerBuffer) -> Variant:
	assert(codec._is_record)
	var parser : JSON = JSON.new()
	var error : Error = parser.parse(buf.data_array.get_string_from_utf8())
	assert(error == OK)
	var binary : StreamPeerBuffer = StreamPeerBuffer.new()
	if codec._json_wire_encoder != null:
		codec._json_wire_encoder.encode(parser.data, binary)
	else:
		codec._encode_wire(parser.data, binary)
	binary.seek(0)
	return codec.decode(binary)

## Decodes from a Dictionary
func decode_dict(codec:Codec, dict:Dictionary) -> Variant:
	return decode_string(codec, JSON.stringify(dict))

func encode(codec:Codec, value:Variant) -> StreamPeerBuffer:
	assert(codec._is_record)
	var b = StreamPeerBuffer.new()
	codec.encode(value, b)
	b.seek(0)
	return encode_buffer(codec, b)

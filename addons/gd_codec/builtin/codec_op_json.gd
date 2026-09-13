class_name CodecOpJson extends CodecOps


func encode_buffer(codec:Codec, buf:StreamPeerBuffer) -> StreamPeerBuffer:
	assert(codec.is_record)
	var value : Variant = codec.decode(buf)
	var b = StreamPeerBuffer.new()
	b.put_data(JSON.stringify(value).to_utf8_buffer())
	return b


func decode_buffer(codec:Codec, buf:StreamPeerBuffer) -> Variant:
	assert(codec.is_record)
	var parser : JSON = JSON.new()
	var error : Error = parser.parse(buf.data_array.get_string_from_utf8())
	assert(error == OK)
	var binary : StreamPeerBuffer = StreamPeerBuffer.new()
	codec.encode_wire(parser.data, binary)
	binary.seek(0)
	return codec.decode(binary)


func encode(codec:Codec, value:Variant) -> StreamPeerBuffer:
	assert(codec.is_record)
	var b = StreamPeerBuffer.new()
	codec.encode(value, b)
	b.seek(0)
	return encode_buffer(codec, b)

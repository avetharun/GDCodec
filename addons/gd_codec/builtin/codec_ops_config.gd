class_name CodecOpsConfigFile extends CodecOps

const SECTION : String = "data"


func encode_buffer(codec:Codec, buf:StreamPeerBuffer) -> StreamPeerBuffer:
	assert(codec.is_record)
	var value:Dictionary = codec.decode(buf)
	var config := ConfigFile.new()
	for key in value:
		config.set_value(SECTION, key, value[key])
	var result := StreamPeerBuffer.new()
	result.put_data(config.encode_to_text().to_utf8_buffer())
	return result


func decode_buffer(codec:Codec, buf:StreamPeerBuffer) -> Variant:
	assert(codec.is_record)
	var config := ConfigFile.new()
	var error:Error = config.parse(buf.data_array.get_string_from_utf8())
	assert(error == OK)
	var value:Dictionary = {}
	for key in config.get_section_keys(SECTION):
		value[key] = config.get_value(SECTION, key)
	var binary := StreamPeerBuffer.new()
	codec.encode(value, binary)
	binary.seek(0)
	return codec.decode(binary)


func encode(codec:Codec, value:Variant) -> StreamPeerBuffer:
	assert(codec.is_record)
	var binary := StreamPeerBuffer.new()
	codec.encode(value, binary)
	binary.seek(0)
	return encode_buffer(codec, binary)

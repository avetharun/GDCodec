class_name CodecOpsByteBuffer extends CodecOps


func encode_buffer(codec:Codec, buf:StreamPeerBuffer) -> StreamPeerBuffer:
	return buf


func decode_buffer(codec:Codec, buf:StreamPeerBuffer) -> Variant:
	return codec.decode(buf)


func encode(codec:Codec, value:Variant) -> StreamPeerBuffer:
	var buf := StreamPeerBuffer.new()
	codec.encode(value, buf)
	buf.seek(0)
	return encode_buffer(codec, buf)

## A variant of [Codec] that represents a mapping to and from a [CNetPacket].[br]
## For an example on how to use this, 
class_name PacketCodec
extends Codec
## Creates a new PacketCodec.
## Params require pairs of Codec and Field(s) in the following format:
## [CODEC_TYPE, &"field_name"]
## eg: [Codec.INT, &"player_id", Codec.STRING, &"player_name", ...]
## A full example of a PacketCodec can be represented as follows:
## [code]var player_info_codec:PacketCodec = PacketCodec.new([Codec.INT, &"player_id", Codec.STRING, &"player_name"], PlayerEntity)[/code]
func _init(bi_pairs : Array[Variant], c_type:Script, c_ctor : Callable = Callable()) -> void:
	## c_type != CNetPacket ensures CNetPacket is never assigned, as it is both automatically invalid for usage and cannot be initialized.
	assert(c_type != CNetPacket and _script_inherits_from(c_type, CNetPacket), "%s must inherit from CNetPacket." % c_type.get_global_name())
	self._bicast_map(bi_pairs, c_type, c_ctor)


var _p_ref : PacketCodecReference = null
func _register(p_ref : PacketCodecReference) -> PacketCodec:
	_p_ref = p_ref
	return self
## Returns whether the packet bicoders are valid
func is_valid() -> bool:
	return self._encoder != null and self._decoder != null and _p_ref != null and _p_ref.id != PacketRegistry.INVALID_PACKET_ID_HASH
## Returns the registered packet's hash. Used when sending packets. See: [method PacketRegistry.register]
func get_packet_id_hash() -> int:
	return _p_ref.id
func get_packet_id() -> StringName:
	return _p_ref.key
func encode_packet(v:CNetPacket, _prefix_packet_id:bool = true, spb:StreamPeerBuffer = StreamPeerBuffer.new()) -> StreamPeerBuffer:
	if _prefix_packet_id:
		spb.put_u64(_p_ref.id)
	_encoder.encode(v, spb)
	return spb
func decode_packet(spb:StreamPeerBuffer) -> CNetPacket:
	return _decoder.decode(spb) as CNetPacket

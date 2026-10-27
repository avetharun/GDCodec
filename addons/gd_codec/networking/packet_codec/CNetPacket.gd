## Represents an actual object that can be serialized and deserialized from a UDP/TCP [PacketCodec] buffer.
## Classes that extend from this must contain a static [constant CNetPacket.CODEC
@abstract class_name CNetPacket extends Resource
## Packet ID of the given instance.
var packet_id : int
## Returns whether a given CNetPacket is formatted correctly
static func is_valid_packet_type(packet_type: Script, throw_error:bool = false) -> bool:
	var pt_class_name = packet_type.get_global_name()
	if packet_type and "CODEC" in packet_type:
		var codec_value = packet_type.get("CODEC")
		print(codec_value is PacketCodecReference)
		var bl : bool = \
			codec_value is PacketCodecReference \
			and codec_value != null \
			and (codec_value as PacketCodecReference).value != null \
			and (codec_value as PacketCodecReference).value.is_valid()
		if not bl and throw_error:
			printerr("CNetPacket {0} was malformed. {0}.CODEC exists, but was not of type PacketCodecReference. Please ensure {0}.CODEC is of type PacketCodecReference and is fully initialized!".format([pt_class_name]))
			return false
		return bl
	printerr("CNetPacket {0} was malformed. Please ensure {0}.CODEC exists and is of type PacketCodecReference!".format([pt_class_name]))
	return false
static func get_codec(packet_type: Script)->PacketCodecReference:
	return packet_type.get("CODEC") as PacketCodecReference
func _init() -> void:
	assert(is_valid_packet_type(self.get_script()), "CNetPacket {0} was malformed. Please ensure {0}.CODEC exists and is of type PacketCodecReference!".format([get_script().get_global_name()]))
	var _codec : PacketCodecReference = (self.get_script().get("CODEC") as PacketCodecReference)
	assert(_codec != null, "%s.CODEC was null" % get_script().get_global_name())
	assert(_codec != null and _codec.id != PacketRegistry.INVALID_PACKET_ID_HASH, "%s.CODEC was not registered, or hash is invalid!" % get_script().get_global_name())
	self.packet_id = _codec.id
func recieved():
	pass

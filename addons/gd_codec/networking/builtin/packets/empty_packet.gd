## Empty packet stub. Use this for when you need to reference a valid packet,
## but don't want any actual data to be used.
class_name EmptyCNetPacket
extends CNetPacket
## Empty [PacketCodec]. Takes no parameters, and 
static var CODEC : PacketCodec = PacketCodec.new([], EmptyCNetPacket)
func _init() -> void:
	push_warning("Initialized EmptyCNetPacket")

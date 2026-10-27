## Autoload for the packet types you may use
extends Node
static func _static_init() -> void:
	assert(PacketRegistry.bidi_disconnect_packet != null)
	assert(PacketRegistry.bidi_custom_packet != null)
# # Example of a packet:
# # Note: CustomPacketType can be any other type, 
#class CustomPacketType extends RefCounted:
#	var text : String
#	func _init(p_text : String) -> void:
#		self.text = p_text
#static var PACKET_NAME : PacketCodecReference = PacketRegistry.register(
#	&"packet_name", PacketCodec.new([Codec.STRING, &"text"], CustomPacketType)
#	)

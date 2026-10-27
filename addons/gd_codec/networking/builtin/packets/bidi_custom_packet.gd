## Used to send arbitrary (custom) data over [PacketCodecENetPeer]
class_name BiDiCustomPacket extends CNetPacket
## [code]PacketCodec{"data":Codec.VARIANT}[/code]
static var CODEC : PacketCodec = PacketCodec.new(
	[Codec.VARIANT, &"data"],
	BiDiCustomPacket
)
## Custom data recieved or sent from the peer
var data : Variant = null


## Creates a [BiDiCustomPacket] from custom data
func _init(p_data:Variant) -> void:
	self.data = p_data

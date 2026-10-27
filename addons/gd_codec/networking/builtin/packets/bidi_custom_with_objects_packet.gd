## Used to send arbitrary (custom) data with objects over [PacketCodecENetPeer][br]
## Note: This is much more dangerous than [BiDiCustomPacket] due to the possibility of running arbitrary user code.
## Use only if you know it's safe to! (which in most cases, it's not)
class_name BiDiCustomWithObjectsPacket extends CNetPacket
## [code]PacketCodec{"data":Codec.VARIANT_WITH_OBJECTS}[/code]
static var CODEC : PacketCodec = PacketCodec.new(
	[Codec.VARIANT_WITH_OBJECTS, &"data"],
	BiDiCustomWithObjectsPacket
)
## Custom data recieved or sent from the peer
var data : Variant = null

## Creates a [BiDiCustomWithObjectsPacket] from custom data
func _init(p_data:Variant) -> void:
	self.data = p_data

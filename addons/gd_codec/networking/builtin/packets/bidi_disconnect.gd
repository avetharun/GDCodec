class_name BiDiDisconnectPacket extends CNetPacket
## [code]PacketCodec{"disconnect_reason":Codec.STRING}[/code]
static var CODEC : PacketCodec = PacketCodec.new([
	Codec.STRING, &"disconnect_reason"
], BiDiDisconnectPacket)
const DEFAULT_DISCONNECT_REASON : String = "Unknown Disconnect Reason"
## Reason for the disconnect
var disconnect_reason : String = "Unknown Disconnect Reason"


## Constructs a disconnect packet with a supplied reason
func _init(p_disconnect_reason:String) -> void:
	self.disconnect_reason = p_disconnect_reason

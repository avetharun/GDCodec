class_name PacketCodecReference extends RefCounted

var value : PacketCodec
var key : StringName
var id : int

## Emitted when this packet is recieved by a peer.[br]
## Called after [signal PacketCodecENetPeer.packet_received]
signal recieved(peer:int, packet:CNetPacket)
func encode_packet(v:CNetPacket, _prefix_packet_id:bool = true, spb:StreamPeerBuffer = StreamPeerBuffer.new()) -> StreamPeerBuffer:
	return value.encode_packet(v, _prefix_packet_id, spb)
func decode_packet(spb:StreamPeerBuffer) -> CNetPacket:
	return value.decode_packet(spb)

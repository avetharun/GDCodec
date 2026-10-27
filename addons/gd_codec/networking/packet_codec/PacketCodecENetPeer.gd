## [b]A MultiplayerPeer implementation using [ENetMultiplayerPeer] as a basis.[/b]
## [br]
## A MultiplayerPeer implementation specifically meant to be used with [PacketCodec], [CNetPacket] and [PacketRegistry] that should be passed to [member MultiplayerAPI.multiplayer_peer]
## after being initialized as either a client, server, or mesh. Events can then be handled by
## connecting to [MultiplayerAPI] signals. See [ENetConnection] for more information on the ENet
## library wrapper.[br]
## [b]Note:[/b] ENet only uses UDP, not TCP. When forwarding the server port to make your server accessible on the public Internet, you only need to forward the server port in UDP. You can use the [UPNP] class to try to forward the server port automatically when starting the server.
class_name PacketCodecENetPeer extends ENetMultiplayerPeer
## Emitted when [PacketCodecENetPeer] recieves a [CNetPacket][br]
## To assign a callback to a specific packet type, use [signal PacketCodecReference.recieved][br]
## Called before [signal PacketCodecReference.recieved]
signal packet_received(sender_peer_id: int, packet: CNetPacket)
## Specifically called when the peer recieves a [BiDiDisconnectPacket], not to be confused with
## [signal MultiplayerAPI.peer_disconnected]
signal disconnect_packet_received(sender_peer_id: int, reason: String)

## Reference to the [SceneMultiplayer] to be used when packets are recieved
var multiplayer_api: SceneMultiplayer:
	set(value):
		if multiplayer_api != null and multiplayer_api.peer_packet.is_connected(_on_peer_packet):
			multiplayer_api.peer_packet.disconnect(_on_peer_packet)
		multiplayer_api = value
		if multiplayer_api != null and not multiplayer_api.peer_packet.is_connected(_on_peer_packet):
			multiplayer_api.peer_packet.connect(_on_peer_packet)
## Sends a [CNetPacket] to a given peer
func send(target_peer: int, cnp: CNetPacket, transfer_mode: int = MultiplayerPeer.TRANSFER_MODE_RELIABLE, transfer_channel: int = 0) -> Error:
	if cnp == null:
		push_error("Cannot send a null CNetPacket.")
		return ERR_INVALID_PARAMETER
	if multiplayer_api == null:
		push_error("PacketCodecENetPeer must be assigned to an active SceneMultiplayer before sending.")
		return ERR_UNCONFIGURED
	var packet_codec: PacketCodecReference = PacketRegistry.get_packet_codec(cnp.packet_id)
	if packet_codec == null:
		push_error("No packet codec is registered for packet ID %d." % cnp.packet_id)
		return ERR_DOES_NOT_EXIST
	var buffer: StreamPeerBuffer = packet_codec.encode_packet(cnp)
	return multiplayer_api.send_bytes(buffer.data_array, target_peer, transfer_mode, transfer_channel)
## Disconnect a peer, optionally with a reason
func disconnect_client(target_peer: int, reason: String = BiDiDisconnectPacket.DEFAULT_DISCONNECT_REASON) -> Error:
	var disconnect_codec: PacketCodecReference = PacketRegistry.bidi_disconnect_packet
	if disconnect_codec == null:
		push_error("The bidirectional disconnect packet is not registered.")
		return ERR_DOES_NOT_EXIST
	if multiplayer_api == null:
		push_error("PacketCodecENetPeer must be assigned to an active SceneMultiplayer before disconnecting a client.")
		return ERR_UNCONFIGURED
	var disconnect_packet: BiDiDisconnectPacket = BiDiDisconnectPacket.new(reason)
	var send_error: Error = send(target_peer, disconnect_packet)
	if send_error != OK:
		return send_error
	multiplayer_api.disconnect_peer(target_peer)
	return OK

func _on_peer_packet(sender_peer_id: int, packet_data: PackedByteArray) -> void:
	if packet_data.size() < 8:
		push_error("Received packet is too small to contain a packet ID.")
		return

	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = packet_data
	var packet_id: int = buffer.get_u64()
	var packet_codec: PacketCodecReference = PacketRegistry.get_packet_codec(packet_id)
	if packet_codec == null:
		push_error("No packet codec is registered for received packet ID %d." % packet_id)
		return

	var cnp: CNetPacket = packet_codec.decode_packet(buffer)
	var disconnect_codec: PacketCodecReference = PacketRegistry.bidi_disconnect_packet
	if disconnect_codec != null and packet_id == disconnect_codec.id:
		if multiplayer_api == null:
			push_error("Cannot process disconnect packet without an active SceneMultiplayer.")
			return
		multiplayer_api.disconnect_peer(sender_peer_id)
		disconnect_packet_received.emit(sender_peer_id, (cnp as BiDiDisconnectPacket).disconnect_reason)
		return
	packet_received.emit(sender_peer_id, cnp)
	PacketRegistry.get_packet_codec(packet_id).recieved.emit(sender_peer_id, cnp)

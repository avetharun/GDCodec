extends Node2D

const PORT: int = 7991
const SERVER_PEER_ID: int = 1

class EchoPacket extends CNetPacket:
	static var CODEC: PacketCodecReference = PacketRegistry.register(&"test_echo_packet", PacketCodec.new([
		Codec.STRING, Codec.STRING.field(&"get_message", Codec.FieldType.Method),
		Codec.BOOL, Codec.BOOL.field(&"is_reply"),
	], EchoPacket))
	var message: String
	var is_reply: bool
	func get_message() -> String:
		return message
	func _init(p_message: String, p_is_reply: bool = false) -> void:
		message = p_message
		is_reply = p_is_reply
		packet_id = CODEC.id


@export var status_label: Label
@export var role_buttons: HBoxContainer
@export var host_button: Button
@export var client_button: Button
@export var echo_button: Button
@export var rpc_button: Button

var peer: PacketCodecENetPeer
var multiplayer_api: SceneMultiplayer
var is_server: bool = false


func _ready() -> void:
	if EchoPacket.CODEC == null:
		_set_status("Could not register the echo packet codec.")
		return
	host_button.pressed.connect(_start_server)
	client_button.pressed.connect(_start_client)
	echo_button.pressed.connect(_send_echo)
	rpc_button.pressed.connect(_send_rpc_echo)
	echo_button.disabled = true
	rpc_button.disabled = true


func _process(_delta: float) -> void:
	if multiplayer_api == null:
		return

	var remote_available: bool = _has_connected_remote()
	echo_button.disabled = not remote_available
	rpc_button.disabled = not remote_available

func _start_server() -> void:
	role_buttons.hide()
	is_server = true
	peer = PacketCodecENetPeer.new()
	var error: Error = peer.create_server(PORT, 1)
	if error != OK:
		peer = null
		is_server = false
		role_buttons.show()
		_set_status("Could not host port %d: %s. Choose Client if another instance is hosting." % [PORT, error_string(error)])
		return
	_activate_peer()
	if multiplayer_api == null:
		return
	_set_status("Hosting on port %d. Start another instance with --client." % PORT)


func _start_client() -> void:
	role_buttons.hide()
	is_server = false
	_set_status("Connecting to 127.0.0.1:%d..." % PORT)
	peer = PacketCodecENetPeer.new()
	var error: Error = peer.create_client("127.0.0.1", PORT)
	if error != OK:
		peer = null
		_set_status("Could not connect to port %d: %s" % [PORT, error_string(error)])
		return
	_activate_peer()
	if multiplayer_api == null:
		return
	_set_status("Connecting to 127.0.0.1:%d..." % PORT)


func _activate_peer() -> void:
	multiplayer_api = get_tree().get_multiplayer() as SceneMultiplayer
	if multiplayer_api == null:
		peer = null
		_set_status("The active MultiplayerAPI is not a SceneMultiplayer.")
		return
	peer.multiplayer_api = multiplayer_api
	peer.packet_received.connect(_on_packet_received)
	peer.disconnect_packet_received.connect(_on_disconnect_packet_received)
	multiplayer_api.peer_connected.connect(_on_peer_connected)
	multiplayer_api.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer_api.connected_to_server.connect(_on_connected_to_server)
	multiplayer_api.connection_failed.connect(_on_connection_failed)
	multiplayer_api.server_disconnected.connect(_on_server_disconnected)
	multiplayer_api.multiplayer_peer = peer


func _on_packet_received(sender_id: int, packet: CNetPacket) -> void:
	if packet is EchoPacket:
		_handle_echo(packet as EchoPacket, sender_id)


func _on_disconnect_packet_received(sender_id: int, reason: String) -> void:
	_set_status("Peer %d disconnected: %s" % [sender_id, reason])


func _handle_echo(packet: EchoPacket, sender_id: int) -> void:
	if packet.is_reply:
		_set_status("Echo reply from %s: %s" % [_remote_role_name(), packet.message])
		return

	_set_status("Echo request from %s: %s. Replying..." % [_remote_role_name(), packet.message])
	var error: Error = peer.send(sender_id, EchoPacket.new(packet.message, true))
	if error != OK:
		_set_status("Failed to reply to peer %d: %s" % [sender_id, error_string(error)])


func _send_echo() -> void:
	var target_peer_id: int = _get_remote_peer_id()
	if target_peer_id == 0:
		_set_status("No connected peer is available to receive the echo.")
		return
	var error: Error = peer.send(target_peer_id, EchoPacket.new("Echo from %s" % _local_role_name()))
	if error != OK:
		_set_status("Failed to send echo: %s" % error_string(error))
	else:
		_set_status("Echo sent to %s; waiting for reply..." % _remote_role_name())


func _send_rpc_echo() -> void:
	var target_peer_id: int = _get_remote_peer_id()
	if target_peer_id == 0:
		_set_status("No connected peer is available for the RPC test.")
		return

	var message: String = "RPC echo from %s" % _local_role_name()
	var error: Error = rpc_id(target_peer_id, "_rpc_echo_request", message)
	if error != OK:
		_set_status("Failed to send RPC echo: %s" % error_string(error))
	else:
		_set_status("RPC echo sent to %s; waiting for reply..." % _remote_role_name())


@rpc("any_peer", "call_remote", "reliable")
func _rpc_echo_request(message: String) -> void:
	var sender_peer_id: int = multiplayer.get_remote_sender_id()
	var sender_role: String = _role_for_peer_id(sender_peer_id)
	if sender_role != _remote_role_name():
		_set_status("RPC request came from unexpected peer %d (%s)." % [sender_peer_id, sender_role])
		return

	_set_status("RPC request received from %s: %s. Replying..." % [sender_role, message])
	var error: Error = rpc_id(sender_peer_id, "_rpc_echo_reply", message)
	if error != OK:
		_set_status("Failed to send RPC echo reply: %s" % error_string(error))


@rpc("any_peer", "call_remote", "reliable")
func _rpc_echo_reply(message: String) -> void:
	var sender_peer_id: int = multiplayer.get_remote_sender_id()
	var sender_role: String = _role_for_peer_id(sender_peer_id)
	if sender_role != _remote_role_name():
		_set_status("RPC reply came from unexpected peer %d (%s)." % [sender_peer_id, sender_role])
		return
	_set_status("RPC echo reply received from %s: %s" % [sender_role, message])


func _role_for_peer_id(peer_id: int) -> String:
	return "server" if peer_id == SERVER_PEER_ID else "client"


func _has_connected_remote() -> bool:
	if multiplayer_api == null or peer == null:
		return false
	if is_server:
		return not multiplayer_api.get_peers().is_empty()
	return multiplayer_api.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED


func _get_remote_peer_id() -> int:
	if not is_server:
		return SERVER_PEER_ID
	if multiplayer_api == null:
		return 0
	var connected_peers: PackedInt32Array = multiplayer_api.get_peers()
	if connected_peers.is_empty():
		return 0
	return connected_peers[0]


func _local_role_name() -> String:
	return "server" if is_server else "client"


func _remote_role_name() -> String:
	return "client" if is_server else "server"


func _on_peer_connected(peer_id: int) -> void:
	if is_server:
		_set_status("Client peer %d connected. Use Echo to send a packet." % peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	_set_status("Peer %d disconnected." % peer_id)


func _on_connected_to_server() -> void:
	_set_status("Connected to server. Use Echo to send a packet.")


func _on_connection_failed() -> void:
	echo_button.disabled = true
	_set_status("Connection to server failed.")


func _on_server_disconnected() -> void:
	echo_button.disabled = true
	_set_status("Disconnected from server.")


func _set_status(message: String) -> void:
	status_label.text = message
	print(message)

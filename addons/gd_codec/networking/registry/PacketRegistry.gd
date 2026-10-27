class_name PacketRegistry extends Node
const INVALID_PACKET_ID : StringName = StringName()
const INVALID_PACKET_ID_HASH : int = INT64_MIN
static var packets : Dictionary[int, PacketCodecReference] = {}
static func get_packet_codec(pid: int) -> PacketCodecReference:
	return packets.get(pid, null)
static func does_packet_exist(pid: int) -> bool:
	return packets.has(pid)
static func get_packet_codec_named(pid: StringName) -> PacketCodecReference:
	return packets.get(pid.hash(), null)
static func register(key:StringName, codec:PacketCodec) -> PacketCodecReference:
	print("Registering " + key)
	var pc_ref : PacketCodecReference = PacketCodecReference.new()
	pc_ref.id = key.hash()
	pc_ref.key = key
	pc_ref.value = codec._register(pc_ref)
	if pc_ref.value.get_packet_id_hash() == INVALID_PACKET_ID_HASH:
		push_error("Failed to register packet " + (pc_ref.key as String) + ".")
		return
	packets.set(pc_ref.id, pc_ref)
	return pc_ref
static var bidi_disconnect_packet : PacketCodecReference = register(&":bidi_disconnect", BiDiDisconnectPacket.CODEC)
## Wrapper for Codec.VARIANT
static var bidi_custom_packet : PacketCodecReference = register(&":custom", BiDiCustomPacket.CODEC)
## Wrapper for Codec.VARIANT_WITH_OBJECTS[br]
## [color=red]Warning: this packet type is dangerous to use. Uncomment if you know what you're doing![/color]
# Comment this out and uncomment the next line to enable this packet type
static var bidi_custom_with_objects_packet : PacketCodecReference = register(&":custom_with_objects", EmptyCNetPacket.CODEC)
#@onready var bidi_custom_with_objects_packet : PacketCodecReference = register(&":custom_with_objects", BiDiCustomWithObjectsPacket.CODEC)

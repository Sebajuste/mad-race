extends Object

class_name Packet

const AUTH_PACKET = 0x01
const AUTH_PACKET_OK = 0x02
const BUS_PACKET = 0x10
const PING_PACKET = 0x20
const RPC_PACKET = 0x30
const SYNC_PACKET = 0x40
#const PING_PACKET = 0x50

static func create_header(write_stream, id_client, id_packet, type):
	write_stream.serialize_bits(0xFF00FF, 24)
	write_stream.serialize_bits(id_client, 8)
	write_stream.serialize_bits(id_packet, 16)
	write_stream.serialize_bits(type, 8)

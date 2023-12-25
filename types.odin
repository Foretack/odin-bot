package main

import "core:net"

Twitch_Client :: struct {
    connection: net.TCP_Socket,
    username: string,
    user_token: string
}

Create_Client_Result :: union {
    Twitch_Client,
    net.Network_Error
}

Parsing_Error :: enum {
	None,
    Unsupported
}
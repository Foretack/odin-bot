package main

import "core:net"
import "core:fmt"
import "core:strings"

send_raw :: proc(client: Twitch_Client, data: string) -> net.Network_Error {
    buf := transmute([]u8)strings.concatenate([]string { data, "\r\n" })
    written, err := net.send_tcp(client.connection, buf)
    return err
}

join :: proc(client: Twitch_Client, channel: string) -> net.Network_Error {
    buf := transmute([]u8)strings.concatenate([]string { "JOIN #", channel, "\r\n" })
    written, err := net.send_tcp(client.connection, buf)
    return err
}

privmsg :: proc(client: Twitch_Client, channel: string, message: string) -> net.Network_Error {
    buf := transmute([]u8)strings.concatenate([]string { "PRIVMSG #", channel, " :", message, "\r\n" })
    written, err := net.send_tcp(client.connection, buf)
    return err
}

tcp_receive :: proc (client: Twitch_Client, buffer: []u8) -> (read: int, err: net.Network_Error) {
    return net.recv_tcp(client.connection, buffer)
}
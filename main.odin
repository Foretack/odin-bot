package main

import "core:fmt"
import "core:net"
import "core:strings"
import "core:bytes"
import "core:time"

ping_str :: "PING :tmi.twitch.tv"

main :: proc() {
    client: Twitch_Client
    switch res in create("justinfan12345", "oauthGUH") {
        case net.Network_Error:
            fmt.printf("Failed to create Twitch client: %s", res)
            panic("Network Error")

        case Twitch_Client:
            client = res
    }

    join(client, "forsen")
    time.sleep(auto_cast time.duration_milliseconds(30))

    buffer: [4096]u8
    slice: []u8 = buffer[:2048]
    for {
        bytes_read, err := tcp_receive(client, slice)
        if err != nil {
            fmt.printf("Error reading data from Twitch IRC: %s\n", err)
            break
        }

        if bytes_read > 0 {
            process_irc_data(client, buffer[0:bytes_read])
        }
    }

}

process_irc_data :: proc(client: Twitch_Client, data: []u8) {
    // TODO: Account for coupled irc messages
    if strings.contains(transmute(string)data, "PING :tmi.twitch.tv") {
        send_raw(client, "PONG")
        return
    }

    author, content, err := message_info(data)
    if err != nil {
        fmt.printf("Failed to parse: \"%s\" | $s\n", transmute(string)data, err)
        return
    }

    fmt.println(strings.concatenate([]string { author, ": ", content }))
}

message_info :: proc(data: []u8) -> (author: string, content: string, err: Parsing_Error) {
    if data[0] != ':' {
        err = Parsing_Error.Unsupported
        return
    }

    // TODO: Better check for invalid slicing 
    first_cln := bytes.index_byte(data, ':')
    if first_cln == -1 {
        err = Parsing_Error.Unsupported
        return
    }

    last_cln := bytes.index_byte(data[first_cln + 1:], ':') + first_cln + 2
    if last_cln == -1 {
        err = Parsing_Error.Unsupported
        return
    }

    excl := bytes.index_byte(data, '!')
    if excl == -1 {
        err = Parsing_Error.Unsupported
        return
    }

    author = transmute(string)data[first_cln + 1:excl]
    content = transmute(string)data[last_cln:]
    return
}

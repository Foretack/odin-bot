package main

import "core:net"
import "core:fmt"
import "core:strings"

create :: proc(username: string, oauth: string) -> Create_Client_Result {
    connection, err := net.dial_tcp_from_hostname_and_port_string("irc.chat.twitch.tv:6667")
    if err != nil {
        fmt.printf("Error connecting to Twitch IRC: %s\n", err)
        return err
    }
    
    client := Twitch_Client{connection, username, oauth}

    send_raw(client, strings.concatenate([]string{"PASS oauth:", oauth}))
    send_raw(client, strings.concatenate([]string{"NICK ", username}))
    return client
}
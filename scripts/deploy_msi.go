package main

import (
    "code.google.com/p/go.crypto/ssh"
)

func main() {
    // msi := os.Args[1] // the first argument is a command we’ll execute on all servers 

    // initialize the structure with the configuration for ssh packat.
    // makeKeyring() function will be written later
    config := &ssh.ClientConfig{
        User: "ec2-user",
        Auth: []ssh.ClientAuth{makeKeyring()},
    }

    // running one goroutine (light-weight alternative of OS thread) per server,
    // executeCmd() function will be written later
    for _, hostname := range hosts {
        go func(hostname string) {
            results <- executeCmd(cmd, hostname, config)
        }(hostname)
    }

    // collect results from all the servers or print "Timed out",
    // if the total execution time has expired
    for i := 0; i < len(hosts); i++ {
        select {
        case res := <-results:
            fmt.Print(res)
        case <-timeout:
            fmt.Println("Timed out!")
            return
        }
    }
}

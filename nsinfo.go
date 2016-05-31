package main

import (
    "github.com/masami256/nsinfo/libs"
    "flag"
    "os"
)

const (
    ShowAll = iota + 1
    ShowPid
    ShowCount
)

func determineOption() (int, int) {
    var all = flag.Bool("a", false, "show all namespaces information")
    var pid = flag.Int("p",  0, "show pid PID's namespace information")
    var count = flag.Bool("c", false, "count number of inodes in each namespacs")

    flag.Parse()

    if !*all && *pid == 0 && !*count {
        return -1, 0
    }

    if *all {
        return ShowAll, 0
    } else if *pid != 0 {
        return ShowPid, *pid
    }

    return ShowCount, 0
}

func main() {
    t, v := determineOption()
    if t == -1 {
        println("usage: hoge")
        os.Exit(0)
    }

    if !nsinfo.IsRoot() {
        panic("yourn't root")
    }

    if t == ShowAll {
        nsinfo.ShowAllNamespaces()
    } else if t == ShowPid {
        println("pid ", v)
    } else if t == ShowCount {
        println("show count")
    }
}

package nsinfo

import (
    "os"
    "io/ioutil"
    "path/filepath"
    "regexp"
    "fmt"
    "strings"
)

const proc_dir = "/proc"

type NamespaceInfo struct {
    ns map[string]string
}

type ProcessMap struct {
    process map[string]NamespaceInfo
}

func lookupNamespaceDirectory(processes *ProcessMap, pid string) {
    nsdir := filepath.Join(proc_dir, pid, "ns")
    namespaces, err := ioutil.ReadDir(nsdir)

    if err != nil {
        panic("cannot read ns directory")
    }

    nsinfo := NamespaceInfo{}
    nsinfo.ns = map[string]string{}

    for _, ns := range namespaces {
        path := filepath.Join(nsdir, ns.Name())
        value, err := os.Readlink(path)

        if err != nil {
            panic("faild to readlink")
        }
        nsinfo.ns[ns.Name()] = strings.Split(strings.Split(value, "[")[1], "]")[0]
    }
    processes.process[pid] = nsinfo
}

func walkProcDirectory() {
    processes := ProcessMap{}
    processes.process = map[string]NamespaceInfo{}

    files, err := ioutil.ReadDir(proc_dir)
    if err != nil {
        panic("Failed to get directories")
    }

    for _, f := range files {
        if regexp.MustCompile("^[1-9]").Match([]byte(f.Name())) {
            lookupNamespaceDirectory(&processes, f.Name())
        }
    }

    for pid, nsinfo := range processes.process {
        fmt.Printf("pid: %s\n", pid)
        for ns, nsval := range nsinfo.ns {
            fmt.Printf("%s: %s, ", ns, nsval)
        }
        println("")
    }

}

func ShowAllNamespaces() {
    walkProcDirectory()
}

func IsRoot() bool {
    return os.Getuid() == 0
}

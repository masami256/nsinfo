package nsinfo

import (
    "os"
    "io/ioutil"
    "path/filepath"
    "regexp"
    "fmt"
    "strings"
    "bufio"
)

const proc_dir = "/proc"

type NamespaceInfo struct {
    ns map[string]string
}

type ProcInfo struct {
    ppid string
    comm string
}

type ProcessMap struct {
    nsInfo map[string]NamespaceInfo
    procInfo map[string]ProcInfo
}

func readPpid(processes *ProcessMap, pid string) {
    status_file := filepath.Join(proc_dir, pid, "status")

    fp, err := os.Open(status_file)
    if err != nil {
        panic("failed to read status file")
    }

    defer fp.Close()

    scanner := bufio.NewScanner(fp)
    for scanner.Scan() {
        line := scanner.Text()
        if line[0:5] == "PPid:" {
            arr := strings.Split(line, ":")
            fmt.Printf("%s\n", strings.TrimSpace(arr[1]))
            break
        }
    }
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
    processes.nsInfo[pid] = nsinfo
}

func walkProcDirectory() {
    processes := ProcessMap{}
    processes.nsInfo = map[string]NamespaceInfo{}
    processes.procInfo = map[string]ProcInfo{}

    files, err := ioutil.ReadDir(proc_dir)
    if err != nil {
        panic("Failed to get directories")
    }

    for _, f := range files {
        if regexp.MustCompile("^[1-9]").Match([]byte(f.Name())) {
            lookupNamespaceDirectory(&processes, f.Name())
            readPpid(&processes, f.Name())
        }
    }

    for pid, nsinfo := range processes.nsInfo {
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

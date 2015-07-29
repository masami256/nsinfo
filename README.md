# nsinfo

nsinfo is a tool for linux that shows namespace information from procfs.

Namecpaces are exported to procfs. You can see namespaces in /proc/<pid>/ns directory.
The ipc, mnt, net, pid, user, uts files are symbolic link. For instance, ipc file is linked to inode 4026531839.

```
masami@saga:~/codes/nsinfo (master)$ ls -l  /proc/self/ns
total 0
dr-x--x--x. 2 masami masami 0 Jul 29 23:52 ./
dr-xr-xr-x. 8 masami masami 0 Jul 29 23:52 ../
lrwxrwxrwx. 1 masami masami 0 Jul 29 23:52 ipc -> ipc:[4026531839]
lrwxrwxrwx. 1 masami masami 0 Jul 29 23:52 mnt -> mnt:[4026531840]
lrwxrwxrwx. 1 masami masami 0 Jul 29 23:52 net -> net:[4026531969]
lrwxrwxrwx. 1 masami masami 0 Jul 29 23:52 pid -> pid:[4026531836]
lrwxrwxrwx. 1 masami masami 0 Jul 29 23:52 user -> user:[4026531837]
lrwxrwxrwx. 1 masami masami 0 Jul 29 23:52 uts -> uts:[4026531838]
```
So, nsinfo collects data by inode to show who uses the inode.

## how to run

```
sudo ./nsinfo.rb
```

## sample output

nsinfo shows pid, ppid, and comm by inode.

```
inode: 4026532860
               pid            ppid      comm
              2245            2198      chrome
              2265            2245      chrome
              2546            2265      chrome
              2570            2265      chrome
              2576            2265      chrome
              2584            2265      chrome
              2590            2265      chrome
              2601            2265      chrome
              3032            2265      chrome
              3114            2265      chrome
              6847            2265      chrome
              7437            2265      chrome
             10065            2265      chrome
             20524            2265      chrome
inode: 4026532859
               pid            ppid      comm
              2255            2245      nacl_helper
inode: 4026531840
               pid            ppid      comm
                 1               0      systemd
                 2               0      kthreadd
                 3               2      ksoftirqd/0
                 5               2      kworker/0
                 7               2      rcu_sched
                 8               2      rcu_bh
 
```


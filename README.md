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

## options

* -a
  show all namespaces(inode)
  default option

* -p
  show specific pid's namespaces 

* -c
  count number of inodes in each namespacs.\


## how to run

```
sudo ./nsinfo.rb
```

## sample output

nsinfo shows pid, ppid, and comm by inode.

```
             14828               2      kworker/6
             15028               2      kworker/u16
             15192               2      kworker/5
             15397               2      kworker/2
             15527               2      kworker/3
             16570            9001      sudo
             16571           16570      ruby-mri
             18810               2      kworker/0
             19747               2      kworker/4
             23515               2      kworker/2
             27485               1      gvfsd-http
user: inode: 4026532860
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
             10065            2265      chrome
             20524            2265      chrome
user: inode: 4026532859
               pid            ppid      comm
              2255            2245      nacl_helper
mnt: inode: 4026531840
               pid            ppid      comm
                 1               0      systemd
                 2               0      kthreadd
                 3               2      ksoftirqd/0
                 5               2      kworker/0
                 7               2      rcu_sched
                 8               2      rcu_bh
                 9               2      rcuos/0
  
```

count option

```
net: namespace
        inode:4026531969 : 266
        inode:4026532328 : 1
        inode:4026532511 : 13
        inode:4026532571 : 1
        Total: 4
uts: namespace
        inode:4026531838 : 281
        Total: 1
ipc: namespace
        inode:4026531839 : 281
        Total: 1
pid: namespace
        inode:4026531836 : 267
        inode:4026532509 : 2
        inode:4026532390 : 1
>>> cut <<<
        inode:4026532386 : 1
        inode:4026532393 : 1
        Total: 14
user: namespace
        inode:4026531837 : 267
        inode:4026532628 : 13
        inode:4026532627 : 1
        Total: 3
mnt: namespace
        inode:4026531840 : 276
        inode:4026531857 : 1
        inode:4026532201 : 1
        inode:4026532318 : 1
        inode:4026532444 : 1
        inode:4026532504 : 1
        Total: 6
Total processes: 1686
```

pid option

```
masami@saga:~/codes/nsinfo (master)$ sudo ./nsinfo.rb -p 11862
Process 11862 : ssh
          net   4026531969
          uts   4026531838
          ipc   4026531839
          pid   4026531836
         user   4026531837
          mnt   4026531840
```

#!/usr/bin/env ruby

# NSInfo
#
# Read /proc/<pid>/ns then collect namespace data
#
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# masami256 wrote this file.  As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.   @masami256
#  ----------------------------------------------------------------------------

require 'optparse'

# Program version
Version = "0.1"

module NSInfo
    def is_root?
        Process.uid == 0
    end

    class NamespaceInfo
 
        def show_all_processes_by_namespaces
            processes = read_process_directories
            data_by_namespace = make_nsinfo_data_by_namespace(processes)
            show_data_by_namespace(data_by_namespace)
        end
    
        def show_namespace_info_by_pid(pid)
            process = {}

            proc_path = "/proc/#{pid}"

            process['ns'] = read_process_directory(proc_path)
            process['process'] = read_process_status(proc_path)

            puts("Process #{process['process']['pid']} : #{process['process']['comm']}")
            process['ns'].keys.each do |key|
                printf("\t%5s\t%10s\n", key, process['ns'][key])
            end
        end
    
        def count_number_of_namespaces
            namespaces = count_number_of_all_namespaces
            show_number_of_namespaces(namespaces)
        end
    
        private
        def read_process_directories
            workthrough_proc_dir
        end

        def make_nsinfo_data_by_namespace(processes)
            threads = []
            data = {}

            namespace_names(processes).each do |name|
                data[name] = {}
                threads << Thread.new do
                    make_data_by_namespace!(name, processes, data[name])
                end
            end 

            threads.each do |thread|
                thread.join
            end

            return data
        end

        def show_data_by_namespace(data)
            data.keys.each do |name|
                ns = data[name]
                ns.keys.each do |inode|
                    inode_data = ns[inode]
                    puts("#{name}: inode: #{inode}")
                    printf("\t%10s\t%10s\t%s\n", "pid", "ppid", "comm")
                    inode_data.each do |d|
                        printf("\t%10s\t%10s\t%s\n", d["pid"], d["ppid"], d["comm"])
                    end
                end
            end
        end

        def workthrough_proc_dir
            processes = {}

            Dir::foreach('/proc') do |item|
                abs_path = '/proc/' + item
                if FileTest.directory?('/proc/' + item)
                    if is_process_dir?(item)
                        processes[item] ||= {}

                        processes[item]['ns'] = read_process_directory(abs_path)
                        processes[item]['process'] = read_process_status(abs_path)
                    end
                end
            end
            return processes
        end
    
        def read_process_directory(path)
            ret = {}

            Dir::foreach(path + '/ns') do |ns|
                abs_path = path + '/ns/' + ns
                if FileTest.file?(abs_path)
                    name, inode = split_name_and_inode(abs_path)
                    ret[name] = inode
                end
            end
            return ret
        end
    
        def read_process_status(path)
            ret = {}
            open(path + '/status') do |file|
                while line = file.gets
                    if line[0..3] == "Name"
                        ret["comm"] = line.split(':')[1].strip
                    elsif line[0..2] == "Pid"
                        ret["pid"] = line.split(':')[1].strip
                    elsif line[0..3] == "PPid"
                        ret["ppid"] = line.split(':')[1].strip
                    end
                end
            end

            return ret
        end
    
        def split_name_and_inode(path)
            tmp = File.readlink(path).split(':')
            name = tmp[0].strip
            inode = tmp[1][1 .. tmp[1].length - 2].strip
            return name, inode
        end
    
        def is_process_dir?(name)
            (name =~ /^\d+$/) == 0
        end

        def namespace_names(processes)
            processes["1"]["ns"].keys
        end

        # Make data by following format
        #
        # {
        #   inode => [
        #     {pid => pid, comm => comm, ppid => ppid},
        #     {pid => pid, comm => comm, ppid => ppid}
        #   ],
        #   inode = [
        #     {pid => pid, comm => comm, ppid => ppid},
        #     {pid => pid, comm => comm, ppid => ppid}
        #   ]
        # }
        def make_data_by_namespace!(name, processes, result_buf)
            processes.keys.each do |pid|
                inode = processes[pid]["ns"][name]
                unless result_buf.has_key?(inode)
                    result_buf[inode] = [ read_process_data_by_pid(pid, processes) ]
                else
                    result_buf[inode] = result_buf[inode] << read_process_data_by_pid(pid, processes)
                end
            end
        end
    
        def read_process_data_by_pid(pid, processes)
            {
                "pid" => pid,
                "comm" => processes[pid]["process"]["comm"],
                "ppid" => processes[pid]["process"]["ppid"]
            }
        end
    
        def count_number_of_all_namespaces
            processes = read_process_directories

            namespaces = {
                'net' => {},
                'uts' => {},
                'ipc' => {},
                'pid' => {},
                'user' => {},
                'mnt' => {} 
            }

            processes.each do |process|
                tmp = process[1]['ns']
                tmp.keys.each do |key|
                    if namespaces[key][tmp[key]].nil?
                        namespaces[key][tmp[key]] = 1
                    else
                        namespaces[key][tmp[key]] += 1
                    end
                end

            end
            return namespaces
        end
    
        def show_number_of_namespaces(namespaces)
            total = 0
            namespaces.keys.each do |ns|
                ns_total = 0
                namespace = namespaces[ns]
                puts ("#{ns}: namespace")
                namespace.keys.each do |inode|
                    puts("\tinode:#{inode} : #{namespace[inode]}")
                    total += namespace[inode]
                    ns_total += 1
                end
                puts("\tTotal: #{ns_total}")
            end
            puts("Total processes: #{total}")
        end
    end
end

include NSInfo
require 'pp'

def usage(prog)
    puts("usage: #{prog} [option]")
    puts("\t-a --all: show all namespace information")
    puts("\t-p PID --pid=PID show pid PID's namespace information")
    exit
end

def parse_options
    opt = OptionParser.new

    options = {}

    opt.on('-a', '--all') do |v|
        options['all'] = true
    end

    opt.on('-p PID', '--pid') do |v|
        options['pid'] = v
    end

    opt.on('-c', '--count') do |v|
        options['count'] = true
    end

    opt.parse(ARGV)

    # set defaul option, if command line parameter(s) is not set
    if options.size == 0
        options["all"] = true
    end

    return options
end

def show_all_processes_namespace_info
    ni = NSInfo::NamespaceInfo.new

    ni.show_all_processes_by_namespaces

end

def show_namespace_by_pid(pid)
    ni = NSInfo::NamespaceInfo.new
    ni.show_namespace_info_by_pid(pid)  
end

def count_namespaces
    ni = NSInfo::NamespaceInfo.new
    ni.count_number_of_namespaces
end

if __FILE__ == $0

    if !NSInfo.is_root?
        puts("You need root privilage to run this program")
        Process.exit(-1)
    end

    options = parse_options
    if options.include?('all')
        show_all_processes_namespace_info
    elsif options.include?('pid')
        show_namespace_by_pid(options['pid'])
    elsif options.include?('count')
        count_namespaces
    else
        usage($0)
    end
end


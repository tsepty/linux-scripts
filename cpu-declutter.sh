#!/bin/bash
# This software will reorganize CPU affinity on server. On one NUMA group will run kernel and systemd process, on the reminder NUMA groups application will run.

# build a kernel process list. kernel processes (or "kernel threads") are children of PID 2 (kthreadd)
KERNEL_PROCESS="kthreadd"

# define additional processes to un in reserver area (PID should be 1)
SYSTEM_PROCESS="systemd init"

# define what processes can run into user-space designated area
# USERSPACE_PROCESSES=""

# NUMA assignments 
KERNEL_NUMA_GROUPS="0-23,96-119"
USERSPACE_NUMA_GROUPS="24-95,120-191"


# see the NUMA groups this CPU has
CPU_CORES=$(lscpu | grep -e "^CPU(s)"  | awk -F ":" '{print $2}' | xargs)
NUMA_NODES=$(lscpu | grep -e "^NUMA node(s)"  | awk -F ":" '{print $2}' | xargs)

echo "This CPU has $CPU_CORES cpu cores"
echo "This CPU has $NUMA_NODES numa nodes"

# STOPME: if server has just one numa group, since reorganization is not possible

# declare indexed arrays
declare -a KERNEL_PROCESS_LIST
declare -a USERSPACE_PROCESS_LIST

kernel_list_index=0
userspace_list_index=0

# add init
KERNEL_PROCESS_LIST[kernel_list_index]="1"
((kernel_list_index=kernel_list_index+1))

# look for all kernel processes and put them in a list
for kernel_process_name in $KERNEL_PROCESS; do
	# echo "Inspecting : $kernel_process_name"
	for kernel_process_id in $(pgrep $kernel_process_name); do 

        echo "debug: kernel $kernel_process_name process PID is $kernel_process_id"   
    
        # debug: print kernel process PID and thread PID and CPU affinity
		#ps --ppid $kernel_process_id -p $kernel_process_id -o uname,pid,ppid,cmd,cls,tid,fname,user,psr

        # list all the kernel processes
		kernel_process_thread_ids=$(ps --ppid $kernel_process_id -p $kernel_process_id -o tid=)
		for kernel_process_thread_id in $kernel_process_thread_ids; do
            # debug: print kernel thread PID for this process ID
            echo "debug: kernel PID $kernel_process_id has a thread with TID $kernel_process_thread_id"
            KERNEL_PROCESS_LIST[kernel_list_index]="$kernel_process_thread_id"
            ((kernel_list_index=kernel_list_index+1))
		done

        # list all the user-space processes (not kernel process)
        userspace_process_thread_ids=$(ps --deselect --ppid $kernel_process_id -p $kernel_process_id -o tid=)
        for userspace_process_thread_id in $userspace_process_thread_ids; do
            # debug: print userspace processes
            echo "debug: found userspace PID $userspace_process_thread_id"
            if [ $userspace_process_thread_id -gt 1 ]
            then
                USERSPACE_PROCESS_LIST[userspace_list_index]="$userspace_process_thread_id"
                ((userspace_list_index=userspace_list_index+1))
            fi
        done

	done
done


# add important process to kernel list
for system_process_name in $SYSTEM_PROCESS; do 
	echo "Inspecting : $system_process_name"
    for system_process_id in $(pgrep $system_process_name); do
        echo "debug: system $system_process_name process PID is $system_process_id"

        # list all sub-processes (threads)
        system_process_thread_ids=$(ps --ppid $system_process_id -p $system_process_id -o tid=)
        for system_process_thread_id in $system_process_thread_ids; do
            # debug: print userspace processes
            echo "debug: found system PID $system_process_id thread TID $system_process_thread_id"
            KERNEL_PROCESS_LIST[kernel_list_index]="$system_process_thread_id"
            ((kernel_list_index=kernel_list_index+1))
        done
    done
done

# fix indexes
((kernel_list_index=kernel_list_index-1))
((userspace_list_index=userspace_list_index-1))

# print process lists
echo "Kernel PIDs : ${KERNEL_PROCESS_LIST[*]}"
echo "Userspace PIDs :${USERSPACE_PROCESS_LIST[*]}"

# assign process affinity (taskset -p -c $LUCKY_CPU_CORE $proc_tid)

echo "Assigning afinity ..."

for kernal_process_index in "${!KERNEL_PROCESS_LIST[@]}" ; do
    echo "$kernel_process_index -> ${KERNEL_PROCESS_LIST[$kernel_process_index]}"
    taskset -a -p -c $KERNEL_NUMA_GROUPS "${KERNEL_PROCESS_LIST[$kernel_process_index]}"
done

for process_index in "${!USERSPACE_PROCESS_LIST[@]}" ; do
    echo "$process_index -> ${USERSPACE_PROCESS_LIST[$process_index]}"
    taskset -a -p -c $USERSPACE_NUMA_GROUPS "${USERSPACE_PROCESS_LIST[$process_index]}"
done


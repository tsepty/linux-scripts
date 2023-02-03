#!/bin/bash
# move the process defined in WATCH_PROCESS to a numa group (random cores)

WATCH_PROCESS='python'
CPU_CORES=$(lscpu | grep -e "^CPU(s)"  | awk -F ":" '{print $2}' | xargs)
NUMA_NODES=$(lscpu | grep -e "^NUMA node(s)"  | awk -F ":" '{print $2}' | xargs)

randArrayElement(){ arr=("${!1}"); echo ${arr["$[RANDOM % ${#arr[@]}]"]}; }

echo "CPU cores on this system : $CPU_CORES"
echo "NUMA Nodes : $NUMA_NODES"

NUMA_HALF=$((NUMA_NODES / 2))
NUMA_LOTTERY_POOL_STRING=""

for numa_node in `seq $NUMA_HALF $(($NUMA_NODES-1))`; do
	echo "NUMA Node : $numa_node"
	NUMA_NODE_CPU_GROUPS=$(lscpu | grep "NUMA node$numa_node" | awk -F ":" '{print $2}' | xargs)
	echo "CPU groups for NUMA node $numa_node : $NUMA_NODE_CPU_GROUPS"
	NUMA_LOTTERY_POOL_STRING+="$NUMA_NODE_CPU_GROUPS "
done

echo "NUMA GROUPS: $NUMA_LOTTERY_POOL_STRING"
NUMA_LOTTERY_POOL=${NUMA_LOTTERY_POOL_STRING//[,]/ }

# build final array
declare -a NUMA_LOTTERY_NO
declare -a LUCKY_CORE_ARRAY

i=0
for numa_group in $NUMA_LOTTERY_POOL; do
	echo "Group : $numa_group"
	NUMA_LOTTERY_NO[$i]="$numa_group"
	((i=i+1))
	echo "i=$i"
done	

echo "Final string : ${NUMA_LOTTERY_NO[*]}"

NUMA_LOTERY_GROUPS=${NUMA_LOTTERY_NO[@]}

for process in $WATCH_PROCESS; do
	echo "Inspecting : $process"
	PROCESS_RAND_NUMA_GROUP=$(randArrayElement  "NUMA_LOTTERY_NO[@]")
	NUMA_GROUP_START=$(echo $PROCESS_RAND_NUMA_GROUP | cut -d '-' -f1)
	NUMA_GROUP_END=$(echo $PROCESS_RAND_NUMA_GROUP | cut -d '-' -f2)
	LUCKY_CORE_ARRAY=($(seq $NUMA_GROUP_START $NUMA_GROUP_END))

	echo "NUMA Group Assigned : $PROCESS_RAND_NUMA_GROUP" 
	for i in $(pgrep $process); do 
		ps -mo pid,tid,fname,user,psr -p $i
		LUCKY_CPU_CORE=$(randArrayElement "LUCKY_CORE_ARRAY[@]")
		echo "Assinged core for process : $LUCKY_CPU_CORE" 
		taskset -p -c $LUCKY_CPU_CORE $i
		PROCESS_TID=$(ps -L --pid $i -o tid=)
		for proc_tid in $PROCESS_TID; do
			echo "process $i tid $proc_tid"
			taskset -p -c $LUCKY_CPU_CORE $proc_tid
		done
	done
done


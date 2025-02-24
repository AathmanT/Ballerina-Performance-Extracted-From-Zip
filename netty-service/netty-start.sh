#!/bin/bash
# Copyright 2017 WSO2 Inc. (http://wso2.org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ----------------------------------------------------------------------------
# Start Netty Service
# ----------------------------------------------------------------------------

script_dir=$(dirname "$0")
# Change directory to make sure logs directory is created inside $script_dir
cd $script_dir
service_name="ballerina"
default_heap_size="4g"
heap_size="$default_heap_size"
wait_listen=false

function usage() {
    echo ""
    echo "Usage: "
    echo "$0 [-m <heap_size>] [-p] [-t] [-w] [-h] -- [ballerina_echo_flags]"
    echo ""
    echo "-m: The heap memory size of Netty Service. Default: $default_heap_size"
    echo "-w: Wait till the port starts to listen."
    echo "-h: Display this help and exit."
    echo ""
}

while getopts "m:p:t:wh" opts; do
    case $opts in
    m)
        heap_size=${OPTARG}
        ;;
    p)
        ballerina_path=${OPTARG}
        ;;
    t)
        max_pool_size=${OPTARG}
        ;;
    w)
        wait_listen=true
        ;;
    h)
        usage
        exit 0
        ;;
    \?)
        usage
        exit 1
        ;;
    esac
done
shift "$((OPTIND - 1))"

ballerina_echo_flags="$@"

if [[ -z $heap_size ]]; then
    echo "Please specify the heap size."
    exit 1
fi

#if pgrep -f "$service_name" >/dev/null; then
#    echo "Shutting down Netty"
#    pkill -f $service_name
#fi

if pgrep -f ballerina.*/bre >/dev/null; then
    echo "Shutting down Netty"
    pkill -f ballerina.*/bre
    # Wait for few seconds
    sleep 5
fi

# Check whether process exists
if pgrep -f ballerina.*/bre >/dev/null; then
    echo "Killing Netty process!!"
    pkill -9 -f ballerina.*/bre
fi


gc_log_file=./logs/nettygc.log

if [[ -f $gc_log_file ]]; then
    echo "GC Log exists. Moving $gc_log_file to /tmp"
    mv $gc_log_file /tmp/
fi

mkdir -p logs

echo "Starting Netty"
#nohup java -Xms${heap_size} -Xmx${heap_size} -XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$gc_log_file \
#    -jar $service_name-0.3.1-SNAPSHOT.jar $netty_service_flags >netty.out 2>&1 &

export JAVA_OPTS="-XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$gc_log_file"
JAVA_OPTS+=" -Xms${heap_size} -Xmx${heap_size}"

export BALLERINA_MAX_POOL_SIZE="${max_pool_size}"

ballerina_command="ballerina run ${ballerina_echo_flags} ballerina-echo-alpha.bal"
echo "Starting Ballerina: $ballerina_command"
cd $ballerina_path
nohup $ballerina_command &>netty.out 2>&1 &


if [ "$wait_listen" = true ]; then
    # Find the port:
    port=$(echo "$ballerina_echo_flags" | sed -nE "s/--port[[:blank:]]([[:digit:]]+)/\1/p")
    if [[ -z $port ]]; then
        # Default port
        port=8688
    fi
    echo "Waiting till the port $port starts to listen."
    n=0
    until [ $n -ge 60 ]; do
        nc -zv localhost $port && break
        n=$(($n + 1))
        sleep 1
    done
fi

sleep 1
tail -50 netty.out

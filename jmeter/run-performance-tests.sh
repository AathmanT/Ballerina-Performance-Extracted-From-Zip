#!/bin/bash -e
# Copyright (c) 2018, WSO2 Inc. (http://wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# ----------------------------------------------------------------------------
# Run Ballerina Performance Tests
# ----------------------------------------------------------------------------

script_dir=$(dirname "$0")
# Execute common script
. $script_dir/perf-test-common.sh

function initialize() {
    export ballerina_ssh_host=ballerina
    export ballerina_host=$(get_ssh_hostname $ballerina_ssh_host)
    echo "Downloading keystore file to $HOME."
    scp $ballerina_ssh_host:/usr/lib/ballerina/ballerina-*/bre/security/ballerinaKeystore.p12 $HOME/
    scp $HOME/ballerinaKeystore.p12 $backend_ssh_host:
}
export -f initialize

declare -A test_scenario0=(
    [name]="h1c_h1c_passthrough"
    [display_name]="Passthrough HTTP service (h1c -> h1c)"
    [description]="An HTTP Service, which forwards all requests to an HTTP back-end service."
    [bal]="h1c_h1c_passthrough.balx"
    [bal_flags]=""
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [skip]=false
)
declare -A test_scenario1=(
    [name]="h1_h1_passthrough"
    [display_name]="Passthrough HTTPS service (h1 -> h1)"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=4"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario2=(
    [name]="h1c_transformation"
    [display_name]="JSON to XML transformation HTTP service"
    [description]="An HTTP Service, which transforms JSON requests to XML and then forwards all requests to an HTTP back-end service."
    [bal]="h1c_transformation.balx"
    [bal_flags]=""
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [skip]=false
)
declare -A test_scenario3=(
    [name]="h1_transformation"
    [display_name]="JSON to XML transformation HTTPS service"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=4"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario4=(
    [name]="h2_h2_passthrough"
    [display_name]="Passthrough HTTP/2(over TLS) service (h2 -> h2)"
    [description]="An HTTPS Service exposed over HTTP/2 protocol, which forwards all requests to an HTTP/2(over TLS) back-end service."
    [bal]="h2_h2_passthrough.balx"
    [bal_flags]=""
    [path]="/passthrough"
    [jmx]="http2-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--http2 --ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario5=(
    [name]="h2_h1_passthrough"
    [display_name]="Passthrough HTTP/2(over TLS) service (h2 -> h1)"
    [description]="An HTTPS Service exposed over HTTP/2 protocol, which forwards all requests to an HTTPS back-end service."
    [bal]="h2_h1_passthrough.balx"
    [bal_flags]=""
    [path]="/passthrough"
    [jmx]="http2-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario6=(
    [name]="h2_h1c_passthrough"
    [display_name]="Passthrough HTTP/2(over TLS) service (h2 -> h1c)"
    [bal]="h2_h1c_passthrough.balx"
    [description]="An HTTPS Service exposed over HTTP/2 protocol, which forwards all requests to an HTTP back-end service."
    [bal_flags]=""
    [path]="/passthrough"
    [jmx]="http2-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [skip]=false
)
declare -A test_scenario7=(
    [name]="h2_h2_client_and_server_downgrade"
    [display_name]="HTTP/2 client and server downgrade service (h2 -> h2)"
    [description]="An HTTP/2(with TLS) server accepts requests from an HTTP/1.1(with TLS) client and the HTTP/2(with TLS) client sends requests to an HTTP/1.1(with TLS) back-end service. Both the upstream and the downgrade connection is downgraded to HTTP/1.1(with TLS)."
    [bal]="h2_h2_passthrough.balx"
    [bal_flags]=""
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario8=(
    [name]="websocket"
    [display_name]="Websocket"
    [description]="Websocket service"
    [bal]="websocket.balx"
    [bal_flags]=""
    [path]="/basic/ws"
    [jmx]="websocket.jmx"
    [protocol]=""
    [use_backend]=false
    [skip]=false
)
declare -A test_scenario9=(
    [name]="passthrough_http_observe_default"
    [display_name]="Passthrough HTTP Service with Default Observability"
    [description]="Observability with default configs"
    [bal]="passthrough.balx"
    [bal_flags]="--observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [skip]=true
)
declare -A test_scenario10=(
    [name]="passthrough_http_observe_metrics"
    [display_name]="Passthrough HTTP Service with Metrics"
    [description]="Metrics only"
    [bal]="passthrough.balx"
    [bal_flags]="-e b7a.observability.metrics.enabled=true"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [skip]=true
)
declare -A test_scenario11=(
    [name]="passthrough_http_observe_tracing"
    [display_name]="Passthrough HTTP Service with Tracing"
    [description]="Tracing only"
    [bal]="passthrough.balx"
    [bal_flags]="-e b7a.observability.tracing.enabled=true"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [skip]=true
)
declare -A test_scenario12=(
    [name]="passthrough_http_observe_metrics_noop"
    [display_name]="Passthrough HTTP Service with Metrics (No-Op)"
    [description]="Metrics (with No-Op implementation) only"
    [bal]="passthrough.balx"
    [bal_flags]="-e b7a.observability.metrics.enabled=true -e b7a.observability.metrics.provider=noop"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [skip]=true
)







declare -A test_scenario13=(
    [name]="h1_transformation_t4"
    [display_name]="JSON to XML transformation HTTPS service t4"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=4 --observe"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario14=(
    [name]="h1_h1_passthrough_t4"
    [display_name]="Passthrough HTTPS service (h1 -> h1) t4"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=4 --observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario15=(
    [name]="h1_transformation_t8"
    [display_name]="JSON to XML transformation HTTPS service t8"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=8 --observe"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario16=(
    [name]="h1_h1_passthrough_t8"
    [display_name]="Passthrough HTTPS service (h1 -> h1) t8"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=8 --observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario17=(
    [name]="h1_transformation_t10"
    [display_name]="JSON to XML transformation HTTPS service t10"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=10 --observe"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario18=(
    [name]="h1_h1_passthrough_t10"
    [display_name]="Passthrough HTTPS service (h1 -> h1) t10"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=10 --observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario19=(
    [name]="h1_transformation_t50"
    [display_name]="JSON to XML transformation HTTPS service t50"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=50 --observe"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario20=(
    [name]="h1_h1_passthrough_t50"
    [display_name]="Passthrough HTTPS service (h1 -> h1) t50"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=50 --observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario21=(
    [name]="h1_transformation_t100"
    [display_name]="JSON to XML transformation HTTPS service t100"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=100 --observe"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario22=(
    [name]="h1_h1_passthrough_t100"
    [display_name]="Passthrough HTTPS service (h1 -> h1) t100"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=100 --observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario23=(
    [name]="h1_transformation_t500"
    [display_name]="JSON to XML transformation HTTPS service t500"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=500 --observe"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario24=(
    [name]="h1_h1_passthrough_t500"
    [display_name]="Passthrough HTTPS service (h1 -> h1) t500"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=500 --observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="https"
    [use_backend]=true
    [backend_flags]="--ssl --key-store-file $HOME/ballerinaKeystore.p12 --key-store-password ballerina"
    [skip]=false
)
declare -A test_scenario25=(
    [name]="h1_h1_passthrough_b10_e10"
    [display_name]="Passthrough HTTPS service (h1 -> h1) b10 e10"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough_new.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=10 --observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=10"
    [skip]=false
)
declare -A test_scenario26=(
    [name]="h1_h1_passthrough_b10_e100"
    [display_name]="Passthrough HTTPS service (h1 -> h1) b10 e100"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough_new.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=10 --observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario27=(
    [name]="h1_h1_passthrough_b100_e10"
    [display_name]="Passthrough HTTPS service (h1 -> h1) b100 e10"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough_new.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=100 --observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=10"
    [skip]=false
)
declare -A test_scenario28=(
    [name]="h1_h1_passthrough_b100_e100"
    [display_name]="Passthrough HTTPS service (h1 -> h1) b100 e100"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1_h1_passthrough_new.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=100 --observe"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario29=(
    [name]="h1_transformation_b10_e10"
    [display_name]="JSON to XML transformation HTTPS service b10 e10"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1c_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=10 --observe"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=10"
    [skip]=false
)
declare -A test_scenario30=(
    [name]="h1_transformation_b10_e100"
    [display_name]="JSON to XML transformation HTTPS service b10 e100"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1c_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=10 --observe"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario31=(
    [name]="h1_transformation_b100_e10"
    [display_name]="JSON to XML transformation HTTPS service b100 e10"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1c_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=100 --observe"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=10"
    [skip]=false
)
declare -A test_scenario32=(
    [name]="h1_transformation_b100_e100"
    [display_name]="JSON to XML transformation HTTPS service b100 e100"
    [description]="An HTTPS Service, which transforms JSON requests to XML and then forwards all requests to an HTTPS back-end service."
    [bal]="h1c_transformation.balx"
    [bal_flags]="-e b7a.runtime.scheduler.threadpoolsize=100 --observe"
    [path]="/transform"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario33=(
    [name]="ballerina_prime_server_521_no_echo_server_t10"
    [display_name]="Ballerina prime server for 521_t10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_passthrough_prime_alpha.bal"
    [bal_flags]="-e prime=521 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario34=(
    [name]="ballerina_prime_server_10007_no_echo_server_t10"
    [display_name]="Ballerina prime server for 10007_t10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_passthrough_prime_alpha.bal"
    [bal_flags]="-e prime=10007 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario35=(
    [name]="ballerina_prime_server_100003_no_echo_server_t10"
    [display_name]="Ballerina prime server for 100003_t10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_passthrough_prime_alpha.bal"
    [bal_flags]="-e prime=100003 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario36=(
    [name]="ballerina_prime_server_10000019_no_echo_server_t10"
    [display_name]="Ballerina prime server for 10000019_t10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_passthrough_prime_alpha.bal"
    [bal_flags]="-e prime=10000019 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario37=(
    [name]="ballerina_prime_server_521_no_echo_server_t100"
    [display_name]="Ballerina prime server for 521_t100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_passthrough_prime_alpha.bal"
    [bal_flags]="-e prime=521 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario38=(
    [name]="ballerina_prime_server_10007_no_echo_server_t100"
    [display_name]="Ballerina prime server for 10007_t100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_passthrough_prime_alpha.bal"
    [bal_flags]="-e prime=10007 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario39=(
    [name]="ballerina_prime_server_100003_no_echo_server_t100"
    [display_name]="Ballerina prime server for 100003_t100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_passthrough_prime_alpha.bal"
    [bal_flags]="-e prime=100003 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario40=(
    [name]="ballerina_prime_server_10000019_no_echo_server_t100"
    [display_name]="Ballerina prime server for 10000019_t100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_passthrough_prime_alpha.bal"
    [bal_flags]="-e prime=10000019 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e b7a.runtime.scheduler.threadpoolsize=100"
    [skip]=false
)
declare -A test_scenario41=(
    [name]="ballerina_prime_521_passthrough_t10_ballerina_prime_echo_t10"
    [display_name]="Ballerina prime and echo server for 521_b10_e10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=521 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=521"
    [echo_max_pool]="10"
    [skip]=false
)
declare -A test_scenario42=(
    [name]="ballerina_prime_521_passthrough_t100_ballerina_prime_echo_t10"
    [display_name]="Ballerina prime and echo server for 521_b100_e10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=521 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=521"
    [echo_max_pool]="10"
    [skip]=false
)
declare -A test_scenario43=(
    [name]="ballerina_prime_521_passthrough_t10_ballerina_prime_echo_t100"
    [display_name]="Ballerina prime and echo server for 521_b10_e100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=521 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=521"
    [echo_max_pool]="100"
    [skip]=false
)
declare -A test_scenario44=(
    [name]="ballerina_prime_521_passthrough_t100_ballerina_prime_echo_t100"
    [display_name]="Ballerina prime and echo server for 521_b100_e100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=521 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=521"
    [echo_max_pool]="100"
    [skip]=false
)
declare -A test_scenario45=(
    [name]="ballerina_prime_10007_passthrough_t10_ballerina_prime_echo_t10"
    [display_name]="Ballerina prime and echo server for 10007_b10_e10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=10007 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=10007"
    [echo_max_pool]="10"
    [skip]=false
)
declare -A test_scenario46=(
    [name]="ballerina_prime_10007_passthrough_t100_ballerina_prime_echo_t10"
    [display_name]="Ballerina prime and echo server for 10007_b100_e10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=10007 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=10007"
    [echo_max_pool]="10"
    [skip]=false
)
declare -A test_scenario47=(
    [name]="ballerina_prime_10007_passthrough_t10_ballerina_prime_echo_t100"
    [display_name]="Ballerina prime and echo server for 10007_b10_e100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=10007 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=10007"
    [echo_max_pool]="100"
    [skip]=false
)
declare -A test_scenario48=(
    [name]="ballerina_prime_10007_passthrough_t100_ballerina_prime_echo_t100"
    [display_name]="Ballerina prime and echo server for 10007_b100_e100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=10007 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=10007"
    [echo_max_pool]="100"
    [skip]=false
)
declare -A test_scenario49=(
    [name]="ballerina_prime_100003_passthrough_t10_ballerina_prime_echo_t10"
    [display_name]="Ballerina prime and echo server for 100003_b10_e10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=100003 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=100003"
    [echo_max_pool]="10"
    [skip]=false
)
declare -A test_scenario50=(
    [name]="ballerina_prime_100003_passthrough_t100_ballerina_prime_echo_t10"
    [display_name]="Ballerina prime and echo server for 100003_b100_e10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=100003 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=100003"
    [echo_max_pool]="10"
    [skip]=false
)
declare -A test_scenario51=(
    [name]="ballerina_prime_100003_passthrough_t10_ballerina_prime_echo_t100"
    [display_name]="Ballerina prime and echo server for 100003_b10_e100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=100003 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=100003"
    [echo_max_pool]="100"
    [skip]=false
)
declare -A test_scenario52=(
    [name]="ballerina_prime_100003_passthrough_t100_ballerina_prime_echo_t100"
    [display_name]="Ballerina prime and echo server for 100003_b100_e100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=100003 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=100003"
    [echo_max_pool]="100"
    [skip]=false
)
declare -A test_scenario53=(
    [name]="ballerina_prime_10000019_passthrough_t10_ballerina_prime_echo_t10"
    [display_name]="Ballerina prime and echo server for 10000019_b10_e10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=10000019 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=10000019"
    [echo_max_pool]="10"
    [skip]=false
)
declare -A test_scenario54=(
    [name]="ballerina_prime_10000019_passthrough_t100_ballerina_prime_echo_t10"
    [display_name]="Ballerina prime and echo server for 10000019_b100_e10"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=10000019 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=10000019"
    [echo_max_pool]="10"
    [skip]=false
)
declare -A test_scenario55=(
    [name]="ballerina_prime_10000019_passthrough_t10_ballerina_prime_echo_t100"
    [display_name]="Ballerina prime and echo server for 10000019_b10_e100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=10000019 --observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=10000019"
    [echo_max_pool]="100"
    [skip]=false
)
declare -A test_scenario56=(
    [name]="ballerina_prime_10000019_passthrough_t100_ballerina_prime_echo_t100"
    [display_name]="Ballerina prime and echo server for 10000019_b100_e100"
    [description]="An HTTPS Service, which checks prime and also echoes the request back"
    [bal]="h1c_h1c_prime_passthrough_alpha.bal"
    [bal_flags]="-e prime=10000019 --observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="-e prime=10000019"
    [echo_max_pool]="100"
    [skip]=false
)
declare -A test_scenario57=(
    [name]="h1_h1_passthrough_b10_e10_alpha"
    [display_name]="Passthrough HTTPS service (h1 -> h1) b10 e10"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1c_h1c_passthrough_alpha.bal"
    [bal_flags]="--observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="--observe"
    [echo_max_pool]="10"
    [skip]=false
)
declare -A test_scenario58=(
    [name]="h1_h1_passthrough_b10_e100_alpha"
    [display_name]="Passthrough HTTPS service (h1 -> h1) b10 e100"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1c_h1c_passthrough_alpha.bal"
    [bal_flags]="--observe"
    [max_pool]="10"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="--observe"
    [echo_max_pool]="100"
    [skip]=false
)
declare -A test_scenario59=(
    [name]="h1_h1_passthrough_b100_e10_alpha"
    [display_name]="Passthrough HTTPS service (h1 -> h1) b100 e10"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1c_h1c_passthrough_alpha.bal"
    [bal_flags]="--observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="--observe"
    [echo_max_pool]="10"
    [skip]=false
)
declare -A test_scenario60=(
    [name]="h1_h1_passthrough_b100_e100_alpha"
    [display_name]="Passthrough HTTPS service (h1 -> h1) b100 e100"
    [description]="An HTTPS Service, which forwards all requests to an HTTPS back-end service."
    [bal]="h1c_h1c_passthrough_alpha.bal"
    [bal_flags]="--observe"
    [max_pool]="100"
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [use_backend]=true
    [backend_flags]="--observe"
    [echo_max_pool]="100"
    [skip]=false
)
# declare -A test_scenario13=(
#     [name]="passthrough_http_observe_tracing_noop"
#     [display_name]="Passthrough HTTP Service with Tracing (No-Op)"
#     [description]="Tracing (with No-Op implementation) only"
#     [bal]="passthrough.balx"
#     [bal_flags]="-e b7a.observability.tracing.enabled=true -e b7a.observability.tracing.name=noop"
#     [path]="/passthrough"
#     [jmx]="http-post-request.jmx"
#     [protocol]="http"
#     [use_backend]=true
#     [skip]=true
# )

function before_execute_test_scenario() {
    local bal_file=${scenario[bal]}
    local bal_flags=${scenario[bal_flags]}
    local max_pool=${scenario[max_pool]}
    local service_path=${scenario[path]}
    local protocol=${scenario[protocol]}
    jmeter_params+=("host=$ballerina_host" "port=9090" "path=$service_path")
    jmeter_params+=("payload=$HOME/${msize}B.json" "response_size=${msize}B" "protocol=$protocol")
    JMETER_JVM_ARGS="-Xbootclasspath/p:/opt/alpnboot/alpnboot.jar"
    echo "Starting Ballerina Service. Ballerina Program: $bal_file, Heap: $heap, Flags: ${bal_flags:-N/A}"
    ssh $ballerina_ssh_host "./ballerina/ballerina-start.sh -p $HOME/ballerina/bal -b $bal_file -t $max_pool -m $heap -- $bal_flags"
    #ssh $ballerina_ssh_host "python request.py $bal_file" &

}

function after_execute_test_scenario() {
    #ssh $ballerina_ssh_host "pkill -f request.py"
    write_server_metrics ballerina $ballerina_ssh_host ballerina.*/bre
    download_file $ballerina_ssh_host ballerina/bal/logs/ballerina.log ballerina.log
    download_file $ballerina_ssh_host ballerina/bal/logs/gc.log ballerina_gc.log
    download_file $ballerina_ssh_host ballerina/bal/logs/heap-dump.hprof ballerina_heap_dump.hprof
    #download_file $ballerina_ssh_host demofile2.txt
}

test_scenarios

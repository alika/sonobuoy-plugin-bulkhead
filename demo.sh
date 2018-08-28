#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

export REGISTRY=quay.io
export TARGET=alika/sonobuoy-plugin-bulkhead

export CLUSTER_USER=alika.larsen@gmail.com
export CLUSTER_REGION=us-west1-a
export CLUSTER_NAME=estore-dev
export CLUSTER_PROJECT=k8s-work

export RESULTS_DIR=./results

get_admin_creds() {
  gcloud container clusters describe ${CLUSTER_NAME} --project ${CLUSTER_PROJECT} --zone ${CLUSTER_REGION}
}

setu_prereqs() {
  # sonobuoy cli

  # for gke
  kubectl --username=admin --password=${CLUSTER_ADMIN_PASS} create clusterrolebinding sonobuoy-cluster-admin-binding --clusterrole=cluster-admin --user=${CLUSTER_USER}
}

run_sonobuoy_cli() {
  sonobuoy run
}

build_and_push_continer() {
  make && make push
}

get_logs() {
  mkdir -p ${RESULTS_DIR}
  sonobuoy logs > ${RESULTS_DIR}/systemd.log
}

get_results() {
  mkdir -p ${RESULTS_DIR}
  sonobuoy retrieve .
  tar xzf *.tar.gz -C ${RESULTS_DIR}
}

run_sonobuoy() {
  kubectl create -f examples/diagnostics.yml
}

cleanup() {
  kubectl delete -f examples/benchmark.yml
  rm *.tar.gz
}

show_sonobuoy_config() {
  cat ${RESULTS_DIR}/resources/ns/heptio-sonobuoy/ConfigMaps.json
}

main() {
  #build_and_push_continer
  #show_sonobuoy_config
  #run_sonobuoy
  get_results
}
main
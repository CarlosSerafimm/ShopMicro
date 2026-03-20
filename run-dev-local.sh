#!/bin/bash

NETWORK_NAME="shopmicro-dev-local-k3d-network"
SUBNET="172.20.0.0/16"
MASTER_IP="172.20.0.10"
AGENT1_IP="172.20.0.11"
AGENT2_IP="172.20.0.12"
CLUSTER_NAME="shopmicro-dev-local-cluster"

# Cria rede Docker customizada se não existir
docker network ls | grep $NETWORK_NAME >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Criando rede Docker $NETWORK_NAME com subnet $SUBNET..."
    docker network create --subnet=$SUBNET $NETWORK_NAME
else
    echo "Rede Docker $NETWORK_NAME já existe."
fi

# CRIAÇÃO DO CLUSTER k3d COM IP FIXO
k3d cluster list | grep $CLUSTER_NAME >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Criando cluster k3d '$CLUSTER_NAME' com IP fixo..."
    k3d cluster create $CLUSTER_NAME \
      --servers 1 \
      --agents 2 \
      --network $NETWORK_NAME \
      --k3s-arg "--node-ip=$MASTER_IP@server:0" \
      --k3s-arg "--node-ip=$AGENT1_IP@agent:0" \
      --k3s-arg "--node-ip=$AGENT2_IP@agent:1"
else
    echo "Cluster $CLUSTER_NAME já existe. Pulando criação."
fi

# INICIAR CLUSTER SE ESTIVER PARADO
k3d cluster list | grep $CLUSTER_NAME | grep "Stopped" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Cluster $CLUSTER_NAME está parado. Iniciando..."
    k3d cluster start $CLUSTER_NAME
fi

# MOSTRAR STATUS DOS PODS
echo "Pods atuais no cluster:"
kubectl get pods -A

#!/bin/bash

NETWORK_NAME="shopmicro-dev-local-k3d-network"
CLUSTER_NAME="shopmicro-dev-local-cluster"

# Cria rede Docker customizada se não existir
docker network ls | grep $NETWORK_NAME >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Criando rede Docker $NETWORK_NAME..."
    docker network create $NETWORK_NAME
else
    echo "Rede Docker $NETWORK_NAME já existe."
fi

# CRIAÇÃO DO CLUSTER k3d SEM IP FIXO
k3d cluster list | grep $CLUSTER_NAME >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Criando cluster k3d '$CLUSTER_NAME' sem IP fixo..."
    k3d cluster create $CLUSTER_NAME \
      --servers 1 \
      --agents 2 \
      --network $NETWORK_NAME
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

#!/usr/bin/env bash
minikube start --driver=docker --cpus=2 --memory=1959
sleep 60
cd terraform && terraform apply -auto-approve



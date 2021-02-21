#!/bin/bash
echo Installing terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - || exit 1
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" || exit 1
sduo apt update || exit 1
sudo apt install terraform  || exit 1
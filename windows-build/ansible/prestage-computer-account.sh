#!/bin/bash
ansible-playbook prestage-computer-account.yml -i myhosts -e "serverList=ukfhpapcho01"

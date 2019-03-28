#!/bin/bash
ansible-playbook add-additional-groups-to-servers.yml -i myhosts -e "serverList=ukfhpapcho01"

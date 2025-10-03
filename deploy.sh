#!/bin/bash

oc apply -f projects.yml

cd hello-app && ./deploy.sh
cd ..


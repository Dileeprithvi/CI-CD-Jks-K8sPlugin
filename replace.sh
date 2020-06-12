#!/bin/bash
sed "s/tagVersion/$1/g" deployment.yml > changed-deploy.yml

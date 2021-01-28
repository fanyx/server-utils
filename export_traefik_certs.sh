#!/bin/bash

# Requirements: you will need to install jq and maybe openssl

traefikdir="/srv/docker/traefik"
certdir="${traefikdir}/certificates"

# creates a directory for all of your certificates
mkdir -p $certdir

# reads the acme.json file, please put this file in the same directory as your script
json=$(cat /srv/docker/traefik/config/acme/acme.json)

export_cer_key () {
  echo $json | jq -r '.[].Certificates[] | select(.domain.main == "'$1'") | .certificate' | base64 -d > $certdir/$1.cer
  echo $json | jq -r '.[].Certificates[] | select(.domain.main == "'$1'") | .key' | base64 -d > $certdir/$1.key
}

export_pfx () {
    openssl pkcs12 -export -out $certdir/$domain.pfx -inkey $certdir/$domain.key -in $certdir/$domain.cer -passout pass: 
}

read -p "Do you want to export as .pfx file as well [y]?" REPLY

# iterates through all of your domains
for domain in $(echo $json | jq -r '.[].Certificates[].domain.main')
do
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    export_cer_key "$domain"
    export_pfx "$domain"
  else
    export_cer_key "$domain"
  fi
done

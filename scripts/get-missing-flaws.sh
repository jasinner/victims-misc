#!/bin/sh
# Retrieves a list of all CVE IDs that have been resolved in Red Hat JBoss and 
# Fuse products. Compares this to the list of CVE IDs currently in the victims 
# DB, and prints a list of all those missing from the DB to cves.missing

RH_URL="https://www.redhat.com/security/data/metrics/rhsamapcpe.txt"
VICTIMS_URL="https://www.victi.ms/service/update/1970-01-01T00:00:00/?fields=cves"

CURL_CMD="curl --insecure --silent"

echo "Fetching unique CVEs from Victi.ms database ..."
${CURL_CMD} "${VICTIMS_URL}" \
	| grep -oh "CVE-[0-9]*-[0-9]*" \
	| sort -u > victims-cves.txt


echo "Fetching unique CVEs from Red Hat RHSA metrics ..."
# Ignore CVE IDs prior to 2010
${CURL_CMD} "${RH_URL}" \
	| grep "fuse\|jboss" \
	| grep -oh "CVE-[0-9]*-[0-9]*" \
	| sort -u \
	| grep -v "CVE-[0-2]00[0-9]" > rh-cves.txt

comm -23 rh-cves.txt victims-cves.txt > cves.missing

echo "Cleaning up temporary files ..."
rm *.txt

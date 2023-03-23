#!/bin/bash

# Set your Gandi API key, domain name, and subdomain
GANDI_API_KEY="$GANDI_API_KEY"
DOMAIN="$DOMAIN"
SUBDOMAIN="$SUBDOMAIN"
# Set the TTL value for the DNS A record in seconds (default is 1800 seconds / 30 minutes)
TTL="$TTL"

IPLOOKUP="$IPLOOKUP"

# Set the log file path
LOG_FILE="/var/log/update_dns.log"

# Get the current external IP address
CURRENT_IP=$(curl -s $IPLOOKUP)

# Get the IP address and TTL of the DNS A record via the Gandi API
DNS_INFO=$(curl -s -H "Authorization: Apikey $GANDI_API_KEY" \
     "https://dns.api.gandi.net/api/v5/domains/$DOMAIN/records/$SUBDOMAIN/A")

# Check if the DNS record exists
if [ -z "$DNS_INFO" ]; then
    # Log an error if the DNS record doesn't exist
    echo "$(date): Error: DNS record doesn't exist" >> "$LOG_FILE"
    exit 1
fi

# Extract the DNS IP address and TTL value from the API response
DNS_IP=$(echo "$DNS_INFO" | jq -r '.rrset_values[0]')
DNS_TTL=$(echo "$DNS_INFO" | jq -r '.rrset_ttl')

# Check if the DNS IP is empty
if [ -z "$DNS_IP" ]; then
    # Log an error if the DNS IP is empty
    echo "$(date): Error: DNS IP is empty" >> "$LOG_FILE"
    exit 1
fi

# Compare the IP addresses
if [ "$CURRENT_IP" != "$DNS_IP" ]; then
    # Log when there is an IP change
    echo "$(date): IP address changed from $DNS_IP to $CURRENT_IP" >> "$LOG_FILE"

    # Update the DNS A record via the Gandi API
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
         -X PUT -H "Content-Type: application/json" -H "Authorization: Apikey $GANDI_API_KEY" \
         -d '{"rrset_values": ["'$CURRENT_IP'"], "rrset_ttl": '$TTL'}' \
         "https://dns.api.gandi.net/api/v5/domains/$DOMAIN/records/$SUBDOMAIN/A")

    if [ "$RESPONSE" == "200" ] || [ "$RESPONSE" == "201" ]; then
        # Log when the DNS record is updated
        echo "$(date): DNS A record updated to $CURRENT_IP with TTL $TTL seconds" >> "$LOG_FILE"
    else
        # Log an error if the API request fails
        echo "$(date): API request failed with status code $RESPONSE" >> "$LOG_FILE"
    fi
else
    # Log when the script is run without any IP change
    echo "$(date): IP address unchanged at $CURRENT_IP with TTL $DNS_TTL seconds" >> "$LOG_FILE"
fi

#!/bin/bash

# Color codes for better visibility
green="\e[32m"
red="\e[31m"
yellow="\e[33m"
blue="\e[34m"
reset="\e[0m"

# Help message
usage() {
    echo -e "${yellow}Usage:${reset} fapi -d <domain> [-o output.txt]"
    echo -e "  -d  Specify the domain (Required)"
    echo -e "  -o  Output file to save results (Optional)"
    exit 1
}

# Check dependencies
check_dependencies() {
    missing=()
    for tool in subfinder waybackurls gau hakrawler anew; do
        if ! command -v $tool &>/dev/null; then
            missing+=("$tool")
        fi
    done
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${red}Error: Missing dependencies: ${missing[*]}.${reset}"
        echo "Install them using:"
        echo "sudo apt install subfinder && go install github.com/tomnomnom/waybackurls@latest && go install github.com/lc/gau@latest && go install github.com/hakluke/hakrawler@latest && go install github.com/tomnomnom/anew@latest"
        exit 1
    fi
}

# Extract API keys using regex
extract_api_keys() {
    grep -Eo "AIza[0-9A-Za-z-_]{35}|ABTasty[0-9A-Za-z-_]+|Algolia[0-9A-Za-z-_]+|AWS[0-9A-Za-z-_]+|Slack[0-9A-Za-z-_]+|Stripe[0-9A-Za-z-_]+|Twilio[0-9A-Za-z-_]+|Telegram[0-9A-Za-z-_]+|GitHub[0-9A-Za-z-_]+|Facebook[0-9A-Za-z-_]+|Paypal[0-9A-Za-z-_]+|Google[0-9A-Za-z-_]+|Dropbox[0-9A-Za-z-_]+|LinkedIn[0-9A-Za-z-_]+|Mapbox[0-9A-Za-z-_]+|Microsoft[0-9A-Za-z-_]+|NewRelic[0-9A-Za-z-_]+|Pagerduty[0-9A-Za-z-_]+|SendGrid[0-9A-Za-z-_]+|Shodan[0-9A-Za-z-_]+|Sonarcloud[0-9A-Za-z-_]+|Spotify[0-9A-Za-z-_]+|YouTube[0-9A-Za-z-_]+" wayback.txt | anew api_keys.txt
}

# Parse command-line arguments
domain=""
output=""
while getopts "d:o:" opt; do
    case ${opt} in
        d) domain=${OPTARG} ;;
        o) output=${OPTARG} ;;
        *) usage ;;
    esac
done

# Check if domain is provided
if [ -z "$domain" ]; then
    echo -e "${red}Error: Domain is required!${reset}"
    usage
fi

# Ensure dependencies are installed
check_dependencies

# Banner
echo -e "${blue}Starting API key finder for domain: ${domain}${reset}"

# Step 1: Find subdomains
subfinder -d $domain -silent | anew subdomains.txt

# Step 2: Fetch URLs from multiple sources
(cat subdomains.txt | waybackurls; 
 cat subdomains.txt | gau --subs;
 echo "$domain" | hakrawler -depth 2 -plain) | anew wayback.txt

# Step 3: Extract API keys
extract_api_keys

# Display results
echo -e "${green}API keys found:${reset}"
cat api_keys.txt

# Save results if -o flag is used
if [ ! -z "$output" ]; then
    cp api_keys.txt "$output"
    echo -e "${green}Results saved to $output${reset}"
fi

echo -e "${blue}Process completed!${reset}"

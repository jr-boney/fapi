
### **fapi - Find API Keys Easily**  
**fapi** is a simple tool to find exposed API keys from subdomains using Wayback Machine, gau, and hakrawler.

---

## Features
- Finds subdomains using `subfinder`
- Extracts JavaScript files using `waybackurls`, `gau`, and `hakrawler`
- Extracts API keys from `.js` files only (to reduce false positives)
- Saves results to a file if specified

## Installation
### Requirements  
Install dependencies first:  
```bash
sudo apt install subfinder
go install github.com/tomnomnom/waybackurls@latest
go install github.com/lc/gau@latest
go install github.com/hakluke/hakrawler@latest
go install github.com/tomnomnom/anew@latest
```

---

## Installation
```bash
git clone https://github.com/jr-boney/fapi
cd fapi
sudo mv fapi /usr/local/bin/fapi
sudo chmod +x /usr/local/bin/fapi
```

## Usage
```bash
fapi -d example.com
```
To save results to a file:
```bash
fapi -d example.com -o results.txt
```

---

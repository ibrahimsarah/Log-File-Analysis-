#!/bin/bash

LOG_FILE="apache_logs.txt"

# 1. Request Counts
total_requests=$(wc -l < "$LOG_FILE")
get_requests=$(grep -c '"GET' "$LOG_FILE")
post_requests=$(grep -c '"POST' "$LOG_FILE")

# 2. Unique IP Addresses
unique_ips=$(cut -d ' ' -f1 "$LOG_FILE" | sort | uniq)
total_unique_ips=$(echo "$unique_ips" | wc -l)

# GET/POST per IP
echo "GET and POST requests per IP:"
for ip in $unique_ips; do
  get_count=$(grep "^$ip " "$LOG_FILE" | grep -c '"GET')
  post_count=$(grep "^$ip " "$LOG_FILE" | grep -c '"POST')
  echo "$ip - GET: $get_count, POST: $post_count"
done

# 3. Failure Requests
failed_requests=$(awk '$9 ~ /^4|^5/' "$LOG_FILE" | wc -l)
failure_percentage=$(awk -v f="$failed_requests" -v t="$total_requests" 'BEGIN { printf "%.2f", (f / t) * 100 }')

# 4. Top User (most requests)
top_user=$(cut -d ' ' -f1 "$LOG_FILE" | sort | uniq -c | sort -nr | head -1)

# 5. Daily Request Averages
total_days=$(cut -d[ -f2 "$LOG_FILE" | cut -d: -f1 | sort | uniq | wc -l)
average_requests_per_day=$(awk -v t="$total_requests" -v d="$total_days" 'BEGIN { printf "%.2f", t / d }')

# 6. Days with Most Failures
echo "Top 5 days with most failures:"
awk '$9 ~ /^4|^5/ {split($4, a, ":"); gsub("\\[", "", a[1]); print a[1]}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5

# Request by Hour
echo "Requests per hour:"
cut -d[ -f2 "$LOG_FILE" | cut -d: -f2 | sort | uniq -c | sort -n

# Status Codes Breakdown
echo "Status code breakdown:"
awk '{print $9}' "$LOG_FILE" | sort | grep -E '^[0-9]{3}$' | uniq -c | sort -nr

# Most Active IPs by Method
most_get=$(grep '"GET' "$LOG_FILE" | cut -d ' ' -f1 | sort | uniq -c | sort -nr | head -1)
most_post=$(grep '"POST' "$LOG_FILE" | cut -d ' ' -f1 | sort | uniq -c | sort -nr | head -1)

# Failure Pattern Analysis
echo "Failures by hour:"
awk '$9 ~ /^4|^5/ {split($4, a, ":"); print a[2]}' "$LOG_FILE" | sort | uniq -c | sort -n

# Final Output
echo -e "\n==== Summary ===="
echo "Total Requests: $total_requests"
echo "GET Requests: $get_requests"
echo "POST Requests: $post_requests"
echo "Unique IPs: $total_unique_ips"
echo "Failed Requests: $failed_requests"
echo "Failure Percentage: $failure_percentage%"
echo "Most Active IP: $top_user"
echo "Average Requests/Day: $average_requests_per_day"
echo "Most Active GET IP: $most_get"
echo "Most Active POST IP: $most_post"

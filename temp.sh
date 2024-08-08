#!/bin/bash
billing_net=0
cost=0.05
declare -A user_bills
tail -n 300 network_usage.log > networks_usage.log
while IFS=' ' read -r date times username ip downloaded uploaded billing
do
    if [[ "$billing" == "Unbilled" ]]; then
     while [ $downloaded -gt 0 ];
     do
     ((downloaded--))
     ((total_data++))
     done
     while [ $uploaded -gt 0 ];
     do
     ((uploaded--))
     ((total_data++))
     done
     temp=$(echo "$total_data * $cost" | bc)
     if [[ -n "${user_bills[$username]}" ]]; then
      user_bills[$username]=$(echo "${user_bills[$username]} + $temp" | bc)
     else
      user_bills[$username]=$temp
     fi
    fi
done < networks_usage.log

{
  for user in "${!user_bills[@]}"; do
    echo "$user ${user_bills[$user]}"
  done
} > network_bills.txt

sort -nrk2 network_bills.txt > network_bills_sorted.txt

echo "Top 3 users with highest unbilled usage:"
head -n 3 network_bills_sorted.txt

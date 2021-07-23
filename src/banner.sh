BANNER="
   ___ _ _ _            
  / _ (_) | | __ _ _ __ 
 / /_)/ | | |/ _' | '__|
/ ___/| | | | (_| | |   
\/    |_|_|_|\__,_|_|   

"

while IFS= read -r line; do
    echo -e "\t$line"
done <<< "$BANNER"

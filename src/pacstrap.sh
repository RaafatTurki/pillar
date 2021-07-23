PACSTRAP_PGKS=""

# printing PKGS
GRP_ID=-1
for GRP in "${PKGS[@]}"; do
    ((GRP_ID=$GRP_ID+1))
    GRP_NAME=`echo $GRP | head -n1 | cut -d ' ' -f1`
    GRP_PKGS=`echo $GRP | cut -d ' ' -f 2-`
    echo -e "$GRP_ID\t$GRP_NAME\t$GRP_PKGS"
done

# building PACSTRAP_PGKS
SEL_GRP_IDS=$(input_valid "Group_IDs" "" "is_number")
for ID in $SEL_GRP_IDS; do
    GRP_PKGS=`echo ${PKGS[$ID]} | cut -d ' ' -f 2-`
    PACSTRAP_PGKS="$PACSTRAP_PGKS $GRP_PKGS"
done
PACSTRAP_PGKS=$(echo "$PACSTRAP_PGKS" | tr ' ' '\n' | sort -u | xargs)

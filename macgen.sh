#!/bin/bash
#GistID: c0b56b179d03ed64b9ee

SCRIPT_DIR='/disk'
FILES=$(ls $SCRIPT_DIR/start_*.sh)

num_macs_needed=$1
macs=()
new_macs=''
collision_test=''

# Text color variables
txtred='\e[0;31m'       # red
txtgrn='\e[0;32m'       # green
txtylw='\e[0;33m'       # yellow
txtblu='\e[0;34m'       # blue
txtpur='\e[0;35m'       # purple
txtcyn='\e[0;36m'       # cyan
txtwht='\e[0;37m'       # white
bldred='\e[1;31m'       # red    - Bold
bldgrn='\e[1;32m'       # green
bldylw='\e[1;33m'       # yellow
bldblu='\e[1;34m'       # blue
bldpur='\e[1;35m'       # purple
bldcyn='\e[1;36m'       # cyan
bldwht='\e[1;37m'       # white
txtund=$(tput sgr 0 1)  # Underline
txtbld=$(tput bold)     # Bold
txtrst='\e[0m'          # Text reset

# Feedback indicators
info=${bldwht}*${txtrst}
pass=${bldblu}*${txtrst}
warn=${bldred}!${txtrst}

mac_gen_rand() {
  # Made 5ca1ab1e for Brett
  MACADDR="5c:a1:ab:1e:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\).*$/\1:\2/')"
  echo $MACADDR
}

for i in $FILES; do
  for a in $(grep -io --color=never '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}' $i); do
    macs+=("$a")
  done
done

echo -ne ${bldblu}; echo -e "Used MACs: ${bldred}${#macs[@]}${bldblu}"
echo ${macs[@]} | sed 's/ /\n/g'; echo -en ${txtrst}

# The following is really ugly...
# check if we need new macs
if [ $num_macs_needed ]; then
  # loop through how many we need
  for (( i = 1 ; i <= $num_macs_needed ; i++ )); do
    success='false'
    until [[ $success = true ]]; do
      success='false'
      a=$(mac_gen_rand)
      echo "${macs[@]}" | grep "$a" &> /dev/null
      # append array if everything looks good
      if [[ $? -gt 0 ]]; then
        success='true'
        macs+=("$a")
      fi
    done
  done

  # find new macs
  echo -ne ${bldgrn}
  echo 'New MACs:'; echo "${macs[@]:$((${#macs[@]}-$num_macs_needed))}" | sed 's/ /\n/g'
  echo -ne ${txtrst}
fi

# fix any forgotten color escapes
echo -e ${txtrst}


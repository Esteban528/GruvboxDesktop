#! /bin/bash

#define icons for workspaces 1-9
ic=(󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰉛 󱨎 )

workspaces() {

	unset -v \
  o1 o2 o3 o4 o5 o6 o7 o8 o9 \
  f1 f2 f3 f4 f5 f6 f7 f8 f9

# Get occupied workspaces and remove workspace -99 aka scratchpad if it exists
# a="$(hyprctl workspaces | grep ID | awk '{print $3}')"
# a="$(echo "${a//-99/}" | sed '/^[[:space:]]*$/d')"
ows="$(hyprctl workspaces -j | jq '.[] | del(select(.id == -99)) | .id')"

for num in $ows; do
	export o"$num"="$num"
done

# Get Focused workspace for current monitor ID
arg="$1"
num="$(hyprctl monitors -j | jq --argjson arg "$arg" '.[] | select(.id == $arg).activeWorkspace.id')"
important="$(hyprctl monitors -j | jq --argjson arg "$arg" '.[] | select(.id == $arg).urgentWorkspace.id')"
export f"$num"="$num"

icon_Focused="󰮯"
declare -A icons

for ((i = 1; i <= 9; i++)); do
  if [ "$num" = "$i" ]; then
    icons[$i]="$icon_Focused"
  else
    icons[$i]=${ic[$i]}
  fi
done

echo 	"(eventbox :onscroll \"echo {} | sed -e 's/up/-1/g' -e 's/down/+1/g' | xargs hyprctl dispatch workspace\" \
          (box	:class \"workspace\"	:orientation \"h\" :space-evenly \"false\"  	\
              (button :onclick \"scripts/dispatch.sh 1\" :class \"w0$o1$f1\" \"${icons[1]} \") \
              (button :onclick \"scripts/dispatch.sh 2\" :class \"w0$o2$f2\" \"${icons[2]} \") \
              (button :onclick \"scripts/dispatch.sh 3\" :class \"w0$o3$f3\" \"${icons[3]} \") \
              (button :onclick \"scripts/dispatch.sh 4\" :class \"w0$o4$f4\" \"${icons[4]} \") \
              (button :onclick \"scripts/dispatch.sh 5\" :class \"w0$o5$f5\" \"${icons[5]} \") \
              (button :onclick \"scripts/dispatch.sh 6\" :class \"w0$o6$f6\" \"${icons[6]} \") \
              (button :onclick \"scripts/dispatch.sh 7\" :class \"w0$o7$f7\" \"${icons[7]} \") \
              (button :onclick \"scripts/dispatch.sh 8\" :class \"w0$o8$f8\" \"${icons[8]} \") \
              (button :onclick \"scripts/dispatch.sh 9\" :class \"w0$o9$f9\" \"${icons[9]} \") \
          )\
        )"
}

workspaces $1 
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r; do 
sleep 0.1
workspaces $1
done

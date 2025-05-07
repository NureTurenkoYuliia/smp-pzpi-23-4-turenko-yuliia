#!/bin/bash

check_params(){
    if [[ ! "$height" =~ ^-?[0-9]+$ || ! "$snow_width" =~ ^-?[0-9]+$ ]]; then
            echo "Параметри повинні бути цілими числами." >&2
            exit 2
    fi

    if ((height<=0 || snow_width<=0)); then
            echo "Параметри повинні бути додатніми." >&2
            exit 3
    fi

    if ((height<8 || snow_width<7)); then
            echo "Замалі параметри для побудови ялинки." >&2
            exit 4
    fi
}

if [[ $# -ne 2 ]]; then
    echo "Потрібно передати два аргументи." >&2
    exit 1
fi

height=$1
snow_width=$2

check_params

if((height % 2 != 0)); then
    height=$((height - 1))
fi

if((snow_width % 2 == 0)); then
    snow_width=$((snow_width - 1))
fi

difference=$((height - snow_width))

if((difference != 1)); then
    echo "Ширина снігу замала щоб побудувати ялинку." >&2
    exit 5
fi

symb1="*"
symb2="#"
t=0
tier_height=$(((height - 2) / 2))

while [[ $t -lt 2 ]]; do
    tier_width=$((t * 2 + 1))
    spaces=$(((snow_width - tier_width) / 2))
    i=0
    until [[ $i -ge $tier_height ]]; do
            printf "%*s" "$spaces" ""
            for((j=0; j < tier_width; j++)); do
                    if((i%2 == 0)); then
                            printf "%s" "$symb1"
                    else
                            printf "%s" "$symb2"
                    fi
            done
            echo
            tier_width=$((tier_width + 2))
            spaces=$((spaces - 1))
            i=$((i + 1))
    done
    if((tier_height % 2 != 0)); then
            symb1="#"
            symb2="*"
    fi
    tier_height=$((tier_height - 1))
    t=$((t + 1))
done

spaces=$(((snow_width - 3) / 2))
printf "%*s" "$spaces" ""
echo "###"
printf "%*s" "$spaces" ""
echo "###"

for((i=0; i < snow_width; i++)); do
    printf "%s" "*"
done
echo

exit 0
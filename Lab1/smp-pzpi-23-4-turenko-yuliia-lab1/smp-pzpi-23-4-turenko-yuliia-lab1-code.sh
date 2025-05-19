#!/bin/bash

default_encoding="cp1251"
locale_output="UTF-8"
quiet=false

if [[ "$1" == "--help" ]]; then
    echo "Використання: $0 [--help | --version] | [[-q|--quiet] [академ_група] файл_із_cist.csv]"
    echo "  --help         Показати це повідомлення і вийти"
    echo "  --version      Показати версію скрипта"
    echo "  -q, --quiet    Не виводити розклад у stdout"
    exit 0
elif [[ "$1" == "--version" ]]; then
    echo "Версія: 1.0"
    exit 0
elif [[ "$1" == "-q" || "$1" == "--quiet" ]]; then
    quiet=true
elif [[ "$1" == *.csv ]]; then
    file_input="$1"
elif [[ "$2" == *.csv ]]; then
    file_input="$2"
    group_input="$1"
fi

if [[ -z "$file_input" ]]; then
    mapfile -t csv_files < <(ls TimeTable_??_??_20??.csv 2>/dev/null | sort)
    if [[ ${#csv_files[@]} -eq 0 ]]; then
        echo "CSV файли не знайдено." >&2
        exit 1
    fi
    csv_files+=("Вийти")
    echo "Виберіть CSV файл зі списку:"
    select selected_file in "${csv_files[@]}"; do
        if [[ "$selected_file" = "Вийти" ]]; then
            echo "Вихід із програми."
            exit 0
        fi

        if [[ -n "$selected_file" ]]; then
            file_input="$selected_file"
            break
        else
            echo "Неправильний вибір. Спробуйте ще раз."
        fi
    done
fi

if [[ ! -r "$file_input" ]]; then
    echo "Помилка: файл '$file_input' не знайдено або він недоступний для читання." >&2
    exit 1
fi

if [ ! -f "$file_input" ]; then
    echo "Помилка: файлу $file_input немає у поточній директорії. Передивіться ще раз назву та розширення файлу .csv" >&2
    exit 2
fi

converted_file=$(mktemp)
if ! iconv -f "$default_encoding" -t "$locale_output" "$file_input" > "$converted_file"; then
    echo "Помилка під час обробки файлу." >&2
    exit 1
fi

mapfile -t available_groups < <(iconv -f cp1251 -t utf-8 "$file_input" | grep -o 'ПЗПІ-[0-9]\+-[0-9]\+' | sort -u)

if [[ ${#available_groups[@]} -eq 0 ]]; then
    echo "У файлі не знайдено жодної групи." >&2
    rm -f "$converted_file"
    exit 1
fi

selected_group=""

if [[ -n "$group_input" ]]; then
    for g in "${available_groups[@]}"; do
        if [[ "$g" == "$group_input" ]]; then
            selected_group="$group_input"
            break
        fi
    done
    if [[ -z "$selected_group" ]]; then
        echo "Групу '$group_input' не знайдено у файлі. Доступні:" >&2
        printf ' - %s\n' "${available_groups[@]}" >&2
        rm -f "$converted_file"
        exit 1
    fi
else
    if [[ ${#available_groups[@]} -eq 1 ]]; then
        selected_group="${available_groups[0]}"
        echo "Автоматично обрана група: $selected_group"
    else
        PS3="Оберіть номер групи: "
        available_groups+=("Вийти")
        select group in "${available_groups[@]}"; do
            if [[ "$group" == "Вийти" ]]; then
                echo "Вихід із програми."
                exit 0
            elif [[ -n "$group" ]]; then
                selected_group="$group"
                break
            else
                echo "Невірний вибір. Спробуйте ще раз."
            fi
        done
    fi
fi


# Формуємо CSV для Google Календаря
output_file=$(basename "$file_input")
output_file="Google_${output_file}"
temp=$(mktemp)
sorted_data=$(mktemp)

sed 's/\r/\n/g' "$file_input" | iconv -f cp1251 -t utf-8 | awk -v GROUP="$selected_group" '
BEGIN {
    FS=","; OFS="\t"
}
NR == 1 { next }

function format_sort_key(date, time) {
    split(date, dmy, ".")
    split(time, hm, ":")
    return sprintf("%04d%02d%02d%02d%02d", dmy[3], dmy[2], dmy[1], hm[1], hm[2])
}

function trim_quotes(s) {
    gsub(/^"|"$/, "", s)
    return s
}

{
    line = $0
    match(line, /"[0-3][0-9]\.[0-1][0-9]\.[0-9]{4}"/)
    if (RSTART == 0) next
    field1 = substr(line, 1, RSTART - 2)
    rest = substr(line, RSTART)

    n = 0; in_quotes = 0; field = ""
    for (i = 1; i <= length(rest); i++) {
        c = substr(rest, i, 1)
        if (c == "\"") in_quotes = !in_quotes
        else if (c == "," && !in_quotes) {
            fields[++n] = field
            field = ""
        } else {
            field = field c
        }
    }
    fields[++n] = field
    for (i = 1; i <= n; i++) fields[i] = trim_quotes(fields[i])
    if (n < 12) next

    # Група (фільтр)
    match(field1, /(ПЗПІ-[0-9]+-[0-9]+)/, m)
    found_group = m[1]

    if (found_group != GROUP) next

    field1 = substr(field1, RSTART + RLENGTH)
    gsub(/^[[:space:]]+/, "", field1)
    subject = field1
    gsub(/^"|"$/, "", subject)
    gsub(/^- /, "", subject)

    desc = fields[11]
    type = "Інше"

    if (desc ~ /Лб/) type = "Лб"
    else if (desc ~ /Лк/) type = "Лк"
    else if (desc ~ /Пз/) type = "Пз"
    else if (desc ~ /Екз/i) type = "Екз"

    sort_key = format_sort_key(fields[1], fields[2])
    print subject, type, fields[1], fields[2], fields[3], fields[4], desc, sort_key
}' > "$temp"

# Сортування
sort -t $'\t' -k8,8 "$temp" > "$sorted_data"

# Генерація CSV для Google Calendar
awk -F'\t' '
BEGIN {
    OFS = ","
    print "Subject", "Start Date", "Start Time", "End Date", "End Time", "Description"
}

function format_date(date) {
    split(date, dmy, ".")
    return sprintf("%02d/%02d/%04d", dmy[2], dmy[1], dmy[3])
}

function format_time(time) {
    split(time, hmin, ":")
    h = hmin[1] + 0
    min = hmin[2]
    ap = (h >= 12) ? "PM" : "AM"
    if (h == 0) h = 12
    else if (h > 12) h -= 12
    return sprintf("%02d:%s %s", h, min, ap)
}

{
    subj_key = $1 "_" $2
    date_key = $3 "_" $7

    if ($2 == "Лб") {
        if (!(date_key in lab_seen)) {
            count[subj_key]++
            lab_seen[date_key] = count[subj_key]
        }
        number = lab_seen[date_key]
    } else {
        count[subj_key]++
        number = count[subj_key]
    }

    subject_full = $1 "; №" number
    start_date = format_date($3)
    start_time = format_time($4)
    end_date = format_date($5)
    end_time = format_time($6)
    desc = $7

    printf "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n", \
        subject_full, start_date, start_time, end_date, end_time, desc
}' "$sorted_data" > "$output_file"

echo "Файл '$output_file' створено успішно."
if [[ "$quiet" == false ]]; then
    cat "$output_file"
fi

rm -f "$converted_file" "$temp"
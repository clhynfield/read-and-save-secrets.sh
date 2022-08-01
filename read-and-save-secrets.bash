#!/usr/bin/env bash

# This script is designed to set and export a list of environment variables containing secrets, 
# storing them in a secrets vault (LastPass for now) for subsequent reuse. 
# This is particularly handy to put into a .envrc file for use with [direnv](https://direnv.net).

project='SECURE_PROJECT'
secret_variables='SECRET_VARIABLE'

read_secret() {
    local path="$1"
    note="$(lpass show --notes $path 2>/dev/null)"
    if [[ $? -ne 0 ]]; then
        echo "Can't read LastPass note" >&2
        return 1
    fi
    echo "$note"
}

write_secret() {
    local path="$1"
    local contents="$2"
    if ! echo "$contents" | lpass add --non-interactive --notes "$path"; then
        echo "Can't write LastPass note" >&2
        return 1
    fi
}

set_and_forget() {
    local variable="$1"
    if [[ -z "${!variable}" ]]; then
        value="$(read_secret $PROJECT/$variable)"
        if [[ -n "$value" ]]; then
            eval "$(echo $variable=\"$value\")"
        else
            read -s -p "$variable:" "$variable"
            write_secret "$PROJECT/$variable" "${!variable}"
        fi
        export "$variable"
    fi
}

for secret_variable in $secret_variables; do
    set_and_forget $secret_variable
done

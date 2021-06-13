#!/bin/sh
# Put variables to file
set -e

ENV_VARIABLES=$(awk 'BEGIN{for(v in ENVIRON) print "$"v}')

for FILE in /etc/raddb/mods-available/sql
do
    envsubst "$ENV_VARIABLES" <$FILE | sponge $FILE
done

for FILE in /etc/raddb/mods-available/eap
do
    envsubst "$ENV_VARIABLES" <$FILE | sponge $FILE
done

for FILE in /etc/raddb/certs/ca.cnf
do
    envsubst "$ENV_VARIABLES" <$FILE | sponge $FILE
done

for FILE in /etc/raddb/certs/server.cnf
do
    envsubst "$ENV_VARIABLES" <$FILE | sponge $FILE
done

# Freeradius own script

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    set -- freeradius "$@"
fi

# check for the expected command
if [ "$1" = 'freeradius' ]; then
    shift
    exec freeradius -f "$@"
fi

# many people are likely to call "radiusd" as well, so allow that
if [ "$1" = 'radiusd' ]; then
    shift
    exec freeradius -f "$@"
fi

# else default to run whatever the user wanted like "bash" or "sh"
exec "$@"
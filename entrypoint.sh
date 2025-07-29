#!/bin/sh
set -e

# Execute any potential shell scripts in the entrypoint.d/ folder.
find "/entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
    case "${f}" in
        *.sh)
            if [ -x "${f}" ]; then
                echo "Launching ${f}";
                "${f}"
            else
                echo "Ignoring ${f}, not executable";
            fi
            ;;
        *)
            echo "Ignoring ${f}";;
    esac
done

# Run rsync as a "deamon", but keep it in the foreground with its log sent to
# stdout instead of a file. Any additional CMD arguments are just appended.
exec rsync --daemon --no-detach --log-file=/dev/stdout --config=/etc/rsyncd.conf $@

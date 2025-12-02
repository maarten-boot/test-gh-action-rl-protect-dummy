#! /usr/bin/env bash

# bools arrive as string: 'true', 'false'
# ints arrive as string

cleanup()
{
    # suspicious chars are mainly `$><|&;

    # for bool we can remove `$><|;&
    RL_VERBOSE=${RL_VERBOSE//[\`\$><|;&]/}
    RL_RETURN_STATUS=${RL_RETURN_STATUS//[\`\$><|;&]/}
    RL_CONCISE=${RL_CONCISE//[\`\$><|;&]/}
    RL_NO_COLOR=${RL_NO_COLOR//[\`\$><|;&]/}

    # file or dir paths may not have `$><|;& so remove
    RL_ITEM_TO_SCAN=${RL_ITEM_TO_SCAN//[\`\$><|;&]/}
    RL_LOG_FILE=${RL_LOG_FILE//[\`\$><|;&]/}
    RL_PROFILE=${RL_PROFILE//[\`\$><|;&]/} # is a string with : or a path

    # a server is either ip4 or ip6 or dns; safe to remove $`><|;&
    RL_SERVER=${RL_SERVER//[\`\$><|;&]/}
    RL_PROXY_SERVER=${RL_PROXY_SERVER//[\`\$><|;&]/}

    # a port is always numeric, remove all other chars
    RL_PROXY_PORT=${RL_PROXY_PORT//[^0-9]/}

    # a user may not contain: `$><|&;
    RL_PROXY_USER=${RL_PROXY_USER//[\`\$><|;&]/}

    RL_CHECK_DEPS=${RL_CHECK_DEPS//[\`\$><|;&]/} # a comma sep value /[a-z]+/i + ,
}

validate_proxy()
{
    # if proxy server then proxy host
    if [ "${RL_PROXY_SERVER}" != "" ]
    then
        if [ "${RL_PROXY_PORT}" == "" ]
        then
            echo "FATAL: when specifying a proxy server you also must specify a proxy port"
            exit 101
        fi
    fi

    # if proxy user then proxy pass and server and port
    if [ "${RL_PROXY_USER}" != "" ]
    then
        if [ "${RL_PROXY_PASSWORD}" == "" ]
        then
            echo "FATAL: when specifying a proxy user you also must specify a proxy password"
            exit 101
        fi
        if [ "${RL_PROXY_SERVER}" == "" ]
        then
            echo "FATAL: when specifying a proxy user you must also specify a server and port"
            exit 101
        fi
    fi
}

validate()
{
    validate_proxy
}

install_tool()
{
    # pip install rl-protect
    # rl-protect --version

    # rl-deploy install just to show that pip install works now when python is installed
    pip install rl-deploy
    rl-deploy --version
}

show_params()
{
    if [ "${RL_VERBOSE}" ]
    then
        cat <<!
Params:
    RL_ITEM_TO_SCAN:    ${RL_ITEM_TO_SCAN}
    RL_PROFILE:         ${RL_PROFILE}
    RL_LOG_FILE:        ${RL_LOG_FILE}
    RL_CHECK_DEPS:      ${RL_CHECK_DEPS}
    RL_CONCISE:         ${RL_CONCISE}
    RL_SERVER:          ${RL_SERVER}
    RL_PROXY_SERVER:    ${RL_PROXY_SERVER}
    RL_PROXY_PORT:      ${RL_PROXY_PORT}
    RL_PROXY_USER:      ${RL_PROXY_USER}
    RL_PROXY_PASSWORD:  ${RL_PROXY_PASSWORD}
    RL_RETURN_STATUS:   ${RL_RETURN_STATUS}
    RL_NO_COLOR:        ${RL_NO_COLOR}
    RL_VERBOSE:         ${RL_VERBOSE}
!
    fi
}

run_scan()
{
    local PARAMS=( ${RL_ITEM_TO_SCAN} )

    # strings
    if [ "${RL_PROFILE}" != "" ]
    then
        PARAMS+=( --profile=${RL_PROFILE} )
    fi

    if [ "${RL_SERVER}" != "" ]
    then
        PARAMS+=( --rl-server=${RL_SERVER} )
    fi

    if [ "${RL_TOKEN}" != "" ]
    then
        PARAMS+=( --rl-token=${RL_TOKEN} )
    fi

    if [ "${RL_LOG_FILE}" != "" ]
    then
        PARAMS+=( --log-file=${RL_LOG_FILE} )
    fi

    if [ "${RL_CHECK_DEPS}" != "" ]
    then
        PARAMS+=( --check-deps=${RL_CHECK_DEPS} )
    fi

    # bools
    if [ "${RL_RETURN_STATUS}" == "true" ]
    then
        PARAMS+=( --return-status=${RL_RETURN_STATUS} )
    fi

    if [ "${RL_NO_COLOR}" == "true" ]
    then
        PARAMS+=( --no-color=${RL_NO_COLOR} )
    fi

    if [ "${RL_CONCISE}" == "true" ]
    then
        PARAMS+=( --concise=${RL_CONCISE} )
    fi

    # proxy
    if [ "${RL_PROXY_SERVER}" != "" ]
    then
        PARAMS+=( --proxy-server=${RL_PROXY_SERVER} )
    fi
    if [ "${RL_PROXY_PORT}" != "" ]
    then
        PARAMS+=( --proxy-port=${RL_PROXY_PORT} )
    fi
    if [ "${RL_PROXY_USER}" != "" ]
    then
        PARAMS+=( --proxy-user=${RL_PROXY_USER} )
    fi
    if [ "${RL_PROXY_PASSWORD}" != "" ]
    then
        PARAMS+=( --proxy-password=${RL_PROXY_PASSWORD} )
    fi

    # intercept output from 1 and 2
    echo rl-protect ${PARAMS[@]} &2>2 | tee 1
    # extract the exit code
    RESULT_CODE=$?

    if [ "${RL_VERBOSE}" == "true" ]
    then
        echo "RESULT_CODE: ${RESULT_CODE}"

        echo "Stdout:"
        cat 1

        echo "Stderr:"
        cat 2
    fi

    # now parse either the output or use the RESULT_CODE
    # to set the OUT_STATUS and the OUT_DESCRIPTION

    OUT_DESCRIPTION="THIS IS A DESCRIPTION MESSAGE showing pass or fail"
    OUT_STATUS="success" # or scan fail
}

set_output()
{
    echo "description=${OUT_DESCRIPTION}" >> $GITHUB_OUTPUT
    echo "status=${OUT_STATUS}"           >> $GITHUB_OUTPUT
}

main()
{
    cleanup
    validate
    show_params # only if verbose
    install_tool
    run_scan
    set_output
}

main

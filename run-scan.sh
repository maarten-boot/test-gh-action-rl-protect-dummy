#! /usr/bin/env bash

install_rl_protect()
{
    pip install rl-protect
    rl-protect --version
}

install_rl_deploy()
{
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
    RL_TOKEN:           ${RL_TOKEN} # remove later
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
    # rl-protect ${RL_ITEM_TO_SCAN} &2>2 | tee 1
    # intercept output from 1 and 2

    OUT_DESCRIPTION="THIS IS A DESCRIPTION MESSAGE"
    OUT_STATUS="success"
}

set_output()
{
    echo "description=${OUT_DESCRIPTION}"  >> $GITHUB_OUTPUT
    echo "status=${OUT_STATUS}"                 >> $GITHUB_OUTPUT
}

main()
{
    install_rl_deploy
    # install_rl_protect

    show_params
    run_scan
    set_output
}

main

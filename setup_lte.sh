#!/usr/bin/bash

# Log to fixed location
LOG_FILE="./setup_lte.log"

# Don't use set -e in this script because we have explicit error handling below.
set +e

# start marker, reinitialize the log
sleep 5

# normal LTE connection
if [ ! -e /dev/cdc-wdm0 ]; then
    echo "NO COMPATIBLE LTE CARD DETECTED: not running LTE connection process"
    echo "NO COMPATIBLE LTE CARD DETECTED: not running LTE connection process">>${LOG_FILE}
else
    echo "---------------------">>${LOG_FILE}
    echo "- LTE CONNECT START -">>${LOG_FILE}
    echo "---------------------">>${LOG_FILE}

    # disable the interface
    WWAN_INTERFACE=$(qmicli --device=/dev/cdc-wdm0 --device-open-proxy --get-wwan-iface)
    echo "WWAN_INTERFACE is ${WWAN_INTERFACE}">>${LOG_FILE}
    ip link set dev $WWAN_INTERFACE down>>${LOG_FILE}


    # LTE module-specific configuration
    model=$(qmicli --device=/dev/cdc-wdm0 --device-open-proxy --dms-get-model | grep "Model:")
    echo "LTE Module $model"
    echo "LTE Module $model">>${LOG_FILE}
    if echo $model | grep "7455"; then    # this model requires raw-ip mode.
        # set raw-ip mode
        qmicli -d /dev/cdc-wdm0 -p -E raw-ip>>${LOG_FILE}
        # to confirm setting:
        qmicli -d /dev/cdc-wdm0 -e>>${LOG_FILE}
    fi

    # turn on interface
    ip link set dev $WWAN_INTERFACE up>>${LOG_FILE}
    # can run following to confirm, should show "connected". in some cases this may fail but the connection still works
    # qmicli -d /dev/cdc-wdm0 --wds-get-packet-service-status

    # T-MOBILE SPECIFIC: connect to wwan network
    lte_connected=false
    carrier="t-mobile" # for echo logging only

    # Test APN
    loop_count=1
    while [ "$lte_connected" != "true" ] && [ $loop_count -le 3 ]; do
        echo "Attempting to connect to T-Mobile TEST APN, Attempt #${loop_count}:"
        echo "Attempting to connect to T-Mobile TEST APN, Attempt #${loop_count}:">>${LOG_FILE}

        # Test APN
        echo "APN=IOT.TMOWHOLESALE"
        echo "APN=IOT.TMOWHOLESALE">>${LOG_FILE}
        qmicli --device=/dev/cdc-wdm0 --device-open-proxy --wds-start-network="ip-type=4,apn=IOT.TMOWHOLESALE" --client-no-release-cid>>${LOG_FILE}

        if [ $? -eq 0 ]; then
            echo "Successfully connected to T-Mobile!"
            echo "Successfully connected to T-Mobile!">>${LOG_FILE}
            lte_connected=true
            echo "lte_connected=${lte_connected}">>${LOG_FILE}
        else
            echo "ERROR: Failed to connect to T-Mobile. Retrying in 5s..."
            echo "ERROR: Failed to connect to T-Mobile. Retrying in 5s...">>${LOG_FILE}
            sleep 5
        fi
        loop_count=$(($loop_count+1))
    done

    # Regular APN
    loop_count=1
    while [ "$lte_connected" != "true" ] && [ $loop_count -le 3 ]; do
        echo "Attempting to connect to T-Mobile REGULAR APN, Attempt #${loop_count}:"
        echo "Attempting to connect to T-Mobile REGULAR APN, Attempt #${loop_count}:">>${LOG_FILE}

        # Regular APN
        echo "APN=fast.t-mobile.com"
        echo "APN=fast.t-mobile.com">>${LOG_FILE}
        qmicli --device=/dev/cdc-wdm0 --device-open-proxy --wds-start-network="ip-type=4,apn=fast.t-mobile.com" --client-no-release-cid>>${LOG_FILE}

        if [ $? -eq 0 ]; then
            echo "Successfully connected to T-Mobile!"
            echo "Successfully connected to T-Mobile!">>${LOG_FILE}
            lte_connected=true
        else
            echo "ERROR: Failed to connect to T-Mobile. Retrying in 5s..."
            echo "ERROR: Failed to connect to T-Mobile. Retrying in 5s...">>${LOG_FILE}
            sleep 5
        fi
        loop_count=$(($loop_count+1))
    done

    if [ "$lte_connected" != "true" ]; then
        echo "ERROR: LTE CONNECT COMPLETE FAILURE: carrier ${carrier}"
        echo "ERROR: LTE CONNECT COMPLETE FAILURE: carrier ${carrier}">>${LOG_FILE}
    else
        echo "SUCCESS: LTE CONNECTED"
        echo "SUCCESS: LTE CONNECTED">>${LOG_FILE}
    fi
    # T-MOBILE SPECIFIC; end block (repeat for each carrier)

    # request IP address via dhcp
    # this may cause the device to disconnect from other networks temporarily
    # this code works for any+all carriers
    lte_dhcp_received=false
    if [ "$lte_connected" == "true" ]; then
        lease_loop_count=1
        while [ "$lte_dhcp_received" != "true" ] && [ $lease_loop_count -le 5 ]; do
            echo "Attempting to request DHCP, Attempt #${lease_loop_count}:"
            echo "Attempting to request DHCP, Attempt #${lease_loop_count}:">>${LOG_FILE}
            udhcpc -q -f -S -n -i $WWAN_INTERFACE>>${LOG_FILE}
            if [ $? -eq 0 ]; then
                echo "Successfully received LTE DHCP lease."
                echo "Successfully received LTE DHCP lease.">>${LOG_FILE}
                lte_dhcp_received=true
                echo "lte_dhcp_received=${lte_dhcp_received}">>${LOG_FILE}
            else
                echo "ERROR: Failed to receive LTE DHCP lease. Retrying in 5s..."
                echo "ERROR: Failed to receive LTE DHCP lease. Retrying in 5s...">>${LOG_FILE}
                sleep 5
            fi
            lease_loop_count=$(($lease_loop_count+1))
        done
    fi

    if [ "$lte_dhcp_received" != "true" ]; then
        echo "ERROR: DHCP LEASE COMPLETE FAILURE: carrier ${carrier}"
        echo "ERROR: DHCP LEASE COMPLETE FAILURE: carrier ${carrier}">>${LOG_FILE}
    else
        echo "LTE NETWORK CONNECT SUCCESS: APN connect OK, DHCP lease OK: carrier ${carrier}"
        echo "LTE NETWORK CONNECT SUCCESS: APN connect OK, DHCP lease OK: carrier ${carrier}">>${LOG_FILE}
    fi
fi

set -e

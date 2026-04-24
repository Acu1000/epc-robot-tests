*** Settings ***
Documentation     Verification that the system blocks data transfer exceeding maximum throughput.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}          http://localhost:8000
${UE_ID}             10
${DEFAULT_BEARER}    9
${TOO_HIGH_MBPS}     1000
${EXPECTED_ERR}      less than or equal to 100

*** Test Cases ***
Scenario 11: Attempt to start data transfer exceeding maximum throughput
    [Documentation]    Goal: Verification whether the system prevents starting traffic above the allowed throughput limit.
    [Tags]             traffic    negative

    Given Simulator Is Reset And UE ${UE_ID} Is Connected
    When User Attempts To Start Data Transfer With ${TOO_HIGH_MBPS} Mbps For UE ${UE_ID}
    Then System Should Block The Operation With Message    ${EXPECTED_ERR}
    And Device ${UE_ID} Should Still Exist In The System


*** Keywords ***
Simulator Is Reset And UE ${id} Is Connected
    [Documentation]    Setting initial conditions: a clean network and one active device.
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    ${resp}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Should Be True    ${resp.status_code} < 400

User Attempts To Start Data Transfer With ${mbps} Mbps For UE ${id}
    [Documentation]    Calling the traffic start procedure with throughput above the allowed limit.
    ${body}=    Create Dictionary    protocol=tcp    Mbps=${mbps}
    ${response}=    POST On Session    epc    /ues/${id}/bearers/${DEFAULT_BEARER}/traffic    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

System Should Block The Operation With Message
    [Arguments]    ${msg}
    [Documentation]    Verification whether the system rejected the request and displayed the correct message.
    Should Be True    ${LAST_RESPONSE.status_code} >= 400
    Should Contain    ${LAST_RESPONSE.text}    ${msg}
    Log    The error status and message are correct.    level=INFO

Device ${id} Should Still Exist In The System
    [Documentation]    Final confirmation that the UE was not removed after rejected traffic request.
    GET On Session    epc    /ues/${id}    expected_status=200
    Log    Success: The device remained intact.    level=INFO
*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000
${UE_ID}    50

*** Test Cases ***
Clashing throughput values in different units
    Simulation With Single UE

    When Tried To Start Transfer With 1 Mbps, 2 kbps And 3 bps

    Then Attempt Blocked

*** Keywords ***
Simulation With Single UE
    Create Session    epc    ${BASE_URL}
    ${response}=    POST On Session    epc    /reset
    ${body}=    Create Dictionary    ue_id=${UE_ID}
    ${resp}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Status Should Be    200    ${response}

Tried To Start Transfer With ${Mbps} Mbps, ${kbps} kbps And ${bps} bps
    ${data}=    Create Dictionary    protocol=tcp    Mbps=${Mbps}    kbps=${kbps}    bps=${bps}
    ${response}=    POST On Session    epc    /ues/${UE_ID}/bearers/9/traffic    json=${data}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Attempt Blocked
    Status Should Be    422    ${LAST_RESPONSE}
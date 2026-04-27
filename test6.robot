*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000
${UE_ID}    50
${KBPS_SPEED}    50
${PROTOCOL}    tcp
${BEARER_ID}    5

*** Test Cases ***
Incorrect bearer id test
    Given Blank Simulation
    UE With ID ${UE_ID} Connected

    When Attempted To Start Transmission With UE ID ${UE_ID} And Bearer ID ${BEARER_ID}

    Returned Status Is Bad Request
    And Simulation Is Up

*** Keywords ***
Blank Simulation
    Create Session    epc    ${BASE_URL}
    ${response}=    POST On Session    epc    /reset
    Status Should Be    200    ${response}

UE With ID ${id} Connected
    ${body}=    Create Dictionary    ue_id=${id}
    ${response}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Status Should Be    200    ${response}

Attempted To Start Transmission With UE ID ${ue_id} And Bearer ID ${bearer_id}
    ${data}=    Create Dictionary    protocol=${PROTOCOL}    kbps=${KBPS_SPEED}
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers/${bearer_id}/traffic    json=${data}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Returned Status Is Bad Request
    Status Should Be    400    ${LAST_RESPONSE}

Simulation Is Up
    ${LAST_RESPONSE}=    GET On Session    epc    /ues
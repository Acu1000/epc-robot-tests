*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
Returns Not Found On Get Incorrect UE ID
    Given Blank Simulation
    When Attempted To Get Info For UE ID 50
    Then Attempt Returns Not Found

*** Keywords ***
Blank Simulation
    Create Session    epc    ${BASE_URL}
    ${response}=    POST On Session    epc    /reset
    Status Should Be    200    ${response}

Attempted To Get Info For UE ID ${ue_id}
    ${response}=    GET On Session    epc    /ues/${ue_id}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Attempt Returns Not Found
    Status Should Be    404    ${LAST_RESPONSE}
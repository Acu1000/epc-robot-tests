*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000
${MIN_UE_ID}    0
${MAX_UE_ID}    100
${UE_COUNT}     ${MAX_UE_ID}-${MIN_UE_ID}+1

*** Test Cases ***
Create Network With Every Possible UE
    Given Blank Simulation
    When Created UEs With IDs From ${MIN_UE_ID} To ${MAX_UE_ID} Inclusive
    # TODO: Also check for UE count in simulation
    Then Simulation Is Up

*** Keywords ***
Blank Simulation
    Create Session    epc    ${BASE_URL}
    ${response}=    POST On Session    epc    /reset
    Status Should Be    200    ${response}

Create UE With ID ${ue_id}
    ${data}=    Create Dictionary    ue_id=${ue_id}
    ${response}=    POST On Session    epc    /ues    json=${data}
    Status Should Be    200    ${response}

Created UEs With IDs From ${from} To ${to} Inclusive
    FOR    ${i}    IN RANGE    ${from}    ${to}+1
        Log    ${i}
        Create UE With ID ${i}
    END

Simulation Is Up
    ${response}=    GET On Session    epc    /ues
    Status Should Be    200    ${response}

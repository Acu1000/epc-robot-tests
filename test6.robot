*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
Incorrect bearer id test
    Create Session    mysession    ${BASE_URL}

    ${response}=    POST On Session    mysession    /reset
    Status Should Be    200    ${response}

    ${data}=    Create Dictionary    ue_id=50
    ${response}=    POST On Session    mysession    /ues    json=${data}
    Status Should Be    200    ${response}

    ${data}=    Create Dictionary    protocol=tcp    kbps=50
    ${response}=    POST On Session    mysession    /ues/50/bearers/5/traffic    json=${data}    expected_status=any
    Status Should Be    400    ${response}
    
    ${response}=    GET On Session    mysession    /
    Status Should Be    200    ${response}
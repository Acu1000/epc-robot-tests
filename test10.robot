*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
Incorrect bearer id test
    Create Session    mysession    ${BASE_URL}

    ${response}=    POST On Session    mysession    /reset
    Status Should Be    200    ${response}

    ${data}=    Create Dictionary    ue_id=60
    ${response}=    POST On Session    mysession    /ues    json=${data}
    Status Should Be    200    ${response}

    ${data}=    Create Dictionary    bearer_id=5
    ${response}=    POST On Session    mysession    /ues/60/bearers    json=${data}
    Status Should Be    200    ${response}

    ${data}=    Create Dictionary    bearer_id=6
    ${response}=    POST On Session    mysession    /ues/60/bearers    json=${data}
    Status Should Be    200    ${response}

    ${data}=    Create Dictionary    protocol=tcp    kbps=50
    ${response}=    POST On Session    mysession    /ues/60/bearers/5/traffic    json=${data}
    Status Should Be    200    ${response}

    ${data}=    Create Dictionary    protocol=tcp    kbps=50
    ${response}=    POST On Session    mysession    /ues/60/bearers/6/traffic    json=${data}
    Status Should Be    200    ${response}

    # Supposed to not put bearer id here but it seems impossible without it currently?
    ${response}=    DELETE On Session    mysession    /ues/60/bearers/5/traffic    json=${data}
    Status Should Be    200    ${response}

    ${response}=    GET On Session    mysession    /
    Status Should Be    200    ${response}
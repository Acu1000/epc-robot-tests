*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
Create large network test
    Create Session    mysession    ${BASE_URL}

    ${response}=    POST On Session    mysession    /reset
    Status Should Be    200    ${response}

    FOR    ${i}    IN RANGE    1    101
        ${data}=    Create Dictionary    ue_id=${i}
        ${response}=    POST On Session    mysession    /ues    json=${data}
        Status Should Be    200    ${response}
    END
    
    ${response}=    GET On Session    mysession    /ues
    Status Should Be    200    ${response}

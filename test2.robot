*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
Test Stworzenie Duzej Sieci
    Given System Jest Zresetowany
    When Stworzono 100 UE
    Then System Dziala

*** Keywords ***
System Jest Zresetowany
    Create Session    epc    ${BASE_URL}
    ${response}=    POST On Session    epc    /reset
    Status Should Be    200    ${response}

Stworz UE z ID ${ue_id}
    ${data}=    Create Dictionary    ue_id=${ue_id}
    ${response}=    POST On Session    epc    /ues    json=${data}
    Status Should Be    200    ${response}

Stworzono ${count} UE
    FOR    ${i}    IN RANGE    1    ${count}+1
        Stworz UE z ID ${i}
    END

System Dziala
    ${response}=    GET On Session    epc    /ues
    Status Should Be    200    ${response}

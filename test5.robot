*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
Start Transfer DL Poprawny
    [Documentation]    Weryfikacja rozpoczecia transferu danych dla poprawnego UE
    [Tags]    traffic    positive
    Create Session    epc    ${BASE_URL}

  
    ${body}=    Create Dictionary    ue_id=10
    ${attach}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Should Be True    ${attach.status_code} == 200 or ${attach.status_code} == 201

    ${traffic_body}=    Create Dictionary    protocol=tcp    Mbps=10
    ${response}=    POST On Session    epc    /ues/10/bearers/9/traffic    json=${traffic_body}    expected_status=any
    Log To Console    ${response.status_code}
    Log To Console    ${response.text}

    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 201
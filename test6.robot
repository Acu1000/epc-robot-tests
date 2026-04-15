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
    Given Symulator Jest Zresetowany I UE ${UE_ID} Podlaczone
    When Proba Rozpoczecia Transmisji Dla UE ${UE_ID} Z Bearerem ${BEARER_ID}
    Then Powinno Zwrocic Status 400
    And Aplikacja Powinna Byc aktywna

*** Keywords ***
Symulator Jest Zresetowany I UE ${id} Podlaczone
    [Documentation]    Ustawienie warunków początkowych: czysta sieć i jedno aktywne urządzenie 
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    ${resp}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Should Be True    ${resp.status_code} < 400

Proba Rozpoczecia Transmisji Dla UE ${ue_id} Z Bearerem ${bearer_id}
    ${data}=    Create Dictionary    protocol=${PROTOCOL}    kbps=${KBPS_SPEED}
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers/${bearer_id}/traffic    json=${data}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Powinno Zwrocic Status ${status}
    Status Should Be    400    ${LAST_RESPONSE}

Aplikacja Powinna Byc Aktywna
    ${response}=    GET On Session    epc    /
    Status Should Be    200    ${response}
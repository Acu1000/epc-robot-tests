*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Keywords ***
Utwórz sesję API
    Create Session    epc    ${BASE_URL}

Dodaj urządzenie UE
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    ue_id=${ue_id}
    ${response}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Status odpowiedzi powinien być 422
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    422

Odpowiedź powinna zawierać komunikat o zbyt dużym ID
    Should Contain    ${LAST_RESPONSE.text}    less than or equal to 100

Uruchom transfer danych
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    protocol=tcp    Mbps=10
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers/9/traffic    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Status odpowiedzi powinien być sukcesem
    Should Be True    ${LAST_RESPONSE.status_code} == 200 or ${LAST_RESPONSE.status_code} == 201


Pobierz listę urządzeń UE
    ${response}=    GET On Session    epc    /ues    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Lista urządzeń UE nie powinna być pusta
    Pobierz listę urządzeń UE
    ${response_json}=    Evaluate    $LAST_RESPONSE.json()
    Should Not Be Empty    ${response_json}

Wykonaj reset symulatora
    ${response}=    POST On Session    epc    /reset    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Status resetu powinien być sukcesem
    Should Be True    ${LAST_RESPONSE.status_code} == 200 or ${LAST_RESPONSE.status_code} == 204

Lista urządzeń UE powinna być pusta technicznie
    Pobierz listę urządzeń UE
    ${response_json}=    Evaluate    $LAST_RESPONSE.json()
    Length Should Be    ${response_json["ues"]}    0
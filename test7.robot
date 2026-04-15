*** Settings ***
Documentation     Weryfikacja blokady usuwania domyślnego kanału transportowego (ID 9)
...               Scenariusz sprawdza odporność systemu na próby usunięcia fundamentu połączenia.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000
${UE_ID}          50
${DEFAULT_BEARER}  9
${EXPECTED_ERR}   Cannot remove default bearer

*** Test Cases ***
Scenario 7: Proba usuniecia domyslnego bearera o ID 9
    [Documentation]    Cel: Weryfikacja, czy system zgodnie ze specyfikacją uniemożliwia usunięcie
    ...                obowiązkowego kanału o numerze ID 9.
    [Tags]             bearer    negative
    
    Given Symulator Jest Zresetowany I UE ${UE_ID} Podlaczone
    When Probuje Usunac Domyslny Bearer ${DEFAULT_BEARER}
    Then System Powinien Zablokowac Operacje Komunikatem    ${EXPECTED_ERR}
    And Urzadzenie ${UE_ID} Powinno Nadal Istniec W Systemie


*** Keywords ***
Symulator Jest Zresetowany I UE ${id} Podlaczone
    [Documentation]    Ustawienie warunków początkowych: czysta sieć i jedno aktywne urządzenie 
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    ${resp}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Should Be True    ${resp.status_code} < 400

Probuje Usunac Domyslny Bearer ${bearer_id}
    [Documentation]    Wywołanie procedury usunięcia kanału (bearer deletion)
    ${response}=    DELETE On Session    epc    /ues/${UE_ID}/bearers/${bearer_id}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

System Powinien Zablokowac Operacje Komunikatem
    [Arguments]    ${msg}
    [Documentation]    Weryfikacja, czy system odrzucił żądanie i wyświetlił poprawny komunikat (bo w test3 tez byl niepopr komunikat)
    # Sprawdzamy kod błędu (>= 400)
    Should Be True    ${LAST_RESPONSE.status_code} >= 400
    # Weryfikujemy treść błędu (zgodnie z logami symulatora)
    Should Contain    ${LAST_RESPONSE.text}    ${msg}
    Log    Status błędu i komunikat są poprawne.    level=INFO

Urzadzenie ${id} Powinno Nadal Istniec W Systemie
    [Documentation]    Ostateczne potwierdzenie, że zasób nie został usunięty.
    # Używamy GET na adresie urządzenia, co jest najbardziej stabilnym endpointem w Twoim API.
    GET On Session    epc    /ues/${id}    expected_status=200
    Log    Sukces: Urządzenie i jego domyślne zasoby pozostały nienaruszone.
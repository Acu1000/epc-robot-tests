*** Settings ***
Documentation     Scenariusz 4: Weryfikacja blokady transferu w kierunku UL (tylko DL jest dozwolony).
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000
${UE_50}          50
${UE_51}          51

*** Test Cases ***
Scenariusz 4 - Próba przesyłania danych w kierunku UL
    [Documentation]    Test sprawdza, czy symulator poprawnie odrzuca próby 
    ...                rozpoczęcia transferu danych w niedozwolonym kierunku Uplink.
    [Tags]    traffic    negative
    
    Given Symulator Jest Zresetowany I Urzadzenia O ID ${UE_50} Oraz ${UE_51} Sa Podlaczone
    When Uzytkownik Probuje Uruchomic Transfer UL Dla Urzadzenia ${UE_50} Na Bearerze 9
    Then Proba Przeslania Danych Powinna Zostac Odrzucona Przez Symulator


*** Keywords ***
Symulator Jest Zresetowany I Urzadzenia O ID ${id1} Oraz ${id2} Sa Podlaczone
    [Documentation]    Resetuje symulator i podłącza dwa urządzenia testowe.
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body1}=    Create Dictionary    ue_id=${id1}
    ${body2}=    Create Dictionary    ue_id=${id2}
    POST On Session    epc    /ues    json=${body1}    expected_status=any
    POST On Session    epc    /ues    json=${body2}    expected_status=any

Uzytkownik Probuje Uruchomic Transfer UL Dla Urzadzenia ${ue_id} Na Bearerze ${bearer_id}
    [Documentation]    Wysyła żądanie startu ruchu z parametrem direction=UL.
    ${body}=    Create Dictionary    protocol=tcp    Mbps=10    direction=UL
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers/${bearer_id}/traffic    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Proba Przeslania Danych Powinna Zostac Odrzucona Przez Symulator
    [Documentation]    Weryfikacja, czy system zwrócił kod błędu.
    Log    UWAGA: Według planu testów system powinien zwrócić błąd (>=400). Jeśli otrzymano 200, oznacza to błąd aplikacji (P1).    level=WARN
    Should Be True    ${LAST_RESPONSE.status_code} >= 400    msg=BŁĄD KRYTYCZNY: Symulator pozwolił na transfer UL mimo zakazu w dokumentacji!
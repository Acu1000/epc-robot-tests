*** Settings ***
Documentation     Scenariusz 4: Próba przesyłania danych w kierunku UL.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000

*** Test Cases ***
Próba przesłania danych w kierunku UL
    [Documentation]    Weryfikacja blokady transferu w kierunku UL (tylko DL jest dozwolony).
    [Tags]    traffic    negative
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset

    # Warunki początkowe: Podłączone UE 50 i 51 [cite: 919, 1286]
    ${ue50}=    Create Dictionary    ue_id=${50}
    ${ue51}=    Create Dictionary    ue_id=${51}
    POST On Session    epc    /ues    json=${ue50}
    POST On Session    epc    /ues    json=${ue51}

    # Próba rozpoczęcia transferu UL
    ${body}=    Create Dictionary    protocol=tcp    Mbps=10    direction=UL
    ${response}=    POST On Session    epc    /ues/50/bearers/9/traffic    json=${body}    expected_status=any

    # Oczekiwany rezultat wg planu: Próba zostanie powstrzymana [cite: 923, 1289]
    # UWAGA: Twój symulator obecnie zwraca 200, co jest błędem P1 (brak walidacji).
    # Zmieniamy test tak, aby pokazywał błąd, dopóki deweloperzy tego nie naprawią.
    Should Be True    ${response.status_code} >= 400    msg=BŁĄD KRYTYCZNY: Symulator pozwolił na transfer UL mimo zakazu w dokumentacji!
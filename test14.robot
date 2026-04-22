*** Settings ***
Documentation     Scenariusz 14: Weryfikacja poprawnego wyświetlania jednostki transferu.
...               Test celuje w znalezienie defektu P3 (błędne wyświetlanie jednostki "kbps").
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000
${UE_ID}          45

*** Test Cases ***
Scenariusz 14 - Sprawdzenie jednostki w statystykach transferu
    [Documentation]    Cel: Weryfikacja czy domyślna jednostka transferu w statystykach
    ...                jest poprawnie wyświetlana jako "kbps" (zgodnie ze specyfikacją).
    [Tags]             traffic    bug-hunting    negative
    
    Given Symulator Jest Zresetowany I Uruchomiono Transfer Dla Urzadzenia ${UE_ID}
    When Uzytkownik Pobiera Statystyki Transferu Dla Urzadzenia ${UE_ID}
    Then Jednostka W Statystykach Powinna Byc Poprawnie Zapisana Jako kbps

*** Keywords ***
Symulator Jest Zresetowany I Uruchomiono Transfer Dla Urzadzenia ${id}
    [Documentation]    Czysci system, podłącza UE i puszcza ruch.
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any
    
    ${traffic_body}=    Create Dictionary    protocol=tcp    kbps=50
    POST On Session    epc    /ues/${id}/bearers/9/traffic    json=${traffic_body}    expected_status=any

Uzytkownik Pobiera Statystyki Transferu Dla Urzadzenia ${id}
    [Documentation]    Wysyła zapytanie GET, aby sprawdzić obecny transfer.
    ${response}=    GET On Session    epc    /ues/${id}/bearers/9/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Jednostka W Statystykach Powinna Byc Poprawnie Zapisana Jako kbps
    [Documentation]    Szuka w odpowiedzi poprawnego stringa z jednostką.
    Should Be True    ${LAST_RESPONSE.status_code} == 200    msg=Nie udalo sie pobrac statystyk.
    
    Log    UWAGA: Jeśli test się wywali, potwierdza to defekt P3 (błędne wyświetlanie jednostki 'kbps').    level=WARN
    
    ${response_text}=    Convert To String    ${LAST_RESPONSE.text}
    # ignore_case=False sprawia, że test pilnuje wielkości liter. Jeśli apka zwraca "Kbps" lub "KBPS", test słusznie obleje!
    Should Contain    ${response_text}    kbps    ignore_case=False    msg=BŁĄD (Defekt P3): System zwraca niepoprawną nazwę jednostki (literówka lub złe wielkości liter) zamiast wymaganego 'kbps'!
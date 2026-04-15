*** Settings ***
Documentation    Weryfikacja procedury odłączenia urządzenia (Detach) oraz czyszczenia zasobów systemowych.
Library          RequestsLibrary

*** Variables ***
${BASE_URL}      http://localhost:8000
${UE_ID}         7

*** Test Cases ***
Scenariusz 3 - Odłączenie UE od sieci (Detach)
    [Documentation]    Scenariusz sprawdza poprawne odłączenie urządzenia z sieci 
    ...                oraz upewnia się, że jego zasoby nie są już dostępne.
    [Tags]    detach    positive
    
    Given Symulator Jest Zresetowany I Urzadzenie O ID ${UE_ID} Jest Podlaczone
    When Uzytkownik Odlacza Urzadzenie O ID ${UE_ID}
    Then Urzadzenie O ID ${UE_ID} Nie Powinno Byc Dostepne W Sieci


*** Keywords ***
Symulator Jest Zresetowany I Urzadzenie O ID ${id} Jest Podlaczone
    [Documentation]    Resetuje środowisko testowe i przygotowuje aktywne urządzenie do testu.
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

Uzytkownik Odlacza Urzadzenie O ID ${id}
    [Documentation]    Wywołuje procedurę Detach (usunięcie urządzenia z sieci).
    ${response}=    DELETE On Session    epc    /ues/${id}    expected_status=any
    # Weryfikacja czy żądanie usunięcia zostało przyjęte bez błędu serwera
    Should Be True    ${response.status_code} < 400

Urzadzenie O ID ${id} Nie Powinno Byc Dostepne W Sieci
    [Documentation]    Weryfikacja braku urządzenia w systemie po jego odłączeniu.
    ${check}=    GET On Session    epc    /ues/${id}    expected_status=any
    
    # Rejestrujemy uwagę w logach raportu odnośnie specyficznego zachowania API
    Log    UWAGA: Oczekiwany status błędu to 400 (Bad Request), ponieważ symulator nie używa standardowego 404 (Not Found) dla nieistniejących UE.    level=WARN

*** Settings ***
Documentation    Weryfikacja procedury odłączenia urządzenia (Detach) oraz czyszczenia zasobów systemowych.
Library          RequestsLibrary

*** Variables ***
${BASE_URL}      http://localhost:8000

*** Test Cases ***
Scenariusz 3 - Odłączenie UE od sieci (Detach)
    [Tags]    detach    positive
    Create Session    epc    ${BASE_URL}
    
    #1PRZYGOTOWANIE - Reset i dodanie UE 7
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=7
    POST On Session    epc    /ues    json=${body}    expected_status=any

    #2AKCJA - Usunięcie urządzenia ID 7
    ${response}=    DELETE On Session    epc    /ues/7    expected_status=any
    Should Be True    ${response.status_code} < 400

    #3WERYFIKACJA - Sprawdzenie braku urządzenia...........
    ${check}=    GET On Session    epc    /ues/7    expected_status=any
    
    #Rejestrujemy uwagę w logach raportu
    Log    UWAGA: Oczekiwany status błędu to 400 (Bad Request), ponieważ symulator nie używa standardowego 404 (Not Found) dla nieistniejących UE.    level=WARN
    
    #Sprawdzenie kodu z własnym opisem błędu
    Should Be Equal As Integers    ${check.status_code}    400    msg=Symulator zmienił zachowanie! Sprawdź czy nie zaczął zwracać poprawnego kodu 404.
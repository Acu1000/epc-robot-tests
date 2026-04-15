*** Settings ***
Documentation     Scenariusz 8: Weryfikacja próby usunięcia nieaktywnego bearera z urządzenia.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000
${UE_41}          41
${BEARER_2}       2

*** Test Cases ***
Scenariusz 8 - Usunięcie nieaktywnego kanału transportowego
    [Documentation]    Scenariusz sprawdza, czy próba usunięcia kanału (bearer), 
    ...                który nie jest aktywny dla danego UE, kończy się błędem.
    [Tags]    bearer    negative
    
    Given Symulator Jest Zresetowany I Urzadzenie O ID ${UE_41} Jest Podlaczone
    When Uzytkownik Probuje Usunac Nieaktywny Bearer O ID ${BEARER_2} Dla Urzadzenia ${UE_41}
    Then System Powinien Zwrocic Blad O Braku Aktywnego Bearera


*** Keywords ***
Symulator Jest Zresetowany I Urzadzenie O ID ${id} Jest Podlaczone
    [Documentation]    Przygotowuje czyste środowisko z jednym podłączonym urządzeniem.
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

Uzytkownik Probuje Usunac Nieaktywny Bearer O ID ${bearer_id} Dla Urzadzenia ${ue_id}
    [Documentation]    Wywołuje procedurę usunięcia kanału, który nie istnieje (UE 41 ma tylko bearer 9).
    ${response}=    DELETE On Session    epc    /ues/${ue_id}/bearers/${bearer_id}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

System Powinien Zwrocic Blad O Braku Aktywnego Bearera
    [Documentation]    Weryfikacja kodu błędu oraz treści komunikatu z API.
    Should Be True    ${LAST_RESPONSE.status_code} >= 400
    Should Contain    ${LAST_RESPONSE.text}    Bearer not found
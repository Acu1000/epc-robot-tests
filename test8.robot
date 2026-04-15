*** Settings ***
Documentation     Scenariusz 8: Usunięcie kanału transportowego z UE.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000

*** Test Cases ***
Usunięcie nieaktywnego kanału transportowego
    [Documentation]    Weryfikacja próby usunięcia nieaktywnego bearera ID 2 dla UE 41.
    [Tags]    bearer    negative
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset

    # Warunki początkowe: UE 41 podłączone, posiada tylko bearer 9 [cite: 981, 982, 1348, 1349]
    ${body}=    Create Dictionary    ue_id=${41}
    POST On Session    epc    /ues    json=${body}

    # Próba usunięcia nieaktywnego bearera ID 2 [cite: 986, 1353]
    ${response}=    DELETE On Session    epc    /ues/41/bearers/2    expected_status=any

    # Oczekiwany rezultat: System odrzuca operację [cite: 989, 1356]
    Should Be True    ${response.status_code} >= 400
    # Dopasowano do rzeczywistego komunikatu symulatora: "Bearer not found"
    Should Contain    ${response.text}    Bearer not found
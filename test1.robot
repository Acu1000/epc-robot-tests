*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
atttach_to_ue
    [Documentation]    Weryfikacja, czy system blokuje dodanie UE z ID wiekszym niz 100.
    [Tags]    attach    negative    boundary
    Create Session    epc    ${BASE_URL}

    ${body}=    Create Dictionary    ue_id=101
    ${response}=    POST On Session    epc    /ues    json=${body}    expected_status=any

    Should Be Equal As Integers    ${response.status_code}    422
    Should Contain    ${response.text}    less than or equal to 100
*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
Resetowanie Symulatora
    [Documentation]    Weryfikacja resetu symulatora do stanu poczatkowego
    [Tags]    reset    positive
    Create Session    epc    ${BASE_URL}

    ${ue1}=    Create Dictionary    ue_id=1
    ${ue2}=    Create Dictionary    ue_id=2
    POST On Session    epc    /ues    json=${ue1}    expected_status=any
    POST On Session    epc    /ues    json=${ue2}    expected_status=any

  
    ${before}=    GET On Session    epc    /ues    expected_status=any
    ${before_json}=    Evaluate    $before.json()
    Should Not Be Empty    ${before_json}

   
    ${reset}=    POST On Session    epc    /reset    expected_status=any
    Should Be True    ${reset.status_code} == 200 or ${reset.status_code} == 204


    ${after}=    GET On Session    epc    /ues    expected_status=any
    ${after_json}=    Evaluate    $after.json()
    Length Should Be    ${after_json["ues"]}    0
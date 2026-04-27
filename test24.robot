*** Settings ***
Documentation    Scenario 24 - Manual Addition of Default Bearer.
Library          RequestsLibrary
Library          Collections

*** Variables ***
${BASE_URL}      http://localhost:8000
${UE_ID}         60

*** Test Cases ***
Scenario 24 - Prevent Manual Re-addition of Default Bearer 9
    [Documentation]    Verify if the system blocks manual addition of Bearer ID 9 if it already exists.
    [Tags]             bearer    negative
    
    Given Simulator Is Reset And Device With ID ${UE_ID} Is Connected
    When User Tries To Manually Add Bearer ID 9 For Device ${UE_ID}
    Then System Should Warn That Bearer Is Already Active


*** Keywords ***
Simulator Is Reset And Device With ID ${id} Is Connected
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

User Tries To Manually Add Bearer ID 9 For Device ${ue_id}
    ${body}=    Create Dictionary    bearer_id=${9}
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

System Should Warn That Bearer Is Already Active
    Should Be True    ${LAST_RESPONSE.status_code} >= 400    msg=BUG Found: Simulator allowed re-adding default bearer 9!
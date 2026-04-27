*** Settings ***
Documentation    Scenario 21 - Bearer ID Out of Range.
Library          RequestsLibrary
Library          Collections

*** Variables ***
${BASE_URL}      http://localhost:8000
${UE_ID}         20
${BAD_BEARER}    10

*** Test Cases ***
Scenario 21 - Bearer ID Out of Range (ID 10)
    [Documentation]    Verify that the system blocks adding a bearer ID outside the 1-9 range.
    [Tags]             bearer    negative
    
    Given Simulator Is Reset And Device With ID ${UE_ID} Is Connected
    When User Tries To Add Bearer ID ${BAD_BEARER} For Device ${UE_ID}
    Then The Bearer Addition Should Be Rejected


*** Keywords ***
Simulator Is Reset And Device With ID ${id} Is Connected
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

User Tries To Add Bearer ID ${bearer_id} For Device ${ue_id}
    ${body}=    Create Dictionary    bearer_id=${bearer_id}
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

The Bearer Addition Should Be Rejected
    Should Be True    ${LAST_RESPONSE.status_code} >= 400    msg=BUG Found: Simulator accepted Bearer ID 10 despite range limit 1-9!
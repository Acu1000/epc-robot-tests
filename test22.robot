*** Settings ***
Documentation    Scenario 22 - Throughput Limit Violation.
Library          RequestsLibrary
Library          Collections

*** Variables ***
${BASE_URL}      http://localhost:8000
${UE_ID}         30
${OVER_LIMIT}    101

*** Test Cases ***
Scenario 22 - Throughput Limit Violation
    [Documentation]    Verify that the system blocks traffic exceeding the 100 Mbps limit.
    [Tags]             traffic    negative
    
    Given Simulator Is Reset And Device With ID ${UE_ID} Is Connected
    When User Starts DL Traffic With ${OVER_LIMIT} Mbps For Device ${UE_ID}
    Then The Traffic Request Should Be Rejected


*** Keywords ***
Simulator Is Reset And Device With ID ${id} Is Connected
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

User Starts DL Traffic With ${speed} Mbps For Device ${ue_id}
    ${body}=    Create Dictionary    protocol=tcp    Mbps=${speed}
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers/9/traffic    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

The Traffic Request Should Be Rejected
    Should Be True    ${LAST_RESPONSE.status_code} >= 400    msg=BUG Found: Simulator allowed 101 Mbps traffic (max allowed is 100)!
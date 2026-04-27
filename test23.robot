*** Settings ***
Documentation    Scenario 23 - Ghost Traffic on Detached UE.
Library          RequestsLibrary
Library          Collections

*** Variables ***
${BASE_URL}      http://localhost:8000
${UE_ID}         50

*** Test Cases ***
Scenario 23 - Start Traffic For Detached UE
    [Documentation]    Verify that traffic cannot be started for a UE that has been detached.
    [Tags]             detach    negative
    
    Given Simulator Is Reset And Device With ID ${UE_ID} Is Connected
    And User Detaches Device With ID ${UE_ID}
    When User Tries To Start Traffic For Detached Device ${UE_ID}
    Then System Should Return Resource Not Found Error


*** Keywords ***
Simulator Is Reset And Device With ID ${id} Is Connected
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

User Detaches Device With ID ${id}
    DELETE On Session    epc    /ues/${id}    expected_status=any

User Tries To Start Traffic For Detached Device ${id}
    ${body}=    Create Dictionary    protocol=tcp    Mbps=10
    ${response}=    POST On Session    epc    /ues/${id}/bearers/9/traffic    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

System Should Return Resource Not Found Error
    Should Be True    ${LAST_RESPONSE.status_code} >= 400    msg=BUG Found: System allowed starting traffic for a detached UE!
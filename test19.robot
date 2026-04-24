*** Settings ***
Documentation     Verification of UE attachment using boundary ID values (0 and 100).
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}    http://localhost:8000
${UE_ID_MIN}   0
${UE_ID_MAX}   100

*** Test Cases ***
Scenario 19: Attach UE with boundary values (UE ID 100 and 0)
    [Documentation]    Goal: Verification whether the system allows UE creation with boundary ID values.
    [Tags]             ue    positive

    Given Simulator API Session Is Created
    When User Attempts To Add UE With ID ${UE_ID_MAX}
    Then Operation Should Be Successful

    When User Attempts To Add UE With ID ${UE_ID_MIN}
    Then Operation Should Be Successful

*** Keywords ***
Simulator API Session Is Created
    Create Session    epc    ${BASE_URL}

User Attempts To Add UE With ID ${id}
    ${body}=    Create Dictionary    ue_id=${id}
    ${response}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Operation Should Be Successful
    Should Be True    ${LAST_RESPONSE.status_code} == 200 or ${LAST_RESPONSE.status_code} == 201
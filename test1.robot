*** Settings ***
Documentation     Verification that the system rejects UE creation with ID greater than allowed maximum.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}        http://localhost:8000
${UE_ID}           101
${EXPECTED_ERR}    less than or equal to 100

*** Test Cases ***
Scenario 1: Attempt to add UE with ID greater than 100
    [Documentation]    Goal: Verification whether the system prevents adding UE with ID above the allowed limit.
    [Tags]             ue    negative

    Given Simulator API Session Is Created
    When User Attempts To Add UE With ID ${UE_ID}
    Then System Should Reject The Operation With Status 422
    And Response Should Contain Message    ${EXPECTED_ERR}


*** Keywords ***
Simulator API Session Is Created
    [Documentation]    Creating API session with simulator.
    Create Session    epc    ${BASE_URL}

User Attempts To Add UE With ID ${id}
    [Documentation]    Attempting to create UE with invalid ID.
    ${body}=    Create Dictionary    ue_id=${id}
    ${response}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

System Should Reject The Operation With Status 422
    [Documentation]    Verification whether API returned validation error.
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    422

Response Should Contain Message
    [Arguments]    ${msg}
    [Documentation]    Verification whether response contains expected validation message.
    Should Contain    ${LAST_RESPONSE.text}    ${msg}
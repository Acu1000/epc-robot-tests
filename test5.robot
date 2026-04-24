*** Settings ***
Documentation     Verification of successful data transfer start for a valid UE.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}    http://localhost:8000
${UE_ID}       10

*** Test Cases ***
Scenario 5: Start data transfer for a valid UE
    [Documentation]    Verification of successful data transfer start for a valid UE.
    [Tags]             traffic    positive

    Given Simulator API Session Is Created
    And UE ${UE_ID} Exists In The System
    When User Attempts To Start Data Transfer For UE ${UE_ID}
    Then Data Transfer Should Be Started Successfully


*** Keywords ***
Simulator API Session Is Created
    Create Session    epc    ${BASE_URL}

UE ${id} Exists In The System
    ${body}=    Create Dictionary    ue_id=${id}
    ${resp}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Should Be True    ${resp.status_code} < 400

User Attempts To Start Data Transfer For UE ${id}
    ${body}=    Create Dictionary    protocol=tcp    Mbps=10
    ${response}=    POST On Session    epc    /ues/${id}/bearers/9/traffic    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Data Transfer Should Be Started Successfully
    Should Be True    ${LAST_RESPONSE.status_code} == 200 or ${LAST_RESPONSE.status_code} == 201
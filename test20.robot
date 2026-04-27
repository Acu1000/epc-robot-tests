*** Settings ***
Documentation    Scenario 20 - Prevent Duplicate UE Attachment.
Library          RequestsLibrary
Library          Collections

*** Variables ***
${BASE_URL}      http://localhost:8000
${UE_ID}         10

*** Test Cases ***
Scenario 20 - Prevent Duplicate UE Attachment
    [Documentation]    Verify if the system blocks re-attaching a UE ID that is already active.
    [Tags]             attach    negative
    
    Given Simulator Is Reset And Device With ID ${UE_ID} Is Connected
    When User Tries To Attach Device With ID ${UE_ID} Again
    Then The Attachment Should Be Rejected By The System


*** Keywords ***
Simulator Is Reset And Device With ID ${id} Is Connected
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

User Tries To Attach Device With ID ${id} Again
    ${body}=    Create Dictionary    ue_id=${id}
    ${response}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

The Attachment Should Be Rejected By The System
    Should Be True    ${LAST_RESPONSE.status_code} >= 400    msg=BUG Found: Simulator allowed duplicate UE attachment (Status 200)!
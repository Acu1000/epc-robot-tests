*** Settings ***
Documentation     Scenario 12: Verification of the ability to remove a dedicated transport channel.
...               The test aims to detect the P2 defect described in the Test Plan (inability to remove a bearer).
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000
${UE_ID}          25
${BEARER_ID}      5

*** Test Cases ***
Scenario 12 - Remove dedicated bearer
    [Documentation]    Goal: Check if the system allows the removal of a dedicated
    ...                (non-default) transport channel according to the specification.
    [Tags]             bearer    bug-hunting    positive
    
    Given Simulator Is Reset And Device With ID ${UE_ID} Is Connected
    And Device With ID ${UE_ID} Has Additional Bearer With ID ${BEARER_ID}
    When User Attempts To Remove Bearer ${BEARER_ID} For Device ${UE_ID}
    Then System Should Allow Bearer Removal


*** Keywords ***
Simulator Is Reset And Device With ID ${id} Is Connected
    [Documentation]    Resets the environment and connects the device.
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

Device With ID ${ue_id} Has Additional Bearer With ID ${bearer_id}
    [Documentation]    Adds a new (dedicated) transport channel to the device.
    ${data}=    Create Dictionary    bearer_id=${bearer_id}
    POST On Session    epc    /ues/${ue_id}/bearers    json=${data}    expected_status=any

User Attempts To Remove Bearer ${bearer_id} For Device ${id}
    [Documentation]    Attempt to remove the channel (DELETE method). According to requirements, this should succeed.
    ${response}=    DELETE On Session    epc    /ues/${id}/bearers/${bearer_id}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

System Should Allow Bearer Removal
    [Documentation]    Success verification. If an error is thrown, we have a P2 defect!
    Log    WARNING: If this test fails, it confirms the occurrence of a P2 priority defect in the simulator.    level=WARN
    
    # We expect a success code (e.g., 200 or 204), which is < 400.
    Should Be True    ${LAST_RESPONSE.status_code} < 400    msg=ERROR (Defect P2): The system does not allow the removal of a dedicated bearer! Returned error code ${LAST_RESPONSE.status_code}.
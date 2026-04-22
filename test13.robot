*** Settings ***
Documentation     Scenario 13: Verification of the automatic assignment of the default bearer.
...               The test aims to detect a P2 defect (missing bearer ID 9 after device connection).
Library           RequestsLibrary

*** Variables ***
${BASE_URL}       http://localhost:8000
${UE_ID}          30

*** Test Cases ***
Scenario 13 - Check automatic bearer assignment
    [Documentation]    Goal: Verification whether a newly connected UE automatically 
    ...                receives a dedicated default transport channel with ID 9.
    [Tags]             attach    bearer    bug-hunting    positive
    
    Given Simulator Is Reset
    When User Connects Device With ID ${UE_ID}
    Then Device With ID ${UE_ID} Should Have Active Bearer With ID 9


*** Keywords ***
Simulator Is Reset
    [Documentation]    Resets the test environment.
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any

User Connects Device With ID ${id}
    [Documentation]    Connects a new device (Attach) to an empty network.
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

Device With ID ${id} Should Have Active Bearer With ID 9
    [Documentation]    Fetches device data and verifies assigned resources.
    ${response}=    GET On Session    epc    /ues/${id}    expected_status=any
    
    Log    WARNING: If the test shows a missing bearer 9, this confirms a P2 priority defect from the Test Plan.    level=WARN
    
    # First, we check if we can fetch the UE data at all
    Should Be True    ${response.status_code} == 200    msg=No access to the device after the Attach procedure.
    
    # Next, we check if the returned data (JSON) contains the value 9 (indicating the default bearer)
    ${response_text}=    Convert To String    ${response.text}
    Should Contain    ${response_text}    9    msg=ERROR (Defect P2): The device was connected, but the system DID NOT assign it the default bearer with ID 9!
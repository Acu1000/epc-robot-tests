*** Settings ***
Documentation    Verification of the device detach procedure (Detach) and clearing of system resources.
Library          RequestsLibrary

*** Variables ***
${BASE_URL}      http://localhost:8000
${UE_ID}         7

*** Test Cases ***
Scenario 3 - Detach UE from the network
    [Documentation]    The scenario verifies the correct detachment of the device from the network 
    ...                and ensures that its resources are no longer available.
    [Tags]    detach    positive
    
    Given Simulator Is Reset And Device With ID ${UE_ID} Is Connected
    When User Detaches Device With ID ${UE_ID}
    Then Device With ID ${UE_ID} Should Not Be Available In The Network


*** Keywords ***
Simulator Is Reset And Device With ID ${id} Is Connected
    [Documentation]    Resets the test environment and prepares an active device for the test.
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

User Detaches Device With ID ${id}
    [Documentation]    Calls the Detach procedure (removing the device from the network).
    ${response}=    DELETE On Session    epc    /ues/${id}    expected_status=any
    # Verification if the delete request was accepted without a server error
    Should Be True    ${response.status_code} < 400

Device With ID ${id} Should Not Be Available In The Network
    [Documentation]    Verification of the lack of the device in the system after its detachment.
    ${check}=    GET On Session    epc    /ues/${id}    expected_status=any
    
    # We log a note in the report regarding the specific behavior of the API
    Log    WARNING: The expected error status is 400 (Bad Request), because the simulator does not use the standard 404 (Not Found) for non-existent UEs.    level=WARN
    
    # Checking the code with a custom error description in case of possible future API fix
    Should Be Equal As Integers    ${check.status_code}    400    msg=Simulator changed behavior! Check if it started returning the correct 404 code.
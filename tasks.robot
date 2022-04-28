*** Settings ***
Documentation     Creation of a Robot based in a CSV file and compact all in a ZIP archive
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Tables

*** Tasks ***
Creation of a Robot based in a CSV file and compact all in a ZIP archive
    Download the CSV
    Open the robot order website
    Create archive ZIP 
    [Teardown]    Close the browser

    
*** Keywords ***
Download the CSV
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Fill the form of the order
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Click Element    //label[@for="id-body-${row}[Body]"]/input[@value=${row}[Body]]
    Input Text    //input[@class="form-control"]    ${row}[Legs]
    Input Text    address    ${row}[Address]
    Click Button    //button[@id="preview"]

Open the robot order website
    Open Chrome Browser  https://robotsparebinindustries.com/#/robot-order
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${row}    IN    @{orders}
        Click Button When Visible	//button[@class="btn btn-dark"]
        Fill the form of the order    ${row}
        
        Wait Until Keyword Succeeds    5x   0.5s    PDF    ${row}
        
        Screenshot of the robot    ${row}
        
        Wait Until Keyword Succeeds    3x    0.5s     Return   
    END


PDF
    [Arguments]    ${row}
    Click Button    //button[@class="btn btn-primary"]
    Wait Until Page Contains Element    //div[@class="alert alert-success"]
    ${receipt_html}=    Get Element Attribute    //div[@id="receipt"]    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}PDF's${/}receipt#${row}[Order number].pdf    overwrite=True

Screenshot of the robot
    [Arguments]    ${row}
    Wait Until Page Contains Element    //div[@id="robot-preview-image"]
    ${screenshot}=    Screenshot    //div[@id="robot-preview-image"]    ${OUTPUT_DIR}${/}Images${/}robot#${row}[Order number].png
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}Images${/}robot#${row}[Order number].png
    Open Pdf    ${OUTPUT_DIR}${/}PDF's${/}receipt#${row}[Order number].pdf
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}PDF's${/}receipt#${row}[Order number].pdf    append=${TRUE}
    Close Pdf

Create archive ZIP 
    Archive Folder With Zip    ${OUTPUT_DIR}${/}PDF's    ${OUTPUT_DIR}${/}Receipts.zip
    
Return
    Click Button When Visible	//button[@id="order-another"]

Close the browser
    Close Browser

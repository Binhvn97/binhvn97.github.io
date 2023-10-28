*** Settings ***
Library             Browser
Library             FakerLibrary        locale=en_IN
Library             String

*** Variables ***
${BROWSER}          chromium
${HEADLESS}         ${False}
${BROWSER_TIMEOUT}  60 seconds
${SHOULD_TIMEOUT}   0.1 seconds

${URL_DEFAULT}      http://dev1.geneat.vn:7802/vn
${STATE}            Evaluate    json.loads('''{}''')  json

*** Keywords ***
Login to admin
  Enter "email" in "Email" with "admin@gmail.com"
  Enter "password" in "Mật khẩu" with "123123"
  Click "Đăng nhập" button
  User look message "Success" popup

#### Setup e Teardown
Setup
  Set Browser Timeout         ${BROWSER_TIMEOUT}
  New Browser                 ${BROWSER}  headless=${HEADLESS}
  New Page                    ${URL_DEFAULT}
  ${STATE}                    Evaluate  json.loads('''{}''')  json
Tear Down
  Close Browser               ALL

Wait Until Element Is Visible
  [Arguments]               ${locator}  ${message}=${EMPTY}   ${timeout}=${BROWSER_TIMEOUT}
  Wait For Elements State   ${locator}  visible               ${timeout}                    ${message}

Wait Until Page Does Not Contain Element
  [Arguments]               ${locator}  ${message}=${EMPTY}   ${timeout}=${BROWSER_TIMEOUT}
  Wait For Elements State   ${locator}  detached              ${timeout}                    ${message}

Element Should Be Visible
  [Arguments]               ${locator}  ${message}=${EMPTY}   ${timeout}=${SHOULD_TIMEOUT}
  Wait For Elements State   ${locator}  visible               ${timeout}                    ${message}

Element Text Should Be
  [Arguments]               ${locator}  ${expected}           ${message}=${EMPTY}           ${ignore_case}=${EMPTY}
  Get Text                  ${locator}  equal                 ${expected}                   ${message}

Check Text
  [Arguments]               ${text}
  ${containsS}=             Get Regexp Matches                ${text}                      _@(.+)@_                   1
  ${cntS}=                  Get length                        ${containsS}
  IF  ${cntS} > 0
    ${text}=                Set Variable                      ${STATE["${containsS[0]}"]}
  END
  [Return]    ${text}

###  -----  Form  -----  ###
Get Random Text
  [Arguments]               ${type}                           ${text}
  ${symbol}                 Set Variable                      _RANDOM_
  ${new_text}               Set Variable
  ${containsS}=             Get Regexp Matches                ${text}                       _@(.+)@_                   1
  ${cntS}=                  Get length                        ${containsS}
  ${contains}=              Get Regexp Matches                ${text}                       ${symbol}
  ${cnt}=                   Get length                        ${contains}
  IF  ${cntS} > 0
    ${new_text}=            Set Variable                      ${STATE["${containsS[0]}"]}
    ${symbol}=              Set Variable                      _@${containsS[0]}@_
  ELSE IF  ${cnt} > 0 and '${type}' == 'test name'
    ${random}=              FakerLibrary.Sentence             nb_words=3
    ${words}=               Split String                      ${TEST NAME}                  ${SPACE}
    ${new_text}=            Set Variable                      ${words[0]} ${random}
  ELSE IF  ${cnt} > 0 and '${type}' == 'number'
    ${new_text}=            FakerLibrary.Random Int
    ${new_text}=            Convert To String                 ${new_text}
  ELSE IF  ${cnt} > 0 and '${type}' == 'percentage'
    ${new_text}=            FakerLibrary.Random Int           max=100
    ${new_text}=            Convert To String                 ${new_text}
  ELSE IF  ${cnt} > 0 and '${type}' == 'paragraph'
    ${new_text}=            FakerLibrary.Paragraph
  ELSE IF  ${cnt} > 0 and '${type}' == 'email'
    ${new_text}=            FakerLibrary.Email
  ELSE IF  ${cnt} > 0 and '${type}' == 'phone'
    ${new_text}=            FakerLibrary.Random Int           min=2000000000                max=9999999999
    ${new_text}=            Convert To String                 ${new_text}
    ${new_text}=            Catenate                          SEPARATOR=                    0                           ${new_text}
  ELSE IF  ${cnt} > 0 and '${type}' == 'color'
    ${new_text}=            FakerLibrary.Safe Hex Color
  ELSE IF  ${cnt} > 0 and "${type}" == 'password'
    ${new_text}=            FakerLibrary.Password            10                             True                        True                          True                        True
  ELSE IF  ${cnt} > 0 and '${type}' == 'date'
    ${new_text}=            FakerLibrary.Date  	              pattern=%d-%m-%Y
  ELSE IF  ${cnt} > 0 and '${type}' == 'word'
    ${new_text}=            FakerLibrary.Sentence             nb_words=2
  ELSE IF  ${cnt} > 0
    ${new_text}=            FakerLibrary.Sentence
  END
    ${cnt}=                 Get Length                        ${text}
  IF  ${cnt} > 0
    ${text}=                Replace String                    ${text}                       ${symbol}                   ${new_text}
  END
  [Return]    ${text}

Get Element Form Item By Name
  [Arguments]               ${name}                           ${xpath}=${EMPTY}
  [Return]                  xpath=//*[contains(@class, "ant-form-item-label")]/label[text()="${name}"]/../../*[contains(@class, "ant-form-item")]${xpath}

Required message "${text}" displayed under "${name}" field
  ${element}=               Get Element Form Item By Name     ${name}                       //*[contains(@class, "ant-form-item-explain-error")]
  Element Text Should Be    ${element}                        ${text}

Enter "${type}" in "${name}" with "${text}"
  ${text}=                  Get Random Text                   ${type}                       ${text}
  ${element}=               Get Element Form Item By Name     ${name}                       //input[contains(@class, "ant-input")]
  Click                     ${element}
  Clear Text                ${element}
  Fill Text                 ${element}                        ${text}                       True
  ${cnt}=                   Get Length                        ${text}
  IF  ${cnt} > 0
    Set Global Variable     \${STATE["${name}"]}              ${text}
  END

Enter "${type}" in textarea "${name}" with "${text}"
  ${text}=                  Get Random Text                   ${type}                       ${text}
  ${element}=               Get Element Form Item By Name     ${name}                       //textarea
  Clear Text                ${element}
  Fill Text                 ${element}                        ${text}
  ${cnt}=                   Get Length                        ${text}
  IF  ${cnt} > 0
    Set Global Variable     \${STATE["${name}"]}              ${text}
  END

Enter date in "${name}" with "${text}"
  ${text}=                  Get Random Text                   date                          ${text}
  ${element}=               Get Element Form Item By Name     ${name}                       //*[contains(@class, "ant-picker-input")]/input
  Click                     ${element}
  Clear Text                ${element}
  Fill Text                 ${element}                        ${text}
  Press Keys                ${element}                        Tab
  Press Keys                ${element}                        Tab
  ${cnt}=                   Get Length                        ${text}
  IF  ${cnt} > 0
      Set Global Variable   ${STATE["${name}"]}               ${text}
  END

Click select "${name}" with "${text}"
  ${text}=                  Get Random Text                   Text                          ${text}
  ${element}=               Get Element Form Item By Name     ${name}                       //*[contains(@class, "ant-select-show-arrow")]
  Click                     ${element}
  ${element}=               Get Element Form Item By Name     ${name}                       //*[contains(@class, "ant-select-selection-search-input")]
  Fill Text                                                   ${element}                    ${text}
  Click                     xpath=//*[contains(@class, "ant-select-item-option") and @title="${text}"]
  ${cnt}=                   Get Length                        ${text}
  IF  ${cnt} > 0
    Set Global Variable     \${STATE["${name}"]}              ${text}
  END

Enter "${type}" in editor "${name}" with "${text}"
  ${text}=                  Get Random Text                   ${type}                       ${text}
  ${element}=               Get Element Form Item By Name     ${name}                       //*[contains(@class, "ce-paragraph")]
  Clear Text                                                  ${element}
  Fill Text                                                   ${element}                    ${text}

Select file in "${name}" with "${text}"
  ${element}=               Get Element Form Item By Name     ${name}                       //input[@type = "file"]
  Upload File By Selector   ${element}                        test/upload/${text}

Click radio "${name}" in line "${text}"
  ${element}=               Get Element Form Item By Name     ${name}                       //*[contains(@class, "ant-radio-button-wrapper")]/span[contains(text(), "${text}")]
  Click                     ${element}

Click switch "${name}" to be activated
  ${element}=               Get Element Form Item By Name     ${name}                       //button[contains(@class, "ant-switch")]
  Click                     ${element}

Click tree select "${name}" with "${text}"
  ${text}=                  Get Random Text                   Text                          ${text}
  ${element}=               Get Element Form Item By Name     ${name}                       //*[contains(@class, "ant-tree-select")]
  Click                     ${element}
  Fill Text                 ${element}//input                 ${text}
  Click                     xpath=//*[contains(@class, "ant-select-tree-node-content-wrapper") and @title="${text}"]

Click assign list "${list}"
  ${words}=                 Split String                      ${list}                       ,${SPACE}
  FOR    ${word}    IN    @{words}
    Click                   xpath=//*[contains(@class, "ant-checkbox-wrapper")]/*[text()="${word}"]
  END
  Click                     xpath=//*[contains(@class, "ant-transfer-operation")]/button[2]

###  -----  Table  -----  ###
Get Element Item By Name
  [Arguments]               ${name}                           ${xpath}=${EMPTY}
  [Return]                  xpath=//*[contains(@class, "item-text") and contains(text(), "${name}")]/ancestor::*[contains(@class, "item")]${xpath}

Click on the "${text}" button in the "${name}" item line
  Wait Until Element Spin
  ${name}=                  Check Text                        ${name}
  ${element}=               Get Element Item By Name          ${name}                       //button[@title = "${text}"]
  Click                     ${element}
  Click Confirm To Action

Get Element Table Item By Name
  [Arguments]               ${name}                           ${xpath}
  [Return]                  xpath=//*[contains(@class, "ant-table-row")]//*[contains(text(),"${name}")]/ancestor::tr${xpath}

###  -----  Tree  -----  ###
Get Element Tree By Name
  [Arguments]               ${name}                           ${xpath}=${EMPTY}
  [Return]                  xpath=//*[contains(@class, "ant-tree-node-content-wrapper") and @title = "${name}"]/*[contains(@class, "group")]${xpath}

Click on the previously created "${name}" tree to delete
  Wait Until Element Spin
  ${name}=                  Check Text                        ${name}
  ${element}=               Get Element Tree By Name          ${name}
  Scroll To Element         ${element}
  Mouse Move Relative To    ${element}                        0
  Click                     ${element}//*[contains(@class, "la-trash")]
  Click Confirm To Action

Click on the previously created "${name}" tree to edit
  Wait Until Element Spin
  ${name}=                  Check Text                        ${name}
  ${element}=               Get Element Tree By Name          ${name}
  Click                     ${element}


###  -----  Element  -----  ###
Click "${text}" button
  Sleep                     ${SHOULD_TIMEOUT}
  ${cnt}=	                  Get Element Count		              //button[@title = "${text}"]
  IF	${cnt} > 0	
  Click                     xpath=//button[@title = "${text}"]
  Click Confirm To Action
  Scroll By                 ${None}
  ELSE
  Click 	                  //span[contains(text(),"${text}")]
  Click Confirm To Action
  Scroll By                 ${None}
  END

Click "${text}" tab button
  Click                     xpath=//*[contains(@class, "ant-tabs-tab-btn") and contains(text(), "${text}")]

Select on the "${text}" item line
  Wait Until Element Spin
  ${element}=               Get Element Item By Name          ${text}
  Click                     ${element}

Click "${text}" menu
  Click                     xpath=//li[contains(@class, "menu") and descendant::span[contains(text(), "${text}")]]

Click "${text}" sub menu to "${url}"
  Wait Until Element Spin
  Click                     xpath=//a[contains(@class, "sub-menu") and descendant::span[contains(text(), "${text}")]]
  ${curent_url}=            Get Url
  Should Contain            ${curent_url}                     ${URL_DEFAULT}${url}

User look message "${message}" popup
  ${contains}=              Get Regexp Matches                ${message}                    _@(.+)@_                    1
  ${cnt}=                   Get length                        ${contains}
  IF  ${cnt} > 0
    ${message}=             Replace String                    ${message}                    _@${contains[0]}@_          ${STATE["${contains[0]}"]}
  END
  Element Text Should Be    id=swal2-html-container           ${message}
  ${element}=               Set Variable                      xpath=//*[contains(@class, "swal2-confirm")]
  ${passed}                 Run Keyword And Return Status
                            ...   Element Should Be Visible   ${element}
  IF    '${passed}' == 'True'
        Click               ${element}
  END

Click Confirm To Action
  ${element}                Set Variable                      xpath=//*[contains(@class, "ant-popover")]//*[contains(@class, "ant-btn-primary")]
  ${count}=                 Get Element Count                 ${element}
  IF    ${count} > 0
    Click                   ${element}
    Sleep                   ${SHOULD_TIMEOUT}
    Wait Until Element Spin
  END

Wait Until Element Spin
  Sleep                     ${SHOULD_TIMEOUT}
  ${element}                Set Variable                      xpath=//*[contains(@class, "ant-spin-spinning")]
  ${count}=                 Get Element Count                 ${element}
  IF    ${count} > 0
    Wait Until Page Does Not Contain Element                  ${element}
  END

### --- New --- ###
Click on "${name}" check box
  ${element}=                Get Element                      //span[contains(text(),"${name}")]//ancestor::label/span[contains(@class,'ant-checkbox')]
  Click                      ${element}
  
Log out account
  Click                      //img[contains(@alt,'Avatar')]
  Click                      //li[contains(text(),'Đăng xuất')]  
Click on magnifier icon in search box
  Click                      xpath=//*[contains(@class, "ext-lg las la-search")]

Click on eye icon in "${name}" field 
  Wait Until Element Spin
  ${element}=                Get Element                       //*[contains(@class, "ant-form-item-label")]/label[text()="${name}"]/../../*[contains(@class, "ant-form-item")]//input//ancestor::div[contains(@class, 'relative ng-star-inserted')]
  Click                      ${element}/i[contains(@class, "la-eye-slash")]  
  Sleep                      ${SHOULD_TIMEOUT}

Click on the left arrow icon 
  ${element}=                Get Element                       //i[contains(@class,'la-arrow-left')]
  Click                      ${element}
  Wait Until Element Spin

Delete data in "${name}" 
  ${element}                 Get Element Form Item By Name     ${name}                      //input[contains(@class, "ant-input")]
  Clear Text                 ${element}

Enter "${type}" in placeholder "${placeholder}" with "${text}"
  ${text}=                   Get Random Text                   ${type}                       ${text}
  ${element}=                Get Element                       //input[contains(@placeholder, "${placeholder}")]
  Clear Text                 ${element}
  Fill Text                  ${element}                        ${text}
  ${cnt}=                    Get Length                        ${text}
  IF  ${cnt} > 0
    Set Global Variable      \${STATE["${placeholder}"]}       ${text}
  END

Enter "${type}" in login placeholder "${placeholder}" with "${text}"
  ${text}=                   Get Random Text                   ${type}                       ${text}
  ${element}=                Get Element                       //input[contains(@id,'login') and @placeholder = '${placeholder}']
  Clear Text                 ${element}
  Fill Text                  ${element}                        ${text}
  ${cnt}=                    Get Length                        ${text}
  IF  ${cnt} > 0
    Set Global Variable      \${STATE["${placeholder}"]}       ${text}
  END

Enter date in placeholder "${name}" with "${date}"
  ${element}=                 Get Element                      //input[contains(@placeholder, "${name}")]
  Clear Text                  ${element}
  ${date}=                    Convert To String                ${date}    
  Fill Text                   ${element}                       ${date}                      True
  Keyboard Key                Press                            Enter
  ${cnt}=                     Get Length                       ${date}
  IF  ${cnt} > 0
    Set Global Variable       \${STATE["${date}"]}             ${date}
  END
  Wait Until Element Spin  

"${name}" should be visible in table line
  Wait Until Element Spin
  ${name}=                  Check Text                         ${name}
  Get Property              //tbody/tr[2]/td[2]/button[1]      innerText                   equal                         ${name}       

"${name}" should not be visible in table line
  Wait Until Element Spin
  ${name}=                  Check Text                         ${name}
  ${count}=                 Count the number data in list
  IF    ${count} > 0
      Get Property          //tbody/tr[2]/td[2]/button[1]      innerText                   inequal                       ${name}       
  ELSE
      Get Text              //tbody/tr[2]                      equal                       No Data
  END

"${name}" table line should be highlighted
  Wait Until Element Spin
  ${name}=                  Check Text                         ${name}
  Get Property              //button[contains(text(),"${name}")]//ancestor::tr            className                      contains                  bg-blue-100    

"${name}" should be visible in the first table line
  Wait Until Element Spin
  ${name}=                  Check Text                         ${name}
  Get Text                  //tbody/tr[2]/td[2]/*              equal                         ${name}

"${name}" should be visible in the first table line
  Wait Until Element Spin
  ${name}=                  Check Text                         ${name}
  Get Text                  //tbody/tr[2]/td[2]/*              inequal                       ${name}

Data's information in "${name}" should be equal "${value}"
  ${value}=                 Check Text                         ${value}
  ${cnt}=                   Get Element Count                  //label[contains(text(),"${name}")]
  IF    ${cnt} > 0
    ${element}=             Set Variable                       //label[contains(text(),"${name}")]//ancestor::*[contains(@class,'ant-form-item')]//*[contains(@class,'ant-input')]    
    ${cntS}=                Get Element Count                  ${element}
    IF    ${cntS} > 0
      Get Text              ${element}                         equal                        ${value}
    ELSE
      ${element}=           Set Variable                       //label[contains(text(),"${name}")]//ancestor::*[contains(@class,'ant-form-item')]//*[contains(@class,'ant-select-selection-item')] 
      Get Text              ${element}                         equal                        ${value}
    END
  ELSE
    ${element}=             Set Variable                       //th[contains(text(),"${name}")]//following-sibling::th[1]
    Get Text                ${element}                         equal                        ${value}
  END

Data's information should contain "${name}" field 
  ${name_field}=            Check Text                         ${name}
  ${cnt}=                   Get Element Count                  //label[contains(text(),"${name}")]
  IF    ${cnt} > 0
    Should Be True          ${cnt} >= 1
  ELSE
    ${element}=             Set Variable                      //th[contains(text(),"${name}")]
    ${cntS}=                Get Element Count                 ${element}
    Should Be True          ${cntS} > 0
  END

Table line should show empty 
  Wait Until Element Spin
  Get Property              //p[contains(@class, 'ant-empty-description')]                innerText                      equal                     No Data 

The hidden password in "${name}" field should be visibled as "${text}"
  ${text}=                  Check Text                         ${text}            
  ${element}=               Get Element                        //*[contains(@class, "ant-form-item-label")]/label[text()="${name}"]/../../*[contains(@class, "ant-form-item")]//input
  Get Property              ${element}                         type                       ==                             text                     
  Get Text                  ${element}                         equal                      ${text}

Click on the "${text}" button in the "${name}" table line
  Sleep                       ${SHOULD_TIMEOUT}
  Wait Until Element Spin
  ${name}=                    Check Text                        ${name}
  IF    '${text}' == 'Chi tiết'
    ${element1}=              Get Element Table Item By Name    ${name}                      //button[@title = "${text}"]
    ${count}=                 Get Element Count                 ${element1}
    IF    ${count} > 0
      Click                   ${element1}
    ELSE
      ${elementS}=            Get Element Table Item By Name    ${name}                      //p[contains(text(),"${name}")]
      Click                   ${elementS}       
    END
  ELSE
    ${element}=               Get Element Table Item By Name    ${name}                      //button[@title = "${text}"]
    Click                     ${element} 
  END
  Click Confirm To Action
  
Click Cancel Action
  ${element}                Set Variable                       //*[contains(@class, "ant-popover")]//button[1]
  ${count}=                 Get Element Count                  ${element}
  IF    ${count} > 0
    Click                   ${element}
    Sleep                   ${SHOULD_TIMEOUT}
  END

Click "${text}" button with cancel action
  Click                     //button[@title = "${text}"]
  Click Cancel Action
  Scroll By                 ${None}

Click on the "${text}" button in the "${name}" table line with cancel
  Sleep                     ${SHOULD_TIMEOUT}
  Wait Until Element Spin
  ${name}=                  Check Text                         ${name}
  ${element}=               Get Element Table Item By Name     ${name}                    //button[@title = "${text}"]
  Click                     ${element}
  Click Cancel Action

### Related to images ###
Wait Until Image Visible
  ${elementS}= 		          Get Element 			                 //div[contains(@class,'gslide loaded current')]
  Wait For Elements State                                      ${elementS}                visible                    

Click on the "${name}" image
  ${element}=	              Get Element 			                 //p[contains(text(),'${name}')]//following-sibling::div//img
  Click	                    ${element}
  Wait Until Image Visible

Image should be enlarged 	                 
  ${cnt}=	                  Get Element Count			             //img[contains(@class,'zoomable')]
  Should Be True	          ${cnt} > 0

Click on cross button to close image
  ${element}                Get Element                        //button[contains(@aria-label,'Close')]
  Click                     ${element}      

Move to the "${name}" image
  ${element}               Get Element                         //button[contains(@aria-label,'${name}')]
  Click                    ${element}      
  Wait Until Image Visible

# Use for filter function #
Click filter "${name}" with "${text}"
  ${text}=                  Get Random Text                    Text                       ${text}
  ${element}=               Get Element Form Item By Name      ${name}                    //following-sibling::nz-select[contains(@class, "ant-select-show-arrow")]
  Click                     ${element}
  Wait Until Element Spin
  Click                     xpath=//*[contains(@class, "ant-select-item-option") and @title="${text}"]
  ${cnt}=                   Get Length                         ${text}
  IF  ${cnt} > 0
    Set Global Variable     \${STATE["${name}"]}               ${text}
  END

Click on cross icon in select "${name}" 
  ${element}=               Get Element Form Item By Name      ${name}                    //following-sibling::nz-select[contains(@class, "ant-select-show-arrow")]
  Click                     ${element}
  Click                     xpath=//span[contains(@class, "anticon-close-circle")]/*[1]

# Check the existence of function
Webpage should contain the search function
  ${element}=               Get Element                        //*[contains(@class,'flex-col')]//label[contains(text(),"Tìm kiếm")]
  ${count}=                 Get Element Count                  ${element}
  Should Be True            ${count} >= 1

Webpage should contain the "${name}" filter function
  ${element}=               Get Element                        //*[contains(@class,'flex-col')]//label[contains(text(),"${name}")]
  ${count}=                 Get Element Count                 ${element}
  Should Be True            ${count} >= 1

Heading should contain "${text}" inner Text
  Get Text                  //h2                               equal                      ${text}    

Webpage should contain the list data from database
  ${element}=               Get Element                        //div[contains(@class,'datatable-wrapper')]    
  ${count}=                 Get Element Count                  ${element}
  IF    ${count} > 0
    Set Global Variable     \${STATE["${count}"]}              ${count}
  END

Webpage should contain "${name}" select field   
  ${element}=               Set Variable                       //label[text()="${name}"]//ancestor::*[contains(@class,'ant-row')]//input[contains(@class,'ant-select')]
  ${count}=                 Get Element Count                  ${element}
  Should Be True            ${count} >= 1

Webpage should contain "${name}" input field                   
  ${element}=               Set Variable                       //label[text()="${name}"]//ancestor::*[contains(@class,'ant-row')]//input[contains(@class,'ant-input')] 
  ${count}=                 Get Element Count                  ${element}
  Should Be True            ${count} >= 1

Webpage should contain "${name}" button
  ${element}=               Set Variable                       //button[contains(text(),"${name}")]
  ${count}=                 Get Element Count                  ${element}
  Should Be True            ${count} >= 1

Confirm adding "${url}" page
  ${current_url}=           Get Url 
  Should Contain            ${current_url}                     ${URL_DEFAULT}${url}/add  

### Relate to number of list page ###
Count the number data in list
  Wait Until Element Spin
  ${element}=                Set Variable                      xpath=//tbody//tr[contains(@class, 'ant-table-row')]
  ${count}=                  Get Element Count                 ${element}
  IF    ${count} <= 0
    Wait Until Element Spin
    ${count}=                Get Element Count                 ${element}
    ${count}=                Convert To Integer                ${count}
  ELSE 
    ${count}=                Convert To Integer                ${count}
  END
  [Return]                   ${count}
      
Get number data list in last page
  ${element}=                Get Element                       //span[contains(@class, 'ml-3')]
  ${text}=                   Get Text                          ${element}        
  ${pageNum}=                Count the number data in list
  ${total}=                  Get Regexp Matches                ${text}                     của (.+) mục                1 
  ${total}=                  Convert To Integer                ${total[0]}
  ${NumberAcc}=              Evaluate                          ${total} % ${pageNum}
  IF    ${NumberAcc} == 0
    ${NumberAccount}=        Set Variable                      ${pageNum}
  ELSE
    ${NumberAccount}=        Set Variable                      ${NumberAcc}
  END
  [Return]                   ${NumberAccount}  

Get the number of total data
  ${element}=                Get Element                       //span[contains(@class, 'ml-3')]
  ${text}=                   Get Text                          ${element}
  ${total}=                  Get Regexp Matches                ${text}                     của (.+) mục                1 
  ${total}=                  Convert To Integer                ${total[0]}
  ${cnt}=                    Get Length                        ${text}
  IF  ${cnt} > 0
    ${TotalAccount}=         Set Variable                      ${total}
  END
  [Return]                   ${TotalAccount}

Get the last page number
  ${element}=                Get Element                       //span[contains(@class, 'ml-3')]
  ${text}=                   Get Text                          ${element}        
  ${pageNum}=                Count the number data in list
  ${totalP}=                 Get Regexp Matches                ${text}                     của (.+) mục                1 
  ${totalP}=                 Convert To Integer                ${totalP[0]}
  ${con}=                    Evaluate                          ${totalP} % ${pageNum}
  IF    ${con} == 0
    ${lastPN}=               Evaluate                          ${totalP}//${pageNum}
  ELSE
    ${lastPN}=               Evaluate                          (${totalP}//${pageNum})+1
  END
  ${cnt}=                    Get Length                        ${text}
  IF  ${cnt} > 0
    ${lastPageNumber}=       Set Variable                      ${lastPN}
    ${lastPageNumber}=       Convert To String                 ${lastPageNumber} 
  END
  [Return]                   ${lastPageNumber}

Check the amount of page list
  Wait Until Element Spin
  ${countA}=                 Count the number data in list
  ${totalA}=                 Get the number of total data
  IF    ${countA} == ${totalA}
    ${amountPage}=           Set Variable                      1
    Pass Execution           'This list contains only one page'
  ELSE IF    ${countA} < ${totalA}
    ${amountPage}=           Evaluate                          (${totalA}//${countA})+1        
    ${amountPage}=           Set Variable                      ${amountPage}
  END
  [Return]                   ${amountPage}

### --- List of account navigation --- ###
Move to the "${target}" page
  ${count}=                   Get Length                       ${target}
  IF    '${target}' == 'previous'
      Click                   xpath=//*[contains(@class, "las la-angle-left text-xs ng-star-inserted")]
  ELSE IF    '${target}' == 'next'
      Click                   xpath=//*[contains(@class, "las la-angle-right text-xs ng-star-inserted")]
  ELSE
      ${number}=              Convert To Integer    ${target}
      Click                   xpath=//a[contains(@aria-label, "page ${number}")]
  END
  Wait Until Element Spin

Move to the last page and check
  ${countS}=                  Get number data list in last page
  ${number}=                  Get the last page number
  Move to the "${number}" page
  Wait Until Element Spin
  ${elementS}=                Set Variable                     xpath=//tbody//tr[contains(@class, 'ant-table-row')]
  ${count}=                   Get Element Count                ${elementS}
  ${count}=                   Convert To Integer               ${count}
  Should Be Equal             ${count}                         ${countS}         

Click on "${ordinal}" selection to change the number of data show in list and check
  Wait Until Element Spin
  ${cnt}=                       Get Length                      ${ordinal}        
  IF        ${cnt} > 3 and '${ordinal}' == 'first'
    ${select}=                  Set Variable                    1
  ELSE IF   ${cnt} > 3 and '${ordinal}' == 'second'
    ${select}=                  Set Variable                    2  
  ELSE IF   ${cnt} > 3 and '${ordinal}' == 'third'
    ${select}=                  Set Variable                    3  
  ELSE IF   ${cnt} > 3 and '${ordinal}' == 'fourth'
    ${select}=                  Set Variable                    4
  ELSE IF   ${cnt} > 3 and '${ordinal}' == 'fifth'
    ${select}=                  Set Variable                    5
  ELSE
    ${select}=                  Convert To Integer              ${ordinal}
  END
  ${amountPage}=                Check the amount of page list
  ${text_current}=              Get Text                        //*[contains(@class, 'ant-select-selection-item')]
  ${current}=                   Get Regexp Matches              ${text_current}                          (.+) / page                    1
  ${current_number}=            Set Variable                    ${current[0]}
  ${current_number}             Convert To Integer              ${current_number}
  Click                         xpath=//*[contains(@class, 'ant-select-selection-item')]
  ${text_default}=              Get Text                        //nz-option-item[1]/div[contains(@class,'ant-select-item-option-content')]
  ${default}=                   Get Regexp Matches              ${text_default}                          (.+) / page                    1
  ${default_number}=            Set Variable                    ${default[0]}
  ${default_number}=            Convert To Integer              ${default_number}
  ${text_select}=               Get Text                        //nz-option-item[${select}]/div[contains(@class,'ant-select-item-option-content')]      
  ${select_string}=             Get Regexp Matches              ${text_select}                           (.+) / page                    1
  ${select_number}=             Set Variable                    ${select_string[0]}
  ${select_number}=             Convert To Integer              ${select_number}    
  IF                            ${amountPage} >= 2
    IF                          ${current_number} < ${select_number}
      Move to the "next" page
      ${name}=                  Get data in the first row
      ${ordinal_before}=        Evaluate                        ${current_number} + 2
      Click                     xpath=//*[contains(@class, 'ant-select-selection-item')]
      Wait Until Element Spin
      Click                     xpath=//nz-option-item[${select}]/div[contains(@class,'ant-select-item-option-content')]
      Wait Until Element Spin
      Get Text                  //tbody//tr[${ordinal_before}]//button[contains(@title,"Chi tiết")]        equal                       ${name}
    ELSE IF                     ${current_number} > ${select_number}
      ${ordinal_before}=        Evaluate                        ${select_number} + 2
      ${name}=                  Get Text                        //tbody//tr[${ordinal_before}]//button[contains(@title,"Chi tiết")]
      Click                     xpath=//*[contains(@class, 'ant-select-selection-item')]
      Wait Until Element Spin
      Click                     xpath=//nz-option-item[${select}]/div[contains(@class,'ant-select-item-option-content')]
      Wait Until Element Spin
      Move to the "next" page
      ${nameS}=                 Get data in the last row
      Should Be Equal           ${nameS}                         ${name}
      Move to the "previous" page
    ELSE IF                     ${current_number} = ${select_number}
      Click                     xpath=//*[contains(@class, 'ant-select-selection-item')]
      Wait Until Element Spin
      Click                     xpath=//nz-option-item[${select}]/div[contains(@class,'ant-select-item-option-content')]        
      Wait Until Element Spin
    END    
  ELSE IF                       ${amountPage} < 2 
    IF                          ${current_number} <= ${select_number}
      Click                     xpath=//*[contains(@class, 'ant-select-selection-item')]
      Wait Until Element Spin
      Click                     xpath=//nz-option-item[${select}]/div[contains(@class,'ant-select-item-option-content')]
      Wait Until Element Spin
    ELSE IF                     ${current_number} > ${select_number}
      ${account_number}=        Count the number data in list
      IF       ${account_number} > ${select_number}
        ${ordinal_before}=      Evaluate                         ${select_number} + 2
        ${name}=                Get Text                         //tbody//tr[${ordinal_before}]//button[contains(@title,"Chi tiết")]
        Click                   xpath=//*[contains(@class, 'ant-select-selection-item')]
        Wait Until Element Spin
        Click                   xpath=//nz-option-item[${select}]/div[contains(@class,'ant-select-item-option-content')]
        Wait Until Element Spin
        Move to the "next" page
        ${nameS}=               Get data in the first row
        Should Be Equal         ${nameS}                         ${name}
        Move to the "previous" page
      ELSE IF    ${account_number} <= ${select_number}
        Click                   xpath=//*[contains(@class, 'ant-select-selection-item')]
        Wait Until Element Spin
        Click                   xpath=//nz-option-item[${select}]/div[contains(@class,'ant-select-item-option-content')]   
        Wait Until Element Spin
      END    
    END
  END

### --- Get the account name --- ###
Get data in the last row
  ${pageN}=                   Count the number data in list
  ${number}=                  Evaluate                         ${pageN}+1
  ${element}=                 Get Element                      //tbody//tr[${number}]//button[contains(@title,"Chi tiết")]
  ${LAname}=                  Get Text                         ${element}
  ${cnt}=                     Get Length                       ${LAname}
  IF   ${cnt} > 0
    Set Global Variable       \${LAname}                        ${LAname} 
  END
  [Return]                    ${LAname}

Get data in the first row
  ${element}=                 Get Element                      //tbody//tr[2]//button[contains(@title,"Chi tiết")]
  ${Fname}=                   Get Text                         ${element}
  ${cnt}=                     Get Length                       ${Fname}
  IF   ${cnt} > 0
    ${Fname}=                 Set Variable                     ${Fname}
  END
  [Return]                    ${Fname}

#Real Estate
Get the number of real Estate
  ${element}=                 Get Element                      //label[contains(text(),'Mã lô đất')]//following-sibling::div/strong        
  ${code}=                    Get Property                     ${element}              innerText
  [Return]                    ${code}

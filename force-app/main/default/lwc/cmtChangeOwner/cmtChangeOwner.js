/**
 * @description       : 
 * @author            : San,Kang
 * @group             : 
 * @last modified on  : 11-19-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import modal from "@salesforce/resourceUrl/ChangeOwnerModal";

import doInit from '@salesforce/apex/CMTChangeOwnerController.doInit';
import onSave from '@salesforce/apex/CMTChangeOwnerController.onSave';
import updateUser from '@salesforce/apex/CMTChangeOwnerController.updateUser';
import {loadStyle} from "lightning/platformResourceLoader";

export default class cmtChangeOwner extends LightningElement {
    recordId;

    userName; //user name 
    userEmail; //user email info

    settingUserName;
    settingUserId = null;
    settingobj = null;
    settingobjName = null;
    settingUserEmail = null;
    settingOwner;
    settingUser = false;
    clickUserType; //combobox select user Type
    checkboxVal = true; //send email
    userInputName = null; //searchbox
    @track focusDropDown = false; //search box focus
    searchBoxPress = false;
    isLoaded = false;
    isButtonDisabled = false;
    RecordType;
    isAutomationBypassed;
    stage;
    onPlaceholder;//search placeholder
    selectUserType = 'User';
    searchResults = [];
    resultList = [];
    userList = [];
    queueList = [];
    partnerUserList = [];
    refreshUrl;
    KASOprofile;
    CheckKASOGroupName;
    SafetyTeamDesignations;
@track Case_Owner_Cannot_be_Changed_Other_Region = false;
@track Assign_Cases_to_appropriate_personnel = false;
@track permissionAssignmentName =[];
@track GroupName = [];
@track caseNumber;
@track currentOwner;
@track userTypeList = [{label : 'User',value : 'User'}
                     ,{label : 'Partner User',value : 'Partner User'}
                     ,{label : 'Queue',value : 'Queue'}]; //combobox user Type

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log(currentPageReference);
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        loadStyle(this, modal);
        try{
            doInit({recordId : this.recordId}).then(res =>{
                this.userList = res.user;
                this.queueList = res.queue;
                this.partnerUserList = res.partnerUser;
                this.settingobj = res.obj;
                this.settingobjName = res.objName;
                this.settingOwner = res.owner;
                this.caseNumber = res.objSCSCaseNumber;
                this.currentOwner = res.currentOwnerName;
                this.refreshUrl = res.refreshUrl;
                this.resultList = this.userList;
                this.searchResults = this.userList;
                this.RecordType = res.RecordType;
                this.isAutomationBypassed = res.IsAutomationBypassed;
                this.stage = res.Stage;
                
                if(res.obj == 'Case'){
                    if(res.user.length > 0){
                        this.onPlaceholder = 'Search Users...';
                        this.selectUserType = 'User';
                    }
                }
            })
        }catch(e){
            console.log(e);
        }
    }
    
    //Change UserType  
    onUserType(event){
        this.selectUserType = event.detail.value;
        this.userInputName =null;
        if(this.selectUserType == 'User'){
            this.resultList = this.userList;
            this.searchResults = this.userList;
            this.onPlaceholder = 'Search Users...';
        }
        if(this.selectUserType == 'Partner User'){
            this.resultList = this.partnerUserList;
            this.searchResults = this.partnerUserList;
            this.onPlaceholder = 'Search Partner Users...';
        }
        if(this.selectUserType == 'Queue'){
            this.resultList = this.queueList;
            this.searchResults = this.queueList;
            this.onPlaceholder = 'Search Queues...';
        }

    }


    //Search Box onkeypress  
    onUserNamePress(event){
        this.userInputName = event.target.value;
        if(this.userInputName.length > 0){
            this.searchBoxPress=true;
        }else{
            this.searchBoxPress=false;
        }
        this.searchResults = this.resultList.filter(
            (item) => item.Name.toLowerCase().includes(this.userInputName.toLowerCase())
            );
    }

    onUserNameClick(){
        this.focusDropDown = true;
        
    }
    
    //send Email CheckBox
    changeCheckbox(event){
        this.checkboxVal = event.target.checked;
        
    }
    selectUserClick(event){
        const itemName = event.target.closest('li').querySelector('.slds-listbox__option-text_entity span').innerText;
        const itemId = event.currentTarget.dataset.id;
        const emailElement = event.currentTarget.querySelector('.slds-inlds-listbox__option-meta_entity');
        const email = emailElement ? emailElement.textContent : '';
        this.settingUserId = itemId;
        this.settingUserEmail = email;
        this.settingUserName = itemName;
        this.settingUser = true;

    }

    settingClear(event){
        this.connectedCallback();
        this.userInputName = null;
        this.settingUserName = null;
        this.searchBoxPress = false;
        this.focusDropDown = false;
        this.settingUser = false;
    }

    onCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    onSave(event){
        try{
            if(this.settingUser == true){
                if(this.settingOwner == this.settingUserId){
                    const evt = new ShowToastEvent({
                        message: this.settingUserName +' ' +'already owns this record.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
      
                }else{
                    var dataGroup = {
                        userId : this.settingUserId 
                        , type : this.selectUserType
                    };
                    this.settingError = false;
                    onSave({dataGroup : dataGroup}).then(res =>{
                        if(this.selectUserType == 'User'){

                            res.PermissionSetAssignList.forEach(e => {
                                
                                this.permissionAssignmentName.push(e.PermissionSet.Name);
                                this.SafetyTeamDesignations = res.targetUser.SafetyTeamDesignations__c == null ? '' : res.targetUser.SafetyTeamDesignations__c;
                            });
                            res.MemberGroupList.forEach(e => {
                                this.GroupName.push(e.Group.name);
                            });
                            (
                                (this.stage == 'DA' && !this.SafetyTeamDesignations.includes('DA Team')) ||
                                (this.stage == 'DRC' && !this.SafetyTeamDesignations.includes('DRC')) ||
                                (this.stage == 'TRC' && !this.SafetyTeamDesignations.includes('TRC')) ||
                                (this.stage == 'NASDA' && !this.SafetyTeamDesignations.includes('SDA'))
                            &&
                            res.targetUser.Profile.Name !== 'Integration User' &&
                            res.targetUser.Profile.Name !== 'System Administrator' &&
                            !this.permissionAssignmentName.includes('SC_Safety_Admin') &&
                            res.targetUser.Profile.Name !== '(KASO) System Admin') ? this.Assign_Cases_to_appropriate_personnel = true : this.Assign_Cases_to_appropriate_personnel = false;

                            this.CheckKASOGroupName=this.GroupName.includes('KA') ? true : false;
                            this.KASOprofile = res.targetUser.Profile.Name.includes('KASO') ? true : false;
                            console.log('1',!(
                                this.GroupName.includes('KA') || 
                                res.targetUser.Profile.Name.includes('KASO'))
                            );
                            console.log('2',!(
                                (this.GroupName.includes('KA') || 
                                res.targetUser.Profile.Name.includes('KASO')))
                            );
                            (
                                !(
                                    (this.RecordType.includes('KA') &&
                                        (this.GroupName.includes('KA') || 
                                        res.targetUser.Profile.Name.includes('KASO'))
                                    ) || 
                                    (!this.RecordType.includes('KA') &&
                                    !(
                                        this.GroupName.includes('KA') || 
                                        res.targetUser.Profile.Name.includes('KASO'))
                                    )
                                )
                                &&
                                res.targetUser.Profile.Name !== 'Integration User' &&
                                res.targetUser.Profile.Name !== 'System Administrator' &&
                                !this.permissionAssignmentName.includes('SC_Safety_Admin') &&
                                res.targetUser.Profile.Name !== '(KASO) System Admin') ? this.Case_Owner_Cannot_be_Changed_Other_Region = true : this.Case_Owner_Cannot_be_Changed_Other_Region = false;

                                console.log('this.Case_Owner_Cannot_be_Changed_Other_Region',this.Case_Owner_Cannot_be_Changed_Other_Region);
                        
                        (
                            (
                                (this.RecordType.includes('Q_DA') ||
                                this.RecordType.includes('SCDC')) &&
                                !this.permissionAssignmentName.includes('QC_Quality_Quality_Manager')
                            )
                            &&
                            res.targetUser.Profile.Name !== 'Integration User' &&
                            res.targetUser.Profile.Name !== 'System Administrator' &&
                            !this.permissionAssignmentName.includes('SC_Safety_Admin') &&
                            res.targetUser.Profile.Name !== '(KASO) System Admin') ? this.QC_Quality_Case_Change_Owner_Validation = true : this.QC_Quality_Case_Change_Owner_Validation = false;
                        if(this.Assign_Cases_to_appropriate_personnel == true){
                            const evt = new ShowToastEvent({
                                message: 'Assign Case to Appropriate Personnel',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }else if(this.Case_Owner_Cannot_be_Changed_Other_Region == true){
                            const evt = new ShowToastEvent({
                                message: 'Case can be assigned to only its own region user',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }else if(this.QC_Quality_Case_Change_Owner_Validation==true){
                            const evt = new ShowToastEvent({
                                message: 'Quality Case can only be assigned to a Quality Manager Please verify the correct organization before assigning the owner.',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                                            
                        }else{
                            this.updateUser();
                        }
                    }
                })
                }
                
            }else{
                const evt = new ShowToastEvent({
                    message: 'Enter a new owner for this record.',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

            }
        }catch(e){
            console.log(e);
        }
       
    }

    onClickOutside(event){
        if(event.target.closest('.panel') || event.target.closest('.slds-combobox_object-switcher.slds-combobox-addon_start')  ){
            if(!event.target.closest('.slds-combobox_container.slds-combobox-addon_end')){
                this.focusDropDown = false;
            }
        }
    }
    updateUser(){
        var dataGroup = {
            userId : this.settingUserId 
            , userEmail : this.settingUserEmail
            , userName : this.settingUserName
            , targetobj : this.settingobj
            , owner : this.settingOwner
            , sendEmail : this.checkboxVal
            , recordId : this.recordId
            , type : this.selectUserType
            , caseNumber : this.caseNumber
            , currentOwner : this.currentOwner
        };
        this.settingError = false;
        updateUser({dataGroup : dataGroup}).then(res =>{
            this.dispatchEvent(new CloseActionScreenEvent());
            

            const evt = new ShowToastEvent({
                message: this.settingUserName + ' now owns the record for' + this.settingobjName,
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log('dd',this.refreshUrl );
            location.href = this.refreshUrl; 
        
        })
    }
}
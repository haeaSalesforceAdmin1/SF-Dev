/**
 * @description       : 
 * @author            : San,Kang
 * @group             : 
 * @last modified on  : 06-27-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import modal from "@salesforce/resourceUrl/ChangeOwnerModal";

import doInit from '@salesforce/apex/ChangeOwnerController.doInit';
import onSave from '@salesforce/apex/ChangeOwnerController.onSave';
import {loadStyle} from "lightning/platformResourceLoader";

export default class ChangeOwnerCustom extends LightningElement {
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
    onPlaceholder;//search placeholder
    selectUserType;
    searchResults = [];
    resultList = [];
    userList = [];
    partneruserList = [];
    refreshUrl;
@track userTypeList = []; //combobox user Type

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
                this.partneruserList = res.partner;
                this.settingobj = res.obj;
                this.settingobjName = res.objName;
                this.settingOwner = res.owner;
                this.refreshUrl = res.refreshUrl;
                this.resultList = this.userList;
                this.searchResults = this.userList;
                console.log('dd',this.refreshUrl );
                console.log('res.obj',res.obj);
                
                if(res.obj == 'Action_Plan'){
                    if(res.partner == undefined || res.partner == ''){
                        this.onPlaceholder = 'Search Users...';
                        this.selectUserType = 'User';
                        this.userTypeList=[{label : 'User',value : 'User'}];
                    }else if(res.partner.length > 0){
                        this.resultList = this.partneruserList;
                        this.searchResults = this.partneruserList;
                        this.selectUserType = 'Partner User';
                        this.onPlaceholder = 'Search Partner Users...';
                        this.userTypeList=[{label : 'Partner User',value : 'Partner_User'}];


                    }
                }else if(res.obj == 'Evaluation'){
                    this.onPlaceholder = 'Search Users...';
                    this.selectUserType = 'User';
                    this.userTypeList=[{label : 'User',value : 'User'}];
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
        }else{
            this.resultList = this.partneruserList;
            this.searchResults = this.partneruserList;
            this.onPlaceholder = 'Search Partner Users...'
        }
        console.log('result',this.resultList);

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
        const emailElement = event.currentTarget.querySelector('.slds-listbox__option-meta_entity');
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
                        title: 'Toast Error',
                        message: this.settingUserName +' ' +'already owns this record.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
      
                }else{
                    this.isLoaded = true;
                    this.isButtonDisabled = true;
                    var dataGroup = {
                        userId : this.settingUserId 
                        , userEmail : this.settingUserEmail
                        , userName : this.settingUserName
                        , targetobj : this.settingobj
                        , owner : this.settingOwner
                        , sendEmail : this.checkboxVal
                        , recordId : this.recordId
                    };
                    
                    this.settingError = false;
                    onSave({dataGroup : dataGroup}).then(res =>{
                        this.dispatchEvent(new CloseActionScreenEvent());
                        

                        const evt = new ShowToastEvent({
                            title: 'Toast Success',
                            message: this.settingUserName + ' now owns the record for' + this.settingobjName,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        console.log('dd',this.refreshUrl );
                        location.href = this.refreshUrl; 
                        
                        
                })
                }
            }else{
                const evt = new ShowToastEvent({
                    title: 'Toast Error',
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
    
}
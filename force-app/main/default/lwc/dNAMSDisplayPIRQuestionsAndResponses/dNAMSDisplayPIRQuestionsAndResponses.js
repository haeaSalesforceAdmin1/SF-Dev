import { LightningElement, wire, api, track } from 'lwc';
import getPIRResponses from '@salesforce/apex/DNAMSPIRQuestionResponses.getPIRResponses';

export default class DisplayPIRQuestionsAndResponses extends LightningElement {
    @api recordId; 

    @track sections = [];  
    @track sectionNames = []; 
    error;

    @wire(getPIRResponses, { pirId: '$recordId' })
    wiredResponses({ error, data }) {
        if (data) {
            console.log('Data received:', data);
            this.responses = data;
            this.groupResponsesIntoSections();
            console.log('Assigned sections:', this.sections);
            this.error = undefined;
        } else if (error) {
            console.error('Error:', error);
            this.error = error;
            this.responses = [];
            this.sections = []; 
            this.sectionNames = []; 
        }
    }

    groupResponsesIntoSections() {
        const groupedSections = {};

        this.responses.forEach(response => {
            const sectionName = response.Section__c || 'Unspecified'; 

            if (!groupedSections[sectionName]) {
                groupedSections[sectionName] = {
                    SectionName: sectionName,
                    QuesData: []
                };
            }

            groupedSections[sectionName].QuesData.push({
                QuestionId: response.Id,
                Question__c: response.PIR_Question__r.Question__c,
                Response__c: response.Response__c
            });
        });

        this.sections = Object.values(groupedSections);
        
        // Populate sectionNames with all section names to keep them open initially
        this.sectionNames = this.sections.map(section => section.SectionName);
        console.log('Section Names:', this.sectionNames);
    }

    connectedCallback() {
        console.log('Record Id:', this.recordId);
    }
}
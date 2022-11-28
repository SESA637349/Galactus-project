import { LightningElement } from 'lwc';

const columns = [
    { label: 'Case Number', fieldName: 'caseNumber', type: 'url' },
    { label: 'Status', fieldName: 'status'},
    { label: 'Case Date', fieldName: 'caseDate', type: 'date'},
];

export default class CaseInPastComp extends LightningElement {
    data = [];
    columns = columns;
    rowOffset = 0;

    connectedCallback() {
        const data = generateData({ amountOfRecords: 50 });
        this.data = data;
    }
}

function generateData({ amountOfRecords }) {
    return [...Array(amountOfRecords)].map((_, index) => {
        return {
            caseNumber: `0000(${index})`,
            status: 'New',
            caseDate: '24-08-2022',
        };
    });
}
import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getMarkers from '@salesforce/apex/MapMarkerController.getMarkers';

export default class ReliefMap extends LightningElement {
    mapMarkers = [];
    wiredResult;

    @wire(getMarkers)
    wiredMarkers(result) {
        this.wiredResult = result;
        if (result.data) {
            this.mapMarkers = result.data.map((m) => ({
                location: { Latitude: m.latitude, Longitude: m.longitude },
                title: m.title,
                description: m.description,
                icon: m.kind === 'incident' ? 'standard:incident' : 'standard:user'
            }));
        } else if (result.error) {
            this.mapMarkers = [];
        }
    }

    get hasMarkers() {
        return this.mapMarkers.length > 0;
    }

    handleRefresh() {
        return refreshApex(this.wiredResult);
    }
}


using { traveltracking as tt } from '../db/schema';

service TravelRequest @(path: '/service/TravelRequest') {
    entity TravelRequest as projection on tt.TravelRequest;

    annotate TravelRequest with @odata.draft.enabled;
}
sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"traveltrackingui/test/integration/pages/TravelRequestList",
	"traveltrackingui/test/integration/pages/TravelRequestObjectPage"
], function (JourneyRunner, TravelRequestList, TravelRequestObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('traveltrackingui') + '/test/flpSandbox.html#traveltrackingui-tile',
        pages: {
			onTheTravelRequestList: TravelRequestList,
			onTheTravelRequestObjectPage: TravelRequestObjectPage
        },
        async: true
    });

    return runner;
});


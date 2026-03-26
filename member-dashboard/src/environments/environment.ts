// This file can be replaced during build by using the `fileReplacements` array.
// `ng build` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
  production: false,
  application: {
    api: 'http://k8s-default-gatewayi-97a16c80c5-860589405.us-east-1.elb.amazonaws.com/api',
    landingPortal: 'http://k8s-alinefinancial-b41e9faa9f-1405378233.us-east-1.elb.amazonaws.com'
  }
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/plugins/zone-error';  // Included with Angular CLI.

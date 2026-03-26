// export const environment = {
//   production: true,
//   application: {
//     api: 'https://api.alinefinancial.com/api',
//     landingPortal: 'https://alinefinancial.com'
//   }
// };

export const environment = {
  production: true,
  application: {
    api: 'http://k8s-default-gatewayi-97a16c80c5-860589405.us-east-1.elb.amazonaws.com/api',
    landingPortal: 'http://k8s-alinefinancial-b41e9faa9f-1405378233.us-east-1.elb.amazonaws.com'
  }
};
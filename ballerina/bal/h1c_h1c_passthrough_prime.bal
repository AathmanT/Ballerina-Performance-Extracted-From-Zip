import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/config;

@http:ServiceConfig { basePath: "/passthrough" }
service passthroughService on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) {
        int n = config:getAsInt("prime", defaultValue = 521);

        byte[]|error payload = clientRequest.getBinaryPayload();

        if(payload is byte[]){


            checkPrime(n);

            http:Response res = new;
            res.setPayload(untaint payload);
            res.setContentType(untaint clientRequest.getContentType());
            var result = caller->respond(res);
            if (result is error) {
               log:printError("Error sending response", err = result);
            }
        }
    }
}

public function checkPrime(int n) {
       int i=2;
       int m=0;
       int flag=0;
       //it is the number to be checked
       m=n/2;
       if(n==0||n==1){
         io:println(n+" is not prime number");
       }else{
           //for(i=2;i<=m;i++){
           while(i<=m){
               if(n%i==0){
                   io:println(n+" is not prime number");
                   flag=1;
                   break;
               }
               i=i+1;

           }
           if(flag==0)  {
               io:println(n+" is prime number");
           }
       }//end of else
}
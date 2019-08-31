import ballerina/http;
import ballerina/log;
import ballerina/config;
import ballerina/io;

http:Client nettyEP = new("http://netty:8688");

@http:ServiceConfig { basePath: "/passthrough" }
service passthroughService on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) {
        int n = config:getAsInt("prime");
        checkPrime(n);

        var response = nettyEP->forward("/service/EchoService", clientRequest);

        if (response is http:Response) {
            var result = caller->respond(response);
        } else {
            log:printError("Error at h1c_h1c_passthrough", err = response);
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(<string>response.detail()["message"]);
            var result = caller->respond(res);
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
         io:println(n," is not prime number");
       }else{
           //for(i=2;i<=m;i++){
           while(i<=m){
               if(n%i==0){
                   io:println(n," is not prime number");
                   flag=1;
                   break;
               }
               i=i+1;

           }
           if(flag==0)  {
               io:println(n," is prime number");
           }
       }//end of else
}
import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/reflect;


@http:ServiceConfig { basePath: "/service" }
service EchoService on new http:Listener(8688) {

    @http:ResourceConfig {
        methods: ["POST", "PUT", "GET"],
        path: "/EchoService"
    }
    resource function helloResource(http:Caller caller, http:Request req) {

        byte[]|error payload = req.getBinaryPayload();

        if(payload is byte[]){
            int n=10000019;

            checkPrime(n);

            http:Response res = new;
            res.setPayload(untaint payload);
            res.setContentType(untaint req.getContentType());
            var result = caller->respond(res);
            if (result is error) {
               log:printError("Error sending response", err = result);
            }
        }



        //json|error payload = req.getPayload();
        //
        //if (payload is json){
        //
        //   var result = caller->respond(untaint payload);
        //   if (result is error) {
        //        log:printError("Error sending response", err = result);
        //            var result = caller->respond("Error");
        //   }

        //
        //
        //
        //        //var result = caller->respond("Hello fdhfdWorld!");
        //        //if (result is error) {
        //        //    log:printError("Error sending response", err = result);
        //        //}
        //  }




}

}

//import ballerina.net.http;
//@http:configuration {
//    basePath:"/echo"
//}
//service<http> echo {
//    @http:resourceConfig {
//        methods:["POST"],
//        path:"/message"
//    }
//    resource echoMessage (http:Request req, http:Response resp) {
//        string payload = req.getStringPayload();
//        resp.setStringPayload(payload);
//        resp.send();
//    }
//}
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
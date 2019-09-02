import ballerina/http;
import ballerina/log;



@http:ServiceConfig { basePath: "/service" }
service EchoService on new http:Listener(8688) {

    @http:ResourceConfig {
        methods: ["POST", "PUT", "GET"],
        path: "/EchoService"
    }
    resource function helloResource(http:Caller caller, http:Request req) {

        byte[]|error payload = req.getBinaryPayload();

        if(payload is byte[]){
            http:Response res = new;
            res.setPayload(sanitizeAndReturnUntainted(payload));
            res.setContentType(req.getContentType());
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

function sanitizeAndReturnUntainted(byte[] input) returns @untainted byte[] {

    return input;
}
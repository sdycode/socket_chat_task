// import 'package:shelf/shelf.dart' as shelf;
// import 'package:shelf/shelf_io.dart' as io;

// void main() {
//   var handler = const shelf.Pipeline()
//       .addMiddleware(shelf.logRequests())
//       .addHandler(_echoRequest);

//   // Replace `localhost` with your IP address to make the endpoint accessible
//   // from other devices on your network.
//   io.serve(handler,"192.168.0.103", 8000).then((server) {
//     print('Serving at http://${server.address.host}:${server.port}');
//   });
// }

// shelf.Response _echoRequest(shelf.Request request) {
//   // Extract the `name` query parameter from the request and return a response
//   var name = request.url.queryParameters['name'];
//   if (name != null) {
//     nl.add("$name");
//   }
//   return shelf.Response.ok("$nl");
// }

import 'dart:io';
extension Reverse on String {
  String reverse() {
    return this.split('').reversed.join();
  }
  // ···
}

 String reverse(String s) {
    return s.split('').reversed.join();
  }
List<String> nl = [];
void main() async {
  // Create a server socket.
  // 192.168.1.2
  var server = await HttpServer.bind("0.0.0.0", 8080);
  print('Server listening on ${server.address}:${server.port}');

  // Wait for connections.
  await for (HttpRequest req in server) {
    // Upgrade the request to a WebSocket connection.
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      var socket = await WebSocketTransformer.upgrade(req);
      print('WebSocket client connected');

      // Listen for messages from the client.
      socket.listen((message) {
        if (message != null) {nl.add("$message");
          message = reverse(message);
          nl.add("$message");
        }
        print('Received message: $message');

        // Send a message back to the client.
        socket.add(nl.toString());
      });

      // Handle errors.
      socket.done.then((_) {
        print('WebSocket client disconnected');
      }).catchError((error) {
        print('WebSocket error: $error');
      });
    } else {
      // Handle regular HTTP requests.
      req.response.statusCode = HttpStatus.methodNotAllowed;
      req.response.write('WebSocket connections only');
      await req.response.close();
    }
  }
}





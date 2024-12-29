NGINX is now serving data - static data come directly by NGINX
Other from Sinatra - auth_service

# Interaction Flow
- Web Client:
- Sends an HTTP request (e.g., GET /users).
- Nginx (Reverse Proxy):
- Receives the request.
- Determines if it’s for static content (served directly by Nginx) or dynamic content (forwarded to the app server).
- Web Server (e.g., Puma):
- Receives the forwarded request from Nginx.
- Rack:
- Converts the request into a standard Ruby env hash.
- Passes it to Sinatra.
- Sinatra:
- Matches the request to a route (get '/users').
- Executes the Ruby code in the route block to generate a response.
- Rack:
- Wraps the response into a standard format (status, headers, body).
- Passes it back to the web server.
- Web Server (e.g., Puma):
- Sends the response to Nginx.
- Nginx:
- Forwards the dynamic response back to the client or serves cached/static content directly.
- Web Client:
- Receives the HTTP response.

# API doc visualisation with Swagger UI
- openApi documentation visualisation with Swagger UI can be found at:
```
localhost/api-docs/
```

# Debugger
## Configuration
- 2 things need to be set up - external debbuger and Remote interpreter
- I will use RubyMine as external debugger. It needs to be configured as shown in images below:
![image](https://github.com/user-attachments/assets/3238d101-d9e8-4fc2-8c1d-8852b3259fa3)
![image](https://github.com/user-attachments/assets/e3b8dc88-ec9b-4055-b827-48b201c21b0d)

- Also Remote interpreter needs to be set up according to docker-compose. Go to  ``File -> Settings -> Languages and Frameworks -> Ruby SDK and gems ``
- You should see this window:
- ![image](https://github.com/user-attachments/assets/39423a56-9836-4a7f-82c6-ed5d0c531d3f)
- Set it like this and hit OK:
- ![image](https://github.com/user-attachments/assets/ccc80ad5-e78d-46d9-b7e1-8538416a7b29)
- Choose the one you just added and hit OK again:
- ![image](https://github.com/user-attachments/assets/b8a6bf2a-1a43-4dba-b7a5-7fe0c362dfab)


## Run debugger
- You need to set environmental variable PROFILE=debug, to run the application with debugger on ruby_service. Run this in terminal:
```
PROFILE=debug docker compose up --build
```
- The ruby_service will now wait until external debugger is connected. Last line in the terminal should look like this:
```
auth_service   | Fast Debugger (ruby-debug-ide 0.7.4, debase 0.2.8, file filtering is supported) listens on 0.0.0.0:1234
```
- Now you have to go to RubyMine and start the debbuger we set up before.
- ![image](https://github.com/user-attachments/assets/10ffc963-89bd-47e7-a348-934542e4b7a0)

- You should see debug window below
- ![image](https://github.com/user-attachments/assets/61d4a9dd-87b5-4fa9-95c3-758a72bd68f0)


- You should also see that Puma started in the terminal where you run the docker compose up:
- ![image](https://github.com/user-attachments/assets/9739ce54-c6d9-4862-83af-7995312296a3)

- DONE! Now you can try add breakpoints to the code in your RubyMine and send request with Hoppscotch. 

- To run without debugger, simply start the docker without any env var. Such as:
```
docker compose up --build
```



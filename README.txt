NGINX is now serving data - static data come directly by NGINX
Other from Sinatra - auth_service

API/Frontend

Landing Page
	*Welcome to Transcendence + links to reg and login
	*Login could just be modal overlay
Registration form + verification in the front end
	*Username / 16 char
	*Password / 32 char
	*Email / email field - unique identifier
	*Foto/Avatar
Login form
	*Username/email
	*Password
	*OAuth
	* ….
User Info
	* All from registration DB


Get:
URLs;
http://localhost/api/auth/player-info?id=1
http://localhost/api/auth/player-info?id=2
http://localhost/

Static Data:
http://localhost/static/transcendence.jpg

Post:
http://localhost/api/auth/register

To test this in Postman:

Set the Method: POST.
Enter the URL: http://localhost/api/auth/register.
Headers:
Content-Type: application/json.
Body:
insert as Raw or json
{
  "username": "player123",
  "password": "securepassword123",
  "email": "player@example.com",
  "avatar": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
}

How our microservice is designed (single service)?

Interaction Flow

Web Client:
Sends an HTTP request (e.g., GET /users).
Nginx (Reverse Proxy):
Receives the request.
Determines if it’s for static content (served directly by Nginx) or dynamic content (forwarded to the app server).
Web Server (e.g., Puma):
Receives the forwarded request from Nginx.
Rack:
Converts the request into a standard Ruby env hash.
Passes it to Sinatra.
Sinatra:
Matches the request to a route (get '/users').
Executes the Ruby code in the route block to generate a response.
Rack:
Wraps the response into a standard format (status, headers, body).
Passes it back to the web server.
Web Server (e.g., Puma):
Sends the response to Nginx.
Nginx:
Forwards the dynamic response back to the client or serves cached/static content directly.
Web Client:
Receives the HTTP response.

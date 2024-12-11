To learn Ruby just:

Run docker compose command: like so:
docker compose build
docker compose up

In the directory of the auth_service you can edit the aut_service.rb file
to whatever you want and run docker compose again. The volume should contain
the file, so no re-build. Just re-run it. Like so:
docker compose up

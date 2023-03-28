run:
	make front
	make copy
	make docker-compose
front:
	cd frontend && npm run build && cd ..
copy:
	cp -r frontend/build/* backend/pollapp/gui
docker-build:
	cd backend && docker build -t pollapp . && cd ..
docker-compose:
	docker compose up --build
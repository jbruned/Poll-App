run:
	make linters && make build
linters:
	make linter-front && make linter-back
linter-front:
	cd frontend && npm run lint && cd ..
linter-back:
	cd backend && pylint *.py && pylint pollapp && cd ..
build:
	make build-front && make build-image
build-front:
	cd frontend && npm install && npm run build && cd .. && cp -r frontend/build/* backend/pollapp/gui
build-image:
	cd backend && docker build -t pollapp . && cd ..
deploy-local:
	docker compose up --build
push-ecr:
	echo "TODO"
IMAGE_NAME = pollapp
run:
	make deps && make lint && make build && make deploy-local
deps:
	make deps-front && make deps-back
deps-front:
	cd frontend && npm install && cd ..
deps-back:
	cd backend && pip install -r requirements.txt && cd ..
linters:
	make lint-front && make lint-back
lint-front:
	cd frontend && npm run lint && cd ..
lint-back:
	cd backend && pylint *.py && pylint pollapp && cd ..
super-linter:
	docker run --rm -e RUN_LOCAL=true --env-file ".github/super-linter.env" -v /"$(PWD)":/tmp/lint github/super-linter
build:
	make build-front && make build-image
build-front:
	cd frontend && npm install && npm run build && cd .. && mkdir -p backend/pollapp/gui && cp -r frontend/build/* backend/pollapp/gui
build-image:
	cd backend && docker build -t $(IMAGE_NAME) . && cd ..
save-image:
# 	ifeq ($(FILE_NAME),)
# 		$(error FILE_NAME is undefined)
# 	endif
	docker save $(IMAGE_NAME) > $(IMAGE_NAME).tar && gzip -c $(IMAGE_NAME).tar > $(FILE_NAME).tar.gz
deploy-local:
	docker compose up --build
push-ecr:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
	docker tag $(IMAGE_NAME):latest $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(AWS_IMAGE_NAME):latest
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(AWS_IMAGE_NAME):latest
deploy-ecs:
	cd deployment && bash deploy.sh
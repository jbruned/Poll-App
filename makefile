IMAGE_NAME = pollapp
run:
	make deps && make linters && make build
deps:
	make deps-front && make deps-back
deps-front:
	cd frontend && npm install && cd ..
deps-back:
	cd backend && pip install -r requirements.txt && cd ..
linters:
	make linter-front && make linter-back
linter-front:
	cd frontend && npm run lint && cd ..
linter-back:
	cd backend && pylint *.py && pylint pollapp && cd ..
build:
	make build-front && make build-image
build-front:
	cd frontend && npm install && npm run build && cd .. && mkdir -p backend/pollapp/gui && cp -r frontend/build/* backend/pollapp/gui
build-image:
	cd backend && docker build -t $(IMAGE_NAME) . && cd ..
save-image:
	ifndef $(FILE_NAME)
		$(error FILE_NAME is undefined)
	endif
	docker save $(IMAGE_NAME) > $(IMAGE_NAME).tar && gzip -c $(IMAGE_NAME).tar > $(FILE_NAME).tar.gz
deploy-local:
	docker compose up --build
push-ecr:
	ifndef $(AWS_ACCOUNT_ID)
		$(error AWS_ACCOUNT_ID is undefined)
	endif
	ifndef $(AWS_REGION)
		$(error AWS_REGION is undefined)
	endif
	ifndef $(AWS_ACCESS_KEY_ID)
		$(error AWS_ACCESS_KEY_ID is undefined)
	endif
	ifndef $(AWS_SECRET_ACCESS_KEY)
		$(error AWS_SECRET_ACCESS_KEY is undefined)
	endif
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
	docker tag $(IMAGE_NAME):latest $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME):latest
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME):latest
deploy-ecs:
	echo "Not implemented yet"
# 	ifndef AWS_ACCOUNT_ID
# 		$(error AWS_ACCOUNT_ID is undefined)
# 	endif
# 	ifndef AWS_REGION
# 		$(error AWS_REGION is undefined)
# 	endif
# 	ifndef AWS_ACCESS_KEY_ID
# 		$(error AWS_ACCESS_KEY_ID is undefined)
# 	endif
# 	ifndef AWS_SECRET_ACCESS_KEY
# 		$(error AWS_SECRET_ACCESS_KEY is undefined)
# 	endif
# 	aws ecs update-service --cluster pollapp-cluster --service pollapp-service --force-new-deployment
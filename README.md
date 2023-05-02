# Poll-App

Poll app for the "Gestión de Tecnologías Informáticas en las Organizaciones" course.

[![CI/CD](https://github.com/jbruned/Poll-App/actions/workflows/cicd.yml/badge.svg)](https://github.com/jbruned/Poll-App/actions/workflows/cicd.yml)

## Instructions

To build, deploy locally and run the app, you need to follow the next steps:

### 1. Install _Docker_ and _npm_

- You can download _Docker_ from [the official site](https://www.docker.com/products/docker-desktop).
- You can download _npm_ using [this link](https://www.npmjs.com/get-npm).

### 2. Clone the repository

Of course, you need to download the repository. You can do it using `git clone` or downloading the zip file.

### 3. Create the environment file

You need to create a file called `.env` in the root of the project.
This file will contain the environment variables that the app needs to run.
You can use the [`.env.example` file](.env.example) as a template.

### 4. Build and run

To run the app, you only need to run `make`. This will:

- Build the React app and copy the build files to the web server
- Build the web server _Docker_ image
- Create and run all necessary _Docker_ containers

### 5. Access the app

You can access the app at [http://localhost:80](http://localhost:80) or whatever port you specified in the `.env` file.
If your computer is available from the internet, you can access the app from other devices using its IP address or URL.
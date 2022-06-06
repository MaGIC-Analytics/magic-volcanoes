# MaGIC Volcano Plot App

![GitHub last commit](https://img.shields.io/github/last-commit/alemenze/magic-volcanoes)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![made with Shiny](https://img.shields.io/badge/R-Shiny-blue)](https://shiny.rstudio.com/)

## Running the App
This Shiny App has been built in to a docker container for easy deployment. You can build the image yourself (and thereby customize any ports you need) after downloading it:
```
docker build -t volcanoes .
docker run -d --rm -p 8080:8080 volcanoes
#Or for testing docker run -t -i --rm -p 8080:8080 volcanoes
```
And it should be hosted at localhost:8080


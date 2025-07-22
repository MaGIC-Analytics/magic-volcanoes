# MaGIC Volcano Plot App

[![DOI](https://zenodo.org/badge/500248949.svg)](https://zenodo.org/doi/10.5281/zenodo.10845738)
![GitHub last commit](https://img.shields.io/github/last-commit/MaGIC-Analytics/magic-volcanoes)
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

We have also included notes on how to run this via [Cloudrun](https://cloud.google.com/run) as a cost effective testing system, or alternatively as a microservice within a kubernetes cluster.

## Kubernetes deployment
This app has been designed for kubernetes deployment via Cloudrun as mentioned above or with a dedicated cluster. For the latter, we have implemented a system of managing and running microservices at scale via Rancher. Within the deployment directory, modify the services/ingress as needed for access, and the deployment itself for capacity. 
# Deployment notes

## CLI deployment
Based on rand3k repo

```
PROJECTID=$(gcloud config get-value project)
docker build . -t gcr.io/$PROJECTID/magic-volcanoes
docker push gcr.io/$PROJECTID/magic-volcanoes
gcloud run deploy --image gcr.io/$PROJECTID/magic-volcanoes --platform managed --max-instances 1
```
Manually adjust CPUs and RAM applied to the container as it may be custom.

## Manual deployment
Also very easy:
- Log into your gcloud account. 
- Access cloudrun
- Hit deploy new.
- Choose the repository and set it to the dockerfile
- Define your build conditions
- Update the timeout. Default is 10 min. 
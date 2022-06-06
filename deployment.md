#Deployment notes
Based on rand3k repo

```
PROJECTID=$(gcloud config get-value project)
docker build . -t gcr.io/$PROJECTID/magic-volcanoes
docker push gcr.io/$PROJECTID/magic-volcanoes
gcloud run deploy --image gcr.io/$PROJECTID/magic-volcanoes --platform managed --max-instances 1
```
Manually adjust CPUs and RAM applied to the container as it may be custom.

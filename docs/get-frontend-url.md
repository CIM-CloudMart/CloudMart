## Production

To fetch the latest Production URL dynamically:
```bash
kubectl get ingress frontend -n cloudmart-prod -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**Current Production URL:** 
[http://k8s-cloudmar-frontend-48db514dad-286419167.ap-south-1.elb.amazonaws.com](http://k8s-cloudmar-frontend-48db514dad-286419167.ap-south-1.elb.amazonaws.com)

---

## Staging

To fetch the latest Staging URL dynamically:
```bash
kubectl get ingress frontend -n cloudmart-staging -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**Current Staging URL:** 
[http://k8s-cloudmar-frontend-7aa486e458-1292609569.ap-south-1.elb.amazonaws.com](http://k8s-cloudmar-frontend-7aa486e458-1292609569.ap-south-1.elb.amazonaws.com)
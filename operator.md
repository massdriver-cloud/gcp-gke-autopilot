## Google Kubernetes Engine (GKE) Autopilot Cluster

Google Kubernetes Engine (GKE) Autopilot is a fully managed Kubernetes service that allows you to deploy, manage, and scale containerized applications using Google Cloud infrastructure. GKE Autopilot offers a hands-off operational model, taking care of the management and operations of your Kubernetes clusters, allowing you to focus solely on your applications.

### Design Decisions

1. **Enable Autopilot Mode**: The module enables Autopilot mode for the cluster to ensure it operates with a fully managed and hands-off approach.
2. **Private Cluster Configuration**: The design includes private nodes and endpoints to enhance security.
3. **Logging & Monitoring**: Enabled for both system components and workloads to facilitate observability.
4. **Addons**: Important add-ons like HTTP load balancing and GCE Persistent Disk CSI driver are enabled.
5. **Service Account**: A dedicated service account with necessary IAM roles for cluster nodes.
6. **Firewall Rules**: Firewall rules to allow control plane to access webhooks and other intra-cluster communications.
7. **Cert-Manager and External DNS**: Modules included for managing TLS certificates and DNS records with cert-manager and external-dns.

### Runbook

#### Unable to Connect to the Cluster

Ensure you have the correct credentials and your Kubernetes context is properly configured. This can commonly occur due to expired tokens or incorrect cluster configurations.

Check current context

```sh
kubectl config current-context
```

If the context is incorrect, set the correct one:

```sh
kubectl config use-context <your-cluster-name>
```

Fetch the cluster credentials:

```sh
gcloud container clusters get-credentials <your-cluster-name> --region <your-cluster-region>
```

#### Nodes Not Scheduling Pods

This issue can occur due to resource quotas, misconfiguration, or node issues.

Check node status:

```sh
kubectl get nodes
```

Inspect detailed node information:

```sh
kubectl describe node <node-name>
```

Look for potential issues related to resource limits or taints.

#### Pods in CrashLoopBackOff

Common issues for pods being in a CrashLoopBackOff state could be related to misconfigurations or application errors.

Inspect the logs of the pod:

```sh
kubectl logs <pod-name>
```

If the pod has multiple containers, you can specify the container name:

```sh
kubectl logs <pod-name> -c <container-name>
```

Check detailed state and events of the pod:

```sh
kubectl describe pod <pod-name>
```

#### DNS Issues within the Cluster

DNS issues can disrupt service discovery within the cluster and hinder communication between microservices.

Check the DNS resolution:

```sh
kubectl exec -it <pod-name> -- nslookup <service-name>.<namespace>.svc.cluster.local
```

If there are any issues, verify the CoreDNS pods:

```sh
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

Inspect the logs of the CoreDNS pods:

```sh
kubectl logs -n kube-system <coredns-pod-name>
```

#### TLS Certificates Not Renewing

Certificates managed by cert-manager might not renew if there are issues with the issuer or solver configurations.

Check the status of the ClusterIssuer:

```sh
kubectl describe clusterissuer letsencrypt-prod
```

Inspect events and status of Certificate resource:

```sh
kubectl describe certificate <certificate-name>
```

Review logs of the cert-manager pod for any errors:

```sh
kubectl logs -n cert-manager <cert-manager-pod-name>
```


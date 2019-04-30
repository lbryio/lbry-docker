# LBRY on Kubernetes with Helm

Contributing Author: [EnigmaCurry](https://www.enigmacurry.com)

Last Update: May 6 2019

Deploy lbrycrd, lbrynet, chainquery, mysql, and spee.ch on your Kubernetes
cluster.

[![asciicast](https://asciinema.org/a/fkVzPW05vKFEjBXdDp6I81odA.svg)](https://asciinema.org/a/fkVzPW05vKFEjBXdDp6I81odA)

<!-- Regenerate Table of contents with markdown-toc npm library -->
<!-- run:   npx markdown-toc -i README.md                       -->

<!-- toc -->

- [Requirements](#requirements)
- [Helm Charts](#helm-charts)
  * [Tiller](#tiller)
  * [nginx-ingress](#nginx-ingress)
  * [cert-manager](#cert-manager)
  * [k8s-lbry](#k8s-lbry)
  * [lbrycrd](#lbrycrd)
  * [chainquery](#chainquery)
    + [MySQL for chainquery](#mysql-for-chainquery)
    + [Start chainquery](#start-chainquery)
    + [Startup chainquery with a database snapshot](#startup-chainquery-with-a-database-snapshot)
  * [lbrynet](#lbrynet)
    + [IMPORTANT - Backup your cluster wallet](#important---backup-your-cluster-wallet)
  * [spee.ch](#speech)
    + [MySQL for speech](#mysql-for-speech)
    + [Configure Speech](#configure-speech)
- [TLS Support](#tls-support)
  * [Assign DNS name(s) to your Load Balancer](#assign-dns-names-to-your-load-balancer)
  * [Enable TLS](#enable-tls)
- [Improvements](#improvements)

<!-- tocstop -->

## Requirements

 * A Kubernetes cluster with role-based access control (RBAC) enabled.
   * This tutorial was tested on a fresh DigitalOcean managed cluster on nodes
     with 8GB of RAM, on kubernetes 1.13.5.
 * [kubectl command line
   tool](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed on
   your local development machine.
   * Tested with kubectl v1.14.0
 * [Helm command line tool](https://github.com/helm/helm/releases) installed on
   your local development machine.
   * Tested with helm v2.13.1

Your cloud provider should have instructions for setting up kubectl to talk to
your cluster. This usually involves downloading a config file and putting it in
`$HOME/.kube/config`. (The file has to be renamed `config` and put in the
`$HOME/.kube` directory.)

Note: If you want to download the cluster config to a location other than
`$HOME/.kube/config`, you can set the `KUBECONFIG` environment variable to the
full path of your config file, or create a symlink from your config file to
`$HOME/.kube/config`, or you can use the `--kubeconfig` parameter to both
`kubectl` and `helm` commands every time you use them.

Test that your kubectl can talk to your cluster, by querying for a list of running
nodes:

```
kubectl get nodes
```

If everything is working, you should see a list of one or more nodes running and
showing `STATUS=Ready`

## Helm Charts

This system is installed via [Helm](https://helm.sh/docs/), the package manager
for Kubernetes. [Helm Charts](https://helm.sh/docs/developing_charts/#charts)
are the basis for packages in Helm. This directory is a Helm chart itself.

### Tiller

Tiller is the cluster-side component of helm, and needs to be installed before
you can use helm with your cluster. Run the following to install tiller to your
cluster:

```
kubectl -n kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller --clusterrole cluster-admin \
      --serviceaccount=kube-system:tiller

helm init --service-account tiller
helm repo update
```

Now you can use helm locally to install things to your remote cluster.

### nginx-ingress

An Ingress Controller
([nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress))
will help you to route outside internet traffic into your cluster. nginx-ingress
will also help terminate TLS connections (SSL) so that your containers don't
need to worry about encryption.

Install nginx-ingress, with HTTPs turned off initially:

```
helm install stable/nginx-ingress --name nginx-ingress \
  --set nginx-ingress.controller.service.enableHttps=false
```

### cert-manager

[cert-manager](https://docs.cert-manager.io/en/latest/index.html) will provide
TLS certificates (SSL) for your cluster, using [Let's
Encrypt](https://letsencrypt.org/).

Install cert-manager:

```
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.7/deploy/manifests/00-crds.yaml

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install --name cert-manager --namespace cert-manager jetstack/cert-manager --version v0.7.1

kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"
```

### k8s-lbry

The k8s-lbry helm chart installs lbrycrd, chainquery, lbrynet, and mysql. 

Wait for the Load Balancer to show an External IP: 

```
kubectl get svc -l app=nginx-ingress,component=controller -w
```

Press Ctrl-C to quit once you see the External IP listed (and not `<pending>`).

Add the `k8s-lbry` helm repository:

```
helm repo add k8s-lbry https://k8s-lbry.sfo2.digitaloceanspaces.com
```

Create a directory to store your configuration file for `k8s-lbry`. You can
download the default configuration file for the helm chart
([values.yaml](values.yaml)):

```
VALUES=https://raw.githubusercontent.com/lbryio/lbry-docker/master/contrib/k8s-lbry/values.yaml

curl -Lo values.yaml $VALUES
```

`values.yaml` is your own configuration file for `k8s-lbry`. You will need it
everytime you need to update your deployment. Commit the file to a git
repository, or save it someplace safe.

Edit `values.yaml`, change the following things:

 * Change `lbrycrd.configurationFile.lbrycrd.conf` at the bottom find
   `externalip=` and set it equal to the External IP address of the Load
   Balancer obtained above.
 * Change `cert-manager-issuer.email` to your email address to receive notices
   from Let's Encrypt. (Only used if you choose to enable TLS.)
 * Change `echo-http-server.hostname` to any domain name you choose. (It must be
   a real internet domain that you control, if you choose to enable TLS.)

Save `values.yaml`.

Now install `k8s-lbry`:

```
helm install -n k8s-lbry k8s-lbry/k8s-lbry -f values.yaml
```

This will create a new helm release for your cluster called `k8s-lbry`, from the
helm repository called `k8s-lbry`, using the package named `k8s-lbry`, using the
local configuration file called `values.yaml`.

### lbrycrd

Find the lbrycrd pod to ensure it has started correctly:

```
kubectl get pods -l app=lbrycrd
```

Tail the logs (Press Ctrl-C to quit):

```
kubectl logs -f -l app=lbrycrd
```

You can use lbrycrd-cli from the running pod:

```
POD=`kubectl get pod -l app=lbrycrd -o name | sed s+pod/++` && \
  kubectl exec $POD -- lbrycrd-cli -rpcuser=lbry -rpcpassword=lbry getinfo
```

Upgrade the nginx-ingress release to allow forwarding port 9246 to lbrycrd:

```
helm upgrade nginx-ingress stable/nginx-ingress \
  --set tcp.9246="default/k8s-lbry-lbrycrd:9246"
```

Verify the port is now open (9246 listed under PORTS):

```
kubectl get svc nginx-ingress-controller
```

After your lbrycrd service has been online for awhile, check back with the
`lbrcrd-cli getinfo` command from above. You will know that nginx-ingress is
properly connected to lbrycrd if you see that the number of connections listed
is a number greater than 8.

### chainquery

#### MySQL for chainquery
[MySQL](https://github.com/helm/charts/tree/master/stable/mysql) is used as
the database chainquery talks to.

Edit `values.yaml` and set `chainquery-mysql.enabled` to `true`. 

Upgrade the release to turn on mysql for chainquery:

```
helm upgrade k8s-lbry k8s-lbry/k8s-lbry -f values.yaml
```

You can try logging into the mysql shell if you like (default password is
`chainquery`):

```
POD=`kubectl get pod -l app=k8s-lbry-chainquery-mysql -o name | sed s+pod/++` && \
  kubectl exec -it $POD -- mysql -u chainquery -p
```

You can view the mysql logs:

```
kubectl logs -l app=k8s-lbry-chainquery-mysql -f
```

#### Start chainquery

Edit `values.yaml` and set `chainquery.enabled` to `true`. 

Upgrade the release to turn on chainquery:

```
helm upgrade k8s-lbry k8s-lbry/k8s-lbry -f values.yaml
```

You can view the chainquery logs:

```
kubectl logs -l app=chainquery -f
```

#### Startup chainquery with a database snapshot

If chainquery is starting with a blank MySQL database, it will take several days
to synchronize with the full lbycrd blockchain. If this is OK, you can just
watch the chainquery logs and wait for it to get to the [current block
height](https://explorer.lbry.io/).

If you cannot wait that long, you may start from a database snapshot to speed up
this process.

Delete the chainquery and mysql deployments:

```
kubectl delete deployments k8s-lbry-chainquery k8s-lbry-chainquery-mysql
```

The pods will automatically terminate.

The mysql data still exists in a PersistentVolumeClaim, `k8s-lbry-chainquery-mysql`. Check
that it still exists:

```
kubectl get pvc
```

There's an included script to start a utility container with a PersistentVolume
attached. Download the script:

```
SCRIPT=https://raw.githubusercontent.com/lbryio/lbry-docker/master/contrib/k8s-lbry/scripts/kubectl-run-with-pvc.sh

curl -Lo kubectl-run-with-pvc.sh $SCRIPT && chmod a+x kubectl-run-with-pvc.sh
```

Run the `kubectl-run-with-pvc` script, attaching the mysql PVC:

```
./kubectl-run-with-pvc.sh k8s-lbry-chainquery-mysql
```

Wait a second for the container to start, and you should then be placed into a
container shell, indicated by the shell prompt changing to the container's
prompt.

In the container shell, delete any existing mysql data from the volume:

```
rm /pvcs/k8s-lbry-chainquery-mysql/* -rf
```

Still in the container shell, download the backup and extract it to the volume:

```
apt update && apt install -y curl

BACKUP_URL=https://lbry-chainquery-mysql-dump.sfo2.digitaloceanspaces.com/chainquery_height_560900.mysql-backup.tar.gz
curl $BACKUP_URL | tar xvz -C /pvcs/k8s-lbry-chainquery-mysql/
```

Once the download and extraction completes, exit the container (or just press
Ctrl-D):

```
exit
```

Now back on your local shell, upgrade the release to re-create the mysql and
chainquery deployments:

```
helm upgrade k8s-lbry k8s-lbry/k8s-lbry -f values.yaml
```

You can verify that the database now has data up to the height of the database
snapshot. Login to the mysql shell (password: `chainquery`):

```
POD=`kubectl get pod -l app=k8s-lbry-chainquery-mysql -o name | sed s+pod/++` && \
  kubectl exec -it $POD -- mysql -u chainquery -p
```

Then query for the number of blocks:

```
mysql> select count(*) from chainquery.block;
+----------+
| count(*) |
+----------+
|   561034 |
+----------+
1 row in set (15.00 sec)
```

Also verify that chainquery is again happy. View the chainquery logs:

```
kubectl logs -l app=chainquery -f
```

### lbrynet

Edit `values.yaml` and set `lbrynet.enabled` to `true`.

Update the release to turn on lbrynet:

```
helm upgrade k8s-lbry k8s-lbry/k8s-lbry -f values.yaml
```

You can view the lbrynet logs:

```
kubectl logs -l app=lbrynet -f
```

#### IMPORTANT - Backup your cluster wallet

The wallet is stored inside the `k8s-lbry-lbrynet` persistent volume.

Copy the wallet in case the volume gets destroyed:

```
WALLET=/home/lbrynet/.local/share/lbry/lbryum/wallets/default_wallet \
POD=`kubectl get pod -l app=lbrynet -o name | sed s+pod/++` && \
  kubectl cp $POD:$WALLET /tmp/k8s-lbry-lbrynet-wallet-backup.json
```

Check the contents of `/tmp/k8s-lbry-lbrynet-wallet-backup.json` and move the
file to a safe place for backup (and delete this temporary file.)

Once your wallet is backed up, you can generate a receiving address in order to
deposit LBC:

```
POD=`kubectl get pod -l app=lbrynet -o name | sed s+pod/++` && \
  kubectl exec $POD -- lbrynet address unused
```

### spee.ch

Note: Throughout this deployment, the unstylized name `speech` is used.

#### MySQL for speech
[MySQL](https://github.com/helm/charts/tree/master/stable/mysql) is used as
the database speech talks to.

Edit `values.yaml` and set `speech-mysql.enabled` to `true`. 

Upgrade the release to turn on mysql for speech:

```
helm upgrade k8s-lbry k8s-lbry/k8s-lbry -f values.yaml
```

You can try logging into the mysql shell if you like (default password is
`speech`):

```
POD=`kubectl get pod -l app=k8s-lbry-speech-mysql -o name | sed s+pod/++` && \
  kubectl exec -it $POD -- mysql -u speech -p
```

You can view the mysql logs:

```
kubectl logs -l app=k8s-lbry-speech-mysql -f
```

#### Configure Speech

Before you can fully configure speech, you must fund your lbrynet wallet in the
`k8s-lbry-lbrynet` deployment. Check the lbrynet section for details on
generating a receiving address for your wallet, as well as backing up your
wallet.

Speech has a large configuration, all of which is found in `values.yaml`. The
most important settings to configure yourself are:

 * `speech.enabled` - turns on/off the the speech deployment.
 * `speech.service.hostname` - The external hostname for speech.
 * `speech.persistence.size` - How large of a data directory for speech.
 * `speech.auth.masterPassword`
 * `speech.details`
 * `speech.publishing.primaryClaimAddress`

   * This can be retrieved from the lbrynet pod:
   
```
POD=`kubectl get pod -l app=lbrynet -o name | sed s+pod/++` && \
  kubectl exec $POD -- lbrynet address list
```
   
   * Copy the first address from the list. This is your `primaryClaimAddress`.
   
 * `speech.publishing.publishOnlyApproved`
 * `speech.publishing.approvedChannels`
 * `speech.publishing.thumbnailChannel`
 
   * In order to publish thumbnails, you must create a channel. There are many options in creation. See the help from the lbrynet command to list them all:
    
```
POD=`kubectl get pod -l app=lbrynet -o name | sed s+pod/++` && \
  kubectl exec $POD -- lbrynet channel create --help
```
    
   * For example, this will create the channel named `YourChannel`, bidding 1 LBC for the name:

```
POD=`kubectl get pod -l app=lbrynet -o name | sed s+pod/++` && \
  kubectl exec $POD -- lbrynet channel create --name @YourChannel --bid 1.0
```

   * Make sure that when you copy the channel name to `values.yaml` that you use double quotes surrounding the value for thumbnailChannel. This is because in YAML, the `@` symbol cannot be used without quotes. ie: `thumbnailChannel: "@YourChannel"`

 * `speech.publishing.thumbnailChannelId`
 
   * When you create the channel, listed in the `outputs` section, you will find
`claim_id`; this is the `thumbnailChannelId`. You can also retrieve this
information again by running `channel list`:

```
POD=`kubectl get pod -l app=lbrynet -o name | sed s+pod/++` && \ 
  kubectl exec $POD -- lbrynet channel list
```

Once you've configured speech in `values.yaml`, upgrade the helm release to
apply the changes:

```
helm upgrade k8s-lbry k8s-lbry/k8s-lbry -f values.yaml
```

Open your browser to the hostname specified in `speech.service.hostname` and
demo the site.

## TLS Support

Enabling TLS (SSL) for your cluster is optional, but it is useful if you are
going to expose any HTTP services externally.

### Assign DNS name(s) to your Load Balancer

The k8s-lbry chart started a Load Balancer as part of the Ingress Controller.
You can assign a DNS name to the Load Balancer External IP address.

Get the External IP of the Load Balancer:

```
kubectl get svc -l app=nginx-ingress,component=controller
```

Copy the External IP address shown. Update your DNS provider for your domain
accordingly, with a subdomain of your choice to point to the External IP address.

Edit `values.yaml` and set `echo-service.enabled` to `true`. Set
`echo-service.hostname` to the domain name you configued in your DNS.

Upgrade the release to turn on the echo-http-server:

```
helm upgrade k8s-lbry k8s-lbry/k8s-lbry -f values.yaml
```

Verify that the DNS is setup correctly by using curl to the echo-http-server on
port 80:

```
curl http://echo.example.com
```

(Replace `echo.example.com` with the domain you used in `values.yaml`.)

You should see the word `echo` returned.

  
### Enable TLS 

Once you've verified that DNS for your domain correctly routes to the
echo-http-server, upgrade the nginx-ingress release with HTTPs now turned on:

```
helm upgrade nginx-ingress stable/nginx-ingress \
  --set nginx-ingress.controller.service.enableHttps=true
```

Upgrade the k8s-lbry release, turning on HTTPs for the echo-http-server:

```
helm upgrade k8s-lbry k8s-lbry/k8s-lbry -f values.yaml --set echo-http-server.enableHttps=true
```

Check that HTTPs connection to the echo service is working: 

```
curl https://echo.example.com
```

(Replace `echo.example.com` with the domain you used in `values.yaml`.)

You should see the word `echo` returned. However, it may take up to 5 minutes
for it to start to work. 

Watch the cert-manager log:

```
kubectl logs --namespace cert-manager -l app=cert-manager -f
```

A successful certificate message would look like:

```
Certificate "echo-tls" for ingress "echo" is up to date
```

Retry the curl command until you get an `echo` response.

## Improvements

Beyond this point, there are several things one could do to improve this
configuration and harden for production.

 * Secrets

   * At this stage, all your configuration resides in `values.yaml`, including
passwords. You can seperate these secrets out of your config and put them into a
[Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/).

   * [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)

   * [Helm Secrets](https://github.com/futuresimple/helm-secrets)

 * Namespaces

   * If you are using the cluster for things other than lbry, you should install
     k8s-lbry into its own namespace. This will allow pods within the same
     namespace to talk to eachother, but not to pods in other namespaces.

   * Using a namespace in the introductory docs above, would have complicated
     the (already complex) helm and kubectl commands, so they were omitted.

   * Both helm and kubectl support the `--namespace` argument. You can translate
     all the commands above, adding the `--namespace` argument.

     For example, to install the k8s-lbry chart in its own `k8s-lbry` namespace:

     ```
     ## helm install RELEASE REPO/CHART --namespace NAMESPACE -f VALUES
     helm install k8s-lbry k8s-lbry/k8s-lbry --namespace k8s-lbry -f values.yaml
     ```

     And to look at pods in the `k8s-lbry` namespace:

     ```
     kubectl get pods --namespace k8s-lbry
     ```

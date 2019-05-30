# LBRY on Kubernetes with Helm

Contributing Author: [EnigmaCurry](https://www.enigmacurry.com)

Last Update: May 30 2019

Deploy lbrycrd, lbrynet, chainquery, mysql, and spee.ch on your Kubernetes
cluster.

[![asciicast](https://enigmacurry.github.io/lbry-docker/contrib/k8s-lbry/kick-ascii/cast/k8s-lbry.png)](https://enigmacurry.github.io/lbry-docker/contrib/k8s-lbry/kick-ascii/?cast=k8s-lbry&bg=lbry.png)

<!-- Regenerate Table of contents with markdown-toc npm library -->
<!-- run:   npx markdown-toc -i README.md                       -->

<!-- toc -->

- [Requirements](#requirements)
- [Security Notice](#security-notice)
- [Installation](#installation)
  * [Create a project directory](#create-a-project-directory)
  * [Setup alias and tab completion](#setup-alias-and-tab-completion)
  * [k8s-lbry setup](#k8s-lbry-setup)
  * [k8s-lbry install-nginx-ingress](#k8s-lbry-install-nginx-ingress)
  * [k8s-lbry install-cert-manager](#k8s-lbry-install-cert-manager)
  * [k8s-lbry install](#k8s-lbry-install)
  * [k8s-lbry upgrade](#k8s-lbry-upgrade)
- [Services](#services)
  * [lbrycrd](#lbrycrd)
  * [chainquery](#chainquery)
    + [MySQL for chainquery](#mysql-for-chainquery)
    + [Start chainquery](#start-chainquery)
    + [Startup chainquery with a database snapshot](#startup-chainquery-with-a-database-snapshot)
  * [lbrynet API service (not for spee.ch)](#lbrynet-api-service-not-for-speech)
    + [IMPORTANT - Backup your cluster wallet](#important---backup-your-cluster-wallet)
  * [spee.ch (and lbrynet sidecar and mysql)](#speech-and-lbrynet-sidecar-and-mysql)
    + [IMPORTANT - Backup your speech wallet](#important---backup-your-speech-wallet)
    + [Fund your speech wallet](#fund-your-speech-wallet)
    + [Create a thumbnail channel](#create-a-thumbnail-channel)
    + [Finish speech setup](#finish-speech-setup)
- [Extra commands that k8s-lbry (run.sh) provides](#extra-commands-that-k8s-lbry-runsh-provides)
  * [k8s-lbry helm](#k8s-lbry-helm)
  * [k8s-lbry kubectl](#k8s-lbry-kubectl)
  * [k8s-lbry logs](#k8s-lbry-logs)
  * [k8s-lbry shell](#k8s-lbry-shell)
  * [k8s-lbry shell-pvc](#k8s-lbry-shell-pvc)
  * [k8s-lbry restart](#k8s-lbry-restart)
  * [k8s-lbry lbrynet](#k8s-lbry-lbrynet)
  * [k8s-lbry chainquery-mysql-client](#k8s-lbry-chainquery-mysql-client)
  * [k8s-lbry speech-mysql-client](#k8s-lbry-speech-mysql-client)
  * [k8s-lbry lbrynet-copy-wallet](#k8s-lbry-lbrynet-copy-wallet-)
  * [k8s-lbry package](#k8s-lbry-package)
- [TLS / SSL / HTTPS](#tls--ssl--https)
- [Cloud specific notes](#cloud-specific-notes)
  * [AWS](#aws)
  * [minikube](#minikube)
- [Uninstall](#uninstall)

<!-- tocstop -->

## Requirements

 * A Kubernetes cluster.
   * Tested on DigitalOcean managed Kubernetes cluster on nodes with 8GB of RAM,
     on kubernetes 1.14.1.
   * Tested on AWS with [Charmed Kubenetes
     Distribution](https://www.ubuntu.com/kubernetes/docs/quickstart) - See
     [AWS specific notes](#aws).
   * Tested on
     [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) for a
     self-contained virtual machine running kubernetes in VirtualBox - - See
     [minikube specific notes](#minikube).
 * Local development machine dependencies:
   * [GNU Bash](https://www.gnu.org/software/bash/) and friends. If you're on
     Linux or Mac, you should be good to go.
   * [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
      * Tested with kubectl v1.14.0
   * [helm](https://github.com/helm/helm/releases)
      * Tested with helm v2.13.1
 * Optional: for TLS / HTTPs support, you will also need an internet domain
   name, and the ability to update its DNS.

Your cloud provider should have instructions for setting up `kubectl` to talk to
your cluster. This usually involves downloading a config file and putting it in
`$HOME/.kube/config`. (The file has to be renamed `config` and put in the
`$HOME/.kube` directory.)

Test that your `kubectl` can talk to your cluster, by querying for a list of
running nodes:

```
kubectl get nodes
```

If everything is working, you should see a list of one or more nodes running and
showing `STATUS=Ready`

## Security Notice

Any cryptocurrency wallet that is online is a security concern. For any
real-world production deployment, you will need to review this architecture
closely to see if it fits with your chosen platform and network environment.

This system is currently designed for a kubernetes cluster that has a single
administrator (or possibly a small team of trusted users). It will not support
untrusted multi-tenancy out of the box.

All of the services are created in their own namespace, but no [Security
Policies](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) have
been applied to the pods.

The Helm configuration file contains *all* of the configuration for the system,
*including passwords* in plain text.

The lbrynet SDK wallets are individually stored unencrypted in their own
persistent volumes.

## Installation

This system is installed via [Helm](https://helm.sh/docs/), the package manager
for Kubernetes. [Helm Charts](https://helm.sh/docs/developing_charts/#charts)
are the basis for packages in Helm. This directory is a Helm chart itself.

All of the helm and kubectl commands necessary to install, upgrade, and maintain
your deployments, are wrapped in the included [`run.sh`](run.sh) script. For
debugging purposes, this wrapper also prints to stdout the full underlying
commands (helm, kubectl, etc) as they are run.

### Create a project directory

Create a new directory someplace to store your deployment configuration. For the
rest of this tutorial, you will work from this directory:

```
mkdir $HOME/k8s-lbry-test

cd $HOME/k8s-lbry-test
```

Download `run.sh` to this same directory:

```
curl -Lo run.sh https://raw.githubusercontent.com/EnigmaCurry/lbry-docker/k8s-lbry/contrib/k8s-lbry/run.sh

chmod a+x run.sh
```

### Setup alias and tab completion

`run.sh` can be run directly without any setup. However, without adding it to
your `PATH`, you need to specify the full path to the script each time. Setting
a bash alias for `run.sh` is the quickest way of setting up to run from
anywhere, as well as activating support for bash tab completion.

One time setup to install alias to `$HOME/.bashrc`:

```
./run.sh setup-alias
```

It should prompt you if it is OK for the script to edit `$HOME/.bashrc`. Once
you confirm, close your terminal session, then reopen it.

Verify the new `k8s-lbry` alias to `run.sh` is working:

```
k8s-lbry kubectl get nodes
```

Notice that tab completion should work throughout typing the above command.

### k8s-lbry setup

Setup will check for dependencies, update helm repositories, and create an
initial config file (`values-dev.yaml`).

```
k8s-lbry setup
```

### k8s-lbry install-nginx-ingress

An Ingress Controller
([nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress))
will help you to route outside internet traffic into your cluster. nginx-ingress
will also help terminate TLS connections (SSL) so that your containers don't
need to worry about encryption of traffic.

Install nginx-ingress into the `k8s-lbry` namespace:

```
k8s-lbry install-nginx-ingress
```

### k8s-lbry install-cert-manager

[cert-manager](https://docs.cert-manager.io/en/latest/index.html) will provide
TLS certificates (SSL) for your cluster, using [Let's
Encrypt](https://letsencrypt.org/).

Install cert-manager into the `cert-manager` namespace:

```
k8s-lbry install-cert-manager
```

### k8s-lbry install

Once nginx-ingress and cert-manager are installed, the main helm chart can be
installed. This installs lbrycrd, chainquery, lbrynet, spee.ch, and mysql,
depending on what you enable in `values-dev.yaml`.

Find the External IP address for your load balancer:

```
k8s-lbry kubectl get svc nginx-ingress-controller -o wide
```

If you find a hostname instead of an IP address, this means your load balancer
has multiple IP addresses. In this case, you will need to resolve the domain
name to find the IP addresses. If this affects you, [paste the hostname into
this tool](https://toolbox.googleapps.com/apps/dig/). Look for the `;ANSWER`
section and you should see two or more IP addresses listed. Since lbrycrd will
only advertise one IP address, pick just one of the IP addresses to use for the
purposes of this tutorial.

You must edit your own `values-dev.yaml`. (The setup procedure created an
initial configuration in the same directory as `run.sh`.) To use a different
config file, export the `VALUES` environment variable before subsequent
commands, specifying the full path to your values file.

Edit `values-dev.yaml`. You only need to change one thing right now:

 * Change `lbrycrd.configurationFile.lbrycrd.conf` at the bottom of this section
   find `externalip=` and set it equal to the External IP address of the Load
   Balancer obtained above. (Example: `externalip=123.123.123.123`)
 
Save `values-dev.yaml`. 

Now run the install script to create the new release:

```
k8s-lbry install
```

### k8s-lbry upgrade

For helm, `upgrade` does not necessarily mean you are upgrading to a new version
of any particular software, `upgrade` just means to apply your configuration
file to the cluster. If you edit `values-dev.yaml`, you then need to apply your
changes with `k8s-lbry upgrade`.

You can make changes to `values-dev.yaml` at any time. You can apply your
configuration to your cluster by upgrading the release:

```
k8s-lbry upgrade
```

You can upgrade as often as you want. Each time you upgrade the release, helm
increases the `REVISION` number:

```
k8s-lbry helm ls
```

## Services

### lbrycrd

After running the installation above, you should now have a running lbrycrd pod.
Verify this by listing the pods for the `k8s-lbry` namespace:

```
k8s-lbry kubectl get pods
```

You should see a pod listed with a name that starts with `lbrycrd`.

Check the lbrycrd logs:

```
k8s-lbry logs lbrycrd
```

Press Ctrl-C to stop viewing the log.

It is advisable to wait for lbrycrd to synchronize with the full blockchain
before starting other services, so watch the logs until synchronization
completes (`progress=1.0`).

You can utilize `lbrycrd-cli` as well:

```
k8s-lbry lbrycrd-cli --help
```

### chainquery

#### MySQL for chainquery
[MySQL](https://github.com/helm/charts/tree/master/stable/mysql) is used as
the database chainquery talks to.

Edit `values-dev.yaml` and set `chainquery-mysql.enabled` to `true`. 

Upgrade the release to turn on mysql for chainquery:

```
k8s-lbry upgrade
```

You can try logging into the mysql shell if you like:

```
k8s-lbry chainquery-mysql-client
```

You can view the mysql logs:

```
k8s-lbry logs chainquery-mysql
```

Press Ctrl-C to stop viewing the log.

#### Start chainquery

Edit `values-dev.yaml` and set `chainquery.enabled` to `true`. 

Upgrade the release to turn on chainquery:

```
k8s-lbry upgrade
```

You can view the chainquery logs:

```
k8s-lbry logs chainquery
```

#### Startup chainquery with a database snapshot

If chainquery is starting with a blank MySQL database, it will take several days
to synchronize with the full lbrycrd blockchain. If this is OK, you can just
watch the chainquery logs and wait for it to get to the [current block
height](https://explorer.lbry.io/).

If you cannot wait that long, you can scrap your existing chainquery database
and restart from a more recent database snapshot:

```
k8s-lbry chainquery-override-snapshot
```

This will prompt if you really wish to destroy the current chainquery database.
If you confirm, the existing chainquery and chainquery-mysql deployments will be
deleted, and pods will be terminated, ***and the contents of the Persistent
Volume Claim (PVC) for chainquery-mysql will be deleted.*** The snapshot will be
downloaded and restored in its place.

Once the snapshot is restored, upgrade the release to restore the chainquery and
chainquery-mysql deployments, and restart pods:

```
k8s-lbry upgrade
```

You can verify that the database now has data up to the height of the database
snapshot. Login to the mysql shell:

```
k8s-lbry chainquery-mysql-client
```

Then query for the latest block height:

```
mysql> select height from chainquery.block order by id desc limit 1;
+--------+
| height |
+--------+
| 561080 |
+--------+
1 row in set (0.00 sec)
```

Also verify that chainquery is again happy. View the chainquery logs:

```
k8s-lbry logs chainquery
```

Press Ctrl-C to quit viewing the logs.

### lbrynet API service (not for spee.ch)

This is for a standalone lbrynet API service inside your cluster. Blob storage
goes to its own persistent volume, but is configured with `save_files=false`.
There is no outside access to the Downloads directory provided. You can stream
blobs from lbrynet via `http://lbrynet:5279/get/CLAIM_NAME/CLAIM_ID`.

This particular lbrynet configuration won't work for spee.ch (v0.5.12). spee.ch
needs direct access to the Downloads directory of lbrynet. **If you are wanting
lbrynet for spee.ch, skip this section, and head directly to the [spee.ch
section](#speech-and-lbrynet-sidecar-and-mysql), which implements its own
lbrynet sidecar.**

Edit `values-dev.yaml` and set `lbrynet.enabled` to `true`.

Upgrade the release to turn on lbrynet:

```
k8s-lbry upgrade
```

You can view the lbrynet logs:

```
k8s-lbry logs lbrynet
```

#### IMPORTANT - Backup your cluster wallet

The wallet is created inside the `lbrynet` persistent volume.

Copy the wallet in case the volume gets destroyed:

```
k8s-lbry lbrynet-copy-wallet /tmp/k8s-lbry-lbrynet-wallet-backup.json
```

Check the contents of `/tmp/k8s-lbry-lbrynet-wallet-backup.json` and move the
file to a safe place for backup (make sure to delete the temporary file.)

Once your wallet is backed up, you can generate a receiving address in order to
deposit LBC:

```
k8s-lbry lbrynet address unused
```

### spee.ch (and lbrynet sidecar and mysql)

*Note: Throughout this deployment, the unstylized name `speech` is used.*

Speech needs three containers, running in two pods:

 * `speech` pod:
 
   * speech, the nodejs server container.

   * lbrynet, running in the same pod as speech, so as to share one downloads
     directory. (This is called a 'sidecar' container, which is guaranteed to
     run on the same kubernetes node as the spee.ch container.)
   
 * `speech-mysql` pod:
 
   * mysql for storing the speech database.

Edit `values-dev.yaml`. 

 * Set `speech-mysql.enabled` to `true`.
 * Set `speech.enabled` to `true`.
 * Set `speech.service.hostname` to your subdomain name for speech.
 * Set `speech.site.details.host` to your subdomain name for speech.
 * Set `speech.site.details.ipAddress` to your Load Balancer external IP address.
 * Set `speech.site.details.title`

Upgrade the release to turn on `speech`, `speech-lbrynet`, and `speech-mysql`:

```
k8s-lbry upgrade
```

Speech will not work yet! Continue on through the next sections.

#### IMPORTANT - Backup your speech wallet

The wallet for speech is created inside the `speech-lbrynet` persistent volume.

Copy the wallet in case the volume gets destroyed:

```
k8s-lbry speech-lbrynet-copy-wallet /tmp/k8s-lbry-speech-lbrynet-wallet-backup.json
```

Check the contents of `/tmp/k8s-lbry-speech-lbrynet-wallet-backup.json` and move
the file to a safe place for backup (make sure to delete the temporary file.)

#### Fund your speech wallet

Once your wallet is backed up, you can generate a receiving address in order to
deposit LBC:

```
k8s-lbry speech-lbrynet address unused
```

Now send at least 5 LBC to your new speech wallet address.

Verify your speech wallet balance:

```
k8s-lbry speech-lbrynet account balance
```

#### Create a thumbnail channel

Create the LBRY channel for hosting speech thumbnails. Replace `@YOUR_NAME_HERE`
with your chosen (unique) channel name to create. Amount is how much LBC to
reserve for the claim:

```
k8s-lbry speech-lbrynet channel new @YOUR_NAME_HERE --amount=1.0
```

Get the claim id for the channel:

```
k8s-lbry speech-lbrynet channel list
```

The `claim_id` field is your `thumbnailChannelId` used in the next section.

#### Finish speech setup

Edit `values-dev.yaml` again:

 * Set `speech.site.publishing.primaryClaimAddress` The fresh wallet address
   generated above.
 * Set `speech.site.publishing.thumbnailChannel` The name of the channel to
   publish thumbnails
 * Set `speech.site.publishing.thumbnailChannelId` The claim id of the channel
   to publish thumbnails. (see `k8s-lbry speech-lbrynet channel list`)
 * Set `speech.site.publishing.serviceOnlyApproved` if you want to limit the
   channels served.
 * Set `speech.site.publishing.approvedChannels` if you want to limit the
   channels served.
 * Set `speech.site.analytics.googleId`

See the [speech settings docs for more
info](https://github.com/lbryio/spee.ch/blob/master/docs/settings.md)

Upgrade the release to apply the new settings:

```
k8s-lbry upgrade
```

Restart the speech pod:

```
k8s-lbry restart speech
```

## Extra commands that k8s-lbry (run.sh) provides

You can run `k8s-lbry` without any arguments, and it will provide you some help.

### k8s-lbry helm

This script encapsulates helm so that it can run it's own local instance of
tiller through [helm-tiller](https://github.com/rimusz/helm-tiller). As a
convenience function, run.sh can start tiller locally, pass through any helm
commands to your cluster, and then shutdown tiller:

Example:

```
k8s-lbry helm ls
```


If you try to run `helm` without the `run.sh helm` wrapper, you should expect to
see this error:

```
Error: could not find tiller
```

By design, [tiller is not running on your
cluster](https://rimusz.net/tillerless-helm), it just runs locally for the
duration that `run.sh` needs it, then shuts down.

### k8s-lbry kubectl

This script encapsulates kubectl so that you do not have to keep typing
`--namespace k8s-lbry` all the time. All kubectl commands will default to
`k8s-lbry` or the `NAMESPACE` environment variable if set.

Example:

```
k8s-lbry kubectl get pods
```

### k8s-lbry logs 

Stream the logs for a pod into your terminal, given the helm app name. If the
pod contains more than one container you must specify it as the third argument.

Examples:

```
k8s-lbry logs lbrycrd

k8s-lbry logs speech speech-lbrynet
```

Press Ctrl-C to stop streaming the logs. If the logs seemingly hang forever,
press Ctrl-C and try the command again.


### k8s-lbry shell

When doing maintainance tasks, it is often useful to be able to attach a shell
to a running pod. This is a convenience wrapper that uses the helm app name to
connect to the correct pod.

This will connect to the pod running the `lbrynet` service.

Example:

```
k8s-lbry shell lbrynet
```

Once in the shell, do whatever maintaince is necessary, and press `Ctrl-D` or
type `exit` when done.

### k8s-lbry shell-pvc

When doing maintainance tasks, it is often useful to be able to run a utility
container that mounts the persistent volume
([PVC](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)) of
another container. This is especially useful in scenarios where the pod will not
start, and therefore cannot use the `run.sh shell` command in the previous
section.

This will run a shell in a new utility container, mounting the lbrynet PVC to
`/pvcs/lbrynet`.

Example: 

```
k8s-lbry shell-pvc lbrynet
```

Once in the shell, do whatever maintaince is necessary, and press `Ctrl-D` or
type `exit` when done.


### k8s-lbry restart

Delete a pod for a given app name. The existing deployment will immediately
restart a new pod.

Example:

```
k8s-lbry restart speech
```

### k8s-lbry lbrynet
You can run the `lbrynet` client from within the running pod, redirecting output
to your local console.

Example:

```
k8s-lbry lbrynet --help
```

### k8s-lbry chainquery-mysql-client

Run the mysql shell for the chainquery database.

### k8s-lbry speech-mysql-client

Run the mysql shell for the speech database.

### k8s-lbry lbrynet-copy-wallet <local_backup_path>

Backup the lbrynet wallet to a local path.

Example:

```
k8s-lbry lbrynet-copy-wallet /tmp/k8s-lbry-lbrynet-wallet-backup.json
```
### k8s-lbry package

This is for the developer of this package to build and maintain the helm package
releases, and upload to the S3 package repository. Requires `s3cmd` installed.

Example:

```
k8s-lbry package 0.1.1
```


## TLS / SSL / HTTPS

You have already installed cert-manager for your cluster, but HTTPs is not
turned on out of the box. Setup is easy:

 * You need to create a DNS A record for your domain pointing to the External IP
   address of the nginx-ingress Load Balancer. (Preferably create a wildcard
   record for an entire subdomain [`*.example.com` or `*.lbry.example.com`],
   that way you only have to set this up once, no matter how many sub-domains
   you end up needing.) Refer to the [install
   section](https://github.com/EnigmaCurry/lbry-docker/tree/k8s-lbry/contrib/k8s-lbry#k8s-lbry-install)
   for how to retrieve the IP address.
   
 * Edit `values-dev.yaml`
 
 * Change `cert-manager-issuer.email` from the example email address to your
   own. [Let's Encrypt](https://letsencrypt.org/) is a free TLS certificate
   issuer, and they will send you important emails about your domain and
   certificate expirations.
 
 * You can turn on the echo service to test with:
 
   * Change `echo-http-server.enabled` to `true`
   
   * Change `echo-http-server.hostname` to a hostname you've configured the DNS
   for.
 
Upgrade nginx-ingress, turning on HTTPs support:

```
NGINX_ENABLE_HTTPS=true k8s-lbry upgrade-nginx-ingress
```

And Upgrade `k8s-lbry`:

```
k8s-lbry upgrade
```

If you turned on the echo service, try it out with curl:

```
curl -L https://echo.example.com
```

It should return the name of the service: `echo-http-server`.

If you get any certificate validation errors, then you may need to wait for up
to 20 minutes for the certificate to be issued, and then retry.

If you run into problems with certificates, check out the cert-manager logs:

```
kubectl -n cert-manager logs -l app=cert-manager -f
```

Also check the certificate resources:

```
k8s-lbry kubectl get certificates
```

You should see the `echo-http-server-tls` certificate resource listed. The
`READY` status is the indicator as to whether the certificate has been issued
yet or not.

## Cloud specific notes

### AWS 

Deployment on AWS requires these modifications:

Following the [CDK on
AWS](https://www.ubuntu.com/kubernetes/docs/aws-integration) docs, install the
StorageClass for EBS:

```
kubectl create -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-gp2
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
EOF
```

In `values-dev.yaml` all of your persistence configurations need to add
`storageClass: ebs-gp2`. There are commented versions in the default config file
which you can simply uncomment.

### minikube

[minikube](https://kubernetes.io/docs/setup/minikube/) lets you run kubernetes
on your development machine, in VirtualBox.

Make sure you start minikube with sufficient RAM for testing:

```
minikube start --memory 4096
```

In order for minikube to route the LoadBalancer correctly, you need to [add a
route on the host, and install a
patch](https://github.com/elsonrodriguez/minikube-lb-patch) to your cluster:

```
## ONLY RUN THESE COMMANDS IF YOU ARE USING MINIKUBE:
sudo ip route add $(cat ~/.minikube/profiles/minikube/config.json | jq -r ".KubernetesConfig.ServiceCIDR") via $(minikube ip)

kubectl run minikube-lb-patch --replicas=1 --image=elsonrodriguez/minikube-lb-patch:0.1 --namespace=kube-system
```

If it works correctly, after you run `k8s-lbry install-nginx-ingress`, the
External IP address for the LoadBalancer should no longer be `pending`:

```
k8s-lbry kubectl get svc nginx-ingress-controller
```

## Uninstall

If you wish to uninstall k8s-lbry from your cluster, here are the steps:

 * Delete the helm releases:

    ```
     k8s-lbry helm delete k8s-lbry

     k8s-lbry helm delete cert-manager

     k8s-lbry helm delete nginx-ingress
    ```

   * By deleting the `nginx-ingress` release, the Load Balancer resource should
     be automatically cleaned up. You can verify this yourself in your cloud
     provider's console that no Load Balancer is still running.

 * Delete the Persistent Volume Claims:

    * In `values-dev.yaml` all of the persistence claims are labeled as
      `"helm.sh/resource-policy": keep`. This means that helm will not
      automatically delete the volume when it deletes the release.

    * List all of your Persistent Volume Claims:

    ```
    k8s-lbry kubectl get pvc
    ```

    * Then delete each one you no longer want:

    ```
    k8s-lbry kubectl delete pvc [name-of-pvc]
    ```

    * Deleting the claim, should delete the volume. You can verify this yourself
      in your cloud provider's console that no Volumes exist.


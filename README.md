# OpenShift V3 Nagios Plugins

## Overview

By the time of writing, OpenShift V3 comes with poor monitoring capabilities. The build-in monitoring only checks the metrics of Memory/CPU/Network, and it does not even support alerting! And the lowest granular level only down to last hour. So you have to build your own monitoring if you want to keep close eyes on your services running on OpenShift.  

This project aims to develop some Nagios plugins for OpenShift V3. Here are the plugins that are available now:

[x] Persisent storage usage monitor

## Installations  

- Install OpenShift client (oc) on your Nagios box.   
- Create a monitoring account, then get the token. 
```bash
echo '{
  "apiVersion": "v1",
  "kind": "ServiceAccount",
  "metadata": {
    "name": "nagios"
  }
}' > nagiosSA.json
oc create -f nagiosSA.json
oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:nagios
oc get secrets
oc describe secret nagios-token-xxxx
```
- Copy the plugin file into the Nagios libexec folder, typically it is /usr/local/nagios/libexec/. Then replace thisisyourtoken... with the token you got above in 'your_token=thisisyourtokenpleasekeepitsecureyour'.

## Usage
**Persisent storage usage monitor**
```bash
/usr/local/nagios/libexec/openshift_pv_check.sh *project_name*
```
![pv](files/pv.png)

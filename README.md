# k8s-context
Use this to rapidly configure kubernetes contexts using combinations of predfined namespaces and clusters.
The end result will be a generated kube config file under `~/.kube/config` based on the namespaces and clusters supplied.

## Why?
I found myself having to remember which namespace I wanted to deploy Kubernetes resources to so I thought why not create contexts that hard code the namespace.    

Now with the generated kube config you can switch contexts and make sure you deploy to the right namespaces.

## Example
I'm a big fan of VSCode so here's what the end result looks like in that using the [Kubernetes Extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools).
<img src="./docs/img/example-vscode.png" alt="VSCode Kubernetes Extension Example" width="250"/>

To use the contexts with VSCode you'll need;
1) [VSCode](https://code.visualstudio.com/download) (Obviously!)
2) [Kubernetes Extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)


## Requirements
We need to several files to be able to configure the Kubernetes contexts.
1) JSON Config
2) JSON Auth-Cluster Mapping
3) GPG encrypted tokens (single file per cluster)


## Getting Started
You can use the `Example-Run.sh` to try it out. The script will 
- boilerplate files
  - maps.json
  - config.json
- Run the docker image as per below
- Delete the docker image


1) Get your JSON Payload.
Example of a JSON Config snippet Payload 
```
{
  "kubernetes": {
    "cluster_one": [
      {
        "groups": {
          "managed": [
            "somenamespace1-somegroup1",
            "somenamespace2-somegroup2"
          ],
          "non-managed": [
              "somenamespace3-somegroup3"
          ]
        },
        "token-ending": "xxxxxx",
        "username": "userid"
      }
    ],
    "cluster_two": [
      {
        "groups": {
          "managed": [
            "somenamespace1-somegroup1",
            "somenamespace2-somegroup2"
          ],
          "non-managed": [
              "somenamespace3-somegroup3"
          ]
        },
        "token-ending": "xxxxxx",
        "username": "userid"
      }
    ]
  }
}
```

Example of maps.json. The JSON keys must match to the clusters in the JSON Config payload.
```
{
  "cluster_one": {
    "Server": "https://api.cluster1.local",
    "Token": "<TOKEN/GUID>"
  },
  "cluster_two": {
    "Server": "https://api.cluster2.local",
    "Token": "<TOKEN/GUID>"
  }
}
```


1) Then run the following docker command and it will generate a new `~/.kube/config` file.

> Important Note! This will backup your existing config and create a new one. It will not merge the two (yet!).
You must substitute paths for your correct paths leaving the container paths the same.
```
docker run --rm \
        -v /Users/rhysevans/.kube:/root/.kube \
        -v /Users/rhysevans/config.json:/root/config.json:ro \
        -v /Users/rhysevans/maps.json:/root/maps.json:ro \
        k8s-context:latest
```

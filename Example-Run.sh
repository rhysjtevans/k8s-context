echo '{
  "cluster_one": {
    "Server": "https://api.cluster1.local",
    "Token": "<TOKEN/GUID>"
  },
  "cluster_two": {
    "Server": "https://api.cluster2.local",
    "Token": "<TOKEN/GUID>"
  }
}' > ~/maps.json
echo '{
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
}' > ~/config.json

docker run --rm \
        -v "$(echo ~)/.kube":/root/.kube \
        -v "$(echo ~)/config.json":/root/config.json:ro \
        -v "$(echo ~)/maps.json":/root/maps.json:ro \
        rhysjtevans/k8s-context:latest
docker image rm rhysjtevans/k8s-context:latest 
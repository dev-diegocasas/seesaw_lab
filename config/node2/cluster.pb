seesaw_vip: <
  fqdn: "seesaw-vip.lab."
  ipv4: "172.20.10.100/24"
  status: PRODUCTION
>

node: <
  fqdn: "seesaw-node1.lab."
  ipv4: "172.20.10.2/24"
  status: PRODUCTION
>

node: <
  fqdn: "seesaw-node2.lab."
  ipv4: "172.20.10.3/24"
  status: PRODUCTION
>

vserver: <
  name: "http.web@lab"
  entry_address: <
    fqdn: "seesaw-vip.lab."
  >
  vserver_entry: <
    protocol: TCP
    port: 80
    scheduler: RR
    mode: NAT
  >
  backend: < host: < ipv4: "172.20.20.10/24" > weight: 1 >
  backend: < host: < ipv4: "172.20.20.11/24" > weight: 1 >
  backend: < host: < ipv4: "172.20.20.12/24" > weight: 1 >
  healthcheck: <
    type: HTTP
    interval: 3
    timeout: 2
    port: 80
    send: "/healthz"
    receive: "OK"
    retries: 1
  >
>

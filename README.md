# Microsoft Connect Test docker container
Windows Network Connectivity Status Indicator (NCSI) determines network and internet connectivity status, which some applications rely upon to function correctly. In certain enterprise environments, requests to Microsoft's connectivity-test endpoints may be flagged or blocked by network and endpoint security products.

This repository provides a lightweight Docker-based HTTP service that replicates the expected Windows NCSI HTTP probe response, allowing administrators to host an internal connectivity-test endpoint.

**Warning:**
This service replicates the expected NCSI HTTP probe response but does not independently verify internet connectivity. If the internal server remains available during an external connectivity outage, Windows may report internet access incorrectly. Administrators should consider this limitation before deploying the solution.

## Steps

1. Download this repo and move it to the desired docker host

2. Build the Docker Image

```bash
docker build -t local-msft-test .
```

3. Start the docker image
```bash
docker run -d --name msft-test-server -p 80:80 local-msft-test
```
**Note:** Ensure TCP port 80 is available on the Docker host.

4. Validate that the Docker server returns the expected HTTP 200 response and ```Microsoft Connect Test``` content at ```/connecttest.txt``` using the validate-webpage.sh script
```bash
./validate-webpage.sh <your-docker-server-ip>
```

5. Configure your servers and endpoints


There are two approaches to directing Windows NCSI requests to the locally hosted service, you can either 

### Option 1: Internal DNS Override

Create an internal DNS record (and zone, if necessary) that directs `www.msftconnecttest.com` to your Docker host's IP address.

This preserves the default Windows NCSI configuration but overrides DNS resolution for Microsoft's connectivity-test hostname within your environment.

**Note:** This approach affects all clients using the modified DNS zone, so ensure the Docker service is reachable by the intended endpoints before deploying the DNS changes.

### Option 2: Custom NCSI Endpoint

Configure Windows to use a custom NCSI hostname through Group Policy or the registry. This avoids overriding Microsoft's public hostname and allows administrators to control which endpoints use the internal connectivity-test service.

The relevant registry settings are located at:

`HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet`

The following values can be configured to direct NCSI HTTP requests to the internal Docker server:

| Name | Type | Example Data |
| --- | --- | --- |
| ActiveWebProbeHost | REG_SZ | ncsi.example.internal |
| ActiveWebProbePath | REG_SZ | connecttest.txt |
| ActiveWebProbeContent | REG_SZ | Microsoft Connect Test |
| ActiveWebProbeHostV6 | REG_SZ | ncsi.example.internal |
| ActiveWebProbePathV6 | REG_SZ | connecttest.txt |
| ActiveWebProbeContentV6 | REG_SZ | Microsoft Connect Test |
| EnableActiveProbing | REG_DWORD | 1 |

Replace `ncsi.example.internal` with the hostname of your internal Docker server and ensure it resolves to the correct IP address.

The IPv6 settings should only reference an endpoint accessible over IPv6. If IPv6 is used in your environment, ensure the corresponding DNS records and connectivity are configured appropriately.

Other NCSI registry values, including the DNS probe configuration, can generally remain at their Windows defaults unless your environment requires additional changes.

**Important:** These settings control how Windows determines network connectivity. Test changes on a limited group of endpoints before deploying them more broadly. Ensure the internal service remains available to prevent connectivity-status issues.

For additional information, refer to Microsoft's [Network Connectivity Status Indicator (NCSI) troubleshooting guidance](https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/troubleshoot-ncsi-guidance).

## Troubleshooting

If Windows continues to report no internet connectivity:

1. Verify the container is running using `docker ps`.
2. Confirm port 80 is accessible from the affected workstation.
3. Verify the configured NCSI hostname resolves to the Docker host.
4. Confirm `/connecttest.txt` returns HTTP 200 and the expected content.
5. Check the Windows NCSI Operational event log for probe failures.
6. Confirm that Group Policy or registry settings are applied correctly.

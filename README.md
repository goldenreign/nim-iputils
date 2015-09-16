# nim-iputils
IPv4 and IPv6 calculation utilities in pure Nim

Usage:

```nimrod
let myIp = initIpAddress(IpAddressFamily.IPv4, @[239, 1, 10, 18])
let myMask = 4
echo baseIpAddress(myIp, myMask)
echo broadcastIpAddress(myIp, myMask)
```

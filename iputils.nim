import net

proc initIPv4Address*[T: SomeInteger](bytes: openArray[T]): IpAddress =
  if bytes.len < 4:
      raise newException(ValueError, "Initializing array is too short")
  result.family = IpAddressFamily.IPv4
  for i in 0..3:
    result.address_v4[i] = cast[uint8](bytes[i])

proc initIPv6Address*[T: SomeInteger](bytes: openArray[T]): IpAddress =
  if bytes.len < 16:
      raise newException(ValueError, "Initializing array is too short")
  result.family = IpAddressFamily.IPv6
  for i in 0..15:
    result.address_v6[i] = cast[uint8](bytes[i])

proc initIpAddress*[T: SomeInteger](family: IpAddressFamily, bytes: openArray[T]): IpAddress =
  case family
  of IpAddressFamily.IPv4:
    result = initIPv4Address(bytes)
  of IpAddressFamily.IPv6:
    result = initIPv6Address(bytes)

proc prefixToIPv4SubnetMask*[T: SomeInteger](prefix: T): IpAddress =
  if prefix <= cast[T](0) or prefix > cast[T](32):
    raise newException(ValueError, "Invalid IPv4 mask")
  result.family = IpAddressFamily.IPv4
  var bitfield: uint32 = 0
  for i in 1..prefix:
    bitfield = (bitfield shr 1) or 0x80000000'u32
  for i in 0..3:
    result.address_v4[3-i] = cast[uint8](bitfield shr cast[uint32](i*8))

proc baseIPv4Address*(address: IpAddress, mask: IpAddress): IpAddress =
  if address.family != IpAddressFamily.IPv4:
    raise newException(ValueError, "IPv4 address expected")
  result.family = address.family
  for i in 0..3:
    result.address_v4[i] = address.address_v4[i] and mask.address_v4[i]

proc baseIpAddress*(address: IpAddress, mask: IpAddress): IpAddress =
  if address.family == IpAddressFamily.IPv6 or mask.family == IpAddressFamily.IPv6:
    raise newException(ValueError, "IPv6 does not use subnet mask notation")
  case address.family
  of IpAddressFamily.IPv4:
    result = baseIPv4Address(address, mask)
  of IpAddressFamily.IPv6:
    discard

proc baseIpAddress*(address: IpAddress, prefix: SomeInteger): IpAddress =
  case address.family
  of IpAddressFamily.IPv4:
    result = baseIPv4Address(address, prefixToIPv4SubnetMask(prefix))
  of IpAddressFamily.IPv6:
    raise newException(ValueError, "IPv6 is not supported yet :(")

proc broadcastIPv4Address*(address: IpAddress, mask: IpAddress): IpAddress =
  if address.family != IpAddressFamily.IPv4:
    raise newException(ValueError, "IPv4 address expected")
  result.family = address.family
  let baseIp = baseIpAddress(address, mask)
  for i in 0..3:
    result.address_v4[i] = (baseIp.address_v4[i] and mask.address_v4[i]) or (255'u8 and not(mask.address_v4[i]))

proc broadcastIpAddress*(address: IpAddress, mask: IpAddress): IpAddress =
  if address.family == IpAddressFamily.IPv6 or mask.family == IpAddressFamily.IPv6:
    raise newException(ValueError, "IPv6 does not have broadcast address class")
  case address.family
  of IpAddressFamily.IPv4:
    result = broadcastIPv4Address(address, mask)
  of IpAddressFamily.IPv6:
    discard

proc broadcastIpAddress*(address: IpAddress, prefix: SomeInteger): IpAddress =
  case address.family
  of IpAddressFamily.IPv4:
    result = broadcastIPv4Address(address, prefixToIPv4SubnetMask(prefix))
  of IpAddressFamily.IPv6:
    raise newException(ValueError, "IPv6 does not have broadcast address class")

when isMainModule:
  var myIp: IpAddress
  myIp.family = IpAddressFamily.IPv4
  myIp.address_v4 = [192'u8, 168'u8, 1'u8, 15'u8]

  var maskIp: IpAddress
  maskIp.family = IpAddressFamily.IPv4
  maskIp.address_v4 = [255'u8, 255'u8, 255'u8, 0'u8]

  echo baseIpAddress(myIp, maskIp)
  echo baseIpAddress(myIp, 24'u8)
  echo baseIpAddress(myIp, 16)
  echo baseIpAddress(myIp, 8'u32)

  let myMCIp = initIPv4Address(@[239, 1, 10, 18])
  let myMCMask = 4

  echo baseIpAddress(myMCIp, myMCMask)

  echo broadcastIpAddress(myIp, maskIp)
  echo broadcastIpAddress(myIp, 24'u8)
  echo broadcastIpAddress(myIp, 16)
  echo broadcastIpAddress(myIp, 8'u32)
  echo broadcastIpAddress(myMCIp, myMCMask)

  let myIPv6 = initIPv6Address([239, 1, 10, 18, 35, 17, 200, 137, 85, 0, 34, 211, 153, 47, 7, 25])
  echo myIPv6

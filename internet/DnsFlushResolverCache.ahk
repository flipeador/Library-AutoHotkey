/*
    ipconfig /flushdns
*/
DnsFlushResolverCache()
{
    return DllCall("dnsapi.dll\DnsFlushResolverCache")
} ;https://autohotkey.com/boards/viewtopic.php?f=6&t=3514&start=40#p85877

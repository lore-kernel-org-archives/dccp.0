From: Lars Eggert <lars.eggert@nokia.com>
Date: Wed, 18 Apr 2007 16:48:10 +0000
Subject: Re: [dccp] Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <D9EB65D7-30F5-4337-B700-83F50E478052@nokia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Apple-Mail-74-1039194774"
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
To: dccp@vger.kernel.org


--Apple-Mail-74-1039194774
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	delsp=yes;
	format=flowed

On 2007-4-18, at 19:16, ext Colin Perkins wrote:
> On 11 Apr 2007, at 23:45, Ian McDonald wrote:
>> On 4/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>>> There is no way to stop a Linux CCID3 sender from ramping X up to  
>>> the link bandwidth of 1 Gbit/sec; but the scheduler can only  
>>> control packet pacing up to a rate of s * HZ bytes per second.
>>
>> Let's start to think laterally about this. Many of the problems  
>> around
>> CCID3/TFRC implementation seem to be on local LANs and rtt is less
>> than t_gran. We get really badly affected by how we do x_recv etc and
>> the rate is basically all over the show. We get affected by send
>> credits and numerous other problems.
>
> As a data point, we've seen similar stability issues with our user- 
> space TFRC implementation, although at somewhat larger RTTs (order  
> of a few milliseconds or less). We're still checking whether these  
> are bugs in our code, or issues with TFRC, but this may be a  
> broader issue than problems with the Linux DCCP implementation.

I think Vlad saw similar issues with the KAME code when running over  
a local area network. (Vlad?)

Lars



--Apple-Mail-74-1039194774
Content-Transfer-Encoding: base64
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Disposition: attachment;
	filename=smime.p7s

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIGQDCCAvkw
ggJioAMCAQICEGtxkLFHQu1g67hlmYfwPuIwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCWkEx
JTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQ
ZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA3MDEwNDE2MTE1NFoXDTA4MDEwNDE2MTE1
NFowXDEPMA0GA1UEBBMGRWdnZXJ0MQ0wCwYDVQQqEwRMYXJzMRQwEgYDVQQDEwtMYXJzIEVnZ2Vy
dDEkMCIGCSqGSIb3DQEJARYVbGFycy5lZ2dlcnRAbm9raWEuY29tMIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA26hjntVPZMiwh4d8tyuk9KiucvG92BVUGArk5zO1jhmq7tLFgU1mqcIg
VGumfQqjkAzIuh83kxIiqBrB05Wvxp85apwt4sUCvzMe8mQWzZZZYp0rBzwpOj+VC5pxsMRYtYW+
BaTFBEmvFr7D7C7roZUk0lDppS5SZFs4SQbEe9ykB9aeUf1iTiw2+ikyP2+JEYto14WYCoxFWbms
FbQ1uaaK+yn1WH2YHhyMfi0IOxuT0jtbsngjHJMpWIqq334zBhj+rPSUug47YBHr41FCDMHbbbjv
WbyTyDYneOW3WY8LY8bGWVlAknQGB7lgduShe6e0RI/7SL/VE6X27lM9LwIDAQABozIwMDAgBgNV
HREEGTAXgRVsYXJzLmVnZ2VydEBub2tpYS5jb20wDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQUF
AAOBgQCx3nxxTg/WowobVTRXBiXUEEZj4LBiunWbuAnR0UbJIgijvq3JbiJvZo2gUGiW9LPaHSBz
4oxT1VR/S/6O0a4e87oV5cOQm6ReB68o9rDfUzxHTwoCfv2wwMwBrXyzQMjyQK4Lt8siV41gmZpm
rSXMhjTJdd9uYYNoZKQLq+VM+TCCAz8wggKooAMCAQICAQ0wDQYJKoZIhvcNAQEFBQAwgdExCzAJ
BgNVBAYTAlpBMRUwEwYDVQQIEwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNhcGUgVG93bjEaMBgG
A1UEChMRVGhhd3RlIENvbnN1bHRpbmcxKDAmBgNVBAsTH0NlcnRpZmljYXRpb24gU2VydmljZXMg
RGl2aXNpb24xJDAiBgNVBAMTG1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBDQTErMCkGCSqGSIb3
DQEJARYccGVyc29uYWwtZnJlZW1haWxAdGhhd3RlLmNvbTAeFw0wMzA3MTcwMDAwMDBaFw0xMzA3
MTYyMzU5NTlaMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5
KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQTCBnzAN
BgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxKY8VXNV+065yplaHmjAdQRwnd/p/6Me7L3N9VvyGna9
fww6YfK/Uc4B1OVQCjDXAmNaLIkVcI7dyfArhVqqP3FWy688Cwfn8R+RNiQqE88r1fOCdz0Dviv+
uxg+B79AgAJk16emu59l0cUqVIUPSAR/p7bRPGEEQB5kGXJgt/sCAwEAAaOBlDCBkTASBgNVHRMB
Af8ECDAGAQH/AgEAMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwudGhhd3RlLmNvbS9UaGF3
dGVQZXJzb25hbEZyZWVtYWlsQ0EuY3JsMAsGA1UdDwQEAwIBBjApBgNVHREEIjAgpB4wHDEaMBgG
A1UEAxMRUHJpdmF0ZUxhYmVsMi0xMzgwDQYJKoZIhvcNAQEFBQADgYEASIzRUIPqCy7MDaNmrGcP
f6+svsIXoUOWlJ1/TCG4+DYfqi2fNi/A9BxQIJNwPP2t4WFiw9k6GX6EsZkbAMUaC4J0niVQlGLH
2ydxVyWN3amcOY6MIE9lX5Xa9/eH1sYITq726jTlEBpbNU1341YheILcIRk13iSx0x1G/11fZU8x
ggMQMIIDDAIBATB2MGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAo
UHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIQ
a3GQsUdC7WDruGWZh/A+4jAJBgUrDgMCGgUAoIIBbzAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
MBwGCSqGSIb3DQEJBTEPFw0wNzA0MTgxNjQ4MTBaMCMGCSqGSIb3DQEJBDEWBBS2osAZVRBqWq6s
rD//vNXuKB0hnjCBhQYJKwYBBAGCNxAEMXgwdjBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhh
d3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVt
YWlsIElzc3VpbmcgQ0ECEGtxkLFHQu1g67hlmYfwPuIwgYcGCyqGSIb3DQEJEAILMXigdjBiMQsw
CQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UE
AxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0ECEGtxkLFHQu1g67hlmYfwPuIw
DQYJKoZIhvcNAQEBBQAEggEAUrLdcZZs9vneTuN0TQYuH7MV3C4gzfhtznPaz5IL9UQrgsk/EPik
Mcg0NW9VJhRJ6RMa5iVLDBIuyXYZlbZ/AW43DzhY5/T1LxGgE4GIk1gEeAnsDOyW1iChinMyVwth
EpJ2yn2iqnntfyDH/ajZRxhI/UdgOKquvEo/zHvCU+dt4FnNptHhjpygjOCyXz7aEd+0EV+Y01xP
LSeM04hIYNNKgCoz7bsbUjTjoGTKYRW3jLn/i3sNpaDpI2MBAuWhZXC/KSa0LmqK8NygkAWNa3r3
Rqdzx4JUZYs79oqy9O1pdvLYTbAhGadR5CeCnzXbEJ861uB7Piy+sQXrY8QftQAAAAAAAA==

--Apple-Mail-74-1039194774--

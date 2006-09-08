From: gerrit@erg.abdn.ac.uk
Date: Fri, 08 Sep 2006 09:31:41 +0000
Subject: Proposed socket API change
Message-Id: <200609081031.41701@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have the following proposal to simplify the use of the DCCP socket API
and would like to poll for opinions before  sending any patches to the list:

Suggested Change: If user doesn't want to set a service code, that's fine,
                  leave the service code associated with connection at 0.

Justification: 
In a forthcoming communication to SIGCOMM-06, the inventors of DCCP say that
they were "motivated by keeping the basic API as simple as UDP's" and that
"DCCP should provide applications with an API as simple as that of UDP".

DCCP mandates the use of service codes (RFC 4340, sec. 8.1.2). This is mirrored
in the Linux socket API by throwing an error if the application programmer
did not set a service code.

The actual use of service codes, however, depends on the applications. It seems
that the main intention of using service codes is for middleboxes: " Middleboxes,
such as firewalls, can use the Service Code to identify the application running
on a nonstandard port (assuming the DCCP   header has not been encrypted)."

However, there are applications which do not talk through middleboxes - such as
streaming on the intranet, local LAN applications, or testing applications. 
These would be at a disadvantage if forced to come up with service codes.

What makes UDP simple to program is the use of sensible defaults; a message can
be sent with little set-up effort, due to the use of sensible defaults.

The service code `0' has been singled out and designated to indicate the absence
of a meaningful service code.

So,

 * applications which do not want to allocate a service code leave it at the
   default 0, without being required to pass a socket option
 * applications which depend on service codes are free to do so by explicitly
   setting the socket option

Otherwise, if setting service codes is mandatory, it will require applications to
set `dummy' service codes (which have to be hardcoded into both server and client).

The use of service codes is still initial; only a single service code has been 
registered so far, cf.  http://www.iana.org/assignments/service-codes 

So as to not compromise listening sockets, I was thinking of treating an `uninitialized'
0 on a server socket different from a service code = 0 which has been explicitly set by 
the application.


- Gerrit

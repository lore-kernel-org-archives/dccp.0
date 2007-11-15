From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 15 Nov 2007 07:04:59 +0000
Subject: Re: How much is available for reading on the socket?
Message-Id: <20071115070459.GB5654@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
In-Reply-To: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Update documentation on ioctls

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    6 ++++++
 1 file changed, 6 insertions(+)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -161,6 +161,12 @@ sync_ratelimit = 125 ms
 	sequence-invalid packets on the same socket (RFC 4340, 7.5.4). The unit
 	of this parameter is milliseconds; a value of 0 disables rate-limiting.
 
+IOCTLS
+===
+FIONREAD
+	Works as in udp(7): returns in the `int' argument pointer the size of
+	the next pending datagram in bytes, or 0 when no datagram is pending.
+
 Notes
 == 

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 16 Nov 2006 18:42:24 +0000
Subject: Re: [RFC PATCH 1/2]: DCCP Introduce tx queue limits
Message-Id: <200611161842.25190@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611161037.32393.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200611161037.32393.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  Folks,
|  
|  Here is something I've whipped up. Just wondering about your thoughts on this? I think it makes more sense to do by packets queued rather than bytes as it is a datagram based protocol.
|  
|  Notes:
|  - Compile tested only
|  - Probably won't apply to latest tree (sorry about that - will fix before I ask to merge)
|  
|  Appreciate feedback.
|  
|  This implements tx buffer sysctls for DCCP.
This is great to have! Indeed, it is very useful - without control on the tx buffer, it can
lead to much increased jitter (if too much gets blocked). Ideally, this could be a socket option
but I don't think that it is necessary now. It would be good to have this submitted. I had meant
to update it with regard to the latest change sets, but my connection is sluggish and I also need
to update the patch backlog. 
If you submit this, I can take care of making it applicable to the latest changes.

Please see inline.
Gerrit

|  --- a/net/dccp/dccp.h
|  +++ b/net/dccp/dccp.h
|   /* Time in msecs for blocking transmit per packet */
|   
|  +extern int sysctl_dccp_tx_qlen;
can you move the comment to the place where sysctl_dccp_tx_qlen is declared

|  --- a/net/dccp/proto.c
|  +++ b/net/dccp/proto.c
a comment above here would be good
|  +int sysctl_dccp_tx_qlen;
|  +
|  +EXPORT_SYMBOL_GPL(sysctl_dccp_tx_qlen);
This can be deleted since the the variable stays local to net/dccp/proto.c (see below)

 
|+       sysctl_dccp_tx_qlen = 6; /* number that sounds about right */
Can you use a #define in dccp.h please (agree with the number, it seems that 5 is really the minimum)
 and add descriptive text for Documentation/networking/dccp.txt, e.g.
net.dccp.default.tx_qlen = 6 
	The size of the transmit buffer. A value of zero corresponds to an unbounded transmit buffer;
	a value of 5 is recommendable .... 

   
/* 	..... and here follows the second part of the patch 		*/

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -634,6 +634,14 @@ int dccp_sendmsg(struct kiocb *iocb, str
 		return -EMSGSIZE;
 
 	lock_sock(sk);
+
+	if (sysctl_dccp_tx_qlen && 
+	   (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)) {
+		/* if sysctl_dccp_tx_qlen = 0 then unlimited tx queue */
+		rc = -EAGAIN;
+		goto out_release;
+	}
+
 	timeo = sock_sndtimeo(sk, noblock);
 
 	/*



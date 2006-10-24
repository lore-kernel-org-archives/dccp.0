From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 09:15:04 +0000
Subject: Re: [PATCH 1/1] DCCP: Stop logs being filled
Message-Id: <200610241015.04511@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200610241732.30715.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200610241732.30715.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


|  In my opinion this should go into 2.6.19 as bug and causes logs to be
|  filled.
ACK - this is useful and I have found it to apply without problem. Minor quibble below.


|  @@ -58,6 +58,9 @@ #define DCCP_RESOURCE_PROBE_INTERVAL ((u
|   
|   #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
|   
|  +#define DCCP_XMIT_TIMEO 30000
|  +/* Time in msecs for blocking transmit per packet */
All the #define comments in dccp.h are on the right, for consistency, maybe better:
#define DCCP_XMIT_TIMEO 30000 /* Time/	msecs for blocking transmit per packet */

(which is below the limit of 80 chars)


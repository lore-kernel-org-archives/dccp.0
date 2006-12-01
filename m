From: gorry@erg.abdn.ac.uk
Date: Fri, 01 Dec 2006 09:25:32 +0000
Subject: Re: [PATCH] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <48600.139.133.201.167.1164965132.squirrel@139.133.201.167>
List-Id: <dccp.vger.kernel.org>
References: <200611301318.46685@strip-the-willow>
In-Reply-To: <200611301318.46685@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Let me respond simply on the issue of 3 seconds.

I know the value of 3 seconds has not respected in all TCP
Implementations, but this is never the less the value that was put by the
IETF - for good reasons. Smaller values of RTO can and do cause
interoperability problems over some Internet Paths.

This issue is not new, many many years ago one major manufacturer chose a
smaller initial RTO and caused major upset among people using satellite
links... fortunately the implementation was soon patched, but not before
it entered deployment on some web servers, where the problem persisted.

I suggest a value of 3 Secs is sufficient for the General internet...

Gorry

> On Nov 30, 2006, at 11:13, Ian McDonald wrote:
>> This patch provides a configuration option to set the bound for the
>> nofeedback timer, using as default the TCP RTO timeout of 1 second.
>
> The default TCP RTO is 3 seconds (RFC 2988). Linux is apparently not
> conformant to that RFC?
>
> Lars
>
>



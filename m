From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 13 Sep 2007 07:55:17 +0000
Subject: Re: [PATCH 2/5]: Twice the wrong reset code in receiving connection-Requests
Message-Id: <200709130855.17997@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709121535.11607@strip-the-willow>
In-Reply-To: <200709121535.11607@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  > =A02. When receiving a connection-Request on a multicast or broadcast =
address, no
|  > =A0 =A0 Reset should be generated, to avoid storms of such packets. In=
stead of jumping
|  > =A0 =A0 to the `drop' label, the v{4,6}_conn_request functions now ret=
urn 0. Below is
|  > =A0 =A0 why in my understanding this is correct:
|  >
|  DCCP only claims to support unicast so this fix makes sense.. (or
|  should we flag we have multicast/broadcast being used? But that's a
|  whole separate issue).

As far as I understand it, the behaviour of DCCP is consistent with TCP. Lo=
oking at
net/ipv6/tcp_ipv6.c in tcp_v6_conn_request (comments are not mine):

	if (!ipv6_unicast_destination(skb))
                goto drop;
	/* ... */
drop:
        if (req)
                reqsk_free(req);

        return 0; /* don't send reset */


And in tcp_v4_conn_request:

	/* Never answer to SYNs send to broadcast or multicast */
        if (((struct rtable *)skb->dst)->rt_flags &
            (RTCF_BROADCAST | RTCF_MULTICAST))
                goto drop;

	/* ... */
drop:
        return 0;


I only discovered this after you wrote the reply. Initially, the main probl=
em fixed by the
patch was that the reset codes got overwritten, and it was something I had =
caused in a `tidy-up'
patch where I didn't see that dccp_parse_options generates its own reset co=
des.

There is still something missing and that is adding the Data 1..3 fields of=
 the reset packet -
I wonder if this could be done as an array[3] in the DCCP_SKB_CB?

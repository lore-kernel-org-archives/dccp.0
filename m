From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 18:40:29 +0000
Subject: Re: [PATCH 4/9]: Resolve dependencies of features on choice of CCID
Message-Id: <5640c7e00710011140jea816bek2ee1a28d8f1ee929@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709281630.22458@strip-the-willow>
In-Reply-To: <200709281630.22458@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/29/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Resolve dependencies of features on choice of CCID
>
> This provides a missing link in the code chain, as several features implicitly
> depend and/or rely on the choice of CCID. Most notably, this is the Send Ack Vector
> feature, but the patch also takes care of Ack Ratio and Send Loss Event Rate.
>
> For Send Ack Vector, the situation is as follows:
>  * since CCID2 mandates the use of Ack Vectors, there is no point in allowing endpoints
>    which use CCID2 to disable Send Ack Vector features on the corresponding half-connection;
>
>  * a peer with a TX CCID of CCID2 will always expect Ack Vectors, and a peer with a RX CCID
>    of CCID2 must always send Ack Vectors (RFC 4341, sec. 4);
>
>  * for all other CCIDs, the use of (Send) Ack Vector is optional and thus negotiable. However,
>    this implies that the code negotiating the use of Ack Vectors also supports it (i.e. is
>    able to supply and to either parse or ignore received Ack Vectors). Since this is not the
>    case (CCID3 has no Ack Vector support), the use of Ack Vectors is here disabled, with a
>    corresponding comment in the source code.
>
> An analogous consideration arises for the Send Loss Event Rate feature, since the CCID3
> implementation does not support the loss interval options of RFC 4342. To make such use explicit,
> corresponding feature-negotiation options are inserted which signal the use of the loss event
> rate option, as it is used by the CCID3 code.
>
> Lastly, the values of the Ack Ratio feature are matched to the choice of CCID.
>
> The patch implements this as a function which is called after the user has made all other
> registrations for changing default values of features.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

I agree totally with the intent of this patch as long thought it was
silly the ack vectors situation.

I don't quite understand why you're defining on and off when there is
built in stuff for the kernel for true/false. You then pass the
address of the on/off - not the value. Maybe you might like to explain
the rationale behind this as I'm probably missing something.

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

(Sending acked bys these days as much less time so giving quick
reviews. I'm working through all the new group of patches from oldest
first. I've lost track of any old ones I haven't reviewed so if you
still want me to do these can you send me a list of patch sets or git
commit IDs)

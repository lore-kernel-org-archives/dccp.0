From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 02 Oct 2007 22:03:27 +0000
Subject: Re: [PATCH v2 4/9]: Resolve dependencies of features on choice of CCID
Message-Id: <5640c7e00710021503j2e57c309ne95d078125154d61@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710021306.55993@strip-the-willow>
In-Reply-To: <200710021306.55993@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/3/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> ------------------------------> Patch v2 <-----------------------------------------
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
> The table is variable-length, the reserved (and hence for feature-negotiation invalid, confirmed
> by considering section 19.4 of RFC 4340) feature number of 0 is used to mark the end of the table.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

(I have seen Arnaldo's/your later correspondence and happy enough that
you'll resolve that)
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz

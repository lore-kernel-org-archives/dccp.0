From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 18:44:55 +0000
Subject: Re: [PATCH 6/9]: Provide feature negotiation for minimum-checksum-coverage
Message-Id: <5640c7e00710011144y66ae7306n378adca6d265dbf9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/29/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Provide feature negotiation for minimum-checksum-coverage
>
> This provides feature negotiation for server minimum checksum coverage
> which so far has been missing.
>
> Since sender/receiver coverage values range only from 0...15, their
> type has also been reduced in size from u16 to u4.
>
> Feature-negotiation options are now generated for both sender and receiver
> coverage, i.e. when the peer has `forgotten' to enable partial coverage
> then feature negotiation will automatically enable (negotiate) the partial
> coverage value for this connection.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Nice to see reduction in data size of a structure and also simplifying
logic because of it.

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

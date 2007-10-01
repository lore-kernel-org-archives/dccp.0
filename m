From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 18:28:18 +0000
Subject: Re: [PATCH 3/9]: Resolve feature dependencies resulting from choice of CCID
Message-Id: <5640c7e00710011128v20da9791q90a272e4720a0bdf@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/29/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Resolve feature dependencies resulting from choice of CCID
>
> This adds a hook to resolve features whose value depends on the choice of
> CCID. It is done at the server since it can only be done after the CCID
> values have been negotiated; i.e. the client will add its CCID preference
> list on the Change options sent in the Request, which will be reconciled
> with the local preference list of the server.
>
> The concept is documented on
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/implementation_notes.html#ccid_dependencies
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

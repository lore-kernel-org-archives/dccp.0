From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 14 Oct 2007 00:24:33 +0000
Subject: Re: [PATCH 5/5]: Reorder statements with regard to option length
Message-Id: <5640c7e00710131724o48f8c9fbn345a4955798c0ffd@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710121052.00451@strip-the-willow>
In-Reply-To: <200710121052.00451@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [ACKVEC]: Reorder statements with regard to option length
>
> This re-orders two statements which both rely on dccpd_opt_len: the problem
> was that the test for `enough size for Ack Vector' comes before the insertion
> of the Elapsed Time time option, which itself reduces dccpd_opt_len by 6 bytes.
>
> Further added a FIXME for piggybacking of Ack Vectors and a warning message
> which is triggered when running out of option space - to monitor this condition.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

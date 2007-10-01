From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 23:20:38 +0000
Subject: Re: [PATCH 9/11]: Fill in the Data1..3 fields when option processing encounters option errors
Message-Id: <5640c7e00710011620q17cbdd29s89919531fbe7f105@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.31492@strip-the-willow>
In-Reply-To: <200710011518.31492@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Fill in the Data1..3 fields when option processing encounters option errors
>
> DCCP provides the Data 1..3 fields in the Reset header to carry information
> about why the connection was reset. An earlier patch provided basic support,
> this patch extends the capabilities by adding Reset information when processing
> erroneous options.
> This support will be made use of by the next two patches which process Change/
> Confirm feature-negotiation options.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
